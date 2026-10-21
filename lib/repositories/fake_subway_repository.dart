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
    this.delayOverrides = const {},
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       _tips = Tip.listFromJson(fakeTipsResponse);

  final Duration delay; // 로딩 표시를 보기 위한 인위적 지연(600~700ms). 실제 응답 속도가 아니다
  final bool emptyRoutes; // 빈 목록 상태를 보기 위한 설정
  final Map<FakeOperation, Duration> delayOverrides; // 요청 종류별 지연(응답 순서를 바꿔 보는 검사용)
  final DateTime Function() _now;
  final List<Tip> _tips;
  final Map<FakeOperation, List<RepositoryErrorCode>> _queuedFailures = {};
  final Map<String, int> _userIds = {fakeDemoUsername: fakeDemoUserId, 'student02': fakeSampleOwnerId};
  int _nextTipId = 9; // 서버 시드(7·8번) 다음 번호

  // 다음 [times]번의 [operation] 요청을 [code]로 실패시킨다. 위젯 검사와 상태 확인용이다.
  void failNext(FakeOperation operation, RepositoryErrorCode code, {int times = 1}) {
    _queuedFailures.putIfAbsent(operation, () => []).addAll(List.filled(times, code));
  }

  List<Tip> get allTips => List.unmodifiable(_tips);

  Future<void> _wait(FakeOperation operation) async {
    await Future<void>.delayed(delayOverrides[operation] ?? delay);
    final queue = _queuedFailures[operation];
    if (queue != null && queue.isNotEmpty) {
      throw RepositoryException(queue.removeAt(0), 'simulated ${operation.name} failure');
    }
  }

  DateTime _nowUtc() => _now().toUtc();

  void _requireSession(UserSession? session) {
    if (session == null || _userIds[session.username] != session.userId) {
      throw const RepositoryException(RepositoryErrorCode.unauthorized, 'login required');
    }
  }

  // 서버처럼 mine은 요청한 사용자의 팁인지로 정하고, 목록은 번호 내림차순(새 팁 먼저)으로 준다.
  List<Tip> _view(Iterable<Tip> tips, UserSession? session) {
    final list = [
      for (final t in tips) Tip.fromJson({...t.toJson(), 'mine': session != null && t.ownerId == session.userId}),
    ]..sort((a, b) => b.id.compareTo(a.id));
    return List.unmodifiable(list);
  }

  @override
  Future<List<RouteInfo>> fetchRoutes() async {
    await _wait(FakeOperation.routes);
    if (emptyRoutes) return const [];
    return List.unmodifiable(RouteInfo.listFromJson(fakeRoutesResponse));
  }

  @override
  Future<List<GuideStep>> fetchSteps(String routeCode) async {
    await _wait(FakeOperation.steps);
    final response = fakeStepsResponses[routeCode];
    if (response == null) {
      throw RepositoryException(RepositoryErrorCode.notFound, 'no route $routeCode');
    }
    return List.unmodifiable(GuideStep.listFromJson(response));
  }

  @override
  Future<List<Tip>> fetchTips(String routeCode, int stepNo, {UserSession? session}) async {
    await _wait(FakeOperation.tips);
    return _view(_tips.where((t) => t.route == routeCode && t.stepNo == stepNo), session);
  }

  // 서버 GET /api/me/tips와 같이 내 것이면 예시 팁도 준다(화면에서 거른다).
  @override
  Future<List<Tip>> fetchMyTips(UserSession session) async {
    await _wait(FakeOperation.myTips);
    _requireSession(session);
    return _view(_tips.where((t) => t.ownerId == session.userId), session);
  }

  @override
  Future<Tip> createTip(TipDraft draft, UserSession session) async {
    await _wait(FakeOperation.createTip);
    _requireSession(session);
    final errors = validateTip(title: draft.title, location: draft.location, note: draft.note ?? '');
    final steps = fakeStepsResponses[draft.route]?['steps'] as List?;
    if (!errors.isEmpty || steps == null || draft.stepNo < 1 || draft.stepNo > steps.length) {
      throw const RepositoryException(RepositoryErrorCode.validation, 'invalid tip');
    }
    final note = draft.note?.trim();
    final now = _nowUtc();
    final tip = Tip(
      id: _nextTipId++,
      route: draft.route,
      stepNo: draft.stepNo,
      title: draft.title.trim(),
      location: draft.location.trim(),
      note: note == null || note.isEmpty ? null : note,
      status: TipStatus.verified,
      verifiedAt: now,
      createdAt: now,
      ownerId: session.userId,
      mine: true,
    );
    _tips.add(tip);
    return tip;
  }

  // 서버와 같이 올린 사람만 바꾼다(예시 팁도 올린 사람은 바꿀 수 있고, 화면이 버튼을 숨긴다).
  @override
  Future<Tip> updateTipStatus(int tipId, TipStatus status, UserSession session) async {
    await _wait(FakeOperation.updateStatus);
    _requireSession(session);
    final index = _tips.indexWhere((t) => t.id == tipId);
    if (index < 0) throw RepositoryException(RepositoryErrorCode.notFound, 'tip $tipId');
    final tip = _tips[index];
    if (tip.ownerId != session.userId) {
      throw const RepositoryException(RepositoryErrorCode.forbidden, 'only the owner can change status');
    }
    _tips[index] = tip.copyWith(status: status, verifiedAt: _nowUtc());
    return _view([_tips[index]], session).single;
  }

  @override
  Future<UserSession> login(String username, String password) async {
    await _wait(FakeOperation.login);
    final name = username.trim();
    if (name.isEmpty || password.isEmpty || name.toLowerCase() == 'wrong') {
      throw const RepositoryException(RepositoryErrorCode.invalidCredentials);
    }
    final id = _userIds.putIfAbsent(name, () => fakeDemoUserId + _userIds.length);
    // 서버 로그인 응답과 같은 모양을 읽는다(토큰은 의미 없는 표시 값).
    return UserSession.fromLoginJson({
      'accessToken': 'fake-session-$id',
      'tokenType': 'Bearer',
      'expiresIn': 1800,
      'user': {'id': id, 'username': name},
    });
  }
}
