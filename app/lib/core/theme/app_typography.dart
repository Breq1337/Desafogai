import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Stitch: Inter para títulos e corpo; Space Grotesk para labels técnicos (uppercase, tracking).
abstract final class AppTypography {
  static TextTheme get textTheme => TextTheme(
        displayLarge: _display(57),
        displayMedium: _display(45),
        displaySmall: _display(36),
        headlineLarge: _display(32),
        headlineMedium: _display(28),
        headlineSmall: _display(24),
        titleLarge: _display(22),
        titleMedium: _display(16, weight: FontWeight.w700),
        titleSmall: _display(14, weight: FontWeight.w700),
        bodyLarge: _body(16),
        bodyMedium: _body(14),
        bodySmall: _body(12),
        labelLarge: _label(14, weight: FontWeight.w600),
        labelMedium: _label(12, weight: FontWeight.w600),
        labelSmall: _label(10, weight: FontWeight.w700),
      );

  static TextStyle _display(
    double size, {
    FontWeight weight = FontWeight.w800,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: -0.02 * size,
        height: 1.12,
        color: AppColors.textPrimary,
      );

  static TextStyle _body(
    double size, {
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: 1.45,
        color: AppColors.textPrimary,
      );

  static TextStyle _label(
    double size, {
    FontWeight weight = FontWeight.w600,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      );

  static String get headlineFamily => 'Inter';
  static String get labelFamily => 'Space Grotesk';
}
