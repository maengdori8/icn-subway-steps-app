import 'package:flutter/material.dart';

// docs/design-system.json의 tokens.colors(밝게)·tokens.colorsDark(어둡게). 두 벌의 키가 같아 위젯은 키만 쓴다.
// 역할을 섞지 않는다: primary=주요 행동 버튼, signage=상단 바·표지판 칩, routeExpress·routeLocal/onRoute=경로 버튼·띠.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.surfaceContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.outline,
    required this.divider,
    required this.error,
    required this.errorBorder,
    required this.errorSurface,
    required this.statusSurface,
    required this.statusText,
    required this.signage,
    required this.onSignage,
    required this.routeExpress,
    required this.routeLocal,
    required this.onRoute,
    required this.warningSurface,
    required this.warningText,
  });

  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color surfaceContainer;
  final Color textPrimary;
  final Color textSecondary;
  final Color outline;
  final Color divider;
  final Color error;
  final Color errorBorder;
  final Color errorSurface;
  final Color statusSurface;
  final Color statusText;
  final Color signage;
  final Color onSignage;
  final Color routeExpress;
  final Color routeLocal;
  final Color onRoute; // 경로색 위 글자는 반드시 같은 테마의 onRoute
  final Color warningSurface;
  final Color warningText;

  static const light = AppColors(
    primary: Color(0xFF12305F),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF3F5F9),
    textPrimary: Color(0xFF101B2E),
    textSecondary: Color(0xFF4A5874),
    outline: Color(0xFF6E7C97),
    divider: Color(0xFFD4D8E0),
    error: Color(0xFFB3261E),
    errorBorder: Color(0xFFB3261E),
    errorSurface: Color(0xFFFDEBEA),
    statusSurface: Color(0xFFE3F4EA),
    statusText: Color(0xFF1D7A46),
    signage: Color(0xFF12305F),
    onSignage: Color(0xFFFFFFFF),
    routeExpress: Color(0xFFB35300),
    routeLocal: Color(0xFF0B6FA8),
    onRoute: Color(0xFFFFFFFF),
    warningSurface: Color(0xFFFFF4D6),
    warningText: Color(0xFF8A5A00),
  );

  static const dark = AppColors(
    primary: Color(0xFF9DC1FF),
    onPrimary: Color(0xFF0A0F18),
    surface: Color(0xFF111A29),
    surfaceContainer: Color(0xFF1A2638),
    textPrimary: Color(0xFFEEF2F8),
    textSecondary: Color(0xFFA9B6CC),
    outline: Color(0xFF7D8BA5),
    divider: Color(0xFF313C4E),
    error: Color(0xFFFF8A80),
    errorBorder: Color(0xFFFF8A80),
    errorSurface: Color(0xFF3A1614),
    statusSurface: Color(0xFF12301F),
    statusText: Color(0xFF5DD490),
    signage: Color(0xFF0B1E3D),
    onSignage: Color(0xFFFFFFFF),
    routeExpress: Color(0xFFFF9B45),
    routeLocal: Color(0xFF5CB8F0),
    onRoute: Color(0xFF10141C),
    warningSurface: Color(0xFF33270C),
    warningText: Color(0xFFF2C14E),
  );

  static AppColors of(BuildContext context) => Theme.of(context).extension<AppColors>()!;

  // 경로 코드에 맞는 강조색. 준비 중 경로는 outline(시안 .route.soon).
  Color routeColor(String code) => switch (code) {
    'EXPRESS' => routeExpress,
    'LOCAL' => routeLocal,
    _ => outline,
  };

  // 시안의 링크 버튼(+ 팁 등록, 처음부터 등)은 일반열차 파랑을 쓴다(.linkbtn).
  Color get link => routeLocal;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      surface: l(surface, other.surface),
      surfaceContainer: l(surfaceContainer, other.surfaceContainer),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      outline: l(outline, other.outline),
      divider: l(divider, other.divider),
      error: l(error, other.error),
      errorBorder: l(errorBorder, other.errorBorder),
      errorSurface: l(errorSurface, other.errorSurface),
      statusSurface: l(statusSurface, other.statusSurface),
      statusText: l(statusText, other.statusText),
      signage: l(signage, other.signage),
      onSignage: l(onSignage, other.onSignage),
      routeExpress: l(routeExpress, other.routeExpress),
      routeLocal: l(routeLocal, other.routeLocal),
      onRoute: l(onRoute, other.onRoute),
      warningSurface: l(warningSurface, other.warningSurface),
      warningText: l(warningText, other.warningText),
    );
  }
}
