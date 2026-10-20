import '../models/guide_step.dart';
import '../models/route_info.dart';
import '../models/tip.dart';
import '../models/user_session.dart';
import '../validation/tip_rules.dart';
import 'fake_seed.dart';
import 'subway_repository.dart';

// 실패를 흉내 낼 요청 종류.
enum FakeOperation { routes, steps, tips, myTips, createTip, updateStatus, login }

// 서버 없이 화면을 만들기 위한 메모리 저장소. 앱을 다시 시작하면 fake_seed.dart의 처음 자료로 돌아간다.
// 실제 저장·인증이 아니다. 로그인은 아이디 'wrong'만 실패하고 비밀번호는 비어 있지만 않으면 받는다(시안과 같음).
class FakeSubwayRepository implements SubwayRepository {
  FakeSubwayRepository({
    this.delay = const Duration(milliseconds: 650),
    this.emptyRoutes = false,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       _tips = fakeTipsJson.map(Tip.fromJson).toList();

  final Duration delay; // 로딩 표시를 보기 위한 인위적 지연(600~700ms). 실제 응답 속도가 아니다
  final bool emptyRoutes; // 빈 목록 상태를 보기 위한 설정
  final DateTime Function() _now;
  final List<Tip> _tips;
  final Map<FakeOperation, List<RepositoryErrorCode>> _queuedFailures = {};
  final Map<String, int> _userIds = {fakeDemoUsername: fakeDemoUserId};
  int _nextTipId = 1001;

  // 다음 [times]번의 [operation] 요청을 [code]로 실패시킨다. 위젯 검사와 상태 확인용이다.
  void failNext(FakeOperation operation, RepositoryErrorCode code, {int times = 1}) {
    _queuedFailures.putIfAbsent(operation, () => []).addAll(List.filled(times, code));
  }

  List<Tip> get allTips => List.unmodifiable(_tips);

  Future<void> _wait(FakeOperation operation) async {
    await Future<void>.delayed(delay);
    final queue = _queuedFailures[operation];
    if (queue != null && queue.isNotEmpty) {
      throw RepositoryException(queue.removeAt(0), 'simulated ${operation.name} failure');
    }
  }

  String _today() {
    final d = _now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _requireSession(UserSession? session) {
    if (session == null || _userIds[session.username] != session.userId) {
      throw const RepositoryException(RepositoryErrorCode.unauthorized, 'login required');
    }
  }

  @override
  Future<List<RouteInfo>> fetchRoutes() async {
    await _wait(FakeOperation.routes);
    if (emptyRoutes) return const [];
    return List.unmodifiable(fakeRoutesJson.map(RouteInfo.fromJson));
  }

  @override
  Future<List<GuideStep>> fetchSteps(String routeCode) async {
    await _wait(FakeOperation.steps);
    final steps = fakeStepsJson[routeCode];
    if (steps == null) {
      throw RepositoryException(RepositoryErrorCode.notFound, 'no steps for $routeCode');
    }
    return List.unmodifiable(steps.map(GuideStep.fromJson));
  }

  @override
  Future<List<Tip>> fetchTips(String routeCode, int stepNo) async {
    await _wait(FakeOperation.tips);
    return List.unmodifiable(_tips.where((t) => t.route == routeCode && t.stepNo == stepNo));
  }

  @override
  Future<List<Tip>> fetchMyTips(UserSession session) async {
    await _wait(FakeOperation.myTips);
    _requireSession(session);
    return List.unmodifiable(_tips.where((t) => t.ownerId == session.userId && !t.isExample));
  }

  @override
  Future<Tip> createTip(TipDraft draft, UserSession session) async {
    await _wait(FakeOperation.createTip);
    _requireSession(session);
    final errors = validateTip(title: draft.title, location: draft.location, note: draft.note ?? '');
    final steps = fakeStepsJson[draft.route];
    if (!errors.isEmpty || steps == null || draft.stepNo < 1 || draft.stepNo > steps.length) {
      throw const RepositoryException(RepositoryErrorCode.validation, 'invalid tip');
    }
    final note = draft.note?.trim();
    final tip = Tip(
      id: _nextTipId++,
      route: draft.route,
      stepNo: draft.stepNo,
      title: draft.title.trim(),
      location: draft.location.trim(),
      note: note == null || note.isEmpty ? null : note,
      status: TipStatus.verified,
      ownerId: session.userId,
      verifiedAt: _today(),
    );
    _tips.add(tip);
    return tip;
  }

  @override
  Future<Tip> updateTipStatus(int tipId, TipStatus status, UserSession session) async {
    await _wait(FakeOperation.updateStatus);
    _requireSession(session);
    final index = _tips.indexWhere((t) => t.id == tipId);
    if (index < 0) throw RepositoryException(RepositoryErrorCode.notFound, 'tip $tipId');
    final tip = _tips[index];
    if (tip.isExample || tip.ownerId != session.userId) {
      throw const RepositoryException(RepositoryErrorCode.forbidden, 'only the owner can change status');
    }
    final updated = tip.copyWith(status: status, verifiedAt: _today());
    _tips[index] = updated;
    return updated;
  }

  @override
  Future<UserSession> login(String username, String password) async {
    await _wait(FakeOperation.login);
    final name = username.trim();
    if (name.isEmpty || password.isEmpty || name.toLowerCase() == 'wrong') {
      throw const RepositoryException(RepositoryErrorCode.invalidCredentials);
    }
    final id = _userIds.putIfAbsent(name, () => fakeDemoUserId + _userIds.length);
    return UserSession(userId: id, username: name, accessToken: 'fake-session-$id');
  }
}
