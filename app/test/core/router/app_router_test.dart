import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/core/router/app_router.dart';

void main() {
  group('AppRoutes', () {
    test('defines all expected route paths', () {
      expect(AppRoutes.auth, '/auth');
      expect(AppRoutes.register, '/auth/register');
      expect(AppRoutes.forgotPassword, '/auth/forgot-password');
      expect(AppRoutes.onboarding, '/onboarding');
      expect(AppRoutes.dashboard, '/dashboard');
    });
  });
}
