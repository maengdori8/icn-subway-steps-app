import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/tip.dart';
import '../repositories/subway_repository.dart';
import '../state/app_controller.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

enum TipNotice { toggleFailed, forbidden }

// 팁 상태 바꾸기(S02·S06 공통). 카드마다 '저장 중'을 따로 두고(4차 REG-06),
// 실패는 그 팁 아래 알림으로, 권한 없음은 다시 로그인할 때까지 그 팁의 버튼을 막는다(4차 DEC-10).
// 막힘은 AppController에 두어 화면·탭을 오가도 유지된다.
mixin TipStatusActions<T extends StatefulWidget> on State<T> {
  final Set<int> busyTips = {};
  final Map<int, TipNotice> tipNotices = {};

  // 응답이 왔을 때 그 팁이 아직 이 화면에 보이는지(S02는 단계를 옮겼을 수 있다).
  bool isTipOnScreen(Tip tip);
  void applyUpdatedTip(Tip updated);

  Future<void> toggleTipStatus(Tip tip) async {
    final app = AppScope.read(context);
    final session = app.session;
    if (session == null || busyTips.contains(tip.id) || app.isTipBlocked(tip.id)) return;
    final generation = app.sessionGeneration;
    setState(() {
      busyTips.add(tip.id);
      tipNotices.remove(tip.id);
    });
    try {
      final updated = await app.repository.updateTipStatus(tip.id, tip.status.toggled, session);
      if (!mounted) return;
      setState(() => applyUpdatedTip(updated));
    } on RepositoryException catch (e) {
      // 그사이 다시 로그인했으면 앞 세션의 실패는 버린다(새 로그인 직후 다시 막지 않게).
      if (!mounted || app.sessionGeneration != generation) return;
      final notice = e.code == RepositoryErrorCode.forbidden || e.code == RepositoryErrorCode.unauthorized
          ? TipNotice.forbidden
          : TipNotice.toggleFailed;
      final onScreen = isTipOnScreen(tip);
      if (notice == TipNotice.forbidden) app.blockTip(tip.id);
      if (onScreen) setState(() => tipNotices[tip.id] = notice);
      // 다른 단계로 옮긴 뒤 끝난 실패는 하단 알림으로만 알린다(알림이 다른 단계로 따라가지 않게).
      if (!onScreen) {
        app.showMessage((s) => notice == TipNotice.forbidden ? s.forbidden : s.toggleError);
      }
    } finally {
      if (mounted) setState(() => busyTips.remove(tip.id));
    }
  }

  // 로그인 화면에서 실제로 다시 로그인했을 때만(true) 안내를 지운다. 막힘은 새 세션이 되며 풀린다.
  // 취소·뒤로면 막힘과 안내를 그대로 둔다.
  Future<void> reLogin() async {
    final loggedIn = await Navigator.of(context)
        .push(MaterialPageRoute<bool>(builder: (_) => const LoginScreen(purpose: LoginPurpose.general)));
    if (!mounted || loggedIn != true) return;
    setState(() => tipNotices.removeWhere((_, n) => n == TipNotice.forbidden));
  }

  bool isTipBlocked(Tip tip) => AppScope.of(context).isTipBlocked(tip.id);

  // 권한 없음으로 막힌 팁은 단계·탭을 옮겼다 돌아와도 다시 로그인 안내를 함께 보인다.
  Widget? noticeFor(Tip tip, AppStrings s) {
    final notice = isTipBlocked(tip) ? TipNotice.forbidden : tipNotices[tip.id];
    if (notice == null) return null;
    return notice == TipNotice.forbidden
        ? NoticeBox(kind: NoticeKind.warning, message: s.forbidden, actionLabel: s.loginAgain, onAction: reLogin)
        : NoticeBox(
            kind: NoticeKind.error,
            message: s.toggleError,
            actionLabel: s.retry,
            onAction: () => toggleTipStatus(tip),
          );
  }
}
