import 'package:flutter/material.dart';

import '../models/route_info.dart';
import '../state/app_controller.dart';
import '../widgets/common.dart';
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
    if (tab == _tab) return;
    AppScope.read(context).hideMessage();
    setState(() => _tab = tab);
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
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab.index,
          onDestinationSelected: (i) => _select(HomeTab.values[i]),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.signpost_outlined),
              selectedIcon: const Icon(Icons.signpost),
              label: s.tabRoutes,
            ),
            NavigationDestination(
              icon: const Icon(Icons.lightbulb_outline),
              selectedIcon: const Icon(Icons.lightbulb),
              label: s.tabMyTips,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: s.tabSettings,
            ),
          ],
        ),
      ),
    );
  }
}
