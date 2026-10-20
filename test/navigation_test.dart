import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';

import 'helpers.dart';

void main() {
  testWidgets('하단 메뉴는 S01·S06·S05에서만 보이고 S02·S04에서는 숨는다', (tester) async {
    await pumpApp(tester);
    expect(bottomNav, findsOneWidget);
    expect(find.text('Choose a train to Seoul Station.'), findsOneWidget);

    await tester.tap(find.text('My tips'));
    await tester.pumpAndSettle();
    expect(bottomNav, findsOneWidget);
    expect(find.textContaining('Log in to see the tips'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(bottomNav, findsOneWidget);
    expect(find.text('Appearance'.toUpperCase()), findsOneWidget);

    await tester.tap(find.text('Routes'));
    await tester.pumpAndSettle();
    await openRoute(tester, 'Express Train');
    expect(bottomNav, findsNothing, reason: 'S02는 하단 메뉴 대신 이전·다음 고정 바');
    expect(button('Next'), findsOneWidget);

    await tapVisible(tester, find.text('+ Add a tip (log in)'));
    expect(find.text('Log in to add a tip'), findsOneWidget);
    expect(bottomNav, findsNothing, reason: 'S04');
  });

  testWidgets('경로를 고르면 1단계가 열리고 다음·이전으로 넘기며 진행을 기억한다', (tester) async {
    final app = await pumpApp(tester);
    await openRoute(tester, 'Express Train');
    expect(find.text('Walk out of the arrivals hall'), findsOneWidget);
    expect(find.text('Terminal 1 Arrivals'), findsOneWidget);
    expect(tester.widget<FilledButton>(button('Previous')).onPressed, isNull, reason: '첫 단계의 이전은 누를 수 없음');

    await tester.tap(button('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Go down to the Transportation Center'), findsOneWidget);
    expect(find.text('Photo coming soon'), findsWidgets);
    expect(app.progressOf('EXPRESS', 5), 1);

    await tester.tap(button('Previous'));
    await tester.pumpAndSettle();
    expect(find.text('Walk out of the arrivals hall'), findsOneWidget);
    await tester.tap(button('Next'));
    await tester.pumpAndSettle();

    // 뒤로 → S01: 진행 '2/5 이어 보기'와 '처음부터'
    await goBack(tester);
    await tester.pumpAndSettle();
    expect(find.text('2/5'), findsOneWidget);
    expect(find.text('continue'), findsOneWidget);
    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();
    expect(find.text('2/5'), findsNothing);
    expect(app.progressOf('EXPRESS', 5), 0);

    // 다시 열면 이어 보기 위치(처음부터 눌렀으니 1단계)
    await openRoute(tester, 'Express Train');
    expect(find.text('Walk out of the arrivals hall'), findsOneWidget);
  });

  testWidgets("마지막 단계 '승강장에 왔어요' → 완료 화면 → '5단계 다시 보기'", (tester) async {
    await pumpApp(tester, prefs: {'progress.EXPRESS': 4});
    expect(find.text('5/5'), findsOneWidget, reason: 'S01 카드: 5단계부터 이어 보기');
    await openRoute(tester, 'Express Train');
    expect(find.text('Board at the Express platform'), findsOneWidget);
    await tester.tap(button("I'm on the platform"));
    await tester.pumpAndSettle();

    expect(find.text("You're at the platform"), findsOneWidget);
    expect(find.text('Keep your ticket or card until you exit at Seoul Station.'), findsOneWidget);
    expect(button('Step 5 again'), findsOneWidget);
    expect(button('Back to routes'), findsOneWidget);

    await tester.tap(button('Step 5 again'));
    await tester.pumpAndSettle();
    expect(find.text('Board at the Express platform'), findsOneWidget);
    await tester.tap(button("I'm on the platform"));
    await tester.pumpAndSettle();

    await tester.tap(button('Back to routes'));
    await tester.pumpAndSettle();
    expect(find.text('5/5'), findsOneWidget);
    expect(find.text('done'), findsOneWidget);
  });

  testWidgets('사진을 옆으로 밀면 단계가 바뀐다(마지막 단계에서는 완료되지 않음)', (tester) async {
    await pumpApp(tester, prefs: {'progress.LOCAL': 3});
    await openRoute(tester, 'All-stop Train');
    expect(find.text('Tap your card at the gate'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Board at platform 1 or 2'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Board at platform 1 or 2'), findsOneWidget, reason: '밀기로는 완료 화면에 가지 않는다');

    await tester.fling(find.byType(PageView), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Tap your card at the gate'), findsOneWidget);
  });

  testWidgets('전체 단계를 펼쳐 원하는 단계로 바로 간다', (tester) async {
    await pumpApp(tester);
    await openRoute(tester, 'Express Train');
    await tester.tap(find.text('All steps'));
    await tester.pumpAndSettle();
    expect(find.text('Hide steps'), findsOneWidget);
    await tapVisible(tester, find.text('Buy an Express Train ticket'));
    expect(find.text('Hide steps'), findsNothing);
    expect(find.text('Find the Express Train sign.'), findsOneWidget);
  });

  testWidgets("T2는 '준비 중' 안내만 띄우고 S01에 머문다", (tester) async {
    await pumpApp(tester);
    expect(find.text('Coming soon'), findsOneWidget);
    await tapVisible(tester, find.text('T2 → Seoul Station'));
    expect(find.text('T2 directions are coming soon.'), findsNWidgets(2)); // 카드 설명 + 하단 알림
    expect(find.byType(SnackBar), findsOneWidget);
    expect(bottomNav, findsOneWidget);
  });

  testWidgets('시스템 뒤로: S02 → S01, 설정 → 경로 탭', (tester) async {
    await pumpApp(tester);
    await openRoute(tester, 'Express Train');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Choose a train to Seoul Station.'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Choose a train to Seoul Station.'), findsOneWidget);
  });

  testWidgets("S02 단계 제목은 'Step n of N: 제목'으로 읽힌다", (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);
    await openRoute(tester, 'Express Train');
    expect(find.bySemanticsLabel(RegExp(r'^Step 1 of 5: Walk out of the arrivals hall$')), findsOneWidget);
    await tester.tap(button('Next'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'^Step 2 of 5: Go down')), findsOneWidget);
    // S01 카드의 진행도 'Step n of N'으로 읽는다
    await goBack(tester);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('Step 2 of 5, continue')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('S01 상태: 연결 끊김 안내와 다시 시도, 빈 목록', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)
      ..failNext(FakeOperation.routes, RepositoryErrorCode.offline);
    await pumpApp(tester, repository: repo);
    expect(find.text("You're offline"), findsOneWidget);
    expect(find.textContaining("airport's free Wi-Fi"), findsOneWidget);
    await tester.tap(button('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Express Train'), findsOneWidget);
  });

  testWidgets('S01 상태: 빈 목록은 실패와 다른 문구', (tester) async {
    await pumpApp(tester, repository: FakeSubwayRepository(delay: Duration.zero, emptyRoutes: true));
    expect(find.text('No routes yet'), findsOneWidget);
    expect(find.text("You're offline"), findsNothing);
  });

  testWidgets('S01 상태: 불러오는 동안 자리 표시', (tester) async {
    await pumpApp(tester, repository: FakeSubwayRepository(delay: const Duration(milliseconds: 650)));
    // pumpApp의 pumpAndSettle은 타이머를 기다리지 않는다 → 아직 불러오는 중
    expect(find.text('Loading routes…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Express Train'), findsOneWidget);
  });
}
