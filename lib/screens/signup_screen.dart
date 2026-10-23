import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../repositories/subway_repository.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../validation/signup_rules.dart';
import '../widgets/common.dart';
import '../widgets/labeled_field.dart';

// failed: 연결 등으로 가입하지 못함(빨간 상자, 다시 시도).
// unknownResult: 응답 없음(시간 초과). 서버가 가입을 마쳤을 수 있어 다시 가입하게 하지 않고 같은 값으로 로그인해 보게 한다.
enum _Failure { failed, unknownResult }

// 가입이 끝나면 로그인 화면에 돌려주는 값. 로그인 화면이 이 값으로 바로 로그인한다(메모리에만 두고 저장하지 않음).
class SignupResult {
  const SignupResult(this.username, this.password);

  final String username;
  final String password;
}

// 회원가입(2026-10-21 요청, 서버 POST /api/auth/signup). 로그인 화면의 파란 '회원가입' 글자로 들어온다.
// - 아이디는 영어 소문자·숫자·밑줄 4~24자, 비밀번호는 8자 이상·UTF-8 72바이트 이하(서버 규칙과 같음), 비밀번호 확인이 같아야 한다.
// - 칸별 오류와 첫 오류 칸 초점. 이미 있는 아이디(409)는 아이디 칸 아래, 그 밖의 실패는 위 빨간 상자(값 유지).
// - 가입하면 로그인 화면으로 돌아가 같은 아이디·비밀번호로 바로 로그인한다(로그인 화면에 들어온 목적대로 이어짐).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  SignupErrors _errors = const SignupErrors();
  _Failure? _failure; // 칸이 아닌 실패(위 상자)
  (String, String)? _sent; // 마지막으로 보낸 아이디·비밀번호. 시간 초과 뒤 [로그인]이 이 값으로 로그인해 본다
  bool _busy = false;
  bool _showPassword = false;
  bool _left = false; // 취소·뒤로로 닫았는지(닫히는 애니메이션 동안에도 mounted는 true)

  @override
  void dispose() {
    for (final c in [_username, _password, _confirm]) {
      c.dispose();
    }
    for (final f in [_usernameFocus, _passwordFocus, _confirmFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  String? _errorText(SignupFieldError? e, AppStrings s) => switch (e) {
    SignupFieldError.usernameFormat => s.errUsernameFormat,
    SignupFieldError.usernameTaken => s.errUsernameTaken,
    SignupFieldError.passwordShort => s.errPassShort,
    SignupFieldError.passwordLong => s.errPassLong,
    SignupFieldError.passwordMismatch => s.errPassMismatch,
    SignupFieldError.rejected => s.errCheckField,
    null => null,
  };

  // 첫 오류 칸(아이디 → 비밀번호 → 비밀번호 확인)에 초점을 준다.
  void _focusFirstError(SignupErrors errors) {
    if (errors.isEmpty) return;
    (errors.username != null
            ? _usernameFocus
            : errors.password != null
            ? _passwordFocus
            : _confirmFocus)
        .requestFocus();
  }

  void _clearError(String field) {
    if (_errors.isEmpty) return;
    setState(() {
      _errors = SignupErrors(
        username: field == 'username' ? null : _errors.username,
        password: field == 'password' ? null : _errors.password,
        confirm: field == 'confirm' ? null : _errors.confirm,
      );
    });
  }

  Future<void> _submit() async {
    if (_busy) return;
    final errors = validateSignup(username: _username.text, password: _password.text, confirm: _confirm.text);
    setState(() {
      _errors = errors;
      _failure = null;
    });
    if (!errors.isEmpty) {
      _focusFirstError(errors);
      return;
    }
    final app = AppScope.read(context);
    final navigator = Navigator.of(context);
    // 누른 순간의 값을 보낸다(가입하는 동안 칸은 읽기 전용).
    final username = _username.text;
    final password = _password.text;
    setState(() {
      _busy = true;
      _sent = (username, password);
    });
    try {
      await app.repository.signup(username, password);
      if (!mounted || _left) return;
      TextInput.finishAutofillContext(); // 비밀번호 관리자가 새 계정을 저장할지 묻게 한다
      navigator.pop(SignupResult(username, password));
    } on RepositoryException catch (e) {
      if (!mounted || _left) return;
      final fieldErrors = _serverFieldErrors(e);
      setState(() {
        _busy = false;
        _errors = fieldErrors;
        _failure = !fieldErrors.isEmpty
            ? null
            : e.code == RepositoryErrorCode.timeout
            ? _Failure.unknownResult
            : _Failure.failed;
      });
      _focusFirstError(fieldErrors);
    }
  }

  // 409 USERNAME_TAKEN은 아이디 칸 아래. 400의 칸 이름(username·password)은 앱 규칙을 다시 돌려 맞는 종류가 있으면 그 문구,
  // 없으면 일반 문구. 서버의 한국어 문구는 쓰지 않는다. 칸 이름이 없으면 위 상자(빈 값을 돌려줌).
  SignupErrors _serverFieldErrors(RepositoryException e) {
    if (e.code != RepositoryErrorCode.validation) return const SignupErrors();
    if (e.serverCode == 'USERNAME_TAKEN') return const SignupErrors(username: SignupFieldError.usernameTaken);
    final rules = validateSignup(username: _username.text, password: _password.text, confirm: _confirm.text);
    SignupFieldError? pick(String field, SignupFieldError? rule) =>
        e.fieldErrors.contains(field) ? (rule ?? SignupFieldError.rejected) : null;
    return SignupErrors(username: pick('username', rules.username), password: pick('password', rules.password));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final c = AppColors.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _left = true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const BackButtonIcon(),
            tooltip: s.back,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(s.signUp),
        ),
        body: ScrollColumn(
          children: [
            FocusHeading(child: Text(s.signUpTitle, style: Theme.of(context).textTheme.titleLarge)),
            const Gap(6),
            Text(s.signUpLead, style: TextStyle(color: c.textSecondary)),
            const Gap(AppSpace.section),
            if (_failure != null) ...[
              switch (_failure!) {
                _Failure.failed => NoticeBox(kind: NoticeKind.error, message: s.signUpError),
                _Failure.unknownResult => NoticeBox(
                  kind: NoticeKind.warning,
                  message: s.signUpUnknown,
                  actionLabel: s.login,
                  onAction: () => Navigator.of(context).pop(SignupResult(_sent!.$1, _sent!.$2)),
                ),
              },
              const Gap(AppSpace.section),
            ],
            AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LabeledField(
                    label: s.user,
                    controller: _username,
                    focusNode: _usernameFocus,
                    hint: s.usernameHint,
                    errorText: _errorText(_errors.username, s),
                    readOnly: _busy,
                    autofillHints: const [AutofillHints.newUsername],
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _clearError('username'),
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  const Gap(AppSpace.section),
                  LabeledField(
                    label: s.pass,
                    controller: _password,
                    focusNode: _passwordFocus,
                    hint: s.passwordHint,
                    obscureText: !_showPassword,
                    secret: true,
                    errorText: _errorText(_errors.password, s),
                    readOnly: _busy,
                    autofillHints: const [AutofillHints.newPassword],
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _clearError('password'),
                    onSubmitted: (_) => _confirmFocus.requestFocus(),
                    // 로그인 화면과 같은 보기 버튼. 두 비밀번호 칸을 함께 보이거나 숨긴다.
                    suffix: IconButton(
                      tooltip: s.showPw,
                      isSelected: _showPassword,
                      icon: const Icon(Icons.visibility_outlined),
                      selectedIcon: const Icon(Icons.visibility_off_outlined),
                      color: c.textSecondary,
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  const Gap(AppSpace.section),
                  LabeledField(
                    label: s.confirmPass,
                    controller: _confirm,
                    focusNode: _confirmFocus,
                    obscureText: !_showPassword,
                    secret: true,
                    errorText: _errorText(_errors.confirm, s),
                    readOnly: _busy,
                    autofillHints: const [AutofillHints.newPassword],
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => _clearError('confirm'),
                    onSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
            const Gap(AppSpace.section),
            Row(
              children: [
                Expanded(
                  flex: 10,
                  child: FilledButton(
                    style: ghostButtonStyle(c),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(s.cancel, textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 14,
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_busy) ...[
                          SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: c.onPrimary),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(child: Text(s.signUpSubmit, textAlign: TextAlign.center)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
