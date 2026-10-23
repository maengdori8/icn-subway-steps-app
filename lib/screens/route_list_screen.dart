import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/app_strings.dart';
import '../models/route_info.dart';
import '../repositories/subway_repository.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/offline_message.dart';
import 'step_guide_screen.dart';

enum _Phase { loading, ready, failed }

// S01 경로 목록. 로그인 없이 본다. 불러오는 중 / 경로 있음 / 빈 목록 / 연결 끊김 / 원인 모를 실패를 나눠 보인다.
class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  _Phase _phase = _Phase.loading;
  List<RouteInfo> _routes = const [];
  RepositoryException? _error;
  int _request = 0;
  bool _recovering = false; // 연결 끊김에서 시작해 아직 못 읽음: 실패 화면을 AutoRetry로 감싼다

  @override
  void initState() {
    super.initState();
    final cached = AppScope.read(context).cachedRoutes;
    if (cached != null) {
      _routes = cached;
      _phase = _Phase.ready;
    } else {
      _load();
    }
  }

  // 요청 번호로 늦게 온 앞 요청의 결과를 버린다([다시 시도]와 자동 다시 읽기가 겹칠 때).
  Future<void> _load({bool force = false}) async {
    final request = ++_request;
    try {
      final routes = await AppScope.read(context).loadRoutes(force: force);
      if (!mounted || request != _request) return;
      setState(() {
        _routes = routes;
        _phase = _Phase.ready;
        _recovering = false;
      });
    } on RepositoryException catch (e) {
      if (!mounted || request != _request) return;
      setState(() {
        _error = e;
        _phase = _Phase.failed;
        if (e.code == RepositoryErrorCode.offline) _recovering = true;
      });
    }
  }

  void _retry() {
    setState(() => _phase = _Phase.loading);
    _load(force: true);
  }

  Future<void> _open(RouteInfo route) async {
    final app = AppScope.read(context);
    if (!route.available) {
      app.showMessage((s) => _subline(route, s, app.language)); // T2: 안내만 띄우고 S01에 머문다
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StepGuideScreen(route: route, initialIndex: app.progressOf(route.code, route.stepCount)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.strings;
    switch (_phase) {
      case _Phase.loading:
        return ScrollColumn(
          children: [
            Eyebrow(s.tabRoutes),
            const Gap(10),
            FocusHeading(
              child: Text(s.loading, style: TextStyle(color: AppColors.of(context).textSecondary)),
            ),
            SlowConnectionNote(message: s.slowConnection),
            const Gap(AppSpace.section),
            for (var i = 0; i < 3; i++) ...[const SkeletonBox(), const Gap(10)],
          ],
        );
      case _Phase.failed:
        // 연결 끊김이면 그림과 함께 안내한다. 연결 끊김에서 시작했으면 연결되는 대로 저절로 다시 읽는다(AutoRetry).
        final Widget message = _error?.code == RepositoryErrorCode.offline
            ? OfflineMessage(strings: s, onRetry: _retry)
            : StatusMessage(title: s.loadError, actionLabel: s.retry, onAction: _retry);
        return ScrollColumn(
          children: [_recovering ? AutoRetry(onRetry: () => _load(force: true), child: message) : message],
        );
      case _Phase.ready:
        if (_routes.isEmpty) {
          return ScrollColumn(
            children: [StatusMessage(title: s.empty, body: s.emptySub)],
          );
        }
        return _buildList(context, app, s);
    }
  }

  Widget _buildList(BuildContext context, AppController app, AppStrings s) {
    final c = AppColors.of(context);
    final t1 = _routes.where((r) => r.origin == 'T1').toList();
    final others = _routes.where((r) => r.origin != 'T1').toList();
    return ScrollColumn(
      children: [
        // 'From T1 arrivals hall → Seoul Station 서울역'
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.labelMedium,
            children: [
              TextSpan(text: '${s.from.toUpperCase()} → '),
              TextSpan(text: s.seoulStationEn.toUpperCase(), locale: AppLanguage.en.locale),
              const TextSpan(text: ' '),
              TextSpan(text: s.seoulStationKo, locale: AppLanguage.ko.locale),
            ],
          ),
        ),
        const Gap(6),
        FocusHeading(child: Text(s.pickRoute, style: Theme.of(context).textTheme.titleLarge)),
        const Gap(6),
        Text(s.scopeNote, style: TextStyle(color: c.textSecondary)),
        const Gap(AppSpace.section),
        for (final route in t1) ...[
          _RouteCard(route: route, progress: app.progressOf(route.code, route.stepCount), onTap: () => _open(route)),
          if (app.progressOf(route.code, route.stepCount) > 0)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => app.resetProgress(route.code),
                child: Text(s.restart, semanticsLabel: s.restartFor(route.name.of(app.language))),
              ),
            ),
          const Gap(10),
        ],
        if (others.isNotEmpty) ...[
          const Gap(6),
          Eyebrow(s.t2),
          const Gap(10),
          for (final route in others) ...[
            _RouteCard(route: route, progress: 0, onTap: () => _open(route)),
            const Gap(10),
          ],
        ],
      ],
    );
  }
}

// 경로 카드: 왼쪽 경로색 띠, 이름·설명·표지판 병기, 오른쪽 단계 수 또는 진행.
// 색만으로 경로를 구분하지 않고 이름·표지판 글자를 함께 보인다.
// 카드 설명 줄. 준비 중인 T2는 시안 문구('T2 안내는 준비 중입니다'), 나머지는 서버의 summary.
String _subline(RouteInfo route, AppStrings s, AppLanguage lang) =>
    !route.available && route.code == 'T2' ? s.t2msg : route.summary.of(lang);

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route, required this.progress, required this.onTap});

  final RouteInfo route;
  final int progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.strings;
    final lang = app.language;
    final c = AppColors.of(context);
    final n = route.stepCount;
    final done = route.available && progress >= n;
    final started = route.available && progress > 0 && !done;

    Widget? count;
    if (route.available) {
      final (big, small, spoken) = done
          ? ('$n/$n', s.doneLabel, '${s.stepOf(n, n)}, ${s.doneLabel}')
          : started
          ? ('${progress + 1}/$n', s.resume, '${s.stepOf(progress + 1, n)}, ${s.resume}')
          : ('$n', s.steps, s.stepsCount(n));
      count = Semantics(
        label: spoken,
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(big, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1)),
            const SizedBox(height: 4),
            Text(small, style: TextStyle(fontSize: 12, color: c.textSecondary)),
          ],
        ),
      );
    }

    final small = TextStyle(fontSize: 12, color: c.textSecondary);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          color: c.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.card),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 88),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 8,
                      margin: const EdgeInsets.symmetric(vertical: 0),
                      decoration: BoxDecoration(
                        color: c.routeColor(route.code),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(6)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  route.name.of(lang),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
                                ),
                                if (!route.available)
                                  Pill(s.soon, background: c.warningSurface, foreground: c.warningText),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(_subline(route, s, lang), style: TextStyle(fontSize: 14, color: c.textSecondary)),
                            // 표지판 병기: 서버가 주지 않아 앱의 경로별 상수(routeDisplays)로 보인다(시안 .signline).
                            if (route.signKo != null && route.signEn != null)
                              Text.rich(
                                TextSpan(
                                  style: small,
                                  children: [
                                    TextSpan(text: route.signKo, locale: AppLanguage.ko.locale),
                                    const TextSpan(text: ' · '),
                                    TextSpan(text: route.signEn, locale: AppLanguage.en.locale),
                                    const TextSpan(text: ' · '),
                                    TextSpan(text: s.airportRailroadKo, locale: AppLanguage.ko.locale),
                                    const TextSpan(text: ' '),
                                    TextSpan(text: s.airportRailroadEn, locale: AppLanguage.en.locale),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (count != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
                        child: Center(child: count),
                      )
                    else
                      const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
