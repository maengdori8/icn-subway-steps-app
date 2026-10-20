import '../models/guide_step.dart';
import '../models/route_info.dart';
import '../models/tip.dart';
import '../models/user_session.dart';

// 화면이 자료를 읽고 쓰는 약속(창구). 9장은 FakeSubwayRepository, 10장은 HttpSubwayRepository가 같은 약속을 지킨다.
// 경로 옆 주석은 docs/ui-handoff.md의 요청 후보다. 실제 경로는 서버 docs/api-spec.yaml로 확정한다.
abstract class SubwayRepository {
  Future<List<RouteInfo>> fetchRoutes(); // GET /api/routes
  Future<List<GuideStep>> fetchSteps(String routeCode); // GET /api/routes/{code}/steps
  Future<List<Tip>> fetchTips(String routeCode, int stepNo); // GET /api/tips?route=&step=
  Future<List<Tip>> fetchMyTips(UserSession session); // GET /api/tips/mine (후보, 로그인 필요)
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
  const RepositoryException(this.code, [this.message = '']);

  final RepositoryErrorCode code;
  final String message; // 개발자용 설명. 화면 문구는 l10n/app_strings.dart가 정한다

  @override
  String toString() => 'RepositoryException(${code.name}${message.isEmpty ? '' : ': $message'})';
}
