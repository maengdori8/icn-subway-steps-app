import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';

import 'helpers.dart';

// S02 팁 영역의 상태: 불러오는 중 · 없음 · 못 불러옴 · 바꾸는 중 · 못 바꿈 · 권한 없음
void main() {
  FakeSubwayRepository repo({int ms = 0}) => FakeSubwayRepository(
    delay: Duration(milliseconds: ms),
    now: () => DateTime.utc(2026, 10, 20, 3),
  );

  testWidgets("예시 팁은 'Example' 배지와 작성자 'Sample', 상태 바꾸기 없음", (tester) async {
    await pumpApp(tester, prefs: {'progress.EXPRESS': 2}, session: demoSession);
    await openRoute(tester, 'Express Train');
    await tester.ensureVisible(find.text('Ask at the info center if your card fails'));
    expect(find.text('Example'), findsOneWidget);
    expect(find.text('B1, right of the ticket machines · Sample'), findsOneWidget);
    expect(find.text('Mark as out of date'), findsNothing);
  });

  testWidgets('불러오는 중 → 없음', (tester) async {
    await pumpApp(tester, repository: repo(ms: 600));
    await tester.pump(const Duration(milliseconds: 700)); // 경로
    await tester.tap(find.text('Express Train'));
    // 단계가 먼저 오고(600ms) 팁을 읽기 시작한다. 화면 전환 시간과 관계없이 100ms씩 넘기며 기다린다.
    for (var i = 0; i < 20 && find.text('Loading tips…').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Loading steps…'), findsNothing);
    expect(find.text('Loading tips…'), findsOneWidget);
    expect(find.text('No tips for this step yet.'), findsNothing);
    await tester.pump(const Duration(milliseconds: 700)); // 팁
    await tester.pumpAndSettle();
    expect(find.text('No tips for this step yet.'), findsOneWidget);
  });

  testWidgets('못 불러옴 → 단계 안내는 그대로, 다시 시도', (tester) async {
    final r = repo()..failNext(FakeOperation.tips, RepositoryErrorCode.server);
    await pumpApp(tester, repository: r);
    await openRoute(tester, 'Express Train');
    expect(find.text("Couldn't load tips. The steps above still work."), findsOneWidget);
    expect(find.text('Walk out of the arrivals hall'), findsOneWidget);
    await tapVisible(tester, find.text('Try again'));
    expect(find.text('No tips for this step yet.'), findsOneWidget);
  });

  testWidgets('내 팁 상태 바꾸기: 지난 팁 펼치기 → 저장 중 → 배지만 바뀜', (tester) async {
    await pumpApp(tester, repository: repo(ms: 600), prefs: {'progress.LOCAL': 3}, session: demoSession);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.text('All-stop Train'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Show 1 older tip'));
    expect(find.text('Elevator for big suitcases'), findsOneWidget);
    expect(find.text('Marked out of date by author · 2026-09-30'), findsOneWidget);
    expect(find.text('Left end of the gates · by you'), findsOneWidget);

    await tester.ensureVisible(find.text('Mark as checked'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as checked'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Saving…'), findsOneWidget);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Saving…')).onPressed, isNull);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Checked by author · 2026-10-20'), findsOneWidget);
    expect(find.text('Mark as out of date'), findsOneWidget);
  });

  testWidgets('못 바꿈 → 그 팁 아래 알림과 다시 시도, 단계를 옮기면 알림이 사라진다', (tester) async {
    final r = repo()..failNext(FakeOperation.updateStatus, RepositoryErrorCode.server);
    await pumpApp(tester, repository: r, prefs: {'progress.LOCAL': 3}, session: demoSession);
    await openRoute(tester, 'All-stop Train');
    await tapVisible(tester, find.text('Show 1 older tip'));
    await tapVisible(tester, find.text('Mark as checked'));
    expect(find.text("Couldn't change the status. Try again."), findsOneWidget);
    expect(find.text('Marked out of date by author · 2026-09-30'), findsOneWidget, reason: '상태 유지');

    await tester.tap(button('Next'));
    await tester.pumpAndSettle();
    await tester.tap(button('Previous'));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't change the status. Try again."), findsNothing);

    await tapVisible(tester, find.text('Mark as checked'));
    expect(find.text('Checked by author · 2026-10-20'), findsOneWidget);
  });

  testWidgets('권한 없음 → 다시 로그인 안내, 그 팁의 버튼은 막힘', (tester) async {
    final r = repo()..failNext(FakeOperation.updateStatus, RepositoryErrorCode.forbidden);
    await pumpApp(tester, repository: r, prefs: {'progress.LOCAL': 3}, session: demoSession);
    await openRoute(tester, 'All-stop Train');
    await tapVisible(tester, find.text('Show 1 older tip'));
    await tapVisible(tester, find.text('Mark as checked'));
    const forbidden = "You can't change this tip right now. Log in again, then try.";
    expect(find.text(forbidden), findsOneWidget);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark as checked')).onPressed, isNull);

    // 단계를 옮겼다 돌아와도 막힘과 다시 로그인 안내가 함께 남는다(Codex 지적 2)
    await tester.tap(button('Next'));
    await tester.pumpAndSettle();
    await tester.tap(button('Previous'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Elevator for big suitcases'));
    expect(find.text(forbidden), findsOneWidget);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark as checked')).onPressed, isNull);

    // 다시 로그인 화면에서 취소하면 막힘은 그대로(Codex 지적 3)
    await tapVisible(tester, find.text('Log in again'));
    await tapVisible(tester, button('Cancel'));
    expect(find.text(forbidden), findsOneWidget);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark as checked')).onPressed, isNull);

    await tapVisible(tester, find.text('Log in again'));
    expect(find.text('Log in'), findsWidgets);
    await tester.enterText(find.byType(TextField).at(0), 'student01');
    await tester.enterText(find.byType(TextField).at(1), 'pw');
    await tester.tap(button('Log in'));
    await tester.pumpAndSettle();
    expect(find.text("You can't change this tip right now. Log in again, then try."), findsNothing);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark as checked')).onPressed, isNotNull);
  });

  testWidgets('다른 사람이 올린 팁에는 상태 바꾸기 버튼이 없다', (tester) async {
    final r = repo();
    final traveler = (await tester.runAsync(() => r.login('traveler', 'pw')))!;
    await pumpApp(tester, repository: r, prefs: {'progress.LOCAL': 3}, session: traveler);
    await openRoute(tester, 'All-stop Train');
    await tapVisible(tester, find.text('Show 1 older tip'));
    expect(find.text('Left end of the gates · by a traveler'), findsOneWidget);
    expect(find.text('Mark as checked'), findsNothing);
  });

  testWidgets('다시 로그인한 뒤 도착한 앞 세션의 401은 새 세션을 막지 않는다(Codex 2차 지적 2)', (tester) async {
    final r = repo(ms: 600)..failNext(FakeOperation.updateStatus, RepositoryErrorCode.unauthorized);
    final app = await pumpApp(tester, repository: r, prefs: {'progress.LOCAL': 3}, session: demoSession);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.text('All-stop Train'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Show 1 older tip'));
    await tester.ensureVisible(find.text('Mark as checked'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as checked'));
    await tester.pump(const Duration(milliseconds: 100));
    app.signIn(demoSession); // 요청이 가는 동안 다시 로그인(새 세션)
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(app.isTipBlocked(8), isFalse);
    expect(find.text("You can't change this tip right now. Log in again, then try."), findsNothing);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark as checked')).onPressed, isNotNull);
  });
}
