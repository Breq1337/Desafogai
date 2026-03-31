import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/features/dashboard/models/debt_model.dart';
import 'package:desafog_ai/features/dashboard/services/priority_engine.dart';

void main() {
  group('PriorityEngine', () {
    test('prioritizes overdue debts highest', () {
      final overdueDebt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 2.0,
        minimumPayment: 100,
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now(),
      );

      final normalDebt = Debt(
        id: '2',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 10.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 20)),
        createdAt: DateTime.now(),
      );

      final sorted = PriorityEngine.prioritize([normalDebt, overdueDebt]);
      expect(sorted.first.id, '1'); // Overdue first
    });

    test('prioritizes debts due soon', () {
      final soonDebt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 2.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime.now(),
      );

      final laterDebt = Debt(
        id: '2',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 2.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 25)),
        createdAt: DateTime.now(),
      );

      final sorted = PriorityEngine.prioritize([laterDebt, soonDebt]);
      expect(sorted.first.id, '1'); // Soon first
    });

    test('prioritizes high interest rate debts', () {
      final highRate = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 8.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 20)),
        createdAt: DateTime.now(),
      );

      final lowRate = Debt(
        id: '2',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 1.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 20)),
        createdAt: DateTime.now(),
      );

      final sorted = PriorityEngine.prioritize([lowRate, highRate]);
      expect(sorted.first.id, '1'); // High rate first
    });

    test('calculateUrgency returns 100 for overdue debts', () {
      final overdueDebt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 5.0,
        minimumPayment: 100,
        dueDate: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      expect(PriorityEngine.calculateUrgency(overdueDebt), 100.0);
    });

    test('calculateUrgency is clamped 0-100', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 50.0, // extreme
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      );

      final urgency = PriorityEngine.calculateUrgency(debt);
      expect(urgency, lessThanOrEqualTo(100.0));
      expect(urgency, greaterThanOrEqualTo(0.0));
    });
  });
}
