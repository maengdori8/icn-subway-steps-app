import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/app_strings.dart';
import '../models/guide_step.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'mixed_text.dart';

// 진행 표시: 큰 숫자 '현재/전체'와 단계 수만큼의 막대. 숫자는 낭독에서 빼고 단계 제목이 'Step n of N'을 읽는다.
class StepProgress extends StatelessWidget {
  const StepProgress({
    super.key,
    required this.index,
    required this.count,
    required this.color,
    required this.strings,
    this.trailing,
  });

  final int index; // 0부터. count와 같으면 완료
  final int count;
  final Color color;
  final AppStrings strings;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final done = index >= count;
    final number = Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: c.textPrimary, height: 1),
        children: done
            ? [
                TextSpan(text: '$count/$count '),
                TextSpan(
                  text: strings.doneLabel,
                  style: TextStyle(fontSize: 15, color: c.textSecondary),
                ),
              ]
            : [
                TextSpan(text: '${index + 1}'),
                TextSpan(
                  text: '/$count',
                  style: TextStyle(fontSize: 15, color: c.textSecondary),
                ),
              ],
      ),
    );
    final bars = ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: i <= index ? color : c.outline.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
    final head = [ExcludeSemantics(child: number), const SizedBox(width: 12), Expanded(child: bars)];
    if (trailing == null) return Row(children: head);
    // 글자를 1.3배 이상 키우면 '전체 단계' 버튼을 막대 아래 줄로 내린다(한 줄에 넣으면 넘침).
    if (MediaQuery.textScalerOf(context).scale(10) / 10 >= 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: head),
          Align(alignment: Alignment.centerRight, child: trailing),
        ],
      );
    }
    return Row(children: [...head, const SizedBox(width: 8), trailing!]);
  }
}

IconData stepIconData(StepIcon icon) => switch (icon) {
  StepIcon.plane => Icons.flight_land,
  StepIcon.escalator => Icons.escalator,
  StepIcon.train => Icons.train,
};

// 역할 라벨(현재 위치 / 이 표지판을 찾으세요)과 남색 표지판 칩. 표지판 글자는 언어와 관계없이 한·영 병기.
// 4차 VIS-02·DEC-05: 역할 라벨 14 본문색, 칩의 영어도 21·불투명.
class SignChip extends StatelessWidget {
  const SignChip({super.key, required this.step, required this.strings});

  final GuideStep step;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final signStyle = TextStyle(fontSize: 21, height: 1.25, color: c.onSignage);
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (step.role == SignRole.here ? strings.roleHere : strings.roleFind).toUpperCase(),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: c.textPrimary),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: c.signage,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.onSignage.withValues(alpha: 0.22)),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ExcludeSemantics(child: Icon(stepIconData(step.icon), size: 26, color: c.onSignage)),
                Text.rich(
                  TextSpan(
                    text: step.signKo,
                    locale: AppLanguage.ko.locale,
                    style: signStyle.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: step.signEn,
                    locale: AppLanguage.en.locale,
                    style: signStyle.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 단계 사진 한 장(4:3). 사진이 없으면 같은 크기의 '사진 준비 중' 자리표시(칩 위치가 단계마다 흔들리지 않게).
class StepPhoto extends StatelessWidget {
  const StepPhoto({super.key, required this.step, required this.language, required this.strings});

  final GuideStep step;
  final AppLanguage language;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final url = step.photoUrl;
    if (url == null) {
      // 4:3 칸 안에는 아이콘과 '사진 준비 중'만 둔다. 설명 줄('아래 표지판과 안내를 따라가세요')은
      // 사진 출처와 같은 자리(칸 아래)에 보여, 글자를 키워도 칸 안이 넘치지 않는다.
      return Container(
        color: c.surfaceContainer,
        padding: const EdgeInsets.all(12),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Icon(Icons.photo_camera_outlined, size: 32, color: c.textSecondary)),
            const SizedBox(height: 8),
            Text(
              strings.noPhoto,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
            ),
          ],
        ),
      );
    }
    // 사진은 두 테마에서 같은 원본을 쓰고 밝기를 바꾸지 않는다. 대체 문구는 지금 언어의 표지판 이름 하나로.
    final alt = language == AppLanguage.ko ? step.signKo : step.signEn;
    final image = url.startsWith('http')
        ? Image.network(url, fit: BoxFit.cover, semanticLabel: alt)
        : Image.asset(url, fit: BoxFit.cover, semanticLabel: alt);
    return image;
  }
}

// 행동 안내 2줄 목록(경로색 점).
class StepActions extends StatelessWidget {
  const StepActions({super.key, required this.lines, required this.color, required this.language});

  final List<String> lines;
  final Color color;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 9, left: 4, right: 12),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
              Expanded(child: MixedText(line, language: language)),
            ],
          ),
        ),
    ],
  );
}

// 단계 요약 줄(S03): 경로색 띠 + '직통열차 · 3단계 — 승차권 사기'.
class StepSummary extends StatelessWidget {
  const StepSummary({super.key, required this.color, required this.label, required this.line});

  final Color color;
  final String label;
  final Widget line;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(color: c.surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12).copyWith(right: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 2),
                    line,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 경로색 강조 버튼(S02 다음·다시 보기). 글자는 onRoute.
class RouteButton extends StatelessWidget {
  const RouteButton({super.key, required this.color, required this.onPressed, required this.child});

  final Color color;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      FilledButton(style: routeButtonStyle(AppColors.of(context), color), onPressed: onPressed, child: child);
}
