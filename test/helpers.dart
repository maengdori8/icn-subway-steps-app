import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/app.dart';
import 'package:icn_subway_app/models/user_session.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/state/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 위젯 검사 공통 준비: 390×844 화면, 가짜 저장소(기본 지연 0), 빈 기기 저장소.
Future<AppController> pumpApp(
  WidgetTester tester, {
  FakeSubwayRepository? repository,
  Map<String, Object> prefs = const {},
  Size size = const Size(390, 844),
  double textScale = 1.0,
  UserSession? session,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final controller = AppController(
    repository: repository ?? FakeSubwayRepository(delay: Duration.zero),
    prefs: sp,
  );
  if (session != null) controller.signIn(session);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(IcnSubwayApp(controller: controller));
  await tester.pumpAndSettle();
  return controller;
}

// 가짜 저장소가 student01에게 주는 세션(번호 101). 예시 팁 2번의 주인이다.
const demoSession = UserSession(userId: 101, username: 'student01', accessToken: 'fake-session-101');

Finder get bottomNav => find.byType(NavigationBar);

// 스크롤해서 보이게 한 뒤 누른다. 입력칸 초점을 먼저 풀어 커서 위치로 되돌아가는 스크롤을 막는다.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> openRoute(WidgetTester tester, String name) async {
  await tapVisible(tester, find.text(name));
}

// 하단 고정 바(또는 본문 끝)의 버튼.
Finder button(String label) => find.widgetWithText(FilledButton, label);

// 화면 본문 스크롤(입력칸·SelectableText 안의 스크롤과 구분).
Finder get mainScroll =>
    find.descendant(of: find.byType(SingleChildScrollView).first, matching: find.byType(Scrollable)).first;

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: mainScroll);
  await tester.pumpAndSettle();
}

// 상단 바의 뒤로 가기(← 아이콘 버튼).
Future<void> goBack(WidgetTester tester) async {
  await tester.tap(find.ancestor(of: find.byType(BackButtonIcon), matching: find.byType(IconButton)));
  await tester.pumpAndSettle();
}
