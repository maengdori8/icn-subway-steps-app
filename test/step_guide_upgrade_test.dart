import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/models/localized_text.dart';
import 'package:icn_subway_app/models/route_info.dart';
import 'package:icn_subway_app/models/tip.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/screens/step_guide_screen.dart';
import 'package:icn_subway_app/state/app_controller.dart';
import 'package:icn_subway_app/theme/app_theme.dart';
import 'package:icn_subway_app/widgets/step_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

// 고도화 P02(docs/upgrade-gap.md S2-01·S2-02·S2-03·S2-06·C-24): S02 단계 이동 맨 위로, 큰 글자 문턱,
// 단계 0개, 전체 단계 목록 낭독, 동작 줄이기에서 새 팁 스크롤.

// Android 글꼴 크기처럼 작은 글자일수록 더 키우는 비선형 배율. [body]는 본문 16에, [small]은 글자 10 이하에
// 곱한다(주지 않으면 body와 같음). 10~16 사이는 두 점을 잇고, 16보다 큰 글자는 1.2씩만 늘린다.
// 본문 1.75배(16 → 28)가 Android 글꼴 200%의 본문이다.
class _NonLinearScaler extends TextScaler {
  const _NonLinearScaler(this.body, {double? small}) : small = small ?? body;

  final double body;
  final double small;

  @override
  double scale(double fontSize) {
    if (fontSize <= 10) return fontSize * small;
    if (fontSize <= 16) return 10 * small + (fontSize - 10) * (16 * body - 10 * small) / 6;
    return 16 * body + (fontSize - 16) * 1.2;
  }

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => body;
}

const _local = RouteInfo(
  code: 'LOCAL',
  name: LocalizedText(en: 'All-stop Train', ko: '일반열차'),
  summary: LocalizedText(en: 'Stops at every station · T-money card', ko: '모든 역 정차 · 교통카드(T-money)'),
  stepCount: 5,
  available: true,
);

const _t2 = RouteInfo(
  code: 'T2',
  name: LocalizedText(en: 'T2 → Seoul Station', ko: 'T2 → 서울역'),
  summary: LocalizedText(en: 'From T2 arrivals', ko: 'T2 입국장에서 출발'),
  stepCount: 0,
  available: false,
);

// StepGuideScreen 하나만 띄운다. [scaler]를 주면 그 화면의 글자 배율을 바꾼다.
Future<void> pumpStepScreen(WidgetTester tester, RouteInfo route, {TextScaler? scaler}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final controller = AppController(repository: FakeSubwayRepository(delay: Duration.zero), prefs: prefs);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AppScope(
      controller: controller,
      child: MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Builder(
          builder: (context) {
            final screen = StepGuideScreen(route: route, initialIndex: 0);
            if (scaler == null) return screen;
            return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: scaler), child: screen);
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double mainOffset(WidgetTester tester) => tester.state<ScrollableState>(mainScroll).position.pixels;

// 사진 PageView가 보여 주는 쪽(0부터).
double? photoPage(WidgetTester tester) => tester.widget<PageView>(find.byType(PageView)).controller!.page;

// '전체 단계' 버튼이 진행 숫자 아래 줄에 있는지(버튼 위끝이 숫자 아래끝보다 아래).
bool allStepsOnOwnLine(WidgetTester tester) =>
    tester.getRect(find.widgetWithText(TextButton, 'All steps')).top >= tester.getRect(find.text('1/5')).bottom;

// 전체 단계 목록의 n번째 항목. 단계 제목 머리글도 같은 라벨로 읽혀서 버튼인 Semantics로 가른다.
Finder stepItem(int n) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.button == true && (w.properties.label ?? '').startsWith('Step $n of 5: '),
);

Future<void> scrollDown(WidgetTester tester) async {
  await tester.drag(mainScroll, const Offset(0, -600));
  await tester.pumpAndSettle();
  expect(mainOffset(tester), greaterThan(0));
}

void main() {
  group('큰 글자 문턱은 본문 16 기준 배율(S2-02)', () {
    test('선형 배율: 1.3배부터 전체 단계 버튼을 아래 줄, 1.7배부터 이전·다음을 본문 끝', () {
      expect(stepsButtonOnOwnLine(const TextScaler.linear(1.29)), isFalse);
      expect(stepsButtonOnOwnLine(const TextScaler.linear(1.3)), isTrue);
      expect(stepNavInline(const TextScaler.linear(1.69)), isFalse);
      expect(stepNavInline(const TextScaler.linear(1.7)), isTrue);
    });

    test('비선형 배율(Android 200%, 본문 1.75배)도 본문 기준으로 판정한다', () {
      expect(stepNavInline(const _NonLinearScaler(1.75)), isTrue, reason: '예전 2.0 문턱에서는 하단 고정으로 남았다');
      expect(stepNavInline(const _NonLinearScaler(1.6)), isFalse);
      expect(stepsButtonOnOwnLine(const _NonLinearScaler(1.6)), isTrue);
      expect(stepsButtonOnOwnLine(const _NonLinearScaler(1.25, small: 1.35)), isFalse, reason: '글자 10은 1.35배여도 본문은 1.25배');
    });
  });

  testWidgets('비선형 1.75배: 하단 고정 바 대신 이전·다음이 본문 끝에 있다', (tester) async {
    await pumpStepScreen(tester, _local, scaler: const _NonLinearScaler(1.75));
    final inBody = find.descendant(of: find.byType(SingleChildScrollView), matching: find.text('Previous'));
    expect(inBody, findsOneWidget);
  });

  testWidgets('글자 10만 1.3배를 넘고 본문은 1.25배면 전체 단계 버튼이 막대와 같은 줄(S2-02)', (tester) async {
    await pumpStepScreen(tester, _local, scaler: const _NonLinearScaler(1.25, small: 1.35));
    expect(allStepsOnOwnLine(tester), isFalse, reason: '예전 판정(글자 10 기준)이면 아래 줄로 내려갔다');
  });

  testWidgets('본문이 1.3배면 글자 10이 1.2배여도 전체 단계 버튼을 막대 아래 줄로(S2-02)', (tester) async {
    await pumpStepScreen(tester, _local, scaler: const _NonLinearScaler(1.3, small: 1.2));
    expect(allStepsOnOwnLine(tester), isTrue, reason: '예전 판정(글자 10 기준)이면 같은 줄에 남았다');
  });

  testWidgets('단계를 옮기면 본문이 맨 위로(다음 버튼·사진 밀기, S2-01)', (tester) async {
    await pumpApp(tester);
    await openRoute(tester, 'All-stop Train');
    await scrollDown(tester);
    await tester.tap(button('Next'));
    await tester.pumpAndSettle();
    expect(mainOffset(tester), 0);
    expect(find.text('Step 2 of 5'), findsNothing); // 숫자는 낭독용 라벨에만 있다(화면 문구 아님)
    expect(find.text('2/5'), findsOneWidget);
    expect(photoPage(tester), 1);

    // 사진이 보이는 만큼만 내린 뒤 사진을 밀어 단계를 옮겨도 맨 위로. 진행 표시와 사진이 같은 단계를 가리킨다.
    await tester.drag(mainScroll, const Offset(0, -150));
    await tester.pumpAndSettle();
    expect(mainOffset(tester), greaterThan(0));
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(mainOffset(tester), 0);
    expect(find.text('3/5'), findsOneWidget);
    expect(photoPage(tester), 2);
  });

  testWidgets('마지막 단계 → 완료 → 다시 보기: 맨 위, 마지막 단계 사진, 진행 5/5(S2-01)', (tester) async {
    await pumpApp(tester, size: const Size(390, 640));
    await openRoute(tester, 'All-stop Train');
    for (var i = 0; i < 4; i++) {
      await tester.tap(button('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('5/5'), findsOneWidget);
    await scrollDown(tester);
    await tester.tap(button("I'm on the platform"));
    await tester.pumpAndSettle();
    expect(find.text("You're at the platform"), findsOneWidget);
    expect(mainOffset(tester), 0);

    await tester.tap(button('Step 5 again'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('5/5'), findsOneWidget);
    expect(mainOffset(tester), 0);
    expect(photoPage(tester), 4, reason: '처음 연 1단계 사진이 아니라 5단계 사진');
  });

  testWidgets('동작 줄이기 설정이면 단계를 옮길 때 바로 맨 위(S2-01)', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);
    await openRoute(tester, 'All-stop Train');
    await scrollDown(tester);
    await tester.tap(button('Next'));
    await tester.pump(); // 한 프레임만
    expect(mainOffset(tester), 0);
    await tester.pumpAndSettle();
  });

  testWidgets('단계가 0개인 경로는 완료 화면 대신 빈 상태와 [경로 목록으로](S2-03)', (tester) async {
    await pumpStepScreen(tester, _t2);
    expect(find.text('No steps yet'), findsOneWidget);
    expect(find.text('Back to routes'), findsOneWidget);
    expect(find.text("You're at the platform"), findsNothing);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('전체 단계: 펼침 상태가 버튼과 함께 읽히고, 목록 항목은 누를 수 있는 버튼(S2-06)', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);
    await openRoute(tester, 'All-stop Train');
    expect(find.semantics.byLabel('All steps'), findsOne, reason: '펼침 상태와 버튼이 한 노드');
    expect(
      tester.getSemantics(find.text('All steps')),
      isSemantics(isButton: true, hasTapAction: true, hasExpandedState: true, isExpanded: false),
    );
    await tester.tap(find.text('All steps'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Hide steps')),
      isSemantics(isButton: true, hasTapAction: true, hasExpandedState: true, isExpanded: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp(r'^Step 2 of 5: '))),
      isSemantics(isButton: true, hasTapAction: true, isSelected: false),
    );
    expect(
      tester.getSemantics(stepItem(1)),
      isSemantics(isButton: true, hasTapAction: true, isSelected: true),
      reason: '지금 단계는 선택됨으로 읽힌다',
    );

    // 낭독기의 두 번 누르기(semantics tap)로 3단계를 고르면 목록이 접히고 3단계로 옮긴다.
    tester.semantics.tap(find.semantics.byLabel(RegExp(r'^Step 3 of 5: ')));
    await tester.pumpAndSettle();
    expect(find.text('3/5'), findsOneWidget);
    expect(find.text('Hide steps'), findsNothing);
    expect(find.semantics.byLabel(RegExp(r'^Step 3 of 5: ')), findsOne, reason: '목록 항목은 사라지고 제목 머리글만 남음');
    semantics.dispose();
  });

  testWidgets('지난 팁 펼침 버튼도 버튼과 펼침 상태가 한 노드로 읽힌다(S2-06)', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, prefs: {'progress.LOCAL': 3});
    await openRoute(tester, 'All-stop Train');
    await scrollTo(tester, find.text('Show 1 older tip'));
    expect(find.semantics.byLabel('Show 1 older tip'), findsOne);
    expect(
      tester.getSemantics(find.text('Show 1 older tip')),
      isSemantics(isButton: true, hasTapAction: true, hasExpandedState: true, isExpanded: false),
    );
    tester.semantics.tap(find.semantics.byLabel('Show 1 older tip'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Hide older tips')),
      isSemantics(isButton: true, hasTapAction: true, hasExpandedState: true, isExpanded: true),
    );
    semantics.dispose();
  });

  testWidgets('동작 줄이기 설정이면 새 팁으로 바로 옮긴다(애니메이션 없음, C-24)', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final repo = FakeSubwayRepository(delay: Duration.zero);
    final app = await pumpApp(tester, repository: repo, session: demoSession);
    await openRoute(tester, 'Express Train');
    expect(mainOffset(tester), 0);
    final tip = (await tester.runAsync(
      () => repo.createTip(
        const TipDraft(route: 'EXPRESS', stepNo: 1, title: 'Fresh tip below the fold', location: 'Arrival exit B'),
        demoSession,
      ),
    ))!;
    app.tipPosted(tip, generation: app.sessionGeneration);
    await tester.pump(); // 목록에 넣고 그린 뒤 새 팁으로 옮김
    await tester.pump();
    final first = mainOffset(tester);
    await tester.pumpAndSettle();
    expect(first, greaterThan(0), reason: '새 팁이 화면 가운데로 옮겨짐');
    expect(mainOffset(tester), first, reason: '바로 옮겨서 뒤에 더 움직이지 않음');
    await tester.pump(const Duration(seconds: 2));
  });
}
