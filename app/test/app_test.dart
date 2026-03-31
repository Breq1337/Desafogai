import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/core/theme/app_colors.dart';

void main() {
  group('DesafogApp Core', () {
    test('AppColors defines primary and background', () {
      expect(AppColors.background.value, isNonZero);
      expect(AppColors.primary.value, isNonZero);
      expect(AppColors.danger.value, isNonZero);
    });
  });
}
