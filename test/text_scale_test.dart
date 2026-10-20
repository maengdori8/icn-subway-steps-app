import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';

import 'helpers.dart';

// 390×844, 글자 1.3·2.0배, 밝게·어둡게에서 모든 화면을 연다. 넘침(RenderFlex overflow)이 나면 검사가 실패한다.
// 글자 확대를 막거나 오류를 숨겨서 통과시키지 않는다.
void main() {
  for (final scale in [1.3, 2.0]) {
    for (final dark in [false, true]) {
      final label = '글자 $scale배 ${dark ? '어둡게' : '밝게'}';

      testWidgets('$label: S01 → S02(사진·팁·완료) → S03(오류) → S04(실패)', (tester) async {
        await pumpApp(tester, textScale: scale, prefs: {'progress.EXPRESS': 2, if (dark) 'theme_mode': 'dark'});
        expect(find.text('Choose a train to Seoul Station.'), findsOneWidget);
        await scrollTo(tester, find.text('T2 → Seoul Station'));

        await openRoute(tester, 'Express Train');
        expect(find.text('Buy an Express Train ticket'), findsOneWidget);
        await scrollTo(tester, find.text('Example'));
        if (scale >= 2.0) {
          await scrollTo(tester, button('Next'));
        }
        await tapVisible(tester, find.text('All steps'));
        await tapVisible(tester, find.text('Board at the Express platform'));
        await tapVisible(tester, button("I'm on the platform"));
        expect(find.text("You're at the platform"), findsOneWidget);
        await tapVisible(tester, button('Step 5 again'));

        await tapVisible(tester, find.text('+ Add a tip (log in)'));
        await tester.enterText(find.byType(TextField).at(0), 'wrong');
        await tester.enterText(find.byType(TextField).at(1), 'pw');
        await tapVisible(tester, button('Log in'));
        expect(find.text("Username or password doesn't match."), findsOneWidget);
        await tester.enterText(find.byType(TextField).at(0), 'student01');
        await tester.enterText(find.byType(TextField).at(1), 'pw');
        await tapVisible(tester, button('Log in'));

        await tester.enterText(find.byType(TextField).at(0), '가' * 81);
        await tapVisible(tester, button('Post tip'));
        expect(find.text('Use 80 characters or fewer.'), findsOneWidget);
        await tapVisible(tester, button('Cancel'));
        await tester.tap(button('Discard'));
        await tester.pumpAndSettle();
      });

      testWidgets('$label: S05 설정, S06 내 팁(목록·알림)', (tester) async {
        final repo = FakeSubwayRepository(delay: Duration.zero)
          ..failNext(FakeOperation.updateStatus, RepositoryErrorCode.forbidden);
        await pumpApp(
          tester,
          repository: repo,
          textScale: scale,
          session: demoSession,
          prefs: {if (dark) 'theme_mode': 'dark'},
        );
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();
        await scrollTo(tester, find.textContaining('creativecommons.org'));

        await tester.tap(find.byIcon(Icons.lightbulb_outline));
        await tester.pumpAndSettle();
        expect(find.text('Elevator for big suitcases'), findsOneWidget);
        await tapVisible(tester, find.text('Mark as checked'));
        expect(find.text('Log in again'), findsOneWidget);
      });

      testWidgets('$label: S01 오프라인 안내', (tester) async {
        final repo = FakeSubwayRepository(delay: Duration.zero)
          ..failNext(FakeOperation.routes, RepositoryErrorCode.offline);
        await pumpApp(tester, repository: repo, textScale: scale, prefs: {if (dark) 'theme_mode': 'dark'});
        expect(find.text("You're offline"), findsOneWidget);
      });
    }
  }

  testWidgets('누르는 영역은 48 이상(하단 메뉴·링크 버튼·이전/다음)', (tester) async {
    await pumpApp(tester, session: demoSession, prefs: {'progress.LOCAL': 3});
    for (final f in [find.text('Routes'), find.text('My tips'), find.text('Settings')]) {
      final dest = find.ancestor(of: f, matching: find.byType(NavigationDestination));
      expect(tester.getSize(dest).height, greaterThanOrEqualTo(48));
    }
    expect(tester.getSize(find.widgetWithText(TextButton, 'Start over')).height, greaterThanOrEqualTo(48));
    await openRoute(tester, 'All-stop Train');
    for (final label in ['Previous', 'Next']) {
      expect(tester.getSize(button(label)).height, greaterThanOrEqualTo(48));
    }
    for (final label in ['All steps', '+ Add a tip', 'Show 1 older tip']) {
      await tester.ensureVisible(find.widgetWithText(TextButton, label));
      expect(tester.getSize(find.widgetWithText(TextButton, label)).height, greaterThanOrEqualTo(48));
    }
  });
}
