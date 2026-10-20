import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/guide_step.dart';
import '../models/route_info.dart';
import '../models/tip.dart';
import '../repositories/subway_repository.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../validation/tip_rules.dart';
import '../widgets/common.dart';
import '../widgets/labeled_field.dart';
import '../widgets/step_widgets.dart';
import 'login_screen.dart';

enum _Failure { postFailed, sessionEnded }

// S03 팁 등록. 들어온 경로·단계가 함께 넘어온다(화면에서 고르지 않음).
// - 제목·위치는 앞뒤 공백을 뺀 뒤 1~80자, 메모는 선택 150자 이하(코드 포인트 기준). 칸 아래에 오류.
// - 올리는 중에는 버튼을 막고 입력칸을 읽기 전용으로 둔다. 요청 번호로 어느 요청의 완료인지 구분한다.
// - 작성 중 나가기(취소·뒤로)는 [버리기]/[계속 쓰기] 확인. 올리는 중에 나가면 확인 없이 나가고 요청은 계속된다.
// - 성공하면 S02 같은 단계로 돌아가 '팁을 올렸습니다'. 실패하면 값을 그대로 두고 다시 시도.
class AddTipScreen extends StatefulWidget {
  const AddTipScreen({super.key, required this.route, required this.step, required this.stepCount});

  final RouteInfo route;
  final GuideStep step;
  final int stepCount;

  @override
  State<AddTipScreen> createState() => _AddTipScreenState();
}

class _AddTipScreenState extends State<AddTipScreen> {
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _note = TextEditingController();
  final _titleFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _noteFocus = FocusNode();

  TipFormErrors _errors = const TipFormErrors();
  bool _posting = false;
  int? _request; // 지금 기다리는 올리기 요청 번호
  bool _left = false; // 이 화면을 닫았는지. 닫히는 애니메이션 동안에도 mounted는 true라 따로 둔다

  bool get _here => mounted && !_left;
  _Failure? _failure;

  bool get _dirty => _title.text.trim().isNotEmpty || _location.text.trim().isNotEmpty || _note.text.trim().isNotEmpty;

  @override
  void dispose() {
    for (final c in [_title, _location, _note]) {
      c.dispose();
    }
    for (final f in [_titleFocus, _locationFocus, _noteFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  String? _errorText(TipFieldError? e, AppStrings s) => switch (e) {
    TipFieldError.required => s.errRequired,
    TipFieldError.tooLong80 => s.errLong80,
    TipFieldError.tooLong150 => s.errLong150,
    null => null,
  };

  Future<void> _submit() async {
    if (_posting) return;
    final errors = validateTip(title: _title.text, location: _location.text, note: _note.text);
    if (!errors.isEmpty) {
      setState(() {
        _errors = errors;
        _failure = null;
      });
      (errors.title != null
              ? _titleFocus
              : errors.location != null
              ? _locationFocus
              : _noteFocus)
          .requestFocus();
      return;
    }
    final app = AppScope.read(context);
    final session = app.session;
    if (session == null) {
      setState(() => _failure = _Failure.sessionEnded);
      return;
    }
    // 누른 순간의 값을 복사해 보낸다(올리는 중 값이 바뀌어도 보낸 값은 그대로).
    final note = _note.text.trim();
    final draft = TipDraft(
      route: widget.route.code,
      stepNo: widget.step.stepNo,
      title: _title.text.trim(),
      location: _location.text.trim(),
      note: note.isEmpty ? null : note,
    );
    final request = app.nextRequestId();
    final navigator = Navigator.of(context);
    setState(() {
      _posting = true;
      _request = request;
      _failure = null;
    });
    try {
      final tip = await app.repository.createTip(draft, session);
      app.tipPosted(tip);
      if (_here && _request == request) navigator.pop(tip); // 화면을 옮긴 뒤 알림을 띄운다
      app.showMessage((s) => s.posted);
    } on RepositoryException catch (e) {
      if (_here && _request == request) {
        setState(() {
          _posting = false;
          _request = null;
          _failure = e.code == RepositoryErrorCode.unauthorized ? _Failure.sessionEnded : _Failure.postFailed;
        });
      } else {
        app.showMessage((s) => s.postErrorClosed); // 이미 화면을 떠났다. 입력값은 남아 있지 않다
      }
    }
  }

  Future<bool> _confirmDiscard() async {
    final s = context.strings;
    final c = AppColors.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.cfTitle),
        content: Text(s.cfBody, style: TextStyle(color: c.textSecondary)),
        actions: [
          Row(
            children: [
              Expanded(
                flex: 10,
                child: FilledButton(
                  style: ghostButtonStyle(c),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(s.cfDiscard, textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 14,
                child: FilledButton(
                  autofocus: true, // 초점·바깥 누름·뒤로는 모두 '계속 쓰기'
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(s.cfKeep, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _logInAgain() async {
    final loggedIn = await Navigator.of(context)
        .push(MaterialPageRoute<bool>(builder: (_) => const LoginScreen(purpose: LoginPurpose.general)));
    if (_here && loggedIn == true) setState(() => _failure = null);
  }

  void _clearError(String field) {
    setState(() {
      _errors = TipFormErrors(
        title: field == 'title' ? null : _errors.title,
        location: field == 'location' ? null : _errors.location,
        note: field == 'note' ? null : _errors.note,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.strings;
    final c = AppColors.of(context);
    final lang = app.language;
    final routeName = widget.route.name.of(lang);

    return PopScope(
      canPop: _posting || !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          _left = true; // 올리는 중에 나갔으면 늦게 온 결과가 이 화면 대신 S02를 닫지 않게
          return;
        }
        final navigator = Navigator.of(context);
        if (await _confirmDiscard() && mounted) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const BackButtonIcon(),
            tooltip: s.back,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: FocusHeading(child: Text(s.addTipTitle)),
        ),
        body: ScrollColumn(
          children: [
            StepSummary(
              color: c.routeColor(widget.route.code),
              label: s.stepLabel,
              line: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$routeName · ${s.stepOf(widget.step.stepNo, widget.stepCount)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' — ${widget.step.title.of(lang)}'),
                  ],
                ),
              ),
            ),
            const Gap(AppSpace.section),
            if (_failure != null) ...[
              _failure == _Failure.sessionEnded
                  ? NoticeBox(
                      kind: NoticeKind.error,
                      message: s.sessionEnded,
                      actionLabel: s.loginAgain,
                      onAction: _logInAgain,
                    )
                  : NoticeBox(kind: NoticeKind.error, message: s.postError, actionLabel: s.retry, onAction: _submit),
              const Gap(AppSpace.section),
            ],
            LabeledField(
              label: s.tTitle,
              controller: _title,
              focusNode: _titleFocus,
              hint: s.titlePh,
              errorText: _errorText(_errors.title, s),
              count: tipFieldCount(_title.text, isNote: false),
              maxCount: tipTitleMax,
              readOnly: _posting,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearError('title'),
              onSubmitted: (_) => _locationFocus.requestFocus(),
            ),
            const Gap(AppSpace.section),
            LabeledField(
              label: s.tLoc,
              controller: _location,
              focusNode: _locationFocus,
              hint: s.locPh,
              errorText: _errorText(_errors.location, s),
              count: tipFieldCount(_location.text, isNote: false),
              maxCount: tipLocationMax,
              readOnly: _posting,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearError('location'),
              onSubmitted: (_) => _noteFocus.requestFocus(),
            ),
            const Gap(AppSpace.section),
            LabeledField(
              label: s.tMemo,
              controller: _note,
              focusNode: _noteFocus,
              hint: s.memoPh,
              errorText: _errorText(_errors.note, s),
              count: tipFieldCount(_note.text, isNote: true),
              maxCount: tipNoteMax,
              readOnly: _posting,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => _clearError('note'),
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
                    onPressed: _posting ? null : _submit,
                    child: Text(_posting ? s.posting : s.submit, textAlign: TextAlign.center),
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
