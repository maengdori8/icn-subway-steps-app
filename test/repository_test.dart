import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/models/guide_step.dart';
import 'package:icn_subway_app/models/route_info.dart';
import 'package:icn_subway_app/models/step_photos.dart';
import 'package:icn_subway_app/models/tip.dart';
import 'package:icn_subway_app/models/user_session.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/http_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';
import 'package:icn_subway_app/validation/tip_rules.dart';

const demoSession = UserSession(userId: 101, username: 'student01', accessToken: 'fake-session-101');

void main() {
  // 2026-10-20 12:00 서울 = 03:00 UTC
  FakeSubwayRepository repo() => FakeSubwayRepository(delay: Duration.zero, now: () => DateTime.utc(2026, 10, 20, 3));

  group('서버 응답 모양(camelCase, 서버 docs/api-spec.yaml 예시)을 읽는다', () {
    test('경로 봉투 {routes}', () {
      final routes = RouteInfo.listFromJson({
        'routes': [
          {
            'code': 'EXPRESS',
            'name': {'en': 'Express Train', 'ko': '직통열차'},
            'summary': {'en': 'Non-stop', 'ko': '무정차'},
            'available': true,
            'stepCount': 5,
          },
          {
            'code': 'T2',
            'name': {'en': 'T2 → Seoul Station', 'ko': 'T2 → 서울역'},
            'summary': {'en': 'From T2 arrivals', 'ko': 'T2 입국장에서 출발'},
            'available': false,
            'stepCount': 0,
          },
        ],
      });
      expect(routes.map((r) => r.code), ['EXPRESS', 'T2']);
      expect(routes.first.stepCount, 5);
      expect(routes.map((r) => r.origin), ['T1', 'T2'], reason: '서버가 주지 않아 코드로 정함');
    });

    test('단계: sign 객체, instructions, photoKey·elevator는 null 가능', () {
      final steps = GuideStep.listFromJson({
        'route': 'EXPRESS',
        'steps': [
          {
            'stepNo': 1,
            'role': 'HERE',
            'icon': 'PLANE',
            'photoKey': 'arrivals',
            'sign': {'ko': '제1여객터미널 입국장', 'en': 'Terminal 1 Arrivals'},
            'title': {'en': 'Walk out', 'ko': '나오기'},
            'instructions': {
              'en': ['a', 'b'],
              'ko': ['가', '나'],
            },
            'elevator': null,
          },
          {
            'stepNo': 2,
            'role': 'FIND',
            'icon': 'ESCALATOR',
            'photoKey': null,
            'sign': {'ko': '교통센터', 'en': 'Transportation Center'},
            'title': {'en': 'Go down', 'ko': '내려가기'},
            'instructions': {'en': <String>[], 'ko': <String>[]},
            'elevator': {'en': 'Left of the gates', 'ko': '개찰구 왼쪽'},
          },
        ],
      });
      expect(steps.first.signEn, 'Terminal 1 Arrivals');
      expect(steps.first.role, SignRole.here);
      expect(stepPhotoFor(steps.first.photoKey)!.asset, 'assets/photos/arrivals_t1.jpg');
      expect(steps.first.elevator, isNull);
      expect(stepPhotoFor(steps.last.photoKey), isNull);
      expect(steps.last.elevator!.ko, '개찰구 왼쪽');
    });

    test('팁: ISO UTC 시각, ownerId·mine·example, 배지 날짜는 서울 기준', () {
      final tip = Tip.listFromJson({
        'tips': [
          {
            'id': 9,
            'route': 'LOCAL',
            'stepNo': 4,
            'title': 'Wide gate',
            'location': 'Left end',
            'note': null,
            'status': 'VERIFIED',
            'verifiedAt': '2026-10-20T16:00:00Z', // 서울 10-21 01:00
            'createdAt': '2026-10-20T16:00:00Z',
            'ownerId': 101,
            'mine': true,
            'example': false,
          },
        ],
      }).single;
      expect(tip.stepNo, 4);
      expect(tip.mine, isTrue);
      expect(tip.verifiedAt.isUtc, isTrue);
      expect(seoulDate(tip.verifiedAt), '2026-10-21');
    });

    test('서울 날짜 경계: 자정 직전·정각, 월말·연말, +09:00 오프셋', () {
      expect(seoulDate(DateTime.parse('2026-10-20T14:59:59Z')), '2026-10-20'); // 서울 23:59:59
      expect(seoulDate(DateTime.parse('2026-10-20T15:00:00Z')), '2026-10-21'); // 서울 00:00
      expect(seoulDate(DateTime.parse('2026-10-31T15:00:00Z')), '2026-11-01');
      expect(seoulDate(DateTime.parse('2026-12-31T15:00:00Z')), '2027-01-01');
      expect(seoulDate(DateTime.parse('2026-10-21T00:30:00+09:00')), '2026-10-21');
    });

    test('팁 등록 본문은 다섯 항목뿐(그 밖의 항목은 서버가 400)', () {
      const draft = TipDraft(route: 'LOCAL', stepNo: 4, title: 't', location: 'l');
      expect(draft.toJson().keys, ['route', 'stepNo', 'title', 'location', 'note']);
    });

    test('로그인 응답 {accessToken, tokenType, expiresIn, user{id, username}}', () {
      final session = UserSession.fromLoginJson({
        'accessToken': 'x.y.z',
        'tokenType': 'Bearer',
        'expiresIn': 1800,
        'user': {'id': 102, 'username': 'student02'},
      });
      expect(session.userId, 102);
      expect(session.username, 'student02');
    });
  });

  group('가짜 저장소', () {
    test('경로 3개: 직통·일반 5단계, T2는 준비 중이고 단계는 빈 목록', () async {
      final r = repo();
      final routes = await r.fetchRoutes();
      expect(routes.map((r) => r.code), ['EXPRESS', 'LOCAL', 'T2']);
      expect(routes.where((r) => r.available).map((r) => r.stepCount), [5, 5]);
      expect(routes.last.available, isFalse);
      expect(await r.fetchSteps('T2'), isEmpty);
      await expectLater(r.fetchSteps('NOPE'), throwsA(isA<RepositoryException>()));
    });

    test('단계는 stepNo 1부터, 사진 없는 단계는 photoKey가 null', () async {
      final steps = await repo().fetchSteps('EXPRESS');
      expect(steps.map((s) => s.stepNo), [1, 2, 3, 4, 5]);
      expect(steps.map((s) => s.photoKey == null), [false, true, false, true, true]);
      expect(steps.first.signEn, 'Terminal 1 Arrivals');
    });

    test('팁 올리기: 앞뒤 공백 제거, 빈 메모는 null, VERIFIED, 올린 사람은 로그인 사용자, 새 팁이 먼저', () async {
      final r = repo();
      final tip = await r.createTip(
        const TipDraft(route: 'LOCAL', stepNo: 4, title: '  엘리베이터  ', location: ' 출구 옆 ', note: '   '),
        demoSession,
      );
      expect(tip.id, 9, reason: '서버 시드 7·8 다음');
      expect(tip.title, '엘리베이터');
      expect(tip.location, '출구 옆');
      expect(tip.note, isNull);
      expect(tip.status, TipStatus.verified);
      expect(tip.ownerId, 101);
      expect(seoulDate(tip.verifiedAt), '2026-10-20');
      final listed = await r.fetchTips('LOCAL', 4, session: demoSession);
      expect(listed.map((t) => t.id), [9, 8]);
      expect(listed.every((t) => t.mine), isTrue);
      expect((await r.fetchTips('LOCAL', 4)).any((t) => t.mine), isFalse, reason: '토큰 없으면 mine은 false');
    });

    test('남이 올린 팁은 상태를 바꿀 수 없다(403), 올린 사람은 바꾼다', () async {
      final r = repo();
      final other = await r.login('traveler', 'pw');
      await expectLater(
        r.updateTipStatus(8, TipStatus.verified, other),
        throwsA(isA<RepositoryException>().having((e) => e.code, 'code', RepositoryErrorCode.forbidden)),
      );
      await expectLater(r.updateTipStatus(7, TipStatus.outdated, demoSession), throwsA(isA<RepositoryException>()));
      final mine = await r.updateTipStatus(8, TipStatus.verified, demoSession);
      expect(mine.status, TipStatus.verified);
      expect(seoulDate(mine.verifiedAt), '2026-10-20');
    });

    test("로그인: 아이디 'wrong'은 실패, student01은 101번, student02는 102번", () async {
      final r = repo();
      await expectLater(
        r.login('wrong', 'x'),
        throwsA(isA<RepositoryException>().having((e) => e.code, 'code', RepositoryErrorCode.invalidCredentials)),
      );
      expect((await r.login(' student01 ', 'x')).userId, 101);
      expect((await r.login('student02', 'x')).userId, 102);
    });

    test('failNext로 정한 횟수만큼만 실패한다', () async {
      final r = repo()..failNext(FakeOperation.routes, RepositoryErrorCode.offline);
      await expectLater(r.fetchRoutes(), throwsA(isA<RepositoryException>()));
      expect(await r.fetchRoutes(), hasLength(3));
    });

    test('내 팁(GET /api/me/tips)은 로그인이 필요하고 내 것이면 예시 팁도 준다', () async {
      final r = repo();
      expect((await r.fetchMyTips(demoSession)).map((t) => t.id), [8]);
      final student02 = await r.login('student02', 'x');
      expect((await r.fetchMyTips(student02)).single.example, isTrue);
    });
  });

  group('팁 입력 규칙(앞뒤 공백 제거 뒤 코드 포인트)', () {
    test('제목·위치 1~80자, 공백만은 빈 값', () {
      expect(validateTip(title: '   ', location: 'a', note: '').title, TipFieldError.required);
      expect(validateTip(title: '가' * 80, location: 'a', note: '').isEmpty, isTrue);
      expect(validateTip(title: '가' * 81, location: 'a', note: '').title, TipFieldError.tooLong80);
      expect(validateTip(title: ' ${'가' * 80} ', location: 'a', note: '').isEmpty, isTrue);
    });

    test('이모지 한 개는 1자(UTF-16 2칸이어도)', () {
      expect(codePointLength('🚆'), 1);
      expect(validateTip(title: '🚆' * 80, location: 'a', note: '').isEmpty, isTrue);
      expect(validateTip(title: '🚆' * 81, location: 'a', note: '').title, TipFieldError.tooLong80);
    });

    test('메모는 선택, 공백을 뺀 뒤 150자까지(서버와 같음)', () {
      expect(validateTip(title: 'a', location: 'a', note: '').note, isNull);
      expect(validateTip(title: 'a', location: 'a', note: 'm' * 150).note, isNull);
      expect(validateTip(title: 'a', location: 'a', note: ' ${'m' * 150} ').note, isNull);
      expect(validateTip(title: 'a', location: 'a', note: 'm' * 151).note, TipFieldError.tooLong150);
    });
  });

  test('HTTP 저장소 뼈대: 에뮬레이터 기본 주소, 아직 요청을 보내지 않음', () async {
    final http = HttpSubwayRepository();
    expect(http.baseUrl, 'http://10.0.2.2:8097');
    await expectLater(http.fetchMyTips(demoSession), throwsA(isA<UnimplementedError>()));
  });
}
