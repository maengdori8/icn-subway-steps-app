import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';

import 'helpers.dart';

Finder field(int index) => find.byType(TextField).at(index); // 0 제목, 1 위치, 2 메모

TextField textField(WidgetTester tester, int index) => tester.widget<TextField>(field(index));

Future<void> openAddTip(WidgetTester tester, {String route = 'Express Train'}) async {
  await openRoute(tester, route);
  await tapVisible(tester, find.text('+ Add a tip'));
  expect(find.text('Add a tip'), findsWidgets);
}

void main() {
  FakeSubwayRepository repo({int ms = 0}) => FakeSubwayRepository(delay: Duration(milliseconds: ms));

  testWidgets('로그인하지 않았으면 S04를 거쳐 같은 단계의 S03으로 간다', (tester) async {
    await pumpApp(tester, prefs: {'progress.EXPRESS': 2});
    await openRoute(tester, 'Express Train');
    await tapVisible(tester, find.text('+ Add a tip (log in)'));
    expect(find.text('Log in to add a tip'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'student01');
    await tester.enterText(find.byType(TextField).at(1), 'pw');
    await tester.tap(button('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Express Train · Step 3 of 5 — Buy an Express Train ticket'), findsOneWidget);

    // S03 취소(빈 입력) → S02 같은 단계
    await tester.tap(button('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Buy an Express Train ticket'), findsOneWidget);
    expect(find.text('+ Add a tip'), findsOneWidget, reason: '이제 로그인 상태');
  });

  testWidgets('빈 값: 칸마다 오류, 첫 오류 칸에 초점, 고치기 시작하면 그 칸 오류만 지운다', (tester) async {
    await pumpApp(tester, session: demoSession);
    await openAddTip(tester);
    await tapVisible(tester, button('Post tip'));
    expect(find.text('Enter 1–80 characters.'), findsNWidgets(2));
    expect(textField(tester, 0).focusNode!.hasFocus, isTrue);

    await tester.enterText(field(0), '엘리베이터');
    await tester.pump();
    expect(find.text('Enter 1–80 characters.'), findsOneWidget, reason: '위치 칸 오류는 남음');

    await tester.enterText(field(1), '   ');
    await tester.pump();
    await tapVisible(tester, button('Post tip'));
    expect(find.text('Enter 1–80 characters.'), findsOneWidget, reason: '공백만은 빈 값');
    expect(textField(tester, 0).controller!.text, '엘리베이터', reason: '다른 값 유지');
  });

  testWidgets('제목 80자 통과·81자 거절, 메모 150자 통과·151자 거절(코드 포인트)', (tester) async {
    final r = repo();
    await pumpApp(tester, repository: r, session: demoSession);
    await openAddTip(tester);

    await tester.enterText(field(0), '가' * 81);
    await tester.enterText(field(1), '🚆' * 80);
    await tester.enterText(field(2), 'm' * 151);
    await tester.pump();
    expect(find.text('81/80'), findsOneWidget);
    expect(find.text('80/80'), findsOneWidget, reason: '이모지 80개는 80자');
    expect(find.text('151/150'), findsOneWidget);
    await tapVisible(tester, button('Post tip'));
    expect(find.text('Use 80 characters or fewer.'), findsOneWidget);
    expect(find.text('Use 150 characters or fewer.'), findsOneWidget);
    expect(r.allTips, hasLength(2), reason: '보내지 않음');

    await tester.enterText(field(0), '가' * 80);
    await tester.enterText(field(2), 'm' * 150);
    await tester.pump();
    await tapVisible(tester, button('Post tip'));
    expect(r.allTips, hasLength(3));
    expect(find.text('Tip posted'), findsOneWidget);
  });

  testWidgets('올리는 중: 버튼 막힘·입력칸 읽기 전용·연속 누름 한 번만, 성공하면 S02 같은 단계에 새 팁', (tester) async {
    final r = repo(ms: 600);
    await pumpApp(tester, repository: r, session: demoSession);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.text('Express Train'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('+ Add a tip'));

    await tester.enterText(field(0), 'Wide gate on the left');
    await tester.enterText(field(1), 'Arrival exit B');
    await tester.enterText(field(2), '  ');
    await tester.pump();
    await tester.ensureVisible(button('Post tip'));
    await tester.pumpAndSettle();
    await tester.tap(button('Post tip'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(button('Posting…'), findsOneWidget);
    expect(tester.widget<FilledButton>(button('Posting…')).onPressed, isNull);
    expect(textField(tester, 0).readOnly, isTrue);
    await tester.tap(button('Posting…'));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(r.allTips, hasLength(3), reason: '한 번만 올라감');
    expect(r.allTips.last.note, isNull, reason: '빈 메모는 null');
    expect(find.text('Walk out of the arrivals hall'), findsOneWidget, reason: 'S02 같은 단계');
    expect(find.text('Tip posted'), findsOneWidget);
    expect(find.text('Wide gate on the left'), findsOneWidget);
    expect(find.text('Arrival exit B · by you'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('올리기 실패: 값 유지·안내·다시 시도', (tester) async {
    final r = repo()..failNext(FakeOperation.createTip, RepositoryErrorCode.server);
    await pumpApp(tester, repository: r, session: demoSession);
    await openAddTip(tester);
    await tester.enterText(field(0), 'Title');
    await tester.enterText(field(1), 'Place');
    await tapVisible(tester, button('Post tip'));
    expect(find.text("Couldn't post your tip. What you typed is kept. Try again."), findsOneWidget);
    expect(textField(tester, 0).controller!.text, 'Title');
    expect(textField(tester, 1).controller!.text, 'Place');
    expect(textField(tester, 0).readOnly, isFalse);

    await tapVisible(tester, find.text('Try again'));
    expect(find.text('Tip posted'), findsOneWidget);
    expect(r.allTips.last.title, 'Title');
  });

  testWidgets('작성 중 취소: [계속 쓰기]는 남고 [버리기]는 S02로', (tester) async {
    final r = repo();
    await pumpApp(tester, repository: r, session: demoSession);
    await openAddTip(tester);
    await tester.enterText(field(0), 'Draft');
    await tester.pump();

    await tapVisible(tester, button('Cancel'));
    expect(find.text('Discard this tip?'), findsOneWidget);
    await tester.tap(button('Keep writing'));
    await tester.pumpAndSettle();
    expect(textField(tester, 0).controller!.text, 'Draft');

    await tester.binding.handlePopRoute(); // 시스템 뒤로도 같은 확인
    await tester.pumpAndSettle();
    expect(find.text('Discard this tip?'), findsOneWidget);
    await tester.tap(button('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Walk out of the arrivals hall'), findsOneWidget);
    expect(r.allTips, hasLength(2));
  });

  testWidgets('올리는 중에 나가고 닫히는 동안 응답이 와도 S02는 닫히지 않는다', (tester) async {
    final r = repo(ms: 300);
    await pumpApp(tester, repository: r, session: demoSession);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Express Train'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('+ Add a tip'));
    await tester.enterText(field(0), 'Quick');
    await tester.enterText(field(1), 'Here');
    await tester.ensureVisible(button('Post tip'));
    await tester.pumpAndSettle();
    await tester.tap(button('Post tip'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 250)); // 닫히는 애니메이션 도중 응답 도착
    await tester.pumpAndSettle();
    expect(find.text('Walk out of the arrivals hall'), findsOneWidget);
    expect(find.text('Choose a train to Seoul Station.'), findsNothing);
    expect(r.allTips.last.title, 'Quick');
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('올리는 중에 나갔다가 다시 들어와 올려도 앞 요청이 새 요청의 올리는 중을 풀지 않는다', (tester) async {
    final r = repo(ms: 2000);
    await pumpApp(tester, repository: r, session: demoSession);
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.tap(find.text('Express Train'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 4200));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('+ Add a tip'));

    // 첫 요청
    await tester.enterText(field(0), 'First');
    await tester.enterText(field(1), 'A');
    await tester.ensureVisible(button('Post tip'));
    await tester.pumpAndSettle();
    await tester.tap(button('Post tip'));
    await tester.pump(const Duration(milliseconds: 100));
    // 올리는 중 나가기: 확인 없이 S02로
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard this tip?'), findsNothing);
    expect(find.text('Walk out of the arrivals hall'), findsOneWidget);

    // 다시 들어와 두 번째 요청
    await tapVisible(tester, find.text('+ Add a tip'));
    await tester.enterText(field(0), 'Second');
    await tester.enterText(field(1), 'B');
    await tester.ensureVisible(button('Post tip'));
    await tester.pumpAndSettle();
    await tester.tap(button('Post tip'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(button('Posting…'), findsOneWidget);

    // 첫 요청이 끝나도 두 번째는 계속 올리는 중
    await tester.pump(const Duration(milliseconds: 1500));
    expect(r.allTips.map((t) => t.title), contains('First'));
    expect(button('Posting…'), findsOneWidget);
    expect(textField(tester, 0).controller!.text, 'Second');

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
    expect(r.allTips.map((t) => t.title), containsAll(['First', 'Second']));
    expect(find.text('Walk out of the arrivals hall'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('로그인이 끝나 올리지 못함: 다시 로그인을 취소하면 안내가 남고, 로그인하면 지워진다(값 유지)', (tester) async {
    final r = repo()..failNext(FakeOperation.createTip, RepositoryErrorCode.unauthorized);
    await pumpApp(tester, repository: r, session: demoSession);
    await openAddTip(tester);
    await tester.enterText(field(0), 'Kept title');
    await tester.enterText(field(1), 'Kept place');
    await tapVisible(tester, button('Post tip'));
    const ended = 'Your login has ended. Log in again. What you typed is kept.';
    expect(find.text(ended), findsOneWidget);

    await tapVisible(tester, find.text('Log in again'));
    await tapVisible(tester, button('Cancel'));
    expect(find.text(ended), findsOneWidget);
    expect(textField(tester, 0).controller!.text, 'Kept title');

    await tapVisible(tester, find.text('Log in again'));
    await tester.enterText(find.byType(TextField).at(0), 'student01');
    await tester.enterText(find.byType(TextField).at(1), 'pw');
    await tapVisible(tester, button('Log in'));
    expect(find.text(ended), findsNothing);
    expect(textField(tester, 0).controller!.text, 'Kept title');
    expect(textField(tester, 1).controller!.text, 'Kept place');
  });
}
