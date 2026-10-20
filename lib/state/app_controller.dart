import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../l10n/app_strings.dart';
import '../models/guide_step.dart';
import '../models/route_info.dart';
import '../models/tip.dart';
import '../models/user_session.dart';
import '../repositories/subway_repository.dart';

// 앱 전체가 함께 쓰는 상태: 테마·언어·경로별 진행(기기에 기억), 로그인(앱을 끄면 사라짐),
// 경로·단계 목록(서버 자료를 앱이 켜져 있는 동안 보관), 하단 알림.
class AppController extends ChangeNotifier {
  AppController({required this.repository, required SharedPreferences prefs}) : _prefs = prefs {
    _themeMode = _themeFromName(prefs.getString(_themeKey));
    _language = AppLanguage.fromCode(prefs.getString(_languageKey));
  }

  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language';
  static const _progressPrefix = 'progress.';

  final SubwayRepository repository;
  final SharedPreferences _prefs;
  final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  // 팁이 새로 올라가면 1씩 는다. S02가 듣고 그 단계의 팁을 다시 읽는다.
  final ValueNotifier<int> tipsRevision = ValueNotifier<int>(0);
  Tip? lastPostedTip;

  late ThemeMode _themeMode;
  late AppLanguage _language;
  UserSession? _session;
  List<RouteInfo>? _routes;
  final Map<String, List<GuideStep>> _steps = {};
  int _requestSeq = 0;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  AppStrings get strings => AppStrings.of(_language);
  UserSession? get session => _session;
  List<RouteInfo>? get cachedRoutes => _routes;

  // 팁 올리기 요청 번호. 늦게 끝난 앞 요청이 새 요청의 '올리는 중'을 풀지 못하게 비교한다.
  int nextRequestId() => ++_requestSeq;

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (language == _language) return;
    _language = language;
    _prefs.setString(_languageKey, language.code);
    notifyListeners();
  }

  // 경로별 진행: 0부터 단계 수까지. 단계 수와 같으면 완료 화면.
  int progressOf(String routeCode, int stepCount) {
    final saved = _prefs.getInt('$_progressPrefix$routeCode') ?? 0;
    return saved.clamp(0, stepCount);
  }

  void setProgress(String routeCode, int index) {
    if (_prefs.getInt('$_progressPrefix$routeCode') == index) return;
    _prefs.setInt('$_progressPrefix$routeCode', index);
    notifyListeners();
  }

  void resetProgress(String routeCode) => setProgress(routeCode, 0);

  // 로그인·로그아웃마다 세대 번호를 올린다. 앞 세션으로 보낸 요청의 늦은 응답은 세대를 비교해 버린다.
  int get sessionGeneration => _sessionGeneration;
  int _sessionGeneration = 0;

  // 권한 없음(403·401)으로 막은 팁. 화면·탭을 오가도 남고, 다시 로그인하면(새 세션) 풀린다(4차 DEC-10).
  final Set<int> _blockedTips = {};
  bool isTipBlocked(int tipId) => _blockedTips.contains(tipId);

  void blockTip(int tipId) {
    if (_blockedTips.add(tipId)) notifyListeners();
  }

  void signIn(UserSession session) {
    _session = session;
    _sessionGeneration++;
    _blockedTips.clear();
    notifyListeners();
  }

  void signOut() {
    _session = null;
    _sessionGeneration++;
    _blockedTips.clear();
    notifyListeners();
  }

  Future<List<RouteInfo>> loadRoutes({bool force = false}) async {
    if (!force && _routes != null) return _routes!;
    final routes = await repository.fetchRoutes();
    _routes = routes;
    return routes;
  }

  RouteInfo? routeByCode(String code) {
    for (final r in _routes ?? const <RouteInfo>[]) {
      if (r.code == code) return r;
    }
    return null;
  }

  List<GuideStep>? cachedSteps(String routeCode) => _steps[routeCode];

  Future<List<GuideStep>> loadSteps(String routeCode) async {
    final cached = _steps[routeCode];
    if (cached != null) return cached;
    final steps = await repository.fetchSteps(routeCode);
    _steps[routeCode] = steps;
    return steps;
  }

  void tipPosted(Tip tip) {
    lastPostedTip = tip;
    tipsRevision.value++;
  }

  // 하단 알림(SnackBar). 화면을 옮기면 MessageRouteObserver가 닫는다(4차 REG-05).
  void showMessage(String Function(AppStrings s) message) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message(strings)), duration: const Duration(seconds: 3)));
  }

  void hideMessage() => messengerKey.currentState?.hideCurrentSnackBar();

  static ThemeMode _themeFromName(String? name) =>
      ThemeMode.values.firstWhere((m) => m.name == name, orElse: () => ThemeMode.system);

  @override
  void dispose() {
    tipsRevision.dispose();
    super.dispose();
  }
}

// 위젯 트리 어디서나 AppController를 꺼내 쓴다. of()는 바뀔 때 다시 그리고, read()는 다시 그리지 않는다.
class AppScope extends InheritedNotifier<AppController> {
  const AppScope({super.key, required AppController controller, required super.child}) : super(notifier: controller);

  static AppController of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppController read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

extension AppContext on BuildContext {
  AppStrings get strings => AppScope.of(this).strings;
}

// 화면이 바뀌면(쌓기·닫기) 떠 있던 하단 알림을 닫는다. 새 알림은 이동한 뒤에 띄운다.
class MessageRouteObserver extends NavigatorObserver {
  MessageRouteObserver(this.controller);

  final AppController controller;

  bool _isPage(Route<dynamic>? route) => route is PageRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isPage(route)) controller.hideMessage();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_isPage(route)) controller.hideMessage();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => controller.hideMessage();
}
