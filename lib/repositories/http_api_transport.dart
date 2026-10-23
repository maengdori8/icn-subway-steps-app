import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import 'http_subway_repository.dart';
import 'subway_repository.dart';

// ApiTransport의 실제 구현(10장). http 패키지(publisher dart.dev)로 내 서버에 보낸다.
// - 헤더는 ApiRequest가 정한다. Bearer 토큰은 요청에 bearerToken이 있을 때만 붙고, 로그·오류 문구에 넣지 않는다.
// - 요청 하나(보내기부터 본문을 다 받기까지)에 [timeout]까지 기다린다. 시간 초과는 서버가 처리했는지 알 수 없어
//   timeout으로 알린다. 화면은 등록을 자동으로 다시 보내지 않고, 다시 보내기 전에 목록을 확인하게 한다(교재 10장 Q04).
// - 기기에 망이 없다고 확인될 때(ENETDOWN·ENETUNREACH)만 offline('인터넷에 연결되지 않았습니다')이다.
//   연결 거부(서버 꺼짐)·호스트 접근 실패·이름 풀이 실패는 인터넷 문제로 단정할 수 없어 server('불러오지 못했어요')다.
class HttpApiTransport implements ApiTransport {
  HttpApiTransport({http.Client? client, this.timeout = const Duration(seconds: 15)})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  // 망 없음(ENETDOWN·ENETUNREACH). 앞 둘은 Android·Linux, 뒤 둘은 Windows의 번호다.
  static const _networkDownCodes = {100, 101, 10050, 10051};

  @override
  Future<ApiResponse> send(Uri uri, ApiRequest request) async {
    final req = http.Request(request.method, uri)..headers.addAll(request.headers);
    if (request.body != null) req.body = jsonEncode(request.body); // Content-Type의 charset(utf-8)으로 인코딩
    try {
      return await _sendAndRead(req).timeout(timeout);
    } on TimeoutException {
      throw RepositoryException(RepositoryErrorCode.timeout, 'timeout: $request');
    } on SocketException catch (e) {
      final networkDown = _networkDownCodes.contains(e.osError?.errorCode);
      throw RepositoryException(networkDown ? RepositoryErrorCode.offline : RepositoryErrorCode.server, 'socket: $request');
    } on http.ClientException {
      throw RepositoryException(RepositoryErrorCode.server, 'client: $request');
    }
  }

  Future<ApiResponse> _sendAndRead(http.Request req) async {
    final response = await _client.send(req);
    return ApiResponse(response.statusCode, await response.stream.toBytes());
  }
}
