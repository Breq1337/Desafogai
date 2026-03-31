import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('background matches Stitch void #131313', () {
      expect(AppColors.background.toARGB32(), 0xFF131313);
    });

    test('surface matches Stitch base surface', () {
      expect(AppColors.surface.toARGB32(), 0xFF131313);
    });

    test('primaryContainer is cyan CTA #00F0FF', () {
      expect(AppColors.primaryContainer.toARGB32(), 0xFF00F0FF);
    });

    test('primary soft text is #DBFCFF', () {
      expect(AppColors.primary.toARGB32(), 0xFFDBFCFF);
    });

    test('ctaGradient has two stops', () {
      expect(AppColors.ctaGradient.length, 2);
    });

    test('core text/surface colors are opaque', () {
      final colors = [
        AppColors.background,
        AppColors.surface,
        AppColors.primaryContainer,
        AppColors.primary,
        AppColors.onPrimary,
        AppColors.textPrimary,
        AppColors.textSecondary,
      ];
      for (final color in colors) {
        expect(color.a, 1.0, reason: 'Color $color should be fully opaque');
      }
    });
  });
}
