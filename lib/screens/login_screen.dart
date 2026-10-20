import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/guide_step.dart';
import '../models/route_info.dart';
import '../repositories/subway_repository.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/labeled_field.dart';
import 'add_tip_screen.dart';

// addTip: S02 '+ 팁 등록'에서 옴 → 성공하면 같은 단계의 S03으로 바뀐다.
// general: 설정·내 팁·다시 로그인에서 옴 → 성공하면 들어온 화면으로 돌아간다(4차 REG-08).
enum LoginPurpose { addTip, general }

enum _FieldError { username, password }

// S04 로그인. 칸별 오류, 실패하면 아이디는 남기고 비밀번호만 비운다. 비밀번호 칸 오른쪽에 보기 버튼.
// 취소·뒤로는 들어온 화면(S02 같은 단계, S05, S06)으로 간다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.purpose, this.route, this.step, this.stepCount})
    : assert(purpose != LoginPurpose.addTip || (route != null && step != null && stepCount != null));

  final LoginPurpose purpose;
  final RouteInfo? route;
  final GuideStep? step;
  final int? stepCount;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final Set<_FieldError> _errors = {};
  bool _mismatch = false; // 아이디·비밀번호 불일치
  bool _otherFailure = false; // 연결 등 다른 이유
  bool _busy = false;
  bool _showPassword = false;
  bool _left = false; // 취소·뒤로로 닫았는지(닫히는 애니메이션 동안에도 mounted는 true)

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final errors = {
      if (_username.text.trim().isEmpty) _FieldError.username,
      if (_password.text.isEmpty) _FieldError.password,
    };
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
      _mismatch = false;
      _otherFailure = false;
    });
    if (errors.isNotEmpty) {
      (errors.contains(_FieldError.username) ? _usernameFocus : _passwordFocus).requestFocus();
      return;
    }
    final app = AppScope.read(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final session = await app.repository.login(_username.text.trim(), _password.text);
      // 기다리는 동안 취소·뒤로로 이 화면을 떠났으면 결과를 버린다(늦게 온 응답이 다른 계정의 로그인을 덮어쓰지 않게).
      if (!mounted || _left) return;
      app.signIn(session);
      TextInput.finishAutofillContext();
      if (widget.purpose == LoginPurpose.addTip) {
        navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => AddTipScreen(route: widget.route!, step: widget.step!, stepCount: widget.stepCount!),
          ),
        );
      } else {
        navigator.pop(true);
      }
    } on RepositoryException catch (e) {
      if (!mounted || _left) return;
      final mismatch = e.code == RepositoryErrorCode.invalidCredentials;
      setState(() {
        _busy = false;
        _mismatch = mismatch;
        _otherFailure = !mismatch;
        if (mismatch) _password.clear(); // 아이디는 유지, 비밀번호만 비움
      });
      if (mismatch) _passwordFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.strings;
    final c = AppColors.of(context);
    final forTip = widget.purpose == LoginPurpose.addTip;
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
          title: Text(s.login),
        ),
        body: ScrollColumn(
          children: [
            FocusHeading(child: Text(forTip ? s.loginTitle : s.login, style: Theme.of(context).textTheme.titleLarge)),
            const Gap(6),
            Text(forTip ? s.loginLead : s.loginLeadGeneral, style: TextStyle(color: c.textSecondary)),
            const Gap(AppSpace.section),
            if (_mismatch || _otherFailure) ...[
              NoticeBox(kind: NoticeKind.error, message: _mismatch ? s.loginFail : s.loginError),
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
                    errorText: _errors.contains(_FieldError.username) ? s.errUser : null,
                    autofillHints: const [AutofillHints.username],
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_errors.remove(_FieldError.username)) setState(() {});
                    },
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  const Gap(AppSpace.section),
                  LabeledField(
                    label: s.pass,
                    controller: _password,
                    focusNode: _passwordFocus,
                    obscureText: !_showPassword,
                    errorText: _errors.contains(_FieldError.password) ? s.errPass : null,
                    autofillHints: const [AutofillHints.password],
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      if (_errors.remove(_FieldError.password)) setState(() {});
                    },
                    onSubmitted: (_) => _submit(),
                    // 이름은 'Show password'로 고정하고 눌림 상태로 알린다. 누른 뒤에도 초점은 이 버튼에 남는다(4차 A11Y-10).
                    suffix: IconButton(
                      tooltip: s.showPw,
                      isSelected: _showPassword,
                      icon: const Icon(Icons.visibility_outlined),
                      selectedIcon: const Icon(Icons.visibility_off_outlined),
                      color: c.textSecondary,
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
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
                        Flexible(child: Text(s.login, textAlign: TextAlign.center)),
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
