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

enum _Failure { postFailed, sessionEnded, unknownResult }

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
  TipDraft? _sentDraft; // 마지막으로 보낸 등록. 시간 초과 뒤 [팁 목록 확인]이 이 값과 같은 팁을 찾는다
  int? _sentUserId; // 그 등록을 보낸 사용자. 확인은 지금 로그인과 관계없이 ownerId로 맞춘다

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
    TipFieldError.rejected => s.errCheckField,
    null => null,
  };

  static const _tipFields = {'title', 'location', 'note'};

  // 서버 400 errors의 칸 이름(title·location·note)을 칸 오류로 바꾼다(P01 결정 4). 서버 문구는 한국어뿐이라 쓰지 않고,
  // 앱 규칙을 다시 돌려 맞는 종류가 있으면 그 문구, 없으면 일반 문구('이 칸을 다시 확인하세요')를 보인다.
  TipFormErrors _serverFieldErrors(Set<String> fields) {
    final rules = validateTip(title: _title.text, location: _location.text, note: _note.text);
    TipFieldError? pick(String field, TipFieldError? rule) =>
        fields.contains(field) ? (rule ?? TipFieldError.rejected) : null;
    return TipFormErrors(
      title: pick('title', rules.title),
      location: pick('location', rules.location),
      note: pick('note', rules.note),
    );
  }

  // 첫 오류 칸(제목 → 위치 → 메모)에 초점을 준다.
  void _focusFirstError(TipFormErrors errors) {
    if (errors.isEmpty) return;
    (errors.title != null
            ? _titleFocus
            : errors.location != null
            ? _locationFocus
            : _noteFocus)
        .requestFocus();
  }

  Future<void> _submit() async {
    if (_posting) return;
    // 시간 초과로 결과를 모르면 다시 보내기 전에 목록부터 확인한다(하단 버튼도 같은 길, Codex 10장 2회차 지적 1).
    if (_failure == _Failure.unknownResult) return _checkPosted();
    final errors = validateTip(title: _title.text, location: _location.text, note: _note.text);
    if (!errors.isEmpty) {
      setState(() {
        _errors = errors;
        _failure = null;
      });
      _focusFirstError(errors);
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
    final generation = app.sessionGeneration;
    final navigator = Navigator.of(context);
    setState(() {
      _posting = true;
      _request = request;
      _failure = null;
    });
    try {
      final tip = await app.repository.createTip(draft, session);
      app.tipPosted(tip, generation: generation);
      if (_here && _request == request) navigator.pop(tip); // 화면을 옮긴 뒤 알림을 띄운다
      app.showMessage((s) => s.posted);
    } on RepositoryException catch (e) {
      // 401: 요청을 보낸 세션이 아직 지금 세션이면 끝낸다(만료 토큰을 다시 쓰지 않게). 입력값은 그대로 둔다.
      if (e.code == RepositoryErrorCode.unauthorized) app.sessionExpired(generation);
      if (_here && _request == request) {
        final fieldErrors = e.code == RepositoryErrorCode.validation
            ? _serverFieldErrors(e.fieldErrors)
            : const TipFormErrors();
        setState(() {
          _posting = false;
          _request = null;
          _sentDraft = draft;
          _sentUserId = session.userId;
          _errors = fieldErrors;
          _failure = switch (e.code) {
            RepositoryErrorCode.unauthorized => _Failure.sessionEnded,
            // 응답 없음: 서버에 저장됐을 수 있어 바로 다시 보내지 않고 목록부터 확인하게 한다(교재 10장 2.5·Q04).
            RepositoryErrorCode.timeout => _Failure.unknownResult,
            // 400이 입력칸 이름만 주면 칸 아래 오류로 알린다. 칸이 아닌 이름(route·stepNo 등)이 있거나 이름이 없으면 상자.
            RepositoryErrorCode.validation when !fieldErrors.isEmpty && e.fieldErrors.every(_tipFields.contains) => null,
            _ => _Failure.postFailed,
          };
        });
        _focusFirstError(fieldErrors);
      } else {
        app.showMessage((s) => s.postErrorClosed); // 이미 화면을 떠났다. 입력값은 남아 있지 않다
      }
    }
  }

  // 시간 초과 뒤 [팁 목록 확인]: 그 단계의 팁을 서버에서 읽어, 보낸 값과 같은 팁(보낸 사용자·제목·위치·메모)이 있으면
  // 닫는다. 없으면 그때 다시 올리기를 보인다(같은 등록을 확인 없이 두 번 보내 중복을 만들지 않게).
  // 공개 GET이라 그사이 로그인이 바뀌거나 끝나도 확인할 수 있다(Codex 10장 2회차 지적 3).
  Future<void> _checkPosted() async {
    final app = AppScope.read(context);
    final draft = _sentDraft;
    final ownerId = _sentUserId;
    if (draft == null || ownerId == null || _posting) return;
    final request = app.nextRequestId();
    final generation = app.sessionGeneration;
    final navigator = Navigator.of(context);
    setState(() {
      _posting = true;
      _request = request;
    });
    try {
      final tips = await app.repository.fetchTips(draft.route, draft.stepNo, session: app.session);
      if (!_here || _request != request) return;
      final same = tips.where(
        (t) => t.ownerId == ownerId && t.title == draft.title && t.location == draft.location && t.note == draft.note,
      );
      if (same.isNotEmpty) {
        // 이번 요청이 저장한 것인지 앞서 올린 같은 팁인지는 구별할 수 없어 '같은 팁이 있다'고만 알린다(지적 2).
        app.tipPosted(same.first, generation: generation);
        navigator.pop(same.first);
        app.showMessage((s) => s.postFound);
        return;
      }
      setState(() {
        _posting = false;
        _request = null;
        _failure = _Failure.postFailed;
      });
    } on RepositoryException catch (e) {
      // 401(만료 토큰)이면 그 세션을 끝낸다. 결과는 여전히 모르므로 확인 안내를 남긴다(다시 누르면 토큰 없이 읽는다).
      if (e.code == RepositoryErrorCode.unauthorized) app.sessionExpired(generation);
      if (!_here || _request != request) return;
      setState(() {
        _posting = false;
        _request = null;
        _failure = _Failure.unknownResult;
      });
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
              switch (_failure!) {
                _Failure.sessionEnded => NoticeBox(
                  kind: NoticeKind.error,
                  message: s.sessionEnded,
                  actionLabel: s.loginAgain,
                  onAction: _logInAgain,
                ),
                _Failure.unknownResult => NoticeBox(
                  kind: NoticeKind.warning,
                  message: s.postUnknown,
                  actionLabel: s.checkTips,
                  onAction: _checkPosted,
                ),
                _Failure.postFailed => NoticeBox(
                  kind: NoticeKind.error,
                  message: s.postError,
                  actionLabel: s.retry,
                  onAction: _submit,
                ),
              },
              const Gap(AppSpace.section),
            ],
            LabeledField(
              label: s.tTitle,
              controller: _title,
              focusNode: _titleFocus,
              hint: s.titlePh,
              errorText: _errorText(_errors.title, s),
              count: tipFieldCount(_title.text),
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
              count: tipFieldCount(_location.text),
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
              count: tipFieldCount(_note.text),
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
