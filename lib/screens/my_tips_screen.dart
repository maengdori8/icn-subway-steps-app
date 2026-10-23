import 'package:flutter/material.dart';

import '../models/route_info.dart';
import '../models/tip.dart';
import '../repositories/subway_repository.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/offline_message.dart';
import '../widgets/tip_card.dart';
import 'login_screen.dart';
import 'tip_status_actions.dart';

enum _Phase { loading, ready, failed }

typedef OpenStep = Future<void> Function(RouteInfo route, int index, bool showOlder);

// S06 내 팁. 로그인해야 보인다. 내가 올린 팁마다 '이 단계 보기'(그 단계의 S02)와 S02와 같은 상태 바꾸기.
class MyTipsScreen extends StatefulWidget {
  const MyTipsScreen({super.key, required this.onOpenStep});

  final OpenStep onOpenStep;

  @override
  State<MyTipsScreen> createState() => _MyTipsScreenState();
}

class _MyTipsScreenState extends State<MyTipsScreen> with TipStatusActions<MyTipsScreen> {
  _Phase _phase = _Phase.loading;
  List<Tip> _tips = const [];
  RepositoryException? _error;
  int? _loadedFor; // 어느 사용자의 목록인지. 로그인·로그아웃하면 다시 읽는다
  int _request = 0;
  bool _recovering = false; // 연결 끊김에서 시작해 아직 못 읽음: 실패 화면을 AutoRetry로 감싼다

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = AppScope.of(context).session?.userId;
    if (userId != _loadedFor) {
      _loadedFor = userId;
      _phase = _Phase.loading;
      _recovering = false;
      _tips = const [];
      busyTips.clear();
      tipNotices.clear();
      if (userId != null) _load();
    }
  }

  // [quiet]: 보이는 목록을 두고 다시 읽는다(상태 변경 뒤 재조회). 실패하면 보이는 목록을 그대로 둔다.
  Future<void> _load({bool quiet = false}) async {
    final app = AppScope.read(context);
    final session = app.session;
    if (session == null) return;
    final request = ++_request;
    final generation = app.sessionGeneration;
    try {
      await app.loadRoutes(); // 경로 이름·단계 수('직통열차 · 5단계 중 3단계')
      // 서버는 내 것이면 예시 팁도 주지만, 시안처럼 내 팁 목록에서는 뺀다.
      final tips = (await app.repository.fetchMyTips(session)).where((t) => !t.example).toList();
      if (!mounted || request != _request) return;
      setState(() {
        _tips = tips;
        _phase = _Phase.ready;
        _recovering = false;
      });
    } on RepositoryException catch (e) {
      if (!mounted || request != _request) return;
      // 만료·무효 토큰(401)이면 그 세션을 끝낸다. 로그아웃되면 이 화면은 로그인 안내로 바뀐다.
      if (e.code == RepositoryErrorCode.unauthorized && app.sessionExpired(generation)) {
        app.showMessage((s) => s.loggedOut);
        return;
      }
      if (quiet && _phase == _Phase.ready) return;
      setState(() {
        _error = e;
        _phase = _Phase.failed;
        if (e.code == RepositoryErrorCode.offline) _recovering = true;
      });
    }
  }

  void _retry() {
    setState(() => _phase = _Phase.loading);
    _load();
  }

  @override
  bool isTipOnScreen(Tip tip) => _tips.any((t) => t.id == tip.id);

  @override
  void applyUpdatedTip(Tip updated) => _tips = [for (final t in _tips) t.id == updated.id ? updated : t];

  @override
  void reloadTipsQuietly() => _load(quiet: true);

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.strings;
    if (app.session == null) {
      return ScrollColumn(
        children: [
          StatusMessage(
            title: s.myTipsTitle,
            body: s.myTipsLoggedOut,
            actionLabel: s.login,
            focusTitle: false, // 제목 초점은 상단 바 제목
            onAction: () =>
                Navigator.of(context)
                    .push(MaterialPageRoute<bool>(builder: (_) => const LoginScreen(purpose: LoginPurpose.general))),
          ),
        ],
      );
    }
    switch (_phase) {
      case _Phase.loading:
        // 다른 화면처럼 문구 한 줄이 상태를 알린다(S06 명세 규칙). 자리표시는 낭독에서 뺀다. 초점은 상단 바 제목.
        final secondary = TextStyle(color: AppColors.of(context).textSecondary);
        return ScrollColumn(
          children: [
            Semantics(liveRegion: true, child: Text(s.myTipsLoading, style: secondary)),
            SlowConnectionNote(key: ValueKey(_request), message: s.slowConnection, style: secondary),
            const Gap(AppSpace.section),
            for (var i = 0; i < 2; i++) ...[const SkeletonBox(height: 120, radius: 12), const Gap(10)],
          ],
        );
      case _Phase.failed:
        // 연결 끊김이면 그림과 함께 안내한다. 연결 끊김에서 시작했으면 연결되는 대로 저절로 다시 읽는다(AutoRetry).
        final Widget message = _error?.code == RepositoryErrorCode.offline
            ? OfflineMessage(strings: s, focusTitle: false, onRetry: _retry)
            : StatusMessage(title: s.loadError, actionLabel: s.retry, focusTitle: false, onAction: _retry);
        return ScrollColumn(children: [_recovering ? AutoRetry(onRetry: _load, child: message) : message]);
      case _Phase.ready:
        if (_tips.isEmpty) return ScrollColumn(children: [StatusMessage(body: s.myTipsEmpty)]);
        return ScrollColumn(
          children: [
            for (final tip in _tips) ...[_card(app, tip), const Gap(AppSpace.card)],
          ],
        );
    }
  }

  Widget _card(AppController app, Tip tip) {
    final s = app.strings;
    final route = app.routeByCode(tip.route);
    final routeName = route?.name.of(app.language) ?? tip.route;
    final count = route?.stepCount ?? tip.stepNo;
    return TipCard(
      tip: tip,
      strings: s,
      where: s.whereStep(routeName, tip.stepNo, count),
      canToggle: !tip.example,
      busy: busyTips.contains(tip.id),
      toggleBlocked: isTipBlocked(tip),
      onToggle: () => toggleTipStatus(tip),
      notice: noticeFor(tip, s),
      leadingAction: route == null
          ? null
          : TextButton(
              onPressed: () => widget.onOpenStep(route, tip.stepNo - 1, tip.status == TipStatus.outdated),
              child: Text(s.openStep),
            ),
    );
  }
}
