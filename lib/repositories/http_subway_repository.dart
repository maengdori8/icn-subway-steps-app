import 'dart:convert';

import '../models/guide_step.dart';
import '../models/route_info.dart';
import '../models/tip.dart';
import '../models/user_session.dart';
import 'subway_repository.dart';

// 서버 주소. 에뮬레이터에서 PC의 localhost는 10.0.2.2로 보인다(서버는 127.0.0.1에만 열려 실기기 불가).
// 다른 주소로 실행: flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8097
class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8097');
}

// 서버로 보낼 요청 한 건. 경로·쿼리·본문은 서버 계약(icn-subway-server의 docs/api-spec.yaml)을 따른다.
class ApiRequest {
  const ApiRequest(this.method, this.path, {this.query, this.body, this.bearerToken});

  final String method; // GET / POST / PATCH
  final String path;
  final Map<String, String>? query;
  final Map<String, dynamic>? body; // JSON 본문. 계약에 없는 항목을 넣으면 서버가 400
  final String? bearerToken; // 로그인했을 때만. 로그·화면에 찍지 않는다

  Map<String, String> get headers => {
    'Accept': 'application/json',
    if (body != null) 'Content-Type': 'application/json; charset=utf-8',
    if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
  };

  // 토큰·본문(비밀번호)을 빼고 보인다.
  @override
  String toString() => '$method $path';
}

class ApiResponse {
  const ApiResponse(this.statusCode, this.bodyBytes);

  final int statusCode;
  final List<int> bodyBytes; // UTF-8로 읽는다(utf8.decode)
}

// 실제 전송. 구현은 HttpApiTransport(http_api_transport.dart)이고 main.dart가 HttpSubwayRepository(transport: ...)에 넣는다.
// 연결 실패·시간 초과는 구현 안에서 RepositoryException(offline 또는 server)으로 바꾼다.
abstract class ApiTransport {
  Future<ApiResponse> send(Uri uri, ApiRequest request);
}

class _NotConnectedTransport implements ApiTransport {
  const _NotConnectedTransport();

  @override
  Future<ApiResponse> send(Uri uri, ApiRequest request) async => throw UnimplementedError('전송을 넣지 않음: $request ($uri)');
}

// 실제 API 저장소. 경로·본문 만들기와 응답·오류 읽기를 맡고, 전송은 넣어 준 ApiTransport가 한다
// (전송을 넣지 않으면 요청을 보내지 않는다: 검사용 기본값).
// - 공개 GET이라도 무효·만료 토큰을 붙이면 401이다. 화면은 unauthorized를 받으면 다시 로그인으로 보낸다.
// - 오류 본문 {code, message, errors}는 RepositoryException.fromErrorResponse가 읽는다(message는 한국어뿐이라 화면에 쓰지 않음).
class HttpSubwayRepository implements SubwayRepository {
  HttpSubwayRepository({this.baseUrl = ApiConfig.baseUrl, ApiTransport? transport})
    : _transport = transport ?? const _NotConnectedTransport();

  final String baseUrl;
  final ApiTransport _transport;

  Uri uriFor(ApiRequest request) => Uri.parse(baseUrl).replace(path: request.path, queryParameters: request.query);

  Future<Map<String, dynamic>> _send(ApiRequest request) async {
    final response = await _transport.send(uriFor(request), request);
    Map<String, dynamic>? json;
    try {
      final text = utf8.decode(response.bodyBytes);
      final decoded = text.isEmpty ? null : jsonDecode(text);
      if (decoded is Map<String, dynamic>) json = decoded;
    } on FormatException {
      json = null;
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (json == null) throw RepositoryException(RepositoryErrorCode.server, 'unreadable body: $request');
      return json;
    }
    throw RepositoryException.fromErrorResponse(response.statusCode, json);
  }

  // 응답 모양이 계약과 다르면(키 없음·타입 다름·날짜 형식·모르는 열거값) 원인 모를 실패로 본다.
  // 모델 파싱은 TypeError·FormatException·StateError 등 무엇이든 던질 수 있어 모두 server로 바꾼다.
  Future<T> _read<T>(ApiRequest request, T Function(Map<String, dynamic> json) parse) async {
    final json = await _send(request);
    try {
      return parse(json);
    } catch (_) {
      throw RepositoryException(RepositoryErrorCode.server, 'unexpected shape: $request');
    }
  }

  @override
  Future<List<RouteInfo>> fetchRoutes() => _read(const ApiRequest('GET', '/api/routes'), RouteInfo.listFromJson);

  @override
  Future<List<GuideStep>> fetchSteps(String routeCode) =>
      _read(ApiRequest('GET', '/api/routes/${Uri.encodeComponent(routeCode)}/steps'), GuideStep.listFromJson);

  @override
  Future<List<Tip>> fetchTips(String routeCode, int stepNo, {UserSession? session}) => _read(
    ApiRequest('GET', '/api/tips', query: {'route': routeCode, 'step': '$stepNo'}, bearerToken: session?.accessToken),
    Tip.listFromJson,
  );

  @override
  Future<List<Tip>> fetchMyTips(UserSession session) =>
      _read(ApiRequest('GET', '/api/me/tips', bearerToken: session.accessToken), Tip.listFromJson);

  @override
  Future<Tip> createTip(TipDraft draft, UserSession session) =>
      _read(ApiRequest('POST', '/api/tips', body: draft.toJson(), bearerToken: session.accessToken), Tip.fromJson);

  @override
  Future<Tip> updateTipStatus(int tipId, TipStatus status, UserSession session) => _read(
    ApiRequest('PATCH', '/api/tips/$tipId/status', body: status.toRequestJson(), bearerToken: session.accessToken),
    Tip.fromJson,
  );

  // 로그인에는 토큰을 붙이지 않는다(오래된 토큰이 있어도 로그인 가능).
  @override
  Future<UserSession> login(String username, String password) => _read(
    ApiRequest('POST', '/api/auth/login', body: {'username': username, 'password': password}),
    UserSession.fromLoginJson,
  );

  // 가입에도 토큰을 붙이지 않는다. 응답 User의 모양(id·username)만 확인한다.
  @override
  Future<void> signup(String username, String password) => _read(
    ApiRequest('POST', '/api/auth/signup', body: {'username': username, 'password': password}),
    (json) => (json['id'] as int, json['username'] as String),
  );
}
