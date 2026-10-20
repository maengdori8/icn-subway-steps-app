import 'package:flutter/material.dart';

import '../models/route_info.dart';
import '../models/tip.dart';
import '../repositories/subway_repository.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = AppScope.of(context).session?.userId;
    if (userId != _loadedFor) {
      _loadedFor = userId;
      _phase = _Phase.loading;
      _tips = const [];
      busyTips.clear();
      tipNotices.clear();
      if (userId != null) _load();
    }
  }

  Future<void> _load() async {
    final app = AppScope.read(context);
    final session = app.session;
    if (session == null) return;
    final request = ++_request;
    try {
      await app.loadRoutes(); // 경로 이름·단계 수('직통열차 · 5단계 중 3단계')
      final tips = await app.repository.fetchMyTips(session);
      if (!mounted || request != _request) return;
      setState(() {
        _tips = tips;
        _phase = _Phase.ready;
      });
    } on RepositoryException catch (e) {
      if (!mounted || request != _request) return;
      setState(() {
        _error = e;
        _phase = _Phase.failed;
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
        return ScrollColumn(
          children: [
            for (var i = 0; i < 2; i++) ...[const SkeletonBox(height: 120, radius: 12), const Gap(10)],
          ],
        );
      case _Phase.failed:
        final offline = _error?.code == RepositoryErrorCode.offline;
        return ScrollColumn(
          children: [
            StatusMessage(
              title: offline ? s.offline : s.loadError,
              body: offline ? s.offlineSub : null,
              actionLabel: s.retry,
              focusTitle: false,
              onAction: _retry,
            ),
          ],
        );
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
      canToggle: true,
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
