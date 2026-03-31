import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.primaryContainer,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          onSurface: AppColors.onSurface,
          outline: AppColors.outline,
          surfaceContainerHighest: AppColors.surfaceContainerHigh,
        ),
        textTheme: AppTypography.textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            elevation: 8,
            shadowColor: AppColors.primaryContainer,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryContainer,
            side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryContainer,
              width: 2,
            ),
          ),
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
          thickness: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceContainerHigh,
          contentTextStyle: const TextStyle(color: AppColors.textPrimary),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
