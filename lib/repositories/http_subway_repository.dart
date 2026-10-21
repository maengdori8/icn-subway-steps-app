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

// 10장에서 채울 실제 API 저장소의 뼈대. 지금은 어떤 요청도 보내지 않는다.
// 서버 계약: icn-subway-server의 docs/api-spec.yaml(camelCase). 연결할 때 할 일(docs/handoff.md 3절):
// - http 패키지 추가(승인 후), android/app/src/main/AndroidManifest.xml에 INTERNET 권한,
//   http:// 주소를 쓰면 개발용 cleartext 허용
// - 본문은 utf8.decode(response.bodyBytes)로 읽고, 봉투를 각 모델의 listFromJson으로 읽는다
//   ({routes}, {route, steps}, {tips}). 로그인 응답은 UserSession.fromLoginJson.
// - 로그인했으면 Authorization: Bearer <accessToken>. 401(무효·만료 토큰은 공개 GET도 401)이면 세션을 버리고 다시 로그인,
//   403은 forbidden, 로그인 실패 401(LOGIN_FAILED)은 invalidCredentials, 연결 실패는 offline으로 바꾼다
// - 오류 본문 {code, message, errors}의 message는 한국어뿐이다. 화면 문구는 errors의 키(title·location·note…)로 앱이 고른다
class HttpSubwayRepository implements SubwayRepository {
  HttpSubwayRepository({this.baseUrl = ApiConfig.baseUrl});

  final String baseUrl;

  Never _notConnected(String endpoint) => throw UnimplementedError('10장에서 연결: $endpoint ($baseUrl)');

  @override
  Future<List<RouteInfo>> fetchRoutes() async => _notConnected('GET /api/routes');

  @override
  Future<List<GuideStep>> fetchSteps(String routeCode) async => _notConnected('GET /api/routes/$routeCode/steps');

  @override
  Future<List<Tip>> fetchTips(String routeCode, int stepNo, {UserSession? session}) async =>
      _notConnected('GET /api/tips?route=$routeCode&step=$stepNo');

  @override
  Future<List<Tip>> fetchMyTips(UserSession session) async => _notConnected('GET /api/me/tips');

  @override
  Future<Tip> createTip(TipDraft draft, UserSession session) async => _notConnected('POST /api/tips');

  @override
  Future<Tip> updateTipStatus(int tipId, TipStatus status, UserSession session) async =>
      _notConnected('PATCH /api/tips/$tipId/status');

  @override
  Future<UserSession> login(String username, String password) async => _notConnected('POST /api/auth/login');
}
