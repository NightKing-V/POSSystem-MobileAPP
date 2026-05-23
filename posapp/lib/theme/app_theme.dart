import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF000101);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1A1C1E);
  static const Color onPrimaryContainer = Color(0xFF838486);

  // Secondary (accent blue)
  static const Color secondary = Color(0xFF0453CD);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF356EE7);
  static const Color onSecondaryContainer = Color(0xFFFEFCFF);
  static const Color secondaryFixed = Color(0xFFDAE2FF);
  static const Color secondaryFixedDim = Color(0xFFB2C5FF);
  static const Color onSecondaryFixedVariant = Color(0xFF0040A2);

  // Surface
  static const Color background = Color(0xFFFCF8F8);
  static const Color surface = Color(0xFFFCF8F8);
  static const Color surfaceDim = Color(0xFFDDD9D9);
  static const Color surfaceContainer = Color(0xFFF1EDED);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainerHigh = Color(0xFFEBE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color surfaceVariant = Color(0xFFE5E2E1);

  // On-surface
  static const Color onBackground = Color(0xFF1C1B1B);
  static const Color onSurface = Color(0xFF1C1B1B);
  static const Color onSurfaceVariant = Color(0xFF44474A);

  // Outline
  static const Color outline = Color(0xFF75777A);
  static const Color outlineVariant = Color(0xFFC5C6CA);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Inverse
  static const Color inverseOnSurface = Color(0xFFF4F0EF);
  static const Color inverseSurface = Color(0xFF313030);
  static const Color inversePrimary = Color(0xFFC6C6C9);
}

class AppTypography {
  static const String fontFamily = 'Inter';

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.25,
    letterSpacing: -0.02 * 32,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.38,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.45,
    letterSpacing: 0.05 * 11,
    fontWeight: FontWeight.w700,
  );
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
        labelStyle: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: AppTypography.titleSm,
          elevation: 0,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.secondary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
    );
  }
}