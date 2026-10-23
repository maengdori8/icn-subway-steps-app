import 'package:flutter/material.dart';

import '../models/route_info.dart';
import '../state/app_controller.dart';
import '../widgets/common.dart';
import '../widgets/floating_tab_bar.dart';
import 'my_tips_screen.dart';
import 'route_list_screen.dart';
import 'settings_screen.dart';
import 'step_guide_screen.dart';

enum HomeTab { routes, myTips, settings }

// 최상위 화면(S01 경로 / S06 내 팁 / S05 설정)과 하단 메뉴. 하단 메뉴는 여기서만 보인다.
// S02·S03·S04는 이 화면 위에 쌓여 하단 메뉴를 가린다(S02는 이전·다음 하단 고정 바가 대신함).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  HomeTab _tab = HomeTab.routes;

  void _select(HomeTab tab) {
    if (tab == _tab) {
      _scrollToTop(); // 지금 탭을 다시 누르면 그 화면을 맨 위로(DS·CR 하단 메뉴 sameTab 규칙)
      return;
    }
    AppScope.read(context).hideMessage();
    setState(() => _tab = tab);
  }

  // 탭 화면(S01·S06·S05)의 본문 스크롤은 컨트롤러를 따로 주지 않아 이 경로의 PrimaryScrollController에 붙는다
  // (세로 스크롤 기본값, Android). 움직임은 S02 단계 이동과 같은 250ms easeOut, 동작 줄이기 설정이면 바로 옮긴다.
  void _scrollToTop() {
    final scroll = PrimaryScrollController.maybeOf(context);
    if (scroll == null) return;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    for (final position in List.of(scroll.positions)) {
      if (position.pixels == 0) continue;
      if (reduceMotion) {
        position.jumpTo(0);
      } else {
        position.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    }
  }

  // S06 '이 단계 보기': 경로 탭으로 바꾼 뒤 S02를 연다. S02에서 뒤로 가면 S01(흐름표).
  Future<void> _openStep(RouteInfo route, int index, bool showOlder) async {
    _select(HomeTab.routes);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StepGuideScreen(route: route, initialIndex: index, showOlderTips: showOlder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final title = switch (_tab) {
      HomeTab.routes => s.app,
      HomeTab.myTips => s.myTipsTitle,
      HomeTab.settings => s.settings,
    };
    return PopScope(
      // 시스템 뒤로: 내 팁·설정에서는 경로 탭으로, 경로 탭에서는 앱을 닫는다.
      canPop: _tab == HomeTab.routes,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(HomeTab.routes);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 메뉴가 보이는 화면에는 뒤로 가기 버튼이 없다
          title: FocusHeading(
            key: ValueKey(_tab),
            autofocus: _tab != HomeTab.routes, // S01은 본문 제목에 초점
            child: Text(title),
          ),
        ),
        body: switch (_tab) {
          HomeTab.routes => const RouteListScreen(),
          HomeTab.myTips => MyTipsScreen(onOpenStep: _openStep),
          HomeTab.settings => const SettingsScreen(),
        },
        // 떠 있는 둥근 캡슐 하단 메뉴(아이콘 + 작은 글자, 2026-10-22 사용자 요청).
        bottomNavigationBar: FloatingTabBar(
          selectedIndex: _tab.index,
          onSelected: (i) => _select(HomeTab.values[i]),
          tabs: [
            FloatingTab(icon: Icons.signpost_outlined, selectedIcon: Icons.signpost, label: s.tabRoutes),
            FloatingTab(icon: Icons.lightbulb_outline, selectedIcon: Icons.lightbulb, label: s.tabMyTips),
            FloatingTab(icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: s.tabSettings),
          ],
        ),
      ),
    );
  }
}
