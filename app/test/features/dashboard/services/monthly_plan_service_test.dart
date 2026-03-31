import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/features/dashboard/models/debt_model.dart';
import 'package:desafog_ai/features/dashboard/services/monthly_plan_service.dart';

void main() {
  group('MonthlyPlanService', () {
    test('generates plan with correct structure', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 5000,
        interestRate: 3.5,
        minimumPayment: 150,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      final plan = MonthlyPlanService.generate(
        debts: [debt],
        monthlyIncome: 3000,
        fixedExpenses: 1500,
      );

      expect(plan.debts.length, 1);
      expect(plan.recommendations.isNotEmpty, true);
      expect(plan.availableForPayment, 1500);
      expect(plan.totalSuggested, greaterThan(0));
    });

    test('allocates budget respecting available funds', () {
      final debts = [
        Debt(
          id: '1',
          creditor: 'Bank A',
          amount: 3000,
          interestRate: 5.0,
          minimumPayment: 100,
          dueDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
        ),
        Debt(
          id: '2',
          creditor: 'Bank B',
          amount: 2000,
          interestRate: 2.0,
          minimumPayment: 75,
          dueDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
        ),
      ];

      final plan = MonthlyPlanService.generate(
        debts: debts,
        monthlyIncome: 2000,
        fixedExpenses: 800,
      );

      final totalAllocated = plan.recommendations.fold<double>(
        0,
        (sum, rec) => sum + rec.suggestedPayment,
      );

      expect(totalAllocated, lessThanOrEqualTo(1200)); // 2000 - 800
    });

    test('estimates months to payoff correctly', () {
      final months = MonthlyPlanService.estimateMonthsToPayOff(
        debt: 1000,
        monthlyPayment: 100,
        monthlyRate: 1.0,
      );

      // With 1% monthly rate and $100 payment, should take ~11 months
      expect(months, greaterThan(10));
      expect(months, lessThan(15));
    });

    test('calculates savings rate', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 5000,
        interestRate: 3.5,
        minimumPayment: 150,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      final plan = MonthlyPlanService.generate(
        debts: [debt],
        monthlyIncome: 3000,
        fixedExpenses: 1500,
      );

      expect(plan.savingsRate, greaterThanOrEqualTo(0));
      expect(plan.savingsRate, lessThanOrEqualTo(100));
    });
  });
}
