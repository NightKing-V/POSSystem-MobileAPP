import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the app.
///
/// Signature direction: this is a POS app, so the palette and type
/// borrow from receipts and market signage rather than a generic
/// SaaS dashboard look. Keep new UI consistent with these tokens
/// instead of picking one-off colors per screen.
class AppColors {
  AppColors._();

  static const inkTeal = Color(0xFF153E8A); //deep cobalt, from logo gradient
  static const paper = Color(0xFFF7F3EC); // warm background, like receipt paper
  static const marigold = Color(0xFF1FD6C7); // cyan accent, from logo gradient
  static const ink = Color(0xFF1B2521); // primary text
  static const slate = Color(0xFF6B7280); // secondary text / hints
  static const hairline = Color(0xFFE1DACB); // dividers, field borders
  static const error = Color(0xFFC0392B);
}

class AppText {
  AppText._();

  static TextTheme get textTheme => TextTheme(
    displaySmall: GoogleFonts.sora(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
      height: 1.2,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.slate,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.paper,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
      letterSpacing: 0.2,
    ),
  );

  static ThemeData themeData() {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Clean off-white background
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.inkTeal,
        primary: AppColors.inkTeal,
        secondary: AppColors.marigold,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.hairline, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.inkTeal, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.error, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.slate, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.slate, fontSize: 14),
      ),
    );
  }
}