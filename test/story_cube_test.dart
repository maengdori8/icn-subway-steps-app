import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

// 2026-10-22 사용자 요청: S02 사진 넘김을 인스타그램 스토리처럼(정육면체 면이 돌아가듯).

Finder cube(int index) => find.byKey(ValueKey('cube-$index'));

Finder get anyCube => find.byWidgetPredicate(
  (w) => w is Transform && w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('cube-'),
);

void main() {
  testWidgets('사진을 미는 동안 나가는 사진과 들어오는 사진이 맞닿은 모서리를 축으로 돈다', (tester) async {
    await pumpApp(tester);
    await openRoute(tester, 'All-stop Train');
    final gesture = await tester.startGesture(tester.getCenter(find.byType(PageView)));
    await gesture.moveBy(const Offset(-40, 0));
    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump();

    final leaving = tester.widget<Transform>(cube(0));
    final entering = tester.widget<Transform>(cube(1));
    expect(leaving.transform, isNot(Matrix4.identity()), reason: '1단계 사진이 돌며 나감');
    expect(leaving.alignment, Alignment.centerRight, reason: '다음 사진 쪽 모서리가 축');
    expect(entering.transform, isNot(Matrix4.identity()), reason: '2단계 사진이 돌며 들어옴');
    expect(entering.alignment, Alignment.centerLeft, reason: '앞 사진 쪽 모서리가 축');

    await gesture.up();
    await tester.pumpAndSettle();
    for (final t in tester.widgetList<Transform>(anyCube)) {
      expect(t.transform, Matrix4.identity(), reason: '넘김이 끝나면 평평하게');
    }
  });

  testWidgets('다음 버튼으로 넘길 때도 돌고, 끝나면 평평하다', (tester) async {
    await pumpApp(tester);
    await openRoute(tester, 'All-stop Train');
    await tester.tap(button('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<Transform>(cube(0)).transform, isNot(Matrix4.identity()));
    await tester.pumpAndSettle();
    expect(tester.widget<Transform>(cube(1)).transform, Matrix4.identity());
    expect(find.text('2/5'), findsOneWidget);
  });

  testWidgets('동작 줄이기 설정이면 돌리지 않고 평평하게 넘긴다', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);
    await openRoute(tester, 'All-stop Train');
    final gesture = await tester.startGesture(tester.getCenter(find.byType(PageView)));
    await gesture.moveBy(const Offset(-40, 0));
    await gesture.moveBy(const Offset(-80, 0));
    await tester.pump();
    expect(anyCube, findsNothing);
    await gesture.up();
    await tester.pumpAndSettle();
  });
}
