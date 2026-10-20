import '../l10n/app_language.dart';

// 경로·단계 안내처럼 서버가 두 언어로 주는 문구. JSON은 {"en": "...", "ko": "..."}.
// 사용자가 쓴 팁(제목·위치·메모)은 쓴 언어 하나뿐이라 이 형식을 쓰지 않는다.
class LocalizedText {
  const LocalizedText({required this.en, required this.ko});

  final String en;
  final String ko;

  String of(AppLanguage language) => language == AppLanguage.ko ? ko : en;

  factory LocalizedText.fromJson(Map<String, dynamic> json) =>
      LocalizedText(en: json['en'] as String, ko: json['ko'] as String);

  Map<String, dynamic> toJson() => {'en': en, 'ko': ko};
}

// 단계의 행동 안내 줄 목록. JSON은 {"en": [...], "ko": [...]}.
class LocalizedLines {
  const LocalizedLines({required this.en, required this.ko});

  final List<String> en;
  final List<String> ko;

  List<String> of(AppLanguage language) => language == AppLanguage.ko ? ko : en;

  factory LocalizedLines.fromJson(Map<String, dynamic> json) =>
      LocalizedLines(en: List<String>.from(json['en'] as List), ko: List<String>.from(json['ko'] as List));

  Map<String, dynamic> toJson() => {'en': en, 'ko': ko};
}
