import 'package:flutter_test/flutter_test.dart';
import 'package:desafog_ai/features/dashboard/models/debt_model.dart';
import 'package:desafog_ai/features/dashboard/models/simulation.dart';
import 'package:desafog_ai/features/dashboard/services/simulator_service.dart';

void main() {
  group('SimulatorService', () {
    test('simulates single debt with minimum payment strategy', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 1.0, // 1% ao mês
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      final scenario = SimulationScenario(
        debts: [debt],
        monthlyIncome: 2000,
        fixedExpenses: 500,
        strategy: PaymentStrategy.minimum,
        months: 24,
      );

      final result = SimulatorService.simulate(scenario);

      expect(result.snapshots.isNotEmpty, true);
      expect(result.monthsToPayOff, greaterThan(0));
      expect(result.totalInterestPaid, greaterThan(0));
      expect(result.totalPaid, greaterThan(0));
    });

    test('aggressive strategy pays off faster than minimum', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 5000,
        interestRate: 2.0,
        minimumPayment: 200,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      // Simulação com estratégia mínima
      final minScenario = SimulationScenario(
        debts: [debt],
        monthlyIncome: 3000,
        fixedExpenses: 1000,
        strategy: PaymentStrategy.minimum,
        months: 60,
      );

      // Simulação com estratégia agressiva
      final aggScenario = SimulationScenario(
        debts: [debt],
        monthlyIncome: 3000,
        fixedExpenses: 1000,
        strategy: PaymentStrategy.aggressive,
        months: 60,
      );

      final minResult = SimulatorService.simulate(minScenario);
      final aggResult = SimulatorService.simulate(aggScenario);

      // Estratégia agressiva deve pagar mais rápido
      expect(aggResult.monthsToPayOff, lessThanOrEqualTo(minResult.monthsToPayOff));

      // Estratégia agressiva deve pagar menos juros
      expect(aggResult.totalInterestPaid, lessThan(minResult.totalInterestPaid));
    });

    test('multiple debts prioritizes by urgency', () {
      final debts = [
        Debt(
          id: '1',
          creditor: 'Bank A',
          amount: 2000,
          interestRate: 5.0, // Alto
          minimumPayment: 100,
          dueDate: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
        ),
        Debt(
          id: '2',
          creditor: 'Bank B',
          amount: 1000,
          interestRate: 1.0, // Baixo
          minimumPayment: 50,
          dueDate: DateTime.now().add(const Duration(days: 60)),
          createdAt: DateTime.now(),
        ),
      ];

      final scenario = SimulationScenario(
        debts: debts,
        monthlyIncome: 2000,
        fixedExpenses: 500,
        strategy: PaymentStrategy.balanced,
        months: 24,
      );

      final result = SimulatorService.simulate(scenario);

      expect(result.snapshots.isNotEmpty, true);
      expect(result.totalPaid, greaterThan(0));
    });

    test('calculates total interest paid correctly', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 1.0, // 1% ao mês
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      final scenario = SimulationScenario(
        debts: [debt],
        monthlyIncome: 2000,
        fixedExpenses: 500,
        strategy: PaymentStrategy.minimum,
        months: 12,
      );

      final result = SimulatorService.simulate(scenario);

      // Com 1% a.m. e pagamento mínimo, deve gerar juros
      expect(result.totalInterestPaid, greaterThan(0));

      // Total pago deve ser > valor original (principal + juros)
      expect(result.totalPaid, greaterThan(1000));
    });

    test('marks debts as cleared when balance reaches zero', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 500,
        interestRate: 0.5,
        minimumPayment: 150,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      final scenario = SimulationScenario(
        debts: [debt],
        monthlyIncome: 3000,
        fixedExpenses: 500,
        strategy: PaymentStrategy.aggressive,
        months: 12,
      );

      final result = SimulatorService.simulate(scenario);

      // Deve quitada em poucos meses com pagamento agressivo
      expect(result.monthsToPayOff, lessThan(12));
      expect(result.allDebtsCleared, true);
    });

    test('custom payment strategy respects custom amount', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 1000,
        interestRate: 1.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      final scenario = SimulationScenario(
        debts: [debt],
        monthlyIncome: 2000,
        fixedExpenses: 500,
        strategy: PaymentStrategy.custom,
        customPaymentAmount: 250,
        months: 12,
      );

      final result = SimulatorService.simulate(scenario);

      expect(result.snapshots.isNotEmpty, true);
      // Pagamentos customizados devem resultar em quitação mais rápida que mínimo
      expect(result.monthsToPayOff, lessThan(12));
    });

    test('compareStrategies returns results for all strategies', () {
      final debt = Debt(
        id: '1',
        creditor: 'Bank',
        amount: 2000,
        interestRate: 2.0,
        minimumPayment: 100,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      final results = SimulatorService.compareStrategies(
        debts: [debt],
        monthlyIncome: 3000,
        fixedExpenses: 500,
        months: 36,
      );

      expect(results.length, PaymentStrategy.values.length - 1); // Sem custom
      expect(results.containsKey(PaymentStrategy.minimum), true);
      expect(results.containsKey(PaymentStrategy.aggressive), true);
      expect(results.containsKey(PaymentStrategy.balanced), true);
    });
  });
}
