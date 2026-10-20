import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

// 간격·모서리·크기(design-system.json tokens.spacing·radii·sizes).
class AppSpace {
  static const double page = 18;
  static const double fieldGap = 6;
  static const double section = 16;
  static const double card = 12;
}

class AppRadius {
  static const double button = 12;
  static const double input = 10;
  static const double card = 14;
  static const double chip = 999;
}

class AppSizes {
  static const double minimumTap = 48; // flutterAdaptations.sizes.minimumTap
  static const double button = 52; // 시안 .btn min-height
  static const double appBar = 56;
}

// 글자(design-system.json typography + flutterAdaptations). 웹 본문 15 → Flutter 16, 캡션 11 → 12.
// 글꼴은 플랫폼 기본(시안의 Noto Sans KR·Barlow Semi Condensed를 기기에 있다고 가정하지 않음).
TextTheme _textTheme(AppColors c) => TextTheme(
  headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2, color: c.textPrimary),
  titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25, color: c.textPrimary),
  titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4, color: c.textPrimary),
  bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.55, color: c.textPrimary),
  bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.55, color: c.textPrimary),
  bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: c.textSecondary),
  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary),
  labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: c.textSecondary),
);

const _buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

ThemeData buildAppTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    secondary: c.routeLocal,
    onSecondary: c.onRoute,
    error: c.error,
    onError: c.surface,
    surface: c.surface,
    onSurface: c.textPrimary,
    onSurfaceVariant: c.textSecondary,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.surfaceContainer,
    surfaceContainer: c.surfaceContainer,
    surfaceContainerHigh: c.surfaceContainer,
    surfaceContainerHighest: c.surfaceContainer,
    outline: c.outline,
    outlineVariant: c.divider,
    inverseSurface: c.textPrimary, // 성공 알림: textPrimary 바탕 · surface 글자(feedbackBanner.success)
    onInverseSurface: c.surface,
  );
  final text = _textTheme(c);
  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.input),
    borderSide: BorderSide(color: c.outline, width: 1.5),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.surface,
    textTheme: text,
    extensions: [c],
    dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.signage,
      foregroundColor: c.onSignage,
      toolbarHeight: AppSizes.appBar,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: c.onSignage),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.primary.withValues(alpha: 0.16),
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? c.textPrimary : c.textSecondary,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(color: states.contains(WidgetState.selected) ? c.primary : c.textSecondary),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        disabledBackgroundColor: c.primary.withValues(alpha: 0.45),
        disabledForegroundColor: c.onPrimary,
        minimumSize: const Size(AppSizes.minimumTap, AppSizes.button),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        textStyle: _buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.link,
        disabledForegroundColor: c.textSecondary,
        minimumSize: const Size(AppSizes.minimumTap, AppSizes.minimumTap),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.all(12),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.primary, width: 2)),
      errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.errorBorder, width: 1.5)),
      focusedErrorBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.errorBorder, width: 2)),
      // 예시 글자는 textSecondary를 불투명도 1로(플랫폼 기본값에 맡기지 않음)
      hintStyle: TextStyle(color: c.textSecondary, fontSize: 16),
      errorStyle: TextStyle(color: c.error, fontSize: 13, fontWeight: FontWeight.w500),
      errorMaxLines: 3,
      helperMaxLines: 3,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.textPrimary,
      contentTextStyle: TextStyle(color: c.surface, fontSize: 16, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
  );
}

// 경로색 버튼(S02 '다음'). 글자는 onRoute(어두운 테마에서 흰 글자를 쓰면 대비 미달).
ButtonStyle routeButtonStyle(AppColors c, Color routeColor) => FilledButton.styleFrom(
  backgroundColor: routeColor,
  foregroundColor: c.onRoute,
  disabledBackgroundColor: routeColor.withValues(alpha: 0.45),
  disabledForegroundColor: c.onRoute,
);

// 연한 배경의 보조 버튼(이전·취소·경로 목록으로).
ButtonStyle ghostButtonStyle(AppColors c) => FilledButton.styleFrom(
  backgroundColor: c.surfaceContainer,
  foregroundColor: c.textPrimary,
  disabledBackgroundColor: c.surfaceContainer.withValues(alpha: 0.6),
  disabledForegroundColor: c.textPrimary.withValues(alpha: 0.45),
);
