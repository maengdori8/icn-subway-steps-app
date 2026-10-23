import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/l10n/app_language.dart';
import 'package:icn_subway_app/l10n/app_strings.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/http_subway_repository.dart';
import 'package:icn_subway_app/state/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

// 고도화 P04(docs/upgrade-gap.md C-15·S5-01·C-19): 비밀번호 칸 제안·자동고침, S05 버전 문구(P01 결정 6),
// 하단 메뉴 같은 탭 다시 누름 → 맨 위.

// 하단 메뉴의 탭(상단 바 제목과 글자가 같을 수 있어 메뉴 안에서 찾는다).
Finder navTab(String label) => find.descendant(of: bottomNav, matching: find.text(label));

double mainOffset(WidgetTester tester) => tester.state<ScrollableState>(mainScroll).position.pixels;

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(navTab(label));
  await tester.pumpAndSettle();
}

Future<void> scrollBodyDown(WidgetTester tester) async {
  await tester.drag(mainScroll, const Offset(0, -300));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('비밀번호를 보이게 해도 키보드 제안·자동고침은 꺼져 있다(S04, C-15)', (tester) async {
    await pumpApp(tester);
    await openTab(tester, 'My tips');
    await tester.tap(button('Log in'));
    await tester.pumpAndSettle();
    TextField password() => tester.widget<TextField>(find.byType(TextField).at(1));
    expect(password().obscureText, isTrue);
    expect(password().enableSuggestions, isFalse);
    expect(password().autocorrect, isFalse);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(password().obscureText, isFalse);
    expect(password().enableSuggestions, isFalse, reason: '글자를 보여도 제안을 끈다');
    expect(password().autocorrect, isFalse, reason: '글자를 보여도 자동고침을 끈다');
  });

  testWidgets('S05 정보 칸: 학생 실습 프로젝트, 가짜 저장소로 실행하면 시연용 데이터(S5-01)', (tester) async {
    await pumpApp(tester); // 검사는 가짜 저장소
    await openTab(tester, 'Settings');
    expect(find.text('Version 1.0.0 · student project · Demo data'), findsOneWidget);
    expect(find.textContaining('not connected'), findsNothing, reason: '10장 뒤에는 서버에 연결한다');
  });

  test('버전 문구: 서버로 실행하면 시연용 데이터를 붙이지 않는다(S5-01, en·ko)', () {
    expect(AppStrings.of(AppLanguage.en).version(demoData: false), 'Version 1.0.0 · student project');
    expect(AppStrings.of(AppLanguage.ko).version(demoData: false), '버전 1.0.0 · 학생 실습 프로젝트');
    expect(AppStrings.of(AppLanguage.ko).version(demoData: true), '버전 1.0.0 · 학생 실습 프로젝트 · 시연용 데이터');
  });

  test('시연용 데이터 판정: 서버 저장소면 아니고 가짜 저장소면 맞다(S5-01)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    expect(AppController(repository: HttpSubwayRepository(), prefs: prefs).demoData, isFalse);
    expect(AppController(repository: FakeSubwayRepository(), prefs: prefs).demoData, isTrue);
  });

  testWidgets('하단 메뉴에서 지금 탭을 다시 누르면 본문이 맨 위로(S01·S06·S05, C-19)', (tester) async {
    await pumpApp(tester, session: demoSession, size: const Size(390, 480));
    for (final tab in ['Routes', 'My tips', 'Settings']) {
      await openTab(tester, tab);
      await scrollBodyDown(tester);
      expect(mainOffset(tester), greaterThan(0), reason: '$tab 본문을 내림');
      await openTab(tester, tab);
      expect(mainOffset(tester), 0, reason: '$tab 같은 탭을 다시 누름');
    }
  });

  testWidgets('동작 줄이기 설정이면 같은 탭을 다시 누를 때 바로 맨 위(C-19)', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester, size: const Size(390, 480));
    await openTab(tester, 'Settings');
    await scrollBodyDown(tester);
    expect(mainOffset(tester), greaterThan(0));
    await tester.tap(navTab('Settings'));
    await tester.pump(); // 한 프레임만
    expect(mainOffset(tester), 0);
  });
}
