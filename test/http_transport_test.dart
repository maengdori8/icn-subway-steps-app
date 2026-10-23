import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:icn_subway_app/models/tip.dart';
import 'package:icn_subway_app/models/user_session.dart';
import 'package:icn_subway_app/repositories/http_api_transport.dart';
import 'package:icn_subway_app/repositories/http_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';

// 10장: 실제 전송(HttpApiTransport)이 요청의 네 부분(메서드·주소·헤더·본문)을 계약대로 만들고
// 응답·연결 실패를 앱의 실패 종류로 바꾸는지 MockClient(http 패키지의 검사용 클라이언트)로 본다. 실제 서버에는 연결하지 않는다.

const session = UserSession(userId: 101, username: 'student01', accessToken: 'test-token');

http.Response jsonResponse(int status, Object body) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), status, headers: {'content-type': 'application/json'});

// 서버 시드 8번(docs/samples/tips-local-4.json과 같은 값)
const tip8 = {
  'id': 8,
  'route': 'LOCAL',
  'stepNo': 4,
  'title': 'Elevator for big suitcases',
  'location': 'Left end of the gates',
  'note': 'The wide gate next to it fits two suitcases.',
  'status': 'OUTDATED',
  'verifiedAt': '2026-09-30T03:00:00Z',
  'createdAt': '2026-09-30T03:00:00Z',
  'ownerId': 101,
  'mine': true,
  'example': false,
};

void main() {
  final sent = <http.Request>[];

  HttpSubwayRepository repoWith(Future<http.Response> Function(http.Request) handler, {Duration? timeout}) {
    sent.clear();
    final client = MockClient((request) {
      sent.add(request);
      return handler(request);
    });
    return HttpSubwayRepository(
      baseUrl: 'http://10.0.2.2:8097',
      transport: HttpApiTransport(client: client, timeout: timeout ?? const Duration(seconds: 15)),
    );
  }

  Future<RepositoryErrorCode?> failureOf(Future<Object?> Function() call) async {
    try {
      await call();
      return null;
    } on RepositoryException catch (e) {
      return e.code;
    }
  }

  test('공개 GET은 Authorization 없이 보내고, charset 없는 JSON도 UTF-8로 읽는다(한글)', () async {
    final repo = repoWith(
      (_) async => jsonResponse(200, {
        'routes': [
          {
            'code': 'EXPRESS',
            'name': {'en': 'Express Train', 'ko': '직통열차'},
            'summary': {'en': 'Non-stop to Seoul Station · ticket needed', 'ko': '서울역까지 무정차 · 승차권 필요'},
            'available': true,
            'stepCount': 5,
          },
        ],
      }),
    );
    final routes = await repo.fetchRoutes();
    expect(sent.single.method, 'GET');
    expect(sent.single.url.toString(), 'http://10.0.2.2:8097/api/routes');
    expect(sent.single.headers.containsKey('Authorization'), isFalse);
    expect(sent.single.headers['Accept'], 'application/json');
    expect(routes.single.name.ko, '직통열차');
  });

  test('POST /api/tips: Bearer와 JSON 본문 다섯 항목(ownerId·status를 보내지 않음)', () async {
    final repo = repoWith((_) async => jsonResponse(201, {...tip8, 'id': 9, 'status': 'VERIFIED'}));
    final created = await repo.createTip(
      const TipDraft(route: 'LOCAL', stepNo: 4, title: '노란 우산 보관함', location: '개찰구 왼쪽'),
      session,
    );
    final r = sent.single;
    expect(r.method, 'POST');
    expect(r.url.path, '/api/tips');
    expect(r.headers['Authorization'], 'Bearer test-token');
    expect(r.headers['Content-Type'], 'application/json; charset=utf-8');
    final body = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    expect(body.keys, unorderedEquals(['route', 'stepNo', 'title', 'location', 'note']));
    expect(body['title'], '노란 우산 보관함');
    expect(created.id, 9);
  });

  test('PATCH /api/tips/{id}/status: Bearer와 본문 {status}뿐', () async {
    final repo = repoWith((_) async => jsonResponse(200, {...tip8, 'status': 'VERIFIED'}));
    final updated = await repo.updateTipStatus(8, TipStatus.verified, session);
    final r = sent.single;
    expect(r.method, 'PATCH');
    expect(r.url.path, '/api/tips/8/status');
    expect(r.headers['Authorization'], 'Bearer test-token');
    expect(jsonDecode(utf8.decode(r.bodyBytes)), {'status': 'VERIFIED'});
    expect(updated.status, TipStatus.verified);
  });

  test('로그인은 토큰 없이 보내고, 로그인 요청의 401 LOGIN_FAILED는 아이디·비밀번호 확인(invalidCredentials)', () async {
    final repo = repoWith(
      (_) async => jsonResponse(401, {'code': 'LOGIN_FAILED', 'message': '아이디 또는 비밀번호가 맞지 않습니다.', 'errors': {}}),
    );
    expect(await failureOf(() => repo.login('student01', 'wrong-password')), RepositoryErrorCode.invalidCredentials);
    expect(sent.single.headers.containsKey('Authorization'), isFalse);
  });

  test('보호 요청의 401은 unauthorized(세션 정리), 403은 forbidden(로그인 유지)', () async {
    var repo = repoWith(
      (_) async => jsonResponse(401, {'code': 'UNAUTHORIZED', 'message': '로그인이 필요합니다.', 'errors': {}}),
    );
    expect(await failureOf(() => repo.fetchMyTips(session)), RepositoryErrorCode.unauthorized);
    repo = repoWith(
      (_) async => jsonResponse(403, {'code': 'FORBIDDEN', 'message': '이 팁을 올린 사람만 상태를 바꿀 수 있습니다.', 'errors': {}}),
    );
    expect(await failureOf(() => repo.updateTipStatus(7, TipStatus.outdated, session)), RepositoryErrorCode.forbidden);
  });

  group('응답을 받지 못함', () {
    test('서버가 꺼져 연결 거부(Connection refused)는 인터넷 문제로 단정하지 않는다(server)', () async {
      final repo = repoWith((_) async => throw const SocketException('Connection refused', osError: OSError('Connection refused', 111)));
      expect(await failureOf(repo.fetchRoutes), RepositoryErrorCode.server);
    });

    test('기기 망 없음(Network is unreachable)만 offline', () async {
      final repo = repoWith(
        (_) async => throw const SocketException('Network is unreachable', osError: OSError('Network is unreachable', 101)),
      );
      expect(await failureOf(repo.fetchRoutes), RepositoryErrorCode.offline);
    });

    test('이름 풀이 실패·호스트 접근 실패(No route to host)는 인터넷 문제로 단정하지 않는다(server, Codex 1회차 지적 3)', () async {
      var repo = repoWith((_) async => throw const SocketException("Failed host lookup: 'example.invalid'"));
      expect(await failureOf(repo.fetchRoutes), RepositoryErrorCode.server);
      repo = repoWith((_) async => throw const SocketException('No route to host', osError: OSError('No route to host', 113)));
      expect(await failureOf(repo.fetchRoutes), RepositoryErrorCode.server);
    });

    test('시간 초과는 처리 여부를 알 수 없어 timeout(자동으로 다시 보내지 않음)', () async {
      final never = Completer<http.Response>();
      final repo = repoWith((_) => never.future, timeout: const Duration(milliseconds: 20));
      expect(
        await failureOf(() => repo.createTip(const TipDraft(route: 'LOCAL', stepNo: 4, title: 't', location: 'l'), session)),
        RepositoryErrorCode.timeout,
      );
      expect(sent, hasLength(1), reason: '한 번만 보냄');
    });

    test('제한 시간은 보내기부터 본문을 다 받기까지 한 번이다(헤더·본문이 각각 늦으면 합쳐서 넘김, Codex 1회차 지적 1)', () async {
      final client = MockClient.streaming((request, body) async {
        await Future<void>.delayed(const Duration(milliseconds: 30)); // 헤더가 늦게 옴
        final late = Future<List<int>>.delayed(const Duration(milliseconds: 30), () => utf8.encode('{"routes": []}'));
        return http.StreamedResponse(Stream.fromFuture(late), 200); // 본문도 늦게 옴
      });
      final repo = HttpSubwayRepository(
        transport: HttpApiTransport(client: client, timeout: const Duration(milliseconds: 45)),
      );
      expect(await failureOf(repo.fetchRoutes), RepositoryErrorCode.timeout);
    });

    test('그 밖의 연결 오류(ClientException)는 server', () async {
      final repo = repoWith((_) async => throw http.ClientException('Connection closed while receiving data'));
      expect(await failureOf(repo.fetchRoutes), RepositoryErrorCode.server);
    });
  });
}
