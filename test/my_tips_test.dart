import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';

import 'helpers.dart';

Future<void> openMyTips(WidgetTester tester) async {
  await tester.tap(find.text('My tips'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('로그인 전에는 안내와 로그인 버튼, 로그인하면 내가 올린 팁', (tester) async {
    await pumpApp(tester);
    await openMyTips(tester);
    expect(find.textContaining('Log in to see the tips'), findsOneWidget);
    await tester.tap(button('Log in'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'student01');
    await tester.enterText(find.byType(TextField).at(1), 'pw');
    await tapVisible(tester, button('Log in'));

    expect(bottomNav, findsOneWidget);
    expect(find.text('Elevator for big suitcases'), findsOneWidget);
    expect(find.text('All-stop Train · Step 4 of 5'), findsOneWidget);
    expect(find.text('Ask at the info center if your card fails'), findsNothing, reason: '예시 팁은 내 팁이 아님');
  });

  testWidgets('올린 팁이 없으면 빈 안내', (tester) async {
    final app = await pumpApp(tester);
    final traveler = (await tester.runAsync(() => app.repository.login('traveler', 'pw')))!;
    app.signIn(traveler);
    await openMyTips(tester);
    expect(find.textContaining("You haven't posted a tip yet."), findsOneWidget);
  });

  testWidgets("'이 단계 보기'는 그 단계의 S02를 열고, 뒤로 가면 S01", (tester) async {
    await pumpApp(tester, session: demoSession);
    await openMyTips(tester);
    await tester.tap(find.text('Open this step'));
    await tester.pumpAndSettle();
    expect(find.text('Tap your card at the gate'), findsOneWidget);
    expect(bottomNav, findsNothing);
    await tester.ensureVisible(find.text('Elevator for big suitcases'));
    expect(find.text('Hide older tips'), findsOneWidget, reason: '오래된 팁이면 펼쳐서 연다');

    await goBack(tester);
    await tester.pumpAndSettle();
    expect(find.text('Choose a train to Seoul Station.'), findsOneWidget);
  });

  testWidgets('내 팁에서 상태 바꾸기', (tester) async {
    await pumpApp(tester, session: demoSession);
    await openMyTips(tester);
    await tester.tap(find.text('Mark as checked'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Checked by author ·'), findsOneWidget);
    expect(find.text('Mark as out of date'), findsOneWidget);
  });

  testWidgets('내 팁에서 상태를 바꾸면 내 팁 목록을 서버에서 다시 읽는다(10장)', (tester) async {
    final r = FakeSubwayRepository(delay: Duration.zero);
    await pumpApp(tester, repository: r, session: demoSession);
    await openMyTips(tester);
    await tester.tap(find.text('Mark as checked'));
    await tester.pumpAndSettle();
    final changed = r.requests.lastIndexOf(FakeOperation.updateStatus);
    expect(changed, isNonNegative);
    expect(r.requests.sublist(changed + 1), contains(FakeOperation.myTips));
    expect(find.textContaining('Checked by author ·'), findsOneWidget);
  });

  testWidgets('로그아웃하면 다시 로그인 안내로', (tester) async {
    final app = await pumpApp(tester, session: demoSession);
    await openMyTips(tester);
    expect(find.text('Elevator for big suitcases'), findsOneWidget);
    app.signOut();
    await tester.pumpAndSettle();
    expect(find.textContaining('Log in to see the tips'), findsOneWidget);
  });

  testWidgets('권한 없음으로 막힌 팁은 탭을 오가도 막혀 있다(Codex 2차 지적 1)', (tester) async {
    final r = FakeSubwayRepository(delay: Duration.zero)
      ..failNext(FakeOperation.updateStatus, RepositoryErrorCode.forbidden);
    await pumpApp(tester, repository: r, session: demoSession);
    await openMyTips(tester);
    await tester.tap(find.text('Mark as checked'));
    await tester.pumpAndSettle();
    const forbidden = 'Only the person who posted this tip can change it. If you logged in with another account, log in again.';
    expect(find.text(forbidden), findsOneWidget);

    await tester.tap(find.text('Routes'));
    await tester.pumpAndSettle();
    await openMyTips(tester);
    expect(find.text(forbidden), findsOneWidget);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark as checked')).onPressed, isNull);
  });
}
