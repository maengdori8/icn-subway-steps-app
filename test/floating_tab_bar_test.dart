import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/theme/app_colors.dart';

import 'helpers.dart';

// 2026-10-22 사용자 요청: 상단 바는 밝은 바탕·굵은 본문색 제목, 하단 메뉴는 떠 있는 둥근 캡슐(아이콘 + 작은 글자).
// 2026-10-22 사용자 요청(녹화): 선택 칸이 늘어나며 미끄러지듯 새 탭으로 옮겨 가고, 끌면 손가락을 따라간다.

Finder get pill => find.byKey(const ValueKey('tab-pill'));

Finder navText(String label) => find.descendant(of: bottomNav, matching: find.text(label));

// 탭 하나의 칸(누르는 영역).
Rect tabRect(WidgetTester tester, String label) =>
    tester.getRect(find.ancestor(of: navText(label), matching: find.byType(InkWell)).first);

void main() {
  testWidgets('다른 탭을 누르면 선택 칸이 늘어나며 미끄러져 그 탭 아래로 간다', (tester) async {
    await pumpApp(tester);
    final routes = tabRect(tester, 'Routes');
    final settings = tabRect(tester, 'Settings');
    expect(tester.getRect(pill).center.dx, closeTo(routes.center.dx, 1));

    await tester.tap(navText('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final mid = tester.getRect(pill);
    expect(mid.center.dx, greaterThan(routes.center.dx), reason: '가는 중');
    expect(mid.center.dx, lessThan(settings.center.dx), reason: '아직 도착 전');
    expect(mid.width, greaterThan(routes.width * 1.2), reason: '가는 동안 늘어남');
    expect(
      tester.widget<Icon>(find.descendant(of: bottomNav, matching: find.byIcon(Icons.settings))).icon,
      Icons.settings,
      reason: '아이콘은 고른 순간 채운 모양',
    );

    await tester.pumpAndSettle();
    final end = tester.getRect(pill);
    expect(end.center.dx, closeTo(settings.center.dx, 1));
    expect(end.width, closeTo(settings.width, 1), reason: '도착하면 탭 한 칸 크기로 줄어듦');
  });

  testWidgets('탭을 누를 때 색이 바뀌는 물결·눌림 색이 없다(지금 탭은 선택 칸으로 구분)', (tester) async {
    await pumpApp(tester);
    for (final label in ['Routes', 'My tips', 'Settings']) {
      final ink = tester.widget<InkWell>(find.ancestor(of: navText(label), matching: find.byType(InkWell)).first);
      expect(ink.splashFactory, NoSplash.splashFactory);
      expect(ink.highlightColor, Colors.transparent);
    }
  });

  testWidgets('동작 줄이기 설정이면 선택 칸이 한 프레임에 옮겨 간다', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);
    await tester.tap(navText('Settings'));
    await tester.pump();
    expect(tester.getRect(pill).center.dx, closeTo(tabRect(tester, 'Settings').center.dx, 1));
    await tester.pumpAndSettle();
  });

  testWidgets('캡슐 위를 끌면 선택 칸이 손가락을 따라가고, 놓은 자리의 탭을 고른다', (tester) async {
    await pumpApp(tester);
    final from = tabRect(tester, 'Routes').center;
    final to = tabRect(tester, 'My tips').center;
    final gesture = await tester.startGesture(from);
    await gesture.moveBy(Offset((to.dx - from.dx) / 2, 0));
    await tester.pump();
    await gesture.moveTo(to);
    await tester.pump();
    expect(tester.getRect(pill).center.dx, closeTo(to.dx, 2), reason: '손가락 아래');
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('My tips')), findsNothing, reason: '놓기 전에는 그대로');

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('My tips')), findsOneWidget, reason: '놓은 자리의 탭');
    expect(tester.getRect(pill).center.dx, closeTo(to.dx, 1));
  });

  testWidgets('끌다가 원래 탭에서 놓으면 그대로 두고 칸만 제자리로', (tester) async {
    await pumpApp(tester);
    final routes = tabRect(tester, 'Routes');
    final gesture = await tester.startGesture(routes.center);
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-30, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('ICN Subway Steps')), findsOneWidget);
    expect(tester.getRect(pill).center.dx, closeTo(routes.center.dx, 1));
  });

  testWidgets('하단 메뉴 탭은 이름과 순서를 한 버튼으로 읽고, 선택한 탭만 선택됨', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);
    expect(
      tester.getSemantics(find.descendant(of: bottomNav, matching: find.text('Routes'))),
      isSemantics(label: 'Routes\nTab 1 of 3', isButton: true, hasTapAction: true, isSelected: true),
    );
    expect(
      tester.getSemantics(find.descendant(of: bottomNav, matching: find.text('My tips'))),
      isSemantics(label: 'My tips\nTab 2 of 3', isButton: true, hasTapAction: true, isSelected: false),
    );
    await tester.tap(find.descendant(of: bottomNav, matching: find.text('Settings')));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.descendant(of: bottomNav, matching: find.text('Settings'))),
      isSemantics(label: 'Settings\nTab 3 of 3', isButton: true, hasTapAction: true, isSelected: true),
    );
    semantics.dispose();
  });

  testWidgets('상단 바는 화면 바탕과 같은 밝은 색에 본문색 제목(남색은 표지판 칩에만)', (tester) async {
    await pumpApp(tester);
    final bar = tester.widget<AppBar>(find.byType(AppBar));
    final theme = Theme.of(tester.element(find.byType(AppBar)));
    final c = AppColors.of(tester.element(find.byType(AppBar)));
    expect(bar.backgroundColor ?? theme.appBarTheme.backgroundColor, c.surface);
    expect(theme.appBarTheme.foregroundColor, c.textPrimary);
    expect(theme.appBarTheme.centerTitle, isTrue);
  });
}
