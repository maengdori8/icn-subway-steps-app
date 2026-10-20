import '../models/guide_step.dart';
import '../models/route_info.dart';
import '../models/tip.dart';
import '../models/user_session.dart';
import 'subway_repository.dart';

// 서버 주소. 에뮬레이터에서 PC의 localhost는 10.0.2.2로 보인다.
// 다른 주소로 실행: flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8097
class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8097');
}

// 10장에서 채울 실제 API 저장소의 뼈대. 지금은 어떤 요청도 보내지 않는다.
// 연결할 때 할 일(docs/handoff.md 3절):
// - http 패키지 추가(승인 후), android/app/src/main/AndroidManifest.xml에 INTERNET 권한,
//   http:// 주소를 쓰면 개발용 cleartext 허용
// - 응답 JSON은 각 모델의 fromJson(snake_case)으로 읽고, 401·403·연결 끊김을 RepositoryException 코드로 바꾼다
// - 로그인 응답의 토큰을 UserSession.accessToken에 담아 Authorization 헤더로 보낸다
class HttpSubwayRepository implements SubwayRepository {
  HttpSubwayRepository({this.baseUrl = ApiConfig.baseUrl});

  final String baseUrl;

  Never _notConnected(String endpoint) => throw UnimplementedError('10장에서 연결: $endpoint ($baseUrl)');

  @override
  Future<List<RouteInfo>> fetchRoutes() async => _notConnected('GET /api/routes');

  @override
  Future<List<GuideStep>> fetchSteps(String routeCode) async => _notConnected('GET /api/routes/$routeCode/steps');

  @override
  Future<List<Tip>> fetchTips(String routeCode, int stepNo) async =>
      _notConnected('GET /api/tips?route=$routeCode&step=$stepNo');

  @override
  Future<List<Tip>> fetchMyTips(UserSession session) async => _notConnected('GET /api/tips/mine');

  @override
  Future<Tip> createTip(TipDraft draft, UserSession session) async => _notConnected('POST /api/tips');

  @override
  Future<Tip> updateTipStatus(int tipId, TipStatus status, UserSession session) async =>
      _notConnected('PATCH /api/tips/$tipId/status');

  @override
  Future<UserSession> login(String username, String password) async => _notConnected('POST /api/auth/login');
}
