import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import 'common.dart';

// 연결 끊김 안내(S01·S02 단계·S06 전체 화면): 그림 + 'You're offline' + 와이파이 안내 + [다시 시도] + 자동으로 다시 읽는다는 줄.
// 저절로 다시 읽기는 화면이 AutoRetry로 감싸서 한다.
class OfflineMessage extends StatelessWidget {
  const OfflineMessage({super.key, required this.strings, required this.onRetry, this.focusTitle = true});

  final AppStrings strings;
  final VoidCallback onRetry; // [다시 시도]: 불러오는 중 화면으로 바꾸고 다시 읽는다
  final bool focusTitle;

  @override
  Widget build(BuildContext context) => StatusMessage(
    image: const OfflineIllustration(),
    title: strings.offline,
    body: strings.offlineSub,
    actionLabel: strings.retry,
    onAction: onRetry,
    note: strings.offlineAutoRetry,
    focusTitle: focusTitle,
  );
}

// 실패 화면을 연결되면 저절로 다시 읽게 감싼다. [every]마다, 그리고 앱으로 돌아올 때(resumed) 화면을 그대로 둔 채 [onRetry]를
// 부르고, 앞 요청이 끝나기 전에는 다시 부르지 않는다. 성공·[다시 시도]·화면 이탈로 이 위젯이 사라지면 타이머도 멈춘다.
// 화면은 연결 끊김에서 시작한 동안(_recovering) 이 위젯을 두어, 다시 붙는 도중 다른 실패(시간 초과·연결 거부)가 나도 이어 간다.
// 망 상태를 따로 묻지 않고 요청 결과로 판단하므로 INTERNET 말고 다른 권한(ACCESS_NETWORK_STATE 등)이 필요 없다.
class AutoRetry extends StatefulWidget {
  const AutoRetry({super.key, required this.onRetry, required this.child});

  static const every = Duration(seconds: 3);

  final Future<void> Function() onRetry;
  final Widget child;

  @override
  State<AutoRetry> createState() => _AutoRetryState();
}

class _AutoRetryState extends State<AutoRetry> with WidgetsBindingObserver {
  late final Timer _timer;
  bool _busy = false; // 앞 요청이 끝나기 전에는 다시 보내지 않는다

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(AutoRetry.every, (_) => _retryQuietly());
  }

  // 설정에서 비행기 모드를 끄고 앱으로 돌아오면 기다리지 않고 바로 다시 읽는다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _retryQuietly();
  }

  Future<void> _retryQuietly() async {
    if (_busy) return;
    _busy = true;
    try {
      await widget.onRetry();
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// 연결 끊김 그림: 둥근 바탕에 와이파이 끊김 아이콘, 오른쪽 아래에 비행기 모드 표시. 뜻은 제목이 알리므로 낭독에서 뺀다.
// 아이콘으로 그려 두 테마의 색을 따르고 그림 파일(애셋)이 필요 없다.
class OfflineIllustration extends StatelessWidget {
  const OfflineIllustration({super.key});

  static const double size = 112;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: c.surfaceContainer, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.wifi_off_rounded, size: 56, color: c.textSecondary),
            ),
            Positioned(
              right: 0,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: c.warningSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.surface, width: 3),
                ),
                child: Icon(Icons.airplanemode_active_rounded, size: 22, color: c.warningText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
