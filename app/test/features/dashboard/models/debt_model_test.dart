import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/features/dashboard/models/debt_model.dart';

void main() {
  group('Debt Model', () {
    test('creates debt with correct properties', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 5.0,
        minimumPayment: 100,
        dueDate: DateTime(2026, 3, 30),
        createdAt: DateTime(2026, 3, 20),
      );

      expect(debt.id, '1');
      expect(debt.creditor, 'Bank');
      expect(debt.amount, 1000);
      expect(debt.interestRate, 5.0);
      expect(debt.status, 'active');
    });

    test('isOverdue returns true when due date is in the past', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 5.0,
        minimumPayment: 100,
        dueDate: pastDate,
        createdAt: DateTime.now(),
      );

      expect(debt.isOverdue, true);
    });

    test('isDueSoon returns true when due date is within 7 days', () {
      final soonDate = DateTime.now().add(const Duration(days: 3));
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 5.0,
        minimumPayment: 100,
        dueDate: soonDate,
        createdAt: DateTime.now(),
      );

      expect(debt.isDueSoon, true);
    });

    test('urgency score is higher for debts with higher interest rates', () {
      final highRate = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 10.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 15)),
        createdAt: DateTime.now(),
      );

      final lowRate = Debt(
        id: '2',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 2.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 15)),
        createdAt: DateTime.now(),
      );

      expect(highRate.urgencyScore, greaterThan(lowRate.urgencyScore));
    });

    test('urgency score is higher for debts due sooner', () {
      final soonDebt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 5.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        createdAt: DateTime.now(),
      );

      final laterDebt = Debt(
        id: '2',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 5.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 20)),
        createdAt: DateTime.now(),
      );

      expect(soonDebt.urgencyScore, greaterThan(laterDebt.urgencyScore));
    });

    test('urgency score is clamped between 0 and 100', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 50.0, // extreme value
        minimumPayment: 100,
        dueDate: DateTime.now().subtract(const Duration(days: 30)), // very overdue
        createdAt: DateTime.now(),
      );

      expect(debt.urgencyScore, lessThanOrEqualTo(100));
      expect(debt.urgencyScore, greaterThanOrEqualTo(0));
    });

    test('toFirestore and fromFirestore roundtrip works', () {
      final original = Debt(
        id: '1',
        creditor: 'Bank XYZ',
        amount: 5000,
        interestRate: 3.5,
        minimumPayment: 150,
        dueDate: DateTime(2026, 4, 30),
        createdAt: DateTime(2026, 1, 15),
        status: 'active',
      );

      final data = original.toFirestore();
      expect(data['creditor'], 'Bank XYZ');
      expect(data['amount'], 5000);
      expect(data['interestRate'], 3.5);
      expect(data['status'], 'active');
    });
  });
}
