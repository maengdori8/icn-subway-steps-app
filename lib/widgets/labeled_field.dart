import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

// 입력칸: 라벨 위 · 입력칸 · 아래 줄(왼쪽 오류 문구, 오른쪽 글자 수). 시안 .field와 같은 배치.
// 보이는 라벨은 낭독에서 빼고 입력칸 자체에 같은 이름을 붙인다(라벨과 칸이 따로 읽히지 않게).
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.hint,
    this.errorText,
    this.count,
    this.maxCount,
    this.readOnly = false,
    this.obscureText = false,
    this.secret = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.textInputAction,
    this.keyboardType,
    this.autofillHints,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? errorText;
  final int? count;
  final int? maxCount;
  final bool readOnly; // 올리는 중에는 읽기 전용(입력한 값이 조용히 버려지지 않게)
  final bool obscureText;
  final bool secret; // 비밀번호 칸: [보이기]로 글자를 보여도 키보드 제안·자동고침을 끈다(CR·S04 규칙)
  final int minLines;
  final int maxLines;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final over = count != null && maxCount != null && count! > maxCount!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
        const SizedBox(height: AppSpace.fieldGap),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            obscureText: obscureText,
            enableSuggestions: !(obscureText || secret),
            autocorrect: !(obscureText || secret),
            minLines: minLines,
            maxLines: maxLines,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              fillColor: readOnly ? c.surfaceContainer : null,
              suffixIcon: suffix,
              counter: maxCount == null
                  ? null
                  : Text(
                      '$count/$maxCount',
                      style: TextStyle(
                        fontSize: 12,
                        color: over ? c.error : c.textSecondary,
                        fontWeight: over ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
