import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desafog_ai/features/dashboard/providers/income_provider.dart';

void main() {
  group('Income Provider', () {
    test('monthlyIncomeProvider returns Stream', () {
      final container = ProviderContainer();

      final provider = container.read(monthlyIncomeProvider);
      // StreamProvider returns AsyncValue, which will be loading initially
      // since there's no authenticated user
      expect(provider, isA<AsyncValue>());
    });
  });
}
