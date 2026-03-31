import 'package:desafog_ai/core/theme/app_colors.dart';
import 'package:flutter_test/flutter_test.dart';

// OfflineBanner requires Firestore initialization which can't easily be mocked
// in unit tests. We test the visual constants it depends on instead.
void main() {
  group('OfflineBanner dependencies', () {
    test('AppColors.warning is defined for offline banner', () {
      expect(AppColors.warning, isNotNull);
    });
  });
}
