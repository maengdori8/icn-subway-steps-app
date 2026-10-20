import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';

import 'helpers.dart';

Future<void> openLoginFromStep(WidgetTester tester) async {
  await openRoute(tester, 'Express Train');
  await tapVisible(tester, find.text('+ Add a tip (log in)'));
}

TextField textField(WidgetTester tester, int index) => tester.widget<TextField>(find.byType(TextField).at(index));

void main() {
  testWidgets('빈 칸이면 칸마다 오류', (tester) async {
    await pumpApp(tester);
    await openLoginFromStep(tester);
    await tapVisible(tester, button('Log in'));
    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(textField(tester, 0).focusNode!.hasFocus, isTrue);
  });

  testWidgets('로그인 실패: 아이디는 남고 비밀번호만 비운다', (tester) async {
    final app = await pumpApp(tester);
    await openLoginFromStep(tester);
    await tester.enterText(find.byType(TextField).at(0), 'wrong');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tapVisible(tester, button('Log in'));
    expect(find.text("Username or password doesn't match."), findsOneWidget);
    expect(textField(tester, 0).controller!.text, 'wrong');
    expect(textField(tester, 1).controller!.text, isEmpty);
    expect(textField(tester, 1).focusNode!.hasFocus, isTrue);
    expect(app.session, isNull);
  });

  testWidgets('비밀번호 보기: 입력칸 오른쪽 눈 버튼, 이름은 고정하고 눌림 상태로 바뀐다', (tester) async {
    await pumpApp(tester);
    await openLoginFromStep(tester);
    expect(textField(tester, 1).obscureText, isTrue);
    expect(textField(tester, 1).autofillHints, contains('password'));
    expect(textField(tester, 0).autofillHints, contains('username'));

    final eye = find.byTooltip('Show password');
    expect(find.descendant(of: find.byType(TextField).at(1), matching: eye), findsOneWidget);
    expect(tester.getSize(eye).width, greaterThanOrEqualTo(48));
    await tester.tap(eye);
    await tester.pump();
    expect(textField(tester, 1).obscureText, isFalse);
    expect(find.byTooltip('Show password'), findsOneWidget);
    expect(tester.widget<IconButton>(find.ancestor(of: eye, matching: find.byType(IconButton))).isSelected, isTrue);
  });

  testWidgets('로그인 중에 취소하면 늦게 온 응답으로 로그인되지 않는다(Codex 지적 1)', (tester) async {
    final app = await pumpApp(tester, repository: FakeSubwayRepository(delay: const Duration(milliseconds: 600)));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    await openRoute(tester, 'Express Train');
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('+ Add a tip (log in)'));

    await tester.enterText(find.byType(TextField).at(0), 'alice');
    await tester.enterText(find.byType(TextField).at(1), 'pw');
    await tester.ensureVisible(button('Log in'));
    await tester.pumpAndSettle();
    await tester.tap(button('Log in'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(button('Cancel'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700)); // alice 응답이 화면을 떠난 뒤 도착
    await tester.pumpAndSettle();
    expect(app.session, isNull);
    expect(find.text('+ Add a tip (log in)'), findsOneWidget);

    await tapVisible(tester, find.text('+ Add a tip (log in)'));
    await tester.enterText(find.byType(TextField).at(0), 'bob');
    await tester.enterText(find.byType(TextField).at(1), 'pw');
    await tester.ensureVisible(button('Log in'));
    await tester.pumpAndSettle();
    await tester.tap(button('Log in'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(app.session?.username, 'bob');
  });

  testWidgets('취소하면 S02 같은 단계로', (tester) async {
    await pumpApp(tester, prefs: {'progress.EXPRESS': 1});
    await openLoginFromStep(tester);
    await tapVisible(tester, button('Cancel'));
    expect(find.text('Go down to the Transportation Center'), findsOneWidget);
  });

  testWidgets('설정에서 로그인하면 단계 복귀 문구 없이 로그인하고 설정으로 돌아온다', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.widgetWithText(TextButton, 'Log in'));
    expect(find.text('Log in to add a tip'), findsNothing);
    expect(find.text("You don't need an account to follow the steps."), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'mina');
    await tester.enterText(find.byType(TextField).at(1), 'pw');
    await tapVisible(tester, button('Log in'));
    expect(find.text('Logged in as mina'), findsOneWidget);
    expect(bottomNav, findsOneWidget);
  });
}
