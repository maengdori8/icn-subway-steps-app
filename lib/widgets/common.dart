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

// 가운데 안내(빈 목록·오프라인·읽기 실패·로그인 필요). 아이콘 없이 제목·설명·버튼만(statusMessage).
class StatusMessage extends StatelessWidget {
  const StatusMessage({super.key, this.title, this.body, this.actionLabel, this.onAction, this.focusTitle = true});

  final String? title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool focusTitle;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
      child: Column(
        children: [
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

// 화면 본문 스크롤. ListView(지연 생성)를 쓰지 않는 이유: 스크롤로 제목이 다시 만들어지면
// 제목 초점(FocusHeading)이 다시 걸려 사용자가 있던 곳에서 초점을 빼앗기 때문.
class ScrollColumn extends StatelessWidget {
  const ScrollColumn({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
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
