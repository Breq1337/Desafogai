import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desafog_ai/features/expenses/providers/expenses_provider.dart';
import 'package:desafog_ai/features/expenses/models/expense_model.dart';

void main() {
  group('Expenses Providers', () {
    test('expensesProvider returns Stream', () {
      final container = ProviderContainer();

      final provider = container.read(expensesProvider);
      // StreamProvider returns AsyncValue, which will be loading initially
      // since there's no authenticated user
      expect(provider, isA<AsyncValue>());
    });

    test('expensesByMonthProvider is accessible', () {
      final container = ProviderContainer();
      final now = DateTime.now();
      final month = DateTime(now.year, now.month);

      final provider = container.read(expensesByMonthProvider(month));
      expect(provider, isA<AsyncValue>());
    });

    test('monthlyExpenseTotalProvider is accessible', () {
      final container = ProviderContainer();

      final provider = container.read(monthlyExpenseTotalProvider);
      expect(provider, isA<AsyncValue>());
    });

    test('monthlyExpenseByCategoryProvider is accessible', () {
      final container = ProviderContainer();

      final provider = container.read(monthlyExpenseByCategoryProvider);
      expect(provider, isA<AsyncValue>());
    });

    test('budgetsProvider returns Stream', () {
      final container = ProviderContainer();

      final provider = container.read(budgetsProvider);
      expect(provider, isA<AsyncValue>());
    });
  });
}
