import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/tip.dart';
import '../theme/app_colors.dart';
import 'common.dart';

// 팁 상태 배지: 예시 / 작성자 확인 · 날짜 / 작성자가 오래됨 표시 · 날짜.
class TipStatusPill extends StatelessWidget {
  const TipStatusPill({super.key, required this.tip, required this.strings});

  final Tip tip;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (tip.isExample) return Pill(strings.example, background: c.textSecondary, foreground: c.surface);
    return tip.status == TipStatus.verified
        ? Pill(strings.checked(tip.verifiedAt), background: c.statusSurface, foreground: c.statusText, liveRegion: true)
        : Pill(
            strings.outdated(tip.verifiedAt),
            background: c.warningSurface,
            foreground: c.warningText,
            liveRegion: true,
          );
  }
}

// 팁 카드(S02 팁 영역, S06 내 팁). 상태 바꾸기는 그 팁을 올린 사용자에게만 보인다.
class TipCard extends StatelessWidget {
  const TipCard({
    super.key,
    required this.tip,
    required this.strings,
    this.author,
    this.where,
    this.fresh = false,
    this.canToggle = false,
    this.busy = false,
    this.toggleBlocked = false,
    this.onToggle,
    this.notice,
    this.leadingAction,
  });

  final Tip tip;
  final AppStrings strings;
  final String? author; // S02: 샘플 / 내가 올림 / 여행객. S06에서는 쓰지 않는다
  final String? where; // S06: '직통열차 · 5단계 중 3단계'
  final bool fresh; // 방금 올린 팁 강조
  final bool canToggle;
  final bool busy; // 이 카드만의 '저장 중'(4차 REG-06)
  final bool toggleBlocked; // 권한 없음 응답 뒤 다시 로그인할 때까지 막음
  final VoidCallback? onToggle;
  final Widget? notice;
  final Widget? leadingAction; // S06 '이 단계 보기'

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final meta = author == null ? tip.location : '${tip.location} · $author';
    final toggleLabel = busy ? strings.saving : (tip.status == TipStatus.verified ? strings.markOld : strings.markOk);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: c.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fresh ? c.primary : Colors.transparent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (where != null) ...[
            Text(where!, style: TextStyle(fontSize: 13, color: c.textSecondary)),
            const SizedBox(height: 4),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(tip.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              TipStatusPill(tip: tip, strings: strings),
            ],
          ),
          if (tip.note != null) ...[const SizedBox(height: 4), Text(tip.note!, style: const TextStyle(fontSize: 14))],
          const SizedBox(height: 4),
          Text(meta, style: TextStyle(fontSize: 12, color: c.textSecondary)),
          if (notice != null) ...[const SizedBox(height: 8), notice!],
          if (leadingAction != null || canToggle)
            Wrap(
              spacing: 8,
              children: [
                ?leadingAction,
                if (canToggle) TextButton(onPressed: busy || toggleBlocked ? null : onToggle, child: Text(toggleLabel)),
              ],
            ),
        ],
      ),
    );
  }
}
