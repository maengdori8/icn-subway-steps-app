import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../l10n/app_strings.dart';
import '../models/guide_step.dart';
import '../models/route_info.dart';
import '../models/tip.dart';
import '../repositories/subway_repository.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/mixed_text.dart';
import '../widgets/step_widgets.dart';
import '../widgets/tip_card.dart';
import 'add_tip_screen.dart';
import 'login_screen.dart';
import 'tip_status_actions.dart';

enum _TipsPhase { loading, ready, failed }

// S02 단계 안내. 진행 표시 → 4:3 사진(가로로 밀어 단계 이동) → 역할 라벨·표지판 칩 → 제목 → 안내 2줄
// → 엘리베이터 줄 → 팁 영역. 이전·다음은 하단 고정(글자 2배 이상이면 본문 끝으로).
// [initialIndex]가 단계 수와 같으면 완료 화면으로 열린다.
class StepGuideScreen extends StatefulWidget {
  const StepGuideScreen({super.key, required this.route, required this.initialIndex, this.showOlderTips = false});

  final RouteInfo route;
  final int initialIndex;
  final bool showOlderTips;

  @override
  State<StepGuideScreen> createState() => _StepGuideScreenState();
}

class _StepGuideScreenState extends State<StepGuideScreen> with TipStatusActions<StepGuideScreen> {
  late final AppController _app;
  List<GuideStep>? _steps;
  RepositoryException? _stepsError;
  int _index = 0;
  PageController? _pages;
  bool _pageAnimating = false;
  bool _showAll = false;
  late bool _showOlder = widget.showOlderTips;

  _TipsPhase _tipsPhase = _TipsPhase.loading;
  List<Tip> _tips = const [];
  int _tipsRequest = 0;
  int? _freshTipId;
  Timer? _freshTimer;
  final Map<int, GlobalKey> _tipKeys = {};

  String get _code => widget.route.code;
  int get _count => _steps?.length ?? widget.route.stepCount;
  bool get _done => _steps != null && _index >= _steps!.length;
  GuideStep? get _step => (_steps == null || _done) ? null : _steps![_index];

  @override
  void initState() {
    super.initState();
    _app = AppScope.read(context);
    _app.tipsRevision.addListener(_onTipPosted);
    _loadSteps();
  }

  @override
  void dispose() {
    _app.tipsRevision.removeListener(_onTipPosted);
    _pages?.dispose();
    _freshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSteps() async {
    try {
      final steps = await _app.loadSteps(_code);
      if (!mounted) return;
      setState(() {
        _steps = steps;
        _stepsError = null;
        _index = widget.initialIndex.clamp(0, steps.length);
        _pages = _newPageController(_index);
      });
      _loadTips();
    } on RepositoryException catch (e) {
      if (!mounted) return;
      setState(() => _stepsError = e);
    }
  }

  PageController _newPageController(int index) =>
      PageController(initialPage: index.clamp(0, (_steps?.length ?? 1) - 1), keepPage: false);

  Future<void> _loadTips() async {
    final step = _step;
    if (step == null) return;
    final request = ++_tipsRequest;
    setState(() => _tipsPhase = _TipsPhase.loading);
    try {
      final tips = await _app.repository.fetchTips(_code, step.stepNo);
      if (!mounted || request != _tipsRequest) return; // 그사이 단계를 옮겼으면 버린다
      setState(() {
        _tips = tips;
        _tipsPhase = _TipsPhase.ready;
      });
      _revealFreshTip();
    } on RepositoryException {
      if (!mounted || request != _tipsRequest) return;
      setState(() => _tipsPhase = _TipsPhase.failed);
    }
  }

  // 팁이 올라감(S03이 떠난 뒤 끝난 경우 포함). 지금 보고 있는 단계의 팁이면 목록에 넣고 강조한다.
  void _onTipPosted() {
    final tip = _app.lastPostedTip;
    final step = _step;
    if (!mounted || tip == null || step == null || tip.route != _code || tip.stepNo != step.stepNo) return;
    if (_tipsPhase != _TipsPhase.ready) {
      _freshTipId = tip.id;
      _loadTips();
      return;
    }
    setState(() {
      if (!_tips.any((t) => t.id == tip.id)) _tips = [..._tips, tip];
      _freshTipId = tip.id;
    });
    _revealFreshTip();
  }

  void _revealFreshTip() {
    final id = _freshTipId;
    if (id == null) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final ctx = _tipKeys[id]?.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(ctx, alignment: 0.5, duration: const Duration(milliseconds: 300));
      }
    });
    _freshTimer?.cancel();
    _freshTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _freshTipId = null);
    });
  }

  // 단계 이동(버튼·전체 단계 목록·사진 밀기 공통). 진행을 기억하고 그 단계의 팁을 읽는다.
  // 알림과 강조는 단계에 묶여 있으므로 옮기면 지운다(4차 DEC-02).
  void _goTo(int target, {bool fromSwipe = false}) {
    final steps = _steps;
    if (steps == null) return;
    final next = target.clamp(0, steps.length);
    if (next == _index) return;
    final wasDone = _done;
    setState(() {
      _index = next;
      tipNotices.clear();
      _freshTipId = null;
      _tips = const [];
      if (wasDone && next < steps.length) {
        _pages?.dispose();
        _pages = _newPageController(next);
      }
    });
    _app.setProgress(_code, next);
    if (!fromSwipe && !wasDone && next < steps.length) _syncPage(next);
    _loadTips();
  }

  Future<void> _syncPage(int page) async {
    final pages = _pages;
    if (pages == null || !pages.hasClients) return;
    if (MediaQuery.of(context).disableAnimations || (pages.page ?? 0).round() == page) {
      pages.jumpToPage(page);
      return;
    }
    _pageAnimating = true;
    await pages.animateToPage(page, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    _pageAnimating = false;
  }

  void _onPageChanged(int page) {
    if (_pageAnimating) return; // 버튼으로 옮기는 중에 지나가는 페이지는 무시
    _goTo(page, fromSwipe: true);
  }

  Future<void> _addTip() async {
    final step = _step;
    if (step == null) return;
    final nav = Navigator.of(context);
    if (_app.session != null) {
      await nav.push(
        MaterialPageRoute<void>(
          builder: (_) => AddTipScreen(route: widget.route, step: step, stepCount: _count),
        ),
      );
    } else {
      // 로그인하면 S04가 S03으로 바뀌고, S03이 끝나면 이 단계로 돌아온다.
      await nav.push(
        MaterialPageRoute<void>(
          builder: (_) => LoginScreen(purpose: LoginPurpose.addTip, route: widget.route, step: step, stepCount: _count),
        ),
      );
    }
  }

  @override
  bool isTipOnScreen(Tip tip) => !_done && _step?.stepNo == tip.stepNo && tip.route == _code;

  @override
  void applyUpdatedTip(Tip updated) {
    _tips = [for (final t in _tips) t.id == updated.id ? updated : t];
    if (updated.status == TipStatus.outdated) _showOlder = true; // 바꾼 카드가 접힌 목록으로 사라지지 않게
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.strings;
    final c = AppColors.of(context);
    final routeColor = c.routeColor(_code);
    final steps = _steps;
    final inlineNav = MediaQuery.textScalerOf(context).scale(16) / 16 >= 2.0;

    Widget body;
    if (steps == null) {
      body = _stepsError == null
          ? ScrollColumn(
              children: [
                FocusHeading(
                  child: Text(s.loadingSteps, style: TextStyle(color: c.textSecondary)),
                ),
                const Gap(AppSpace.section),
                const AspectRatio(aspectRatio: 4 / 3, child: SkeletonBox()),
              ],
            )
          : ScrollColumn(
              children: [
                StatusMessage(
                  title: _stepsError!.code == RepositoryErrorCode.offline ? s.offline : s.loadError,
                  body: _stepsError!.code == RepositoryErrorCode.offline ? s.offlineSub : null,
                  actionLabel: s.retry,
                  onAction: () {
                    setState(() => _stepsError = null);
                    _loadSteps();
                  },
                ),
              ],
            );
    } else {
      body = ScrollColumn(
        children: [
          ..._done ? _doneContent(s, c, routeColor) : _stepContent(app, s, c, routeColor),
          if (inlineNav) ...[const Gap(AppSpace.section), _navButtons(s, routeColor)],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: s.backRoutes,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.route.name.of(app.language)),
      ),
      body: body,
      bottomNavigationBar: steps == null || inlineNav
          ? null
          : Container(
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(top: BorderSide(color: c.divider)),
              ),
              padding: const EdgeInsets.fromLTRB(AppSpace.page, 10, AppSpace.page, 14),
              child: SafeArea(top: false, child: _navButtons(s, routeColor)),
            ),
    );
  }

  List<Widget> _doneContent(AppStrings s, AppColors c, Color routeColor) => [
    StepProgress(index: _count, count: _count, color: routeColor, strings: s),
    const Gap(AppSpace.section),
    FocusHeading(child: Text(s.doneTitle, style: Theme.of(context).textTheme.headlineSmall)),
    const Gap(10),
    Text(s.doneSub, style: TextStyle(color: c.textPrimary)),
  ];

  List<Widget> _stepContent(AppController app, AppStrings s, AppColors c, Color routeColor) {
    final steps = _steps!;
    final step = steps[_index];
    final lang = app.language;
    return [
      StepProgress(
        index: _index,
        count: steps.length,
        color: routeColor,
        strings: s,
        trailing: Semantics(
          expanded: _showAll,
          child: TextButton(
            onPressed: () => setState(() => _showAll = !_showAll),
            child: Text(_showAll ? s.hideSteps : s.allSteps),
          ),
        ),
      ),
      if (_showAll) ...[
        const Gap(6),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _StepListItem(
              number: i + 1,
              title: steps[i].title.of(lang),
              current: i == _index,
              color: routeColor,
              semanticsLabel: '${s.stepOf(i + 1, steps.length)}: ${steps[i].title.of(lang)}',
              onTap: () {
                setState(() => _showAll = false);
                _goTo(i);
              },
            ),
          ),
      ],
      const Gap(AppSpace.section),
      // 사진: 스크롤 안에서 4:3 고정(줄어들지 않음). 가로로 밀면 단계 이동, 마지막 단계에서 밀어도 완료되지 않는다.
      AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: PageView.builder(
            controller: _pages,
            itemCount: steps.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, i) => StepPhoto(step: steps[i], language: lang, strings: s),
          ),
        ),
      ),
      const Gap(6),
      if (step.photoUrl == null)
        Text(s.noPhotoSub, style: TextStyle(fontSize: 14, color: c.textSecondary))
      else if (step.photoCredit != null)
        MixedText(
          step.photoCredit!,
          language: lang,
          style: TextStyle(fontSize: 12, color: c.textSecondary),
        ),
      const Gap(AppSpace.section),
      SignChip(step: step, strings: s),
      const Gap(AppSpace.section),
      // 단계 제목: 'Step 3 of 5: …'로 읽고, 단계가 바뀌면 다시 읽는다(live region).
      FocusHeading(
        key: const ValueKey('step-title'), // 전체 단계를 펼치고 접어도 같은 제목으로 남아 초점을 다시 걸지 않는다
        liveRegion: true,
        semanticsLabel: '${s.stepOf(step.stepNo, steps.length)}: ${step.title.of(lang)}',
        child: Text(step.title.of(lang), style: Theme.of(context).textTheme.titleLarge),
      ),
      const Gap(10),
      StepActions(lines: step.actions.of(lang), color: routeColor, language: lang),
      const Gap(4),
      Row(
        children: [
          ExcludeSemantics(child: Icon(Icons.elevator_outlined, size: 18, color: c.textSecondary)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(s.elevator, style: TextStyle(fontSize: 14, color: c.textSecondary)),
          ),
        ],
      ),
      const Gap(AppSpace.section),
      _tipsSection(app, s, c),
    ];
  }

  Widget _tipsSection(AppController app, AppStrings s, AppColors c) {
    final session = app.session;
    final current = _tips.where((t) => t.status == TipStatus.verified).toList();
    final older = _tips.where((t) => t.status == TipStatus.outdated).toList();

    Widget card(Tip tip) {
      final mine = session != null && !tip.isExample && tip.ownerId == session.userId;
      final author = tip.isExample ? s.bySample : (mine ? s.byYou : s.byTraveler);
      return Padding(
        key: _tipKeys.putIfAbsent(tip.id, GlobalKey.new),
        padding: const EdgeInsets.only(bottom: 10),
        child: TipCard(
          tip: tip,
          strings: s,
          author: author,
          fresh: _freshTipId == tip.id,
          canToggle: mine,
          busy: busyTips.contains(tip.id),
          toggleBlocked: isTipBlocked(tip),
          onToggle: () => toggleTipStatus(tip),
          notice: noticeFor(tip, s),
        ),
      );
    }

    final content = switch (_tipsPhase) {
      _TipsPhase.loading => <Widget>[
        Semantics(
          liveRegion: true,
          child: Text(s.tipsLoading, style: TextStyle(fontSize: 12, color: c.textSecondary)),
        ),
        const Gap(8),
        const SkeletonBox(height: 56, radius: 12),
      ],
      _TipsPhase.failed => <Widget>[
        NoticeBox(kind: NoticeKind.error, message: s.tipsError, actionLabel: s.retry, onAction: _loadTips),
      ],
      _TipsPhase.ready => <Widget>[
        if (_tips.isEmpty) Text(s.tipsEmpty, style: TextStyle(fontSize: 14, color: c.textSecondary)),
        ...current.map(card),
        if (older.isNotEmpty) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Semantics(
              expanded: _showOlder,
              child: TextButton(
                onPressed: () => setState(() => _showOlder = !_showOlder),
                child: Text(_showOlder ? s.hideOld : s.showOld(older.length)),
              ),
            ),
          ),
          if (_showOlder) ...older.map(card),
        ],
      ],
    };

    return Container(
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 글자를 키워 한 줄에 안 들어가면 '+ 팁 등록'이 다음 줄로 내려간다.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Semantics(header: true, child: Text(s.tipsTitle, style: Theme.of(context).textTheme.titleMedium)),
              TextButton(onPressed: _addTip, child: Text(session != null ? s.addTip : s.addTipNeedsLogin)),
            ],
          ),
          const Gap(4),
          ...content,
        ],
      ),
    );
  }

  Widget _navButtons(AppStrings s, Color routeColor) {
    final c = AppColors.of(context);
    final n = _count;
    if (_done) {
      // 완료: '경로 목록으로'(보조) · 'n단계 다시 보기'(주요, '다음'과 같은 자리)
      return Row(
        children: [
          Expanded(
            child: FilledButton(
              style: ghostButtonStyle(c),
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(s.toList, textAlign: TextAlign.center),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RouteButton(
              color: routeColor,
              onPressed: () => _goTo(n - 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ExcludeSemantics(child: Icon(Icons.arrow_back, size: 18)),
                  const SizedBox(width: 6),
                  Flexible(child: Text(s.reviewLast(n), textAlign: TextAlign.center)),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          flex: 10,
          child: FilledButton(
            style: ghostButtonStyle(c),
            onPressed: _index == 0 ? null : () => _goTo(_index - 1),
            child: Text(s.prev, textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 14,
          child: RouteButton(
            color: routeColor,
            onPressed: () => _goTo(_index + 1),
            child: Text(_index == n - 1 ? s.arrived : s.next, textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}

class _StepListItem extends StatelessWidget {
  const _StepListItem({
    required this.number,
    required this.title,
    required this.current,
    required this.color,
    required this.semanticsLabel,
    required this.onTap,
  });

  final int number;
  final String title;
  final bool current;
  final Color color;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      button: true,
      selected: current,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: c.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: current ? BorderSide(color: color, width: 2) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minimumTap),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text('$number', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 14, fontWeight: current ? FontWeight.w700 : FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
