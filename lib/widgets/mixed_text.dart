import 'package:flutter/material.dart';

import '../l10n/app_language.dart';

final RegExp _markup = RegExp(r'\{(ko|en)\|([^}]+)\}');

// '... Airport Railroad ({ko|공항철도}).' 처럼 다른 언어 구절을 표시한 문구를 TextSpan으로 나눈다.
// 각 조각에 locale을 달아 화면 낭독기가 그 언어 목소리로 읽고, 글꼴도 그 언어에 맞게 고른다(4차 DEC-08).
List<InlineSpan> mixedSpans(String text, {TextStyle? style}) {
  final spans = <InlineSpan>[];
  var start = 0;
  for (final m in _markup.allMatches(text)) {
    if (m.start > start) spans.add(TextSpan(text: text.substring(start, m.start), style: style));
    spans.add(TextSpan(text: m.group(2), locale: Locale(m.group(1)!), style: style));
    start = m.end;
  }
  if (start < text.length) spans.add(TextSpan(text: text.substring(start), style: style));
  return spans;
}

// 표시 없이 읽을 때의 글자(검색·낭독 이름용).
String plainMixed(String text) => text.replaceAllMapped(_markup, (m) => m.group(2)!);

class MixedText extends StatelessWidget {
  const MixedText(this.text, {super.key, required this.language, this.style});

  final String text;
  final AppLanguage language; // 표시 없는 부분의 언어
  final TextStyle? style;

  @override
  Widget build(BuildContext context) =>
      Text.rich(TextSpan(locale: language.locale, style: style, children: mixedSpans(text)));
}
