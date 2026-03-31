import 'debt_model.dart';

/// Estratégia de pagamento para simulação
enum PaymentStrategy {
  /// Pagamento mínimo apenas
  minimum,

  /// Pagamento agressivo (2x mínimo)
  aggressive,

  /// Estratégia equilibrada (mínimo + 50% extra)
  balanced,

  /// Estratégia customizada com valor fixo
  custom;

  String get displayName {
    return switch (this) {
      PaymentStrategy.minimum => 'Mínimo',
      PaymentStrategy.aggressive => 'Agressivo',
      PaymentStrategy.balanced => 'Equilibrado',
      PaymentStrategy.custom => 'Customizado',
    };
  }
}

/// Cenário de simulação com parâmetros
class SimulationScenario {
  final List<Debt> debts;
  final double monthlyIncome;
  final double fixedExpenses;
  final PaymentStrategy strategy;
  final double customPaymentAmount; // Usado apenas quando strategy == custom
  final int months; // Quantidade de meses a simular

  SimulationScenario({
    required this.debts,
    required this.monthlyIncome,
    required this.fixedExpenses,
    required this.strategy,
    this.customPaymentAmount = 0,
    this.months = 36, // 3 anos por padrão
  });

  double get availableForPayment => monthlyIncome - fixedExpenses;
}

/// Snapshot mensal da simulação
class MonthlySnapshot {
  final int month;
  final DateTime date;
  final Map<String, double> debtBalances; // debtId -> balance
  final double totalBalance;
  final double totalInterestAccrued;
  final double totalPaid;
  final int paidDebts; // Quantidade de dívidas quitadas

  MonthlySnapshot({
    required this.month,
    required this.date,
    required this.debtBalances,
    required this.totalBalance,
    required this.totalInterestAccrued,
    required this.totalPaid,
    required this.paidDebts,
  });
}

/// Resultado final da simulação
class SimulationResult {
  final SimulationScenario scenario;
  final List<MonthlySnapshot> snapshots;
  final int monthsToPayOff; // Meses até quitação completa
  final double totalInterestPaid;
  final double totalPaid;
  final bool allDebtsCleared;

  SimulationResult({
    required this.scenario,
    required this.snapshots,
    required this.monthsToPayOff,
    required this.totalInterestPaid,
    required this.totalPaid,
    required this.allDebtsCleared,
  });

  double get savingsVsMinimum {
    // Compara juros pagos com estratégia mínima
    // Quanto menor, melhor
    return totalInterestPaid;
  }

  double get projectedSavingRate {
    if (scenario.monthlyIncome == 0) return 0;
    final monthlyPayment = totalPaid / monthsToPayOff;
    return ((scenario.monthlyIncome - monthlyPayment) / scenario.monthlyIncome) * 100;
  }
}
