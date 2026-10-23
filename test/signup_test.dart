import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icn_subway_app/repositories/fake_subway_repository.dart';
import 'package:icn_subway_app/repositories/subway_repository.dart';
import 'package:icn_subway_app/theme/app_colors.dart';
import 'package:icn_subway_app/validation/signup_rules.dart';

import 'helpers.dart';

// 2026-10-21 사용자 요청: 회원가입을 만들고, 로그인 화면에 파란 글자 '회원가입'을 둔다.

Finder field(int index) => find.byType(TextField).at(index); // 가입 화면: 0 아이디, 1 비밀번호, 2 비밀번호 확인

TextField textField(WidgetTester tester, int index) => tester.widget<TextField>(field(index));

Finder get signUpLink => find.widgetWithText(TextButton, 'Sign up');

// 내 팁 탭의 [로그인]으로 일반 목적 로그인 화면을 연다.
Future<void> openLogin(WidgetTester tester) async {
  await tester.tap(find.descendant(of: bottomNav, matching: find.text('My tips')));
  await tester.pumpAndSettle();
  await tester.tap(button('Log in'));
  await tester.pumpAndSettle();
}

Future<void> fillSignup(WidgetTester tester, String username, String password, [String? confirm]) async {
  await tester.enterText(field(0), username);
  await tester.enterText(field(1), password);
  await tester.enterText(field(2), confirm ?? password);
  await tapVisible(tester, button('Create account'));
}

void main() {
  group('가입 규칙(서버 SignupRequest와 같음)', () {
    test('아이디: 영어 소문자·숫자·밑줄 4~24자', () {
      String? check(String name) => validateSignup(username: name, password: 'longenough', confirm: 'longenough').username?.name;
      expect(check('abcd'), isNull);
      expect(check('a' * 24), isNull);
      expect(check('user_01'), isNull);
      expect(check('abc'), 'usernameFormat');
      expect(check('a' * 25), 'usernameFormat');
      expect(check('User01'), 'usernameFormat', reason: '대문자는 안 됨');
      expect(check('user-01'), 'usernameFormat');
      expect(check(' user01'), 'usernameFormat', reason: '공백을 지우지 않고 검사');
    });

    test('비밀번호: 8자(코드 포인트) 이상, UTF-8 72바이트 이하, 확인이 같아야 함', () {
      SignupErrors check(String pw, [String? confirm]) => validateSignup(username: 'abcd', password: pw, confirm: confirm ?? pw);
      expect(check('1234567').password, SignupFieldError.passwordShort);
      expect(check('12345678').password, isNull);
      expect(check('😀😀😀😀😀😀😀😀').password, isNull, reason: '이모지 1개 = 1자');
      expect(check('😀' * 7).password, SignupFieldError.passwordShort, reason: 'UTF-16 길이(14)가 아니라 코드 포인트(7)로 셈');
      expect(check('😀' * 4).password, SignupFieldError.passwordShort);
      expect(check(' ' * 8).password, isNull, reason: '공백도 글자로 셈');
      expect(check('a' * 72).password, isNull, reason: '72바이트');
      expect(check('a' * 73).password, SignupFieldError.passwordLong, reason: '73바이트');
      expect(check('가' * 24).password, isNull, reason: '72바이트');
      expect(check('가' * 25).password, SignupFieldError.passwordLong, reason: '75바이트');
      expect(check('longenough', 'different').confirm, SignupFieldError.passwordMismatch);
    });
  });

  testWidgets('로그인 화면에 파란 글자 회원가입이 있고, 누르면 가입 화면', (tester) async {
    await pumpApp(tester);
    await openLogin(tester);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(signUpLink, findsOneWidget);
    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: signUpLink, matching: find.byType(RichText)),
    );
    expect(paragraph.text.style?.color, AppColors.of(tester.element(signUpLink)).link, reason: '링크 버튼 파랑');

    await tapVisible(tester, signUpLink);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('4–24 lowercase letters, numbers or _'), findsOneWidget);
  });

  testWidgets('형식이 틀리면 칸별 오류와 첫 오류 칸 초점, 서버에 보내지 않는다', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero);
    await pumpApp(tester, repository: repo);
    await openLogin(tester);
    await tapVisible(tester, signUpLink);
    await fillSignup(tester, 'AB', 'short', 'different');
    expect(find.text('Use 4–24 lowercase letters, numbers or _.'), findsOneWidget);
    expect(find.text('Use 8 or more characters.'), findsOneWidget);
    expect(find.text("Passwords don't match."), findsOneWidget);
    expect(textField(tester, 0).focusNode!.hasFocus, isTrue);
    expect(repo.requests.contains(FakeOperation.signup), isFalse);

    // 고치기 시작하면 그 칸 오류만 지운다
    await tester.enterText(field(0), 'abcd');
    await tester.pump();
    expect(find.text('Use 4–24 lowercase letters, numbers or _.'), findsNothing);
    expect(find.text('Use 8 or more characters.'), findsOneWidget);
  });

  testWidgets('비밀번호 칸은 보이게 해도 제안·자동고침을 끈다', (tester) async {
    await pumpApp(tester);
    await openLogin(tester);
    await tapVisible(tester, signUpLink);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    for (final i in [1, 2]) {
      expect(textField(tester, i).obscureText, isFalse);
      expect(textField(tester, i).enableSuggestions, isFalse);
      expect(textField(tester, i).autocorrect, isFalse);
    }
  });

  testWidgets('이미 있는 아이디(409)는 아이디 칸 아래에 알리고 값은 그대로', (tester) async {
    await pumpApp(tester);
    await openLogin(tester);
    await tapVisible(tester, signUpLink);
    await fillSignup(tester, 'student01', 'longenough1');
    expect(find.text('That username is already taken.'), findsOneWidget);
    expect(textField(tester, 0).controller!.text, 'student01');
    expect(textField(tester, 1).controller!.text, 'longenough1');
    expect(textField(tester, 0).focusNode!.hasFocus, isTrue);
  });

  testWidgets('칸 이름 없는 실패는 위 빨간 상자, 값은 그대로', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)..failNext(FakeOperation.signup, RepositoryErrorCode.server);
    await pumpApp(tester, repository: repo);
    await openLogin(tester);
    await tapVisible(tester, signUpLink);
    await fillSignup(tester, 'new_traveler', 'longenough1');
    expect(find.text("Couldn't create your account. Check your connection and try again."), findsOneWidget);
    expect(textField(tester, 0).controller!.text, 'new_traveler');
  });

  testWidgets('가입하면 로그인 화면으로 돌아가 바로 로그인하고, 들어온 화면(내 팁)으로 간다', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero);
    final app = await pumpApp(tester, repository: repo);
    await openLogin(tester);
    await tapVisible(tester, signUpLink);
    await fillSignup(tester, 'new_traveler', 'longenough1');
    expect(app.session?.username, 'new_traveler');
    expect(find.text("Account created. You're logged in."), findsOneWidget);
    expect(find.textContaining("You haven't posted a tip yet"), findsOneWidget, reason: '새 계정의 내 팁(S06)');
    expect(repo.requests.where((r) => r == FakeOperation.signup).length, 1);
    expect(repo.requests.where((r) => r == FakeOperation.login).length, 1);
  });

  testWidgets('팁 올리기로 들어온 로그인에서 가입하면 같은 단계의 팁 등록 화면으로', (tester) async {
    final app = await pumpApp(tester, prefs: {'progress.EXPRESS': 2});
    await openRoute(tester, 'Express Train');
    await tapVisible(tester, find.text('+ Add a tip (log in)'));
    await tapVisible(tester, signUpLink);
    await fillSignup(tester, 'new_traveler', 'longenough1');
    expect(app.session?.username, 'new_traveler');
    expect(find.text('Express Train · Step 3 of 5 — Buy an Express Train ticket'), findsOneWidget);
    expect(find.text("Account created. You're logged in."), findsOneWidget);
  });

  testWidgets('서버 400이 칸 이름을 주면 앱 규칙으로는 맞는 값이라 일반 문구, 그 칸에 초점(서버 한국어 문구 안 씀)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)
      ..failNext(FakeOperation.signup, RepositoryErrorCode.validation, fieldErrors: {'username'});
    await pumpApp(tester, repository: repo);
    await openLogin(tester);
    await tapVisible(tester, signUpLink);
    await fillSignup(tester, 'new_traveler', 'longenough1');
    expect(find.text('Check this field again.'), findsOneWidget);
    expect(textField(tester, 0).focusNode!.hasFocus, isTrue);
    expect(find.text("Couldn't create your account. Check your connection and try again."), findsNothing);
  });

  testWidgets('응답이 없으면(시간 초과) 다시 가입하게 하지 않고 [로그인]으로 같은 값을 로그인해 본다', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)..failNext(FakeOperation.signup, RepositoryErrorCode.timeout);
    final app = await pumpApp(tester, repository: repo);
    await openLogin(tester);
    await tapVisible(tester, signUpLink);
    await fillSignup(tester, 'new_traveler', 'longenough1');
    expect(find.textContaining("can't tell if your account was created"), findsOneWidget);
    expect(find.text("Couldn't create your account. Check your connection and try again."), findsNothing);
    await tapVisible(tester, find.widgetWithText(TextButton, 'Log in'));
    expect(app.session?.username, 'new_traveler');
    expect(repo.requests.where((r) => r == FakeOperation.signup).length, 1, reason: '가입을 다시 보내지 않음');
  });

  testWidgets('가입하는 중에 뒤로 가면 늦게 온 결과는 버린다(로그인·화면 이동 없음)', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero, delayOverrides: {FakeOperation.signup: const Duration(seconds: 5)});
    final app = await pumpApp(tester, repository: repo);
    await openLogin(tester);
    await tapVisible(tester, signUpLink);
    await tester.enterText(field(0), 'new_traveler');
    await tester.enterText(field(1), 'longenough1');
    await tester.enterText(field(2), 'longenough1');
    await tester.tap(button('Create account'));
    await tester.pump(const Duration(seconds: 1));
    await goBack(tester);
    expect(find.text("Don't have an account?"), findsOneWidget, reason: '로그인 화면으로 돌아옴');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(app.session, isNull);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(repo.requests.contains(FakeOperation.login), isFalse);
  });

  testWidgets('가입 뒤 바로 로그인이 실패하면 로그인 화면에 실패 상자, 아이디는 그대로, 가입 알림 없음', (tester) async {
    final repo = FakeSubwayRepository(delay: Duration.zero)..failNext(FakeOperation.login, RepositoryErrorCode.server);
    final app = await pumpApp(tester, repository: repo);
    await openLogin(tester);
    await tapVisible(tester, signUpLink);
    await fillSignup(tester, 'new_traveler', 'longenough1');
    expect(app.session, isNull);
    expect(find.text("Couldn't log in. Check your connection and try again."), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text, 'new_traveler');
    expect(find.text("Account created. You're logged in."), findsNothing);
  });
}
