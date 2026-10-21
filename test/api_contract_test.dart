import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/models/guide_step.dart';
import 'package:icn_subway_app/models/tip.dart';
import 'package:icn_subway_app/models/user_session.dart';
import 'package:icn_subway_app/repositories/http_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';

// 서버 계약(C:\dev\projects\icn-subway-server\docs\api-spec.yaml)과 앱의 HTTP 저장소를 맞춰 보는 검사.
// 실제 서버에 연결하지 않고, 보낸 요청을 기록하고 명세의 example(또는 스키마대로 만든 JSON)을 돌려주는 전송을 쓴다.

class RecordingTransport implements ApiTransport {
  RecordingTransport(this.reply);

  final ApiResponse Function(Uri uri, ApiRequest request) reply;
  final List<(Uri, ApiRequest)> sent = [];

  @override
  Future<ApiResponse> send(Uri uri, ApiRequest request) async {
    sent.add((uri, request));
    return reply(uri, request);
  }
}

ApiResponse json(int status, Object body) => ApiResponse(status, utf8.encode(jsonEncode(body)));

const session = UserSession(userId: 101, username: 'student01', accessToken: 'test-token');

// api-spec.yaml paths./api/routes.get example (그대로)
const routesExample = {
  'routes': [
    {
      'code': 'EXPRESS',
      'name': {'en': 'Express Train', 'ko': '직통열차'},
      'summary': {'en': 'Non-stop to Seoul Station · ticket needed', 'ko': '서울역까지 무정차 · 승차권 필요'},
      'available': true,
      'stepCount': 5,
    },
    {
      'code': 'LOCAL',
      'name': {'en': 'All-stop Train', 'ko': '일반열차'},
      'summary': {'en': 'Stops at every station · T-money card', 'ko': '모든 역 정차 · 교통카드(T-money)'},
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
};

// components.schemas.Tip의 필수 항목을 모두 갖춘 JSON(서버 시드 8번)
Map<String, dynamic> tipJson({int id = 8, bool mine = true}) => {
  'id': id,
  'route': 'LOCAL',
  'stepNo': 4,
  'title': 'Elevator for big suitcases',
  'location': 'Left end of the gates',
  'note': 'The wide gate next to it fits two suitcases.',
  'status': 'OUTDATED',
  'verifiedAt': '2026-09-30T03:00:00Z',
  'createdAt': '2026-09-30T03:00:00Z',
  'ownerId': 101,
  'mine': mine,
  'example': false,
};

void main() {
  HttpSubwayRepository repoWith(RecordingTransport t) => HttpSubwayRepository(transport: t);

  test('GET /api/routes: 명세 example을 읽고 토큰 없이 보낸다', () async {
    final t = RecordingTransport((_, _) => json(200, routesExample));
    final routes = await repoWith(t).fetchRoutes();
    expect(routes.map((r) => r.code), ['EXPRESS', 'LOCAL', 'T2']);
    expect(routes.last.available, isFalse);
    expect(routes.last.stepCount, 0);
    expect(routes.first.name.ko, '직통열차', reason: 'UTF-8 본문');
    final (uri, req) = t.sent.single;
    expect(req.method, 'GET');
    expect(uri.toString(), 'http://10.0.2.2:8097/api/routes');
    expect(req.headers.containsKey('Authorization'), isFalse);
  });

  test('GET /api/routes/{route}/steps: {route, steps} 봉투, sign 객체·instructions·photoKey·elevator', () async {
    final t = RecordingTransport(
      (_, _) => json(200, {
        'route': 'EXPRESS',
        'steps': [
          {
            'stepNo': 1,
            'role': 'HERE',
            'icon': 'PLANE',
            'photoKey': 'arrivals',
            'sign': {'ko': '제1여객터미널 입국장', 'en': 'Terminal 1 Arrivals'},
            'title': {'en': 'Walk out of the arrivals hall', 'ko': '입국장 밖으로 나오기'},
            'instructions': {
              'en': ['Exit through the arrival doors with your bags.'],
              'ko': ['짐을 찾고 도착 출구로 나옵니다.'],
            },
            'elevator': null,
          },
        ],
      }),
    );
    final step = (await repoWith(t).fetchSteps('EXPRESS')).single;
    expect(step.role, SignRole.here);
    expect(step.signKo, '제1여객터미널 입국장');
    expect(step.photoKey, 'arrivals');
    expect(step.elevator, isNull);
    expect(t.sent.single.$1.path, '/api/routes/EXPRESS/steps');
  });

  test('GET /api/tips: route·step 쿼리, 로그인했으면 Bearer 토큰, {tips} 봉투', () async {
    final t = RecordingTransport(
      (_, _) => json(200, {
        'tips': [tipJson()],
      }),
    );
    final repo = repoWith(t);
    final tips = await repo.fetchTips('LOCAL', 4, session: session);
    expect(tips.single.mine, isTrue);
    expect(tips.single.status, TipStatus.outdated);
    expect(seoulDate(tips.single.verifiedAt), '2026-09-30');
    final (uri, req) = t.sent.single;
    expect(uri.path, '/api/tips');
    expect(uri.queryParameters, {'route': 'LOCAL', 'step': '4'});
    expect(req.headers['Authorization'], 'Bearer test-token');

    await repo.fetchTips('LOCAL', 4);
    expect(t.sent.last.$2.headers.containsKey('Authorization'), isFalse, reason: '로그인 전에는 토큰 없음');
  });

  test('GET /api/me/tips: 내 팁(토큰 필요)', () async {
    final t = RecordingTransport(
      (_, _) => json(200, {
        'tips': [tipJson()],
      }),
    );
    expect((await repoWith(t).fetchMyTips(session)).single.id, 8);
    expect(t.sent.single.$1.path, '/api/me/tips');
    expect(t.sent.single.$2.headers['Authorization'], 'Bearer test-token');
  });

  test('POST /api/tips: 본문은 TipCreateRequest 다섯 항목뿐(명세 example과 같음)', () async {
    final t = RecordingTransport((_, _) => json(201, tipJson(id: 9)..['status'] = 'VERIFIED'));
    final tip = await repoWith(t)
        .createTip(const TipDraft(route: 'LOCAL', stepNo: 4, title: '넓은 개찰구', location: '개찰구 왼쪽 끝'), session);
    expect(tip.id, 9);
    final req = t.sent.single.$2;
    expect(req.method, 'POST');
    expect(req.body, {'route': 'LOCAL', 'stepNo': 4, 'title': '넓은 개찰구', 'location': '개찰구 왼쪽 끝', 'note': null});
    expect(req.headers['Content-Type'], startsWith('application/json'));
  });

  test('PATCH /api/tips/{id}/status: 본문은 {status}뿐', () async {
    final t = RecordingTransport((_, _) => json(200, tipJson()));
    await repoWith(t).updateTipStatus(8, TipStatus.outdated, session);
    final (uri, req) = t.sent.single;
    expect(req.method, 'PATCH');
    expect(uri.path, '/api/tips/8/status');
    expect(req.body, {'status': 'OUTDATED'});
  });

  test('POST /api/auth/login: 토큰 없이 보내고 LoginResponse를 세션으로 읽는다', () async {
    final t = RecordingTransport(
      (_, _) => json(200, {
        'accessToken': 'a.b.c',
        'tokenType': 'Bearer',
        'expiresIn': 1800,
        'user': {'id': 101, 'username': 'student01'},
      }),
    );
    final s = await repoWith(t).login('student01', 'not-a-real-password');
    expect((s.userId, s.username), (101, 'student01'));
    final req = t.sent.single.$2;
    expect(req.body!.keys, ['username', 'password']);
    expect(req.headers.containsKey('Authorization'), isFalse);
    expect(req.toString(), 'POST /api/auth/login', reason: '로그에 비밀번호·토큰이 찍히지 않게');
  });

  group('오류 응답 {code, message, errors}', () {
    Future<RepositoryException> failWith(int status, Object? body) async {
      final t = RecordingTransport((_, _) => body == null ? const ApiResponse(500, []) : json(status, body));
      try {
        await repoWith(t).createTip(const TipDraft(route: 'LOCAL', stepNo: 4, title: 't', location: 'l'), session);
      } on RepositoryException catch (e) {
        return e;
      }
      fail('예외가 나야 함');
    }

    test('400 VALIDATION_FAILED: errors의 키가 S03 입력칸 이름으로 남는다(명세 example)', () async {
      final e = await failWith(400, {
        'code': 'VALIDATION_FAILED',
        'message': '입력값을 확인하세요.',
        'errors': {'title': '1~80자로 입력하세요.', 'location': '80자 이하로 입력하세요.', 'note': '150자 이하로 입력하세요.'},
      });
      expect(e.code, RepositoryErrorCode.validation);
      expect(e.fieldErrors, {'title', 'location', 'note'});
      expect(e.serverCode, 'VALIDATION_FAILED');
    });

    test('400 INVALID_REQUEST_BODY(정하지 않은 항목)', () async {
      final e = await failWith(400, {
        'code': 'INVALID_REQUEST_BODY',
        'message': '요청 본문을 읽을 수 없습니다.',
        'errors': {'status': '허용하지 않는 항목입니다.'},
      });
      expect(e.code, RepositoryErrorCode.validation);
      expect(e.fieldErrors, {'status'});
    });

    test('401·403·404·500을 앱의 실패 종류로', () async {
      final unauthorized = await failWith(401, {'code': 'UNAUTHORIZED', 'message': '로그인이 필요합니다.', 'errors': {}});
      final loginFailed = await failWith(401, {
        'code': 'LOGIN_FAILED',
        'message': '아이디 또는 비밀번호가 맞지 않아요.',
        'errors': {},
      });
      final forbidden = await failWith(403, {
        'code': 'FORBIDDEN',
        'message': '이 팁을 올린 사람만 상태를 바꿀 수 있습니다.',
        'errors': {},
      });
      final notFound = await failWith(404, {'code': 'NOT_FOUND', 'message': '팁을 찾을 수 없습니다.', 'errors': {}});
      final broken = await failWith(500, null);
      expect(
        [unauthorized.code, loginFailed.code, forbidden.code, notFound.code, broken.code],
        [
          RepositoryErrorCode.unauthorized,
          RepositoryErrorCode.invalidCredentials,
          RepositoryErrorCode.forbidden,
          RepositoryErrorCode.notFound,
          RepositoryErrorCode.server,
        ],
      );
    });

    test('200인데 계약과 다른 모양이면 원인 모를 실패(server)', () async {
      final t = RecordingTransport((_, _) => json(200, {'items': []}));
      await expectLater(
        repoWith(t).fetchRoutes(),
        throwsA(isA<RepositoryException>().having((e) => e.code, 'code', RepositoryErrorCode.server)),
      );
    });
  });

  test('계약과 다른 날짜·모르는 상태값도 server 실패로(Codex 4회차 지적 3)', () async {
    for (final broken in [tipJson()..['verifiedAt'] = 'yesterday', tipJson()..['status'] = 'MAYBE']) {
      final t = RecordingTransport(
        (_, _) => json(200, {
          'tips': [broken],
        }),
      );
      await expectLater(
        HttpSubwayRepository(transport: t).fetchTips('LOCAL', 4),
        throwsA(isA<RepositoryException>().having((e) => e.code, 'code', RepositoryErrorCode.server)),
      );
    }
  });

  test('서버가 더 준 키는 무시한다', () async {
    final t = RecordingTransport(
      (_, _) => json(200, {
        'tips': [tipJson()..['extra'] = 1],
      }),
    );
    expect((await HttpSubwayRepository(transport: t).fetchTips('LOCAL', 4)).single.id, 8);
  });

  test('409 USERNAME_TAKEN·415도 errors 키를 남기고 validation으로', () {
    final taken = RepositoryException.fromErrorResponse(409, {
      'code': 'USERNAME_TAKEN',
      'message': '이미 사용 중인 아이디입니다.',
      'errors': {'username': '이미 사용 중인 아이디입니다.'},
    });
    expect(taken.code, RepositoryErrorCode.validation);
    expect(taken.fieldErrors, {'username'});
    final media = RepositoryException.fromErrorResponse(415, {
      'code': 'UNSUPPORTED_MEDIA_TYPE',
      'message': '지원하지 않는 형식입니다.',
      'errors': {},
    });
    expect(media.code, RepositoryErrorCode.validation);
    expect(media.serverCode, 'UNSUPPORTED_MEDIA_TYPE');
  });

  test('형식이 틀린 오류 본문(code가 숫자 등)도 상태 코드로 분류한다(Codex 5회차 지적 2)', () async {
    final t = RecordingTransport((_, _) => json(500, {'code': 123, 'errors': 'x'}));
    await expectLater(
      HttpSubwayRepository(transport: t).login('student01', 'not-a-real-password'),
      throwsA(isA<RepositoryException>().having((e) => e.code, 'code', RepositoryErrorCode.server)),
    );
    final unauthorized = RepositoryException.fromErrorResponse(401, {'code': 5, 'errors': []});
    expect(unauthorized.code, RepositoryErrorCode.unauthorized);
    expect(unauthorized.fieldErrors, isEmpty);
  });
}
