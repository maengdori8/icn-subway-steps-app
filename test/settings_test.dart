import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

Future<void> openSettings(WidgetTester tester, {String label = 'Settings'}) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('테마: 시스템이 기본, 어둡게를 고르면 바로 바뀌고 기억한다', (tester) async {
    final app = await pumpApp(tester);
    expect(app.themeMode, ThemeMode.system);
    await openSettings(tester);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
    expect(Theme.of(tester.element(find.text('Appearance'.toUpperCase()))).brightness, Brightness.dark);
    expect((await SharedPreferences.getInstance()).getString('theme_mode'), 'dark');

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(Theme.of(tester.element(find.text('Appearance'.toUpperCase()))).brightness, Brightness.light);
  });

  testWidgets('저장한 테마·언어로 시작한다', (tester) async {
    await pumpApp(tester, prefs: {'theme_mode': 'dark', 'language': 'ko'});
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
    expect(find.text('서울역행 열차를 고르세요.'), findsOneWidget);
    expect(find.text('직통열차'), findsWidgets);
  });

  testWidgets('언어: 한국어를 고르면 문구가 바뀌고 표지판 병기는 그대로', (tester) async {
    await pumpApp(tester, prefs: {'progress.EXPRESS': 2});
    await openSettings(tester);
    await tester.tap(find.textContaining('한국어'));
    await tester.pumpAndSettle();
    expect(find.text('설정'), findsWidgets);
    expect(find.text('경로'), findsOneWidget);
    expect(find.text('내 팁'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('language'), 'ko');

    await tester.tap(find.text('경로'));
    await tester.pumpAndSettle();
    await openRoute(tester, '직통열차');
    expect(find.text('직통열차 승차권 사기'), findsOneWidget);
    expect(find.text('Express Train'), findsOneWidget, reason: '표지판 칩은 두 언어 병기');
    expect(button('다음'), findsOneWidget);
  });

  testWidgets('계정: 로그인한 아이디를 보이고 로그아웃할 수 있다', (tester) async {
    final app = await pumpApp(tester, session: demoSession);
    await openSettings(tester);
    expect(find.text('Logged in as student01'), findsOneWidget);
    await tapVisible(tester, find.text('Log out'));
    expect(app.session, isNull);
    expect(find.text('Logged out'), findsOneWidget);
    expect(find.text('Not logged in. You only need an account to add tips.'), findsOneWidget);
  });

  testWidgets('사진 출처: 표시 문구와 라이선스·원본 주소', (tester) async {
    await pumpApp(tester);
    await openSettings(tester);
    await scrollTo(tester, find.textContaining('Station-Gates.JPG'));
    expect(find.textContaining('인천국제공항공사'), findsOneWidget);
    expect(find.textContaining('MNXANL / Wikimedia Commons'), findsOneWidget);
    expect(find.text('https://creativecommons.org/licenses/by-sa/4.0/'), findsOneWidget);
    expect(find.textContaining('commons.wikimedia.org/wiki/File:202403_AREX'), findsNWidgets(3));
    // 2026-10-22에 채운 사진 2장: 교통센터(CC BY-SA 4.0), 2007년 일반열차 개찰구(CC BY 2.5)
    expect(find.textContaining('Minseong Kim / Wikimedia Commons'), findsOneWidget);
    expect(find.textContaining('All-stop gate (2007): Kanchi1979 / Wikimedia Commons'), findsOneWidget);
    expect(find.text('https://creativecommons.org/licenses/by/2.5/'), findsOneWidget);
    // 같은 날 더 채운 직통열차 2장: 개찰구(2015, 잘라냄, CC BY-SA 4.0), 승강장(2015, CC BY-SA 2.0)
    expect(find.textContaining('Express gate (2015, cropped): Asacyan / Wikimedia Commons'), findsOneWidget);
    expect(find.textContaining('Express platform (2015): Wei-Te Wong / Wikimedia Commons'), findsOneWidget);
    expect(find.text('https://creativecommons.org/licenses/by-sa/2.0/'), findsOneWidget);
    expect(find.textContaining('commons.wikimedia.org/wiki/File:'), findsNWidgets(7));
  });
}
