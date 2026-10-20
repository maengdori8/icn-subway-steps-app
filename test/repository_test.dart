import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/models/route_info.dart';
import 'package:icn_subway_app/models/tip.dart';
import 'package:icn_subway_app/models/user_session.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/http_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';
import 'package:icn_subway_app/validation/tip_rules.dart';

const demoSession = UserSession(userId: 101, username: 'student01', accessToken: 'fake-session-101');

void main() {
  FakeSubwayRepository repo() => FakeSubwayRepository(delay: Duration.zero, now: () => DateTime(2026, 10, 20));

  group('가짜 저장소', () {
    test('경로 3개: 직통·일반 5단계, T2는 준비 중', () async {
      final routes = await repo().fetchRoutes();
      expect(routes.map((r) => r.code), ['EXPRESS', 'LOCAL', 'T2']);
      expect(routes.where((r) => r.available).map((r) => r.stepCount), [5, 5]);
      expect(routes.last.available, isFalse);
      // JSON 이름은 ui-handoff.md 후보와 같은 snake_case
      expect(routes.first.toJson().keys, containsAll(['code', 'step_count', 'sign_ko', 'sign_en', 'available']));
      expect(RouteInfo.fromJson(routes.first.toJson()).name.ko, '직통열차');
    });

    test('단계는 step_no 1부터, 사진 없는 단계는 photo_url이 null', () async {
      final steps = await repo().fetchSteps('EXPRESS');
      expect(steps.map((s) => s.stepNo), [1, 2, 3, 4, 5]);
      expect(steps.map((s) => s.photoUrl == null), [false, true, false, true, true]);
      expect(steps.first.signEn, 'Terminal 1 Arrivals');
    });

    test('팁 올리기: 앞뒤 공백 제거, 빈 메모는 null, 상태 VERIFIED, 올린 사람은 로그인 사용자', () async {
      final r = repo();
      final tip = await r.createTip(
        const TipDraft(route: 'LOCAL', stepNo: 2, title: '  엘리베이터  ', location: ' 출구 옆 ', note: '   '),
        demoSession,
      );
      expect(tip.title, '엘리베이터');
      expect(tip.location, '출구 옆');
      expect(tip.note, isNull);
      expect(tip.status, TipStatus.verified);
      expect(tip.ownerId, 101);
      expect(tip.verifiedAt, '2026-10-20');
      expect(
        tip.toJson().keys,
        containsAll(['id', 'route', 'step_no', 'title', 'location', 'note', 'status', 'owner_id']),
      );
      expect((await r.fetchTips('LOCAL', 2)).single.id, tip.id);
    });

    test('남이 올린 팁·예시 팁은 상태를 바꿀 수 없다(403)', () async {
      final r = repo();
      final other = await r.login('traveler', 'pw');
      await expectLater(
        r.updateTipStatus(2, TipStatus.verified, other),
        throwsA(isA<RepositoryException>().having((e) => e.code, 'code', RepositoryErrorCode.forbidden)),
      );
      await expectLater(r.updateTipStatus(1, TipStatus.outdated, demoSession), throwsA(isA<RepositoryException>()));
      final mine = await r.updateTipStatus(2, TipStatus.verified, demoSession);
      expect(mine.status, TipStatus.verified);
      expect(mine.verifiedAt, '2026-10-20');
    });

    test("로그인: 아이디 'wrong'은 실패, student01은 101번", () async {
      final r = repo();
      await expectLater(
        r.login('wrong', 'x'),
        throwsA(isA<RepositoryException>().having((e) => e.code, 'code', RepositoryErrorCode.invalidCredentials)),
      );
      expect((await r.login(' student01 ', 'x')).userId, 101);
    });

    test('failNext로 정한 횟수만큼만 실패한다', () async {
      final r = repo()..failNext(FakeOperation.routes, RepositoryErrorCode.offline);
      await expectLater(r.fetchRoutes(), throwsA(isA<RepositoryException>()));
      expect(await r.fetchRoutes(), hasLength(3));
    });

    test('내 팁은 로그인이 필요하고 예시 팁은 빠진다', () async {
      final r = repo();
      expect((await r.fetchMyTips(demoSession)).map((t) => t.id), [2]);
    });
  });

  group('팁 입력 규칙(코드 포인트 기준)', () {
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

    test('메모는 선택, 150자까지', () {
      expect(validateTip(title: 'a', location: 'a', note: '').note, isNull);
      expect(validateTip(title: 'a', location: 'a', note: 'm' * 150).note, isNull);
      expect(validateTip(title: 'a', location: 'a', note: 'm' * 151).note, TipFieldError.tooLong150);
    });
  });

  test('HTTP 저장소 뼈대: 에뮬레이터 기본 주소, 아직 요청을 보내지 않음', () async {
    final http = HttpSubwayRepository();
    expect(http.baseUrl, 'http://10.0.2.2:8097');
    await expectLater(http.fetchRoutes(), throwsA(isA<UnimplementedError>()));
  });
}
