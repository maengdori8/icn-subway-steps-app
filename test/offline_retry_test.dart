import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';
import 'package:icn_subway_app/widgets/offline_message.dart';

import 'helpers.dart';

// 2026-10-21 사용자 요청: 인터넷이 없거나 비행기 모드면 그림과 함께 안내하고, 연결되면 바로(저절로) 다시 불러온다.

const offlineTitle = "You're offline";
const autoNote = "If airplane mode is on, turn it off. We'll load this automatically when you're back online.";

int sent(FakeSubwayRepository repo, FakeOperation op) => repo.requests.where((r) => r == op).length;

void main() {
  testWidgets('앱을 켤 때 끊겨 있으면 그림과 안내, 아직 끊겨 있으면 안내를 그대로 두고, 연결되면 저절로 경로를 보인다(S01)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)
      ..failNext(FakeOperation.routes, RepositoryErrorCode.offline, times: 2);
    await pumpApp(tester, repository: repo);
    expect(find.byType(OfflineIllustration), findsOneWidget);
    expect(find.text(offlineTitle), findsOneWidget);
    expect(find.textContaining("airport's free Wi-Fi"), findsOneWidget);
    expect(find.text(autoNote), findsOneWidget);
    expect(button('Try again'), findsOneWidget);

    await tester.pump(AutoRetry.every); // 첫 자동 재시도: 아직 끊김
    await tester.pump();
    expect(find.text(offlineTitle), findsOneWidget, reason: '불러오는 중으로 깜빡이지 않고 안내를 그대로 둔다');
    expect(find.text('Loading routes…'), findsNothing);

    await tester.pump(AutoRetry.every); // 두 번째: 연결됨
    await tester.pump();
    expect(find.text(offlineTitle), findsNothing);
    expect(find.text('Express Train'), findsOneWidget);
    expect(sent(repo, FakeOperation.routes), 3);
  });

  testWidgets('설정에서 비행기 모드를 끄고 앱으로 돌아오면 기다리지 않고 바로 다시 읽는다(S01)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)..failNext(FakeOperation.routes, RepositoryErrorCode.offline);
    await pumpApp(tester, repository: repo);
    expect(find.text(offlineTitle), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(sent(repo, FakeOperation.routes), 2, reason: '돌아온 순간 다시 보냄(3초 주기를 기다리지 않음)');
    await tester.pump(const Duration(milliseconds: 100)); // 가짜 저장소의 응답(지연 0)을 받는다
    await tester.pump();
    expect(find.text('Express Train'), findsOneWidget);
  });

  testWidgets('단계를 열 때 끊겨 있으면 같은 안내, 연결되면 저절로 단계를 보인다(S02)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)..failNext(FakeOperation.steps, RepositoryErrorCode.offline);
    await pumpApp(tester, repository: repo);
    await openRoute(tester, 'All-stop Train');
    expect(find.byType(OfflineIllustration), findsOneWidget);
    expect(find.text(autoNote), findsOneWidget);
    await tester.pump(AutoRetry.every);
    await tester.pump();
    expect(find.byType(OfflineIllustration), findsNothing);
    expect(find.text('1/5'), findsOneWidget);
  });

  testWidgets('내 팁도 끊겨 있으면 같은 안내, 연결되면 저절로 불러온다(S06)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)..failNext(FakeOperation.myTips, RepositoryErrorCode.offline);
    await pumpApp(tester, repository: repo, session: demoSession);
    await tester.tap(find.text('My tips'));
    await tester.pumpAndSettle();
    expect(find.byType(OfflineIllustration), findsOneWidget);
    await tester.pump(AutoRetry.every);
    await tester.pump();
    expect(find.byType(OfflineIllustration), findsNothing);
    expect(find.text('Elevator for big suitcases'), findsOneWidget);
  });

  testWidgets('연결 끊김이 아닌 실패(서버 등)는 그림·자동 재시도 없이 지금처럼(S01)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)..failNext(FakeOperation.routes, RepositoryErrorCode.server);
    await pumpApp(tester, repository: repo);
    expect(find.text("Couldn't load this. Try again."), findsOneWidget);
    expect(find.byType(OfflineIllustration), findsNothing);
    await tester.pump(const Duration(seconds: 10));
    expect(sent(repo, FakeOperation.routes), 1, reason: '저절로 다시 보내지 않음');
  });

  testWidgets('안내 화면을 떠나면 자동 재시도도 멈춘다(S02)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)
      ..failNext(FakeOperation.steps, RepositoryErrorCode.offline, times: 10);
    await pumpApp(tester, repository: repo);
    await openRoute(tester, 'All-stop Train');
    expect(find.byType(OfflineIllustration), findsOneWidget);
    await goBack(tester);
    final before = sent(repo, FakeOperation.steps);
    await tester.pump(const Duration(seconds: 10));
    expect(sent(repo, FakeOperation.steps), before);
  });

  // 아래 검사는 Codex 반박(추가 요청) 지적 1·2·4를 고정한다. tester.pump()는 시간을 흘리지 않아 가짜 저장소 응답을 받으려면
  // pump(Duration)을 쓴다. 요청 시각은 '지연 10초'를 기준으로 적었다.

  testWidgets('다시 붙는 도중 다른 실패(시간 초과)가 나도 자동 재시도를 이어 간다(S01)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)
      ..failNext(FakeOperation.routes, RepositoryErrorCode.offline)
      ..failNext(FakeOperation.routes, RepositoryErrorCode.timeout);
    await pumpApp(tester, repository: repo);
    expect(find.text(offlineTitle), findsOneWidget);

    await tester.pump(AutoRetry.every); // 망은 붙었지만 첫 요청이 시간 초과
    await tester.pump();
    expect(find.text("Couldn't load this. Try again."), findsOneWidget, reason: '실패 종류는 사실대로 보인다');
    expect(find.byType(OfflineIllustration), findsNothing);

    await tester.pump(AutoRetry.every); // 멈추지 않고 다시 읽어 성공
    await tester.pump();
    expect(find.text('Express Train'), findsOneWidget);
    expect(sent(repo, FakeOperation.routes), 3);
  });

  testWidgets('[다시 시도]와 자동 요청이 겹치면 늦게 온 앞 요청의 결과를 버린다(S01)', (tester) async {
    final repo = FakeSubwayRepository(
      delay: Duration.zero,
      delayOverrides: {FakeOperation.routes: const Duration(seconds: 10)},
    )..failNext(FakeOperation.routes, RepositoryErrorCode.offline);
    await pumpApp(tester, repository: repo);
    await tester.pump(const Duration(seconds: 10)); // t=10 첫 요청이 끊김으로 끝남
    expect(find.text(offlineTitle), findsOneWidget);
    await tester.pump(AutoRetry.every); // t=13 자동 요청 A
    await tester.pump(const Duration(seconds: 2)); // t=15
    await tester.tap(button('Try again')); // 요청 B
    await tester.pump();
    expect(find.text('Loading routes…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 8)); // t=23 A가 끝났지만 B보다 앞 요청이라 버린다
    expect(find.text('Loading routes…'), findsOneWidget);
    expect(find.text('Express Train'), findsNothing);
    await tester.pump(const Duration(seconds: 2)); // t=25 B
    expect(find.text('Express Train'), findsOneWidget);
    expect(sent(repo, FakeOperation.routes), 3);
  });

  testWidgets('단계도 겹친 요청은 마지막 것만 써서 사진 컨트롤러와 팁 읽기가 한 번이다(S02)', (tester) async {
    final repo = FakeSubwayRepository(
      delay: Duration.zero,
      delayOverrides: {FakeOperation.steps: const Duration(seconds: 10)},
    )..failNext(FakeOperation.steps, RepositoryErrorCode.offline);
    await pumpApp(tester, repository: repo);
    await openRoute(tester, 'All-stop Train');
    await tester.pump(const Duration(seconds: 10)); // 첫 단계 요청이 끊김으로 끝남
    expect(find.byType(OfflineIllustration), findsOneWidget);
    await tester.pump(AutoRetry.every); // 자동 요청 A
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(button('Try again')); // 요청 B
    await tester.pump();
    await tester.pump(const Duration(seconds: 8)); // A 성공(버림)
    expect(find.text('Loading steps…'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2)); // B 성공 → 팁 읽기
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('1/5'), findsOneWidget);
    expect(sent(repo, FakeOperation.tips), 1, reason: '두 성공을 모두 쓰면 팁을 두 번 읽는다');
    expect(tester.takeException(), isNull);
  });

  testWidgets('요청이 걸려 있는 동안에는 주기가 여러 번 와도, 앱으로 돌아와도 더 보내지 않는다(S01)', (tester) async {
    final repo = FakeSubwayRepository(
      delay: Duration.zero,
      delayOverrides: {FakeOperation.routes: const Duration(seconds: 10)},
    )..failNext(FakeOperation.routes, RepositoryErrorCode.offline);
    await pumpApp(tester, repository: repo);
    await tester.pump(const Duration(seconds: 10)); // t=10 끊김 안내
    await tester.pump(AutoRetry.every); // t=13 자동 요청 A(10초 걸림)
    expect(sent(repo, FakeOperation.routes), 2);
    await tester.pump(const Duration(seconds: 7)); // t=20 주기 두 번(16·19)이 지나감
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(sent(repo, FakeOperation.routes), 2, reason: 'A가 끝나기 전에는 다시 보내지 않음');
    await tester.pump(const Duration(seconds: 4)); // t=24 A 성공
    expect(find.text('Express Train'), findsOneWidget);
  });

  testWidgets('다시 읽은 뒤에는 자동 요청을 더 보내지 않는다(S01)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)..failNext(FakeOperation.routes, RepositoryErrorCode.offline);
    await pumpApp(tester, repository: repo);
    await tester.pump(AutoRetry.every);
    await tester.pump();
    expect(find.text('Express Train'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    expect(sent(repo, FakeOperation.routes), 2);
  });
}
