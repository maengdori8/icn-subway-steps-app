import '../models/guide_step.dart';
import '../models/route_info.dart';
import '../models/tip.dart';
import '../models/user_session.dart';

// 화면이 자료를 읽고 쓰는 약속(창구). 9장은 FakeSubwayRepository, 10장은 HttpSubwayRepository가 같은 약속을 지킨다.
// 경로 옆 주석은 서버 계약(icn-subway-server의 docs/api-spec.yaml, camelCase)의 요청이다.
abstract class SubwayRepository {
  Future<List<RouteInfo>> fetchRoutes(); // GET /api/routes → {routes: [...]}
  Future<List<GuideStep>> fetchSteps(String routeCode); // GET /api/routes/{route}/steps → {route, steps: [...]}
  // GET /api/tips?route=&step= → {tips: [...]}. 로그인했으면 토큰을 붙여 mine을 받는다.
  Future<List<Tip>> fetchTips(String routeCode, int stepNo, {UserSession? session});
  Future<List<Tip>> fetchMyTips(UserSession session); // GET /api/me/tips (로그인 필요)
  Future<Tip> createTip(TipDraft draft, UserSession session); // POST /api/tips (로그인 필요)
  Future<Tip> updateTipStatus(int tipId, TipStatus status, UserSession session); // PATCH /api/tips/{id}/status
  Future<UserSession> login(String username, String password); // POST /api/auth/login
}

// 실패 종류. 화면은 종류마다 다른 안내를 보인다(원인을 단정할 수 있을 때만 '오프라인' 문구).
enum RepositoryErrorCode {
  offline, // 연결 끊김이 확인됨
  server, // 원인을 모르는 실패(5xx 등)
  unauthorized, // 401: 로그인이 없거나 끝남
  forbidden, // 403: 올린 사람이 아님
  invalidCredentials, // 로그인 실패(아이디·비밀번호 불일치)
  validation, // 400: 입력 규칙 위반
  notFound, // 404
}

class RepositoryException implements Exception {
  const RepositoryException(this.code, [this.message = '', this.fieldErrors = const {}, this.serverCode]);

  // 서버 오류 본문 {code, message, errors}를 앱의 실패 종류로 바꾼다(서버 docs/api-spec.yaml Error 스키마).
  // errors의 키(title·location·note·route·stepNo·status…)는 fieldErrors로 남겨 화면이 칸과 이을 수 있게 한다.
  // 서버 message·errors 문구는 한국어뿐이라 화면에 그대로 쓰지 않는다.
  factory RepositoryException.fromErrorResponse(int statusCode, Map<String, dynamic>? body) {
    // 형식이 틀린 오류 본문(code가 문자열이 아님 등)에서도 예외 없이 읽는다. 상태 코드 분류가 우선이다.
    final rawCode = body?['code'];
    final serverCode = rawCode is String ? rawCode : null;
    final errors = body?['errors'];
    final fields = errors is Map ? errors.keys.map((k) => k.toString()).toSet() : const <String>{};
    final code = switch (statusCode) {
      401 when serverCode == 'LOGIN_FAILED' => RepositoryErrorCode.invalidCredentials,
      401 => RepositoryErrorCode.unauthorized,
      403 => RepositoryErrorCode.forbidden,
      404 => RepositoryErrorCode.notFound,
      400 || 409 || 415 => RepositoryErrorCode.validation,
      _ => RepositoryErrorCode.server,
    };
    return RepositoryException(code, 'HTTP $statusCode ${serverCode ?? ''}', fields, serverCode);
  }

  final RepositoryErrorCode code;
  final String message; // 개발자용 설명. 화면 문구는 l10n/app_strings.dart가 정한다
  final Set<String> fieldErrors; // 서버 errors의 키(입력칸 이름)
  final String? serverCode; // 서버 Error.code(VALIDATION_FAILED 등)

  @override
  String toString() => 'RepositoryException(${code.name}${message.isEmpty ? '' : ': $message'})';
}
