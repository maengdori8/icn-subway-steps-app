import 'package:flutter/widgets.dart';

// 앱이 지원하는 언어. 영어가 기본이고 설정(S05)에서만 바꾼다.
enum AppLanguage {
  en('en', 'English', 'EN'),
  ko('ko', '한국어', 'KO');

  const AppLanguage(this.code, this.nativeName, this.shortCode);

  final String code; // shared_preferences에 저장하는 값
  final String nativeName; // 설정의 언어 목록은 각 언어를 그 언어로 쓴다
  final String shortCode;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.code == code, orElse: () => AppLanguage.en);
}
