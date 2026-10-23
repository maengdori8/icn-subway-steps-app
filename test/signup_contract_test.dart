import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/repositories/http_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';

// 회원가입 계약(서버 docs/api-spec.yaml /api/auth/signup): 보내는 요청과 201·409·400 응답 읽기.
// 실제 서버에 연결하지 않고 보낸 요청을 기록하는 전송을 쓴다. 비밀번호는 표본 값이 아닌 검사용 글자다.

class _Recorder implements ApiTransport {
  _Recorder(this.reply);

  final ApiResponse Function(ApiRequest request) reply;
  final List<(Uri, ApiRequest)> sent = [];

  @override
  Future<ApiResponse> send(Uri uri, ApiRequest request) async {
    sent.add((uri, request));
    return reply(request);
  }
}

ApiResponse _json(int status, Object body) => ApiResponse(status, utf8.encode(jsonEncode(body)));

Future<RepositoryException> _failure(ApiResponse response) async {
  try {
    await HttpSubwayRepository(transport: _Recorder((_) => response)).signup('student01', 'not-a-real-password');
  } on RepositoryException catch (e) {
    return e;
  }
  throw StateError('실패해야 함');
}

void main() {
  test('POST /api/auth/signup: username·password만 보내고 토큰을 붙이지 않으며 201 User를 받는다', () async {
    final t = _Recorder((_) => _json(201, {'id': 103, 'username': 'new_traveler'}));
    await HttpSubwayRepository(transport: t).signup('new_traveler', 'not-a-real-password');
    final (uri, request) = t.sent.single;
    expect(request.method, 'POST');
    expect(uri.path, '/api/auth/signup');
    expect(request.body, {'username': 'new_traveler', 'password': 'not-a-real-password'});
    expect(request.headers.containsKey('Authorization'), isFalse);
    expect(request.headers['Content-Type'], startsWith('application/json'));
    expect(request.toString(), 'POST /api/auth/signup', reason: '로그에 비밀번호가 찍히지 않음');
  });

  test('409 USERNAME_TAKEN은 validation + serverCode, 칸 이름 username', () async {
    final e = await _failure(
      _json(409, {
        'code': 'USERNAME_TAKEN',
        'message': '이미 사용 중인 아이디입니다.',
        'errors': {'username': '이미 사용 중인 아이디입니다.'},
      }),
    );
    expect(e.code, RepositoryErrorCode.validation);
    expect(e.serverCode, 'USERNAME_TAKEN');
    expect(e.fieldErrors, {'username'});
  });

  test('400 VALIDATION_FAILED는 두 칸 이름을 함께 남긴다', () async {
    final e = await _failure(
      _json(400, {
        'code': 'VALIDATION_FAILED',
        'message': '입력값을 확인하세요.',
        'errors': {'username': '소문자 영문·숫자·밑줄 4~24자로 입력하세요.', 'password': '8자 이상, UTF-8 72바이트 이하로 입력하세요.'},
      }),
    );
    expect(e.code, RepositoryErrorCode.validation);
    expect(e.fieldErrors, {'username', 'password'});
  });

  test('201인데 User 모양이 아니면 원인 모를 실패', () async {
    final e = await _failure(_json(201, {'username': 'new_traveler'}));
    expect(e.code, RepositoryErrorCode.server);
  });
}
