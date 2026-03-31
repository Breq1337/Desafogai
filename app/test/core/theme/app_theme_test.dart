import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/core/theme/app_theme.dart';
import 'package:desafog_ai/core/theme/app_colors.dart';

void main() {
  group('AppTheme', () {
    testWidgets('dark theme has correct properties', (tester) async {
      late ThemeData theme;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(builder: (context) {
            theme = Theme.of(context);
            return const SizedBox();
          }),
        ),
      );

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.primaryContainer);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.error, AppColors.error);
    });

    testWidgets('dark theme card and appBar styles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(builder: (context) {
            final t = Theme.of(context);
            expect(t.cardTheme.color, AppColors.surfaceContainerLow);
            expect(t.cardTheme.elevation, 0);
            expect(t.appBarTheme.elevation, 0);
            expect(
              t.inputDecorationTheme.fillColor,
              AppColors.surfaceContainerLowest,
            );
            expect(t.inputDecorationTheme.filled, true);
            return const SizedBox();
          }),
        ),
      );
    });
  });
}
