import 'package:flutter/material.dart';

abstract final class AppColors {
  // --- Surfaces ---
  static const background = Color(0xFF0B0D14);
  static const surface = Color(0xFF12151E);
  static const surfaceDim = Color(0xFF0B0D14);
  static const surfaceContainer = Color(0xFF181B26);
  static const surfaceContainerLow = Color(0xFF14171F);
  static const surfaceContainerLowest = Color(0xFF060810);
  static const surfaceContainerHigh = Color(0xFF1E2230);
  static const surfaceContainerHighest = Color(0xFF262A3A);
  static const surfaceBright = Color(0xFF2E3344);

  // --- Primary (Refined teal) ---
  static const primary = Color(0xFF7DD3C0);
  static const primaryContainer = Color(0xFF3ECFB4);
  static const primaryFixedDim = Color(0xFF2AB89E);
  static const primaryFixed = Color(0xFFB2F0E2);
  static const onPrimary = Color(0xFF00201A);
  static const onPrimaryContainer = Color(0xFF003E32);
  static const surfaceTint = Color(0xFF3ECFB4);

  static const List<Color> ctaGradient = [
    Color(0xFF3ECFB4),
    Color(0xFF2AB89E),
  ];

  // --- Semantic ---
  static const error = Color(0xFFEF6B6B);
  static const errorContainer = Color(0xFF5C1A1A);
  static const onErrorContainer = Color(0xFFFFDADA);
  static const danger = Color(0xFFEF6B6B);
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);

  static const accent = Color(0xFFA78BFA);

  // --- Text ---
  static const onSurface = Color(0xFFF0F2F8);
  static const onSurfaceVariant = Color(0xFF8B92A8);
  static const textPrimary = onSurface;
  static const textSecondary = onSurfaceVariant;
  static const textTertiary = Color(0xFF5C6378);

  // --- Borders ---
  static const outline = Color(0xFF5C6378);
  static const outlineVariant = Color(0xFF262A3A);

  static Color get divider => outlineVariant.withValues(alpha: 0.6);

  static const secondary = Color(0xFF94A3B8);
  static const secondaryContainer = Color(0xFF2E3344);

  static Color get ctaGlow => primaryContainer.withValues(alpha: 0.25);
  static Color get accentGlow => accent.withValues(alpha: 0.2);
}
