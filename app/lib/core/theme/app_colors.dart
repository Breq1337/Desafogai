import 'package:flutter/material.dart';

/// Paleta avançada para “Cinematic Financial Intelligence” — cyan neon vibrante, preto profundo, efeitos glow.
abstract final class AppColors {
  // --- Superfícies (Material-style / Stitch) ---
  static const background = Color(0xFF0A0E27); // Preto azulado profundo
  static const surface = Color(0xFF0F1329);
  static const surfaceDim = Color(0xFF0A0E27);
  static const surfaceContainer = Color(0xFF1A1F3A);
  static const surfaceContainerLow = Color(0xFF131829);
  static const surfaceContainerLowest = Color(0xFF050709);
  static const surfaceContainerHigh = Color(0xFF252D4A);
  static const surfaceContainerHighest = Color(0xFF2F3856);
  static const surfaceBright = Color(0xFF3D465E);

  // --- Primária (Cyan Neon) ---
  static const primaryContainer = Color(0xFF00D9FF); // Cyan vibrante
  static const primaryFixedDim = Color(0xFF00B8D4); // Cyan médio
  static const primaryFixed = Color(0xFF7FFFFF); // Cyan claro
  /// Texto/ícones em destaque “soft cyan”
  static const primary = Color(0xFFE0FFFF);
  static const onPrimary = Color(0xFF001820);
  static const onPrimaryContainer = Color(0xFF004D57);
  static const surfaceTint = Color(0xFF00D9FF);

  /// Gradiente de CTAs (botões principais) — neon mais vibrante
  static const List<Color> ctaGradient = [primaryContainer, primaryFixedDim];

  // --- Semânticas ---
  static const error = Color(0xFFFF4757); // Vermelho neon
  static const errorContainer = Color(0xFF7D0009);
  static const onErrorContainer = Color(0xFFFFE0E0);
  static const danger = Color(0xFFFF3B30);
  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFFA500);

  /// Destaque secundário — magenta/purple
  static const accent = Color(0xFFE01BFF);

  // --- Texto ---
  static const onSurface = Color(0xFFF0F4FF);
  static const onSurfaceVariant = Color(0xFFB0BFD9);
  static const textPrimary = onSurface;
  static const textSecondary = onSurfaceVariant;

  // --- Linhas / divisores ---
  static const outline = Color(0xFF7A8DAE);
  static const outlineVariant = Color(0xFF2D3D5F);

  static Color get divider => outlineVariant.withValues(alpha: 0.25);

  static const secondary = Color(0xFFAEBFD9);
  static const secondaryContainer = Color(0xFF3A4A62);

  /// Sombra “glow” cyan para botões — intenso
  static Color get ctaGlow => primaryContainer.withValues(alpha: 0.5);

  /// Glow magenta para destaque secundário
  static Color get accentGlow => accent.withValues(alpha: 0.45);
}
