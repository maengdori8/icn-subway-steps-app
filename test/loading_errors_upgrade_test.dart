import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';

import 'helpers.dart';

// 고도화 P03(docs/upgrade-gap.md C-26·S6-01·S3-01): 불러오는 중 8초 '느린 연결' 줄, S06 불러오는 중 문구,
// S03 서버 400 칸 오류(P01 결정 4).

const slow = 'Slow connection. Check the airport Wi-Fi.';
const checkField = 'Check this field again.';
const postError = "Couldn't post your tip. What you typed is kept. Try again.";

// 나머지 요청은 바로 오고 [delays]의 요청만 늦게 오는 가짜 저장소.
FakeSubwayRepository slowRepo(Map<FakeOperation, Duration> delays) =>
    FakeSubwayRepository(delay: Duration.zero, delayOverrides: delays);

Finder field(int index) => find.byType(TextField).at(index); // 0 제목, 1 위치, 2 메모

TextField textField(WidgetTester tester, int index) => tester.widget<TextField>(field(index));

Future<void> openAddTipAndPost(WidgetTester tester) async {
  await openRoute(tester, 'Express Train');
  await tapVisible(tester, find.text('+ Add a tip'));
  await tester.enterText(field(0), 'Elevator left of the gates');
  await tester.enterText(field(1), 'B1, next to ticket machines');
  await tester.enterText(field(2), 'Good with big suitcases');
  await tapVisible(tester, button('Post tip'));
}

void main() {
  testWidgets('경로 목록이 8초 넘게 오지 않으면 느린 연결 줄, 응답이 오면 사라짐(S01, C-26)', (tester) async {
    await pumpApp(tester, repository: slowRepo({FakeOperation.routes: const Duration(seconds: 12)}));
    expect(find.text('Loading routes…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    expect(find.text(slow), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(slow), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text(slow), findsNothing);
    expect(find.text('All-stop Train'), findsOneWidget);
  });

  testWidgets('단계와 팁도 8초가 지나면 느린 연결 줄, 팁 요청은 새로 8초를 센다(S02, C-26)', (tester) async {
    await pumpApp(
      tester,
      repository: slowRepo({
        FakeOperation.steps: const Duration(seconds: 12),
        FakeOperation.tips: const Duration(seconds: 12),
      }),
    );
    await openRoute(tester, 'All-stop Train');
    expect(find.text('Loading steps…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    expect(find.text(slow), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(slow), findsOneWidget);

    await tester.pump(const Duration(seconds: 3)); // 단계가 오고 팁 요청이 시작됨
    expect(find.text('Loading tips…'), findsOneWidget);
    expect(find.text(slow), findsNothing, reason: '단계가 오면 사라지고 팁은 처음부터 다시 센다');
    await tester.pump(const Duration(seconds: 7));
    expect(find.text(slow), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(slow), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text(slow), findsNothing);
    expect(find.text('Loading tips…'), findsNothing);
  });

  testWidgets('팁을 기다리는 중 단계를 옮기면 새 요청부터 8초를 다시 센다(S02, C-26)', (tester) async {
    await pumpApp(tester, repository: slowRepo({FakeOperation.tips: const Duration(seconds: 12)}));
    await openRoute(tester, 'All-stop Train');
    expect(find.text('Loading tips…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.tap(button('Next')); // 같은 자리에서 팁 요청을 새로 보냄
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    expect(find.text(slow), findsNothing, reason: '첫 요청부터는 8초가 넘었지만 새 요청은 아직 4초 남짓');
    await tester.pump(const Duration(milliseconds: 4500));
    expect(find.text(slow), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text(slow), findsNothing);
  });

  testWidgets('불러오는 중에 화면을 떠나면 8초 타이머도 정리된다(C-26)', (tester) async {
    await pumpApp(tester, repository: slowRepo({FakeOperation.steps: const Duration(seconds: 3)}));
    await openRoute(tester, 'All-stop Train');
    expect(find.text('Loading steps…'), findsOneWidget);
    await goBack(tester);
    await tester.pump(const Duration(seconds: 3)); // 늦게 온 단계 응답은 버려짐
    expect(find.text('Loading steps…'), findsNothing);
    // 검사가 끝날 때 남은 타이머가 있으면 flutter_test가 실패시킨다. 8초 타이머를 정리하지 않으면 여기서 걸린다.
  });

  testWidgets('내 팁: 불러오는 중 문구 줄, 8초가 지나면 느린 연결 줄(S06, S6-01·C-26)', (tester) async {
    await pumpApp(
      tester,
      repository: slowRepo({FakeOperation.myTips: const Duration(seconds: 12)}),
      session: demoSession,
    );
    await tester.tap(find.text('My tips'));
    await tester.pump();
    expect(find.text('Loading your tips…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    expect(find.text(slow), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(slow), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text(slow), findsNothing);
    expect(find.text('Loading your tips…'), findsNothing);
    expect(find.text('Elevator for big suitcases'), findsOneWidget);
  });

  testWidgets('서버 400이 칸 이름을 주면 그 칸 아래 오류, 첫 오류 칸 초점, 값 유지, 상자 없음(S3-01)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)
      ..failNext(FakeOperation.createTip, RepositoryErrorCode.validation, fieldErrors: {'location', 'note'});
    await pumpApp(tester, repository: repo, session: demoSession);
    await openAddTipAndPost(tester);

    // 앱 규칙으로는 맞는 값이라 맞는 종류가 없다 → 일반 문구(서버의 한국어 문구는 쓰지 않음)
    expect(find.text(checkField), findsNWidgets(2));
    expect(textField(tester, 1).focusNode!.hasFocus, isTrue, reason: '첫 오류 칸(위치)');
    expect(textField(tester, 0).controller!.text, 'Elevator left of the gates');
    expect(textField(tester, 1).controller!.text, 'B1, next to ticket machines');
    expect(textField(tester, 2).controller!.text, 'Good with big suitcases');
    expect(find.text(postError), findsNothing);

    // 고치기 시작하면 그 칸 오류만 지우고, 다시 올리면 S02로 돌아간다
    await tester.enterText(field(1), 'B1, left of ticket machines');
    await tester.pump();
    expect(find.text(checkField), findsOneWidget);
    await tapVisible(tester, button('Post tip'));
    expect(find.text('Post tip'), findsNothing);
    expect(find.text('Elevator left of the gates'), findsOneWidget);
  });

  testWidgets('칸 이름과 칸이 아닌 이름이 섞인 400은 칸 오류와 상자를 함께(S3-01)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)
      ..failNext(FakeOperation.createTip, RepositoryErrorCode.validation, fieldErrors: {'location', 'stepNo'});
    await pumpApp(tester, repository: repo, session: demoSession);
    await openAddTipAndPost(tester);
    expect(find.text(checkField), findsOneWidget);
    expect(find.text(postError), findsOneWidget);
    expect(textField(tester, 1).focusNode!.hasFocus, isTrue);
  });

  testWidgets('이름 없는 400은 상자만(S3-01)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)
      ..failNext(FakeOperation.createTip, RepositoryErrorCode.validation);
    await pumpApp(tester, repository: repo, session: demoSession);
    await openAddTipAndPost(tester);
    expect(find.text(postError), findsOneWidget);
    expect(find.text(checkField), findsNothing);
  });

  testWidgets('칸이 아닌 이름(stepNo)만 준 400은 지금처럼 상자(S3-01)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)
      ..failNext(FakeOperation.createTip, RepositoryErrorCode.validation, fieldErrors: {'stepNo'});
    await pumpApp(tester, repository: repo, session: demoSession);
    await openAddTipAndPost(tester);
    expect(find.text(postError), findsOneWidget);
    expect(find.text(checkField), findsNothing);
    expect(textField(tester, 0).controller!.text, 'Elevator left of the gates');
  });
}
