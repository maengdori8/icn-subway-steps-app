import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

// 화면 제목. 화면이 열리면 키보드·화면 낭독기 초점을 여기로 옮긴다(시안: 화면 전환 시 제목 초점).
class FocusHeading extends StatefulWidget {
  const FocusHeading({
    super.key,
    required this.child,
    this.semanticsLabel,
    this.autofocus = true,
    this.liveRegion = false,
  });

  final Widget child;
  final String? semanticsLabel; // 보이는 글자와 다르게 읽을 때(예: 'Step 3 of 5: ...')
  final bool autofocus;
  final bool liveRegion; // 내용이 바뀌면 낭독(단계 이동)

  @override
  State<FocusHeading> createState() => _FocusHeadingState();
}

class _FocusHeadingState extends State<FocusHeading> {
  final FocusNode _node = FocusNode(debugLabel: 'heading');

  @override
  void initState() {
    super.initState();
    if (widget.autofocus) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? true)) _node.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.semanticsLabel;
    return Focus(
      focusNode: _node,
      child: Semantics(
        header: true,
        liveRegion: widget.liveRegion,
        label: label,
        excludeSemantics: label != null,
        child: widget.child,
      ),
    );
  }
}

// 작은 대문자 머리말(시안 .eyebrow, .group > h2).
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.header = false});

  final String text;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium;
    return Semantics(
      header: header,
      child: Text(text.toUpperCase(), style: style),
    );
  }
}

// 상태 배지(확인됨·정보 오래됨·준비 중·예시). 색과 문구를 함께 쓴다.
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, required this.background, required this.foreground, this.liveRegion = false});

  final String text;
  final Color background;
  final Color foreground;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: liveRegion,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.chip)),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: foreground),
      ),
    ),
  );
}

enum NoticeKind { error, warning, info }

// 화면 안 알림 상자(실패·권한 없음). 다음 행동 버튼을 함께 둔다.
class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key, required this.kind, required this.message, this.actionLabel, this.onAction});

  final NoticeKind kind;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final (bg, fg) = switch (kind) {
      NoticeKind.error => (c.errorSurface, c.error),
      NoticeKind.warning => (c.warningSurface, c.warningText),
      NoticeKind.info => (c.surfaceContainer, c.textPrimary),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(message, style: TextStyle(color: fg, fontSize: 14)),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: fg),
              child: Text(actionLabel!, style: const TextStyle(decoration: TextDecoration.underline)),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// 가운데 안내(빈 목록·오프라인·읽기 실패·로그인 필요). 제목·설명·버튼(statusMessage).
// 연결 끊김만 위에 그림을, 버튼 아래에 한 줄 메모를 더한다(OfflineMessage, 2026-10-21 사용자 요청).
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
    this.image,
    this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.note,
    this.focusTitle = true,
  });

  final Widget? image;
  final String? title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? note; // 버튼 아래 작은 안내(예: 연결되면 자동으로 불러옴)
  final bool focusTitle;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
      child: Column(
        children: [
          if (image != null) ...[image!, const SizedBox(height: AppSpace.section)],
          if (title != null) ...[
            FocusHeading(
              autofocus: focusTitle,
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (body != null)
            Text(
              body!,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary),
            ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
          if (note != null) ...[
            const SizedBox(height: AppSpace.card),
            Text(
              note!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

// 불러오는 중 자리 표시(경로 카드·팁 카드 모양).
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.height = 88, this.radius = AppRadius.card});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}

// 불러오는 중이 8초를 넘으면 문구 아래에 '느린 연결' 한 줄을 더한다(UH 시간 초과 규칙, CR 불러오는 중 규칙).
// 불러오는 중 화면에만 두므로 응답이 오거나 화면을 떠나면 이 위젯과 함께 사라지고 타이머도 정리된다.
// 같은 자리에서 요청을 새로 보내면 key(요청 번호)를 바꿔 8초를 다시 센다.
class SlowConnectionNote extends StatefulWidget {
  const SlowConnectionNote({super.key, required this.message, this.style});

  static const after = Duration(seconds: 8);

  final String message;
  final TextStyle? style; // 위 불러오는 중 문구와 같은 모양(주지 않으면 textSecondary 본문)

  @override
  State<SlowConnectionNote> createState() => _SlowConnectionNoteState();
}

class _SlowConnectionNoteState extends State<SlowConnectionNote> {
  late final Timer _timer;
  bool _slow = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SlowConnectionNote.after, () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_slow) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Text(widget.message, style: widget.style ?? TextStyle(color: AppColors.of(context).textSecondary)),
    );
  }
}

// 화면 본문 스크롤. ListView(지연 생성)를 쓰지 않는 이유: 스크롤로 제목이 다시 만들어지면
// 제목 초점(FocusHeading)이 다시 걸려 사용자가 있던 곳에서 초점을 빼앗기 때문.
class ScrollColumn extends StatelessWidget {
  const ScrollColumn({super.key, required this.children, this.controller});

  final List<Widget> children;
  final ScrollController? controller; // 본문을 맨 위로 올려야 하는 화면(S02 단계 이동 등)이 넘긴다

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    controller: controller,
    padding: const EdgeInsets.all(AppSpace.page),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
  );
}

// 세로로 쌓되 간격을 일정하게(시안 .screen gap 16, .stack gap 10).
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size, width: size);
}
