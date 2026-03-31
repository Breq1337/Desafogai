import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/core/theme/app_typography.dart';
import 'package:desafog_ai/core/theme/app_colors.dart';

void main() {
  group('AppTypography', () {
    test('exposes correct font family names', () {
      expect(AppTypography.headlineFamily, 'Inter');
      expect(AppTypography.labelFamily, 'Space Grotesk');
    });

    testWidgets('textTheme provides all required styles', (tester) async {
      late TextTheme theme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            theme = AppTypography.textTheme;
            return const SizedBox();
          }),
        ),
      );

      expect(theme.displayLarge, isNotNull);
      expect(theme.headlineMedium, isNotNull);
      expect(theme.titleLarge, isNotNull);
      expect(theme.bodyLarge, isNotNull);
      expect(theme.bodyMedium, isNotNull);
      expect(theme.labelLarge, isNotNull);
    });

    testWidgets('text styles use primary text color', (tester) async {
      late TextTheme theme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            theme = AppTypography.textTheme;
            return const SizedBox();
          }),
        ),
      );

      expect(theme.headlineLarge!.color, AppColors.textPrimary);
      expect(theme.bodyMedium!.color, AppColors.textPrimary);
    });
  });
}
