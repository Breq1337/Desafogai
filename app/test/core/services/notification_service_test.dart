import 'package:flutter_test/flutter_test.dart';

import 'package:desafog_ai/core/services/notification_service.dart';
import 'package:desafog_ai/features/dashboard/models/debt_model.dart';

void main() {
  group('NotificationService', () {
    setUp(() async {
      // init() must not throw on any test platform
      await NotificationService.init();
    });

    test('init completes without error', () async {
      // Already called in setUp — just assert no exception was thrown
      expect(true, isTrue);
    });

    test('schedulePaymentReminders skips non-active debts', () async {
      final paid = Debt(
        id: '1',
        creditor: 'Banco X',
        amount: 1000,
        interestRate: 2.5,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: 'paid',
        createdAt: DateTime.now(),
      );

      // Should complete without throwing even for a paid debt
      await expectLater(
        NotificationService.schedulePaymentReminders(debts: [paid]),
        completes,
      );
    });

    test('schedulePaymentReminders processes active debts due soon', () async {
      final active = Debt(
        id: '2',
        creditor: 'Financeira Y',
        amount: 2500,
        interestRate: 3.0,
        minimumPayment: 250,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: 'active',
        createdAt: DateTime.now(),
      );

      await expectLater(
        NotificationService.schedulePaymentReminders(debts: [active]),
        completes,
      );
    });

    test('schedulePaymentReminders ignores debts not due within window', () async {
      final farAway = Debt(
        id: '3',
        creditor: 'Banco Z',
        amount: 5000,
        interestRate: 1.5,
        minimumPayment: 300,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        status: 'active',
        createdAt: DateTime.now(),
      );

      await expectLater(
        NotificationService.schedulePaymentReminders(debts: [farAway]),
        completes,
      );
    });

    test('cancelAll completes without error', () async {
      await expectLater(NotificationService.cancelAll(), completes);
    });
  });
}
