import '../models/debt_model.dart';
import '../models/simulation.dart';

class SimulatorService {
  /// Executa simulação de cenário de pagamento
  static SimulationResult simulate(SimulationScenario scenario) {
    final snapshots = <MonthlySnapshot>[];
    final debtStates = <String, _DebtState>{};

    // Inicializa estado de cada dívida
    for (final debt in scenario.debts) {
      debtStates[debt.id] = _DebtState(
        balance: debt.amount,
        interestRate: debt.interestRate,
        minimumPayment: debt.minimumPayment,
      );
    }

    double totalInterestAccrued = 0;
    double totalPaid = 0;
    int paidDebts = 0;
    int monthsToPayOff = 0;

    // Simula mês a mês
    for (int month = 1; month <= scenario.months; month++) {
      final snapshotDate = DateTime.now().add(Duration(days: month * 30));
      final debtBalances = <String, double>{};
      double monthlyInterest = 0;
      double monthlyPayment = 0;
      int currentPaidDebts = 0;

      // Calcula juros e pagamentos
      for (final entry in debtStates.entries) {
        final debtId = entry.key;
        final state = entry.value;

        // Já foi quitada?
        if (state.balance <= 0) {
          debtBalances[debtId] = 0;
          currentPaidDebts++;
          continue;
        }

        // Acumula juros
        final monthlyInterestOnDebt = (state.balance * state.interestRate) / 100;
        monthlyInterest += monthlyInterestOnDebt;
        state.balance += monthlyInterestOnDebt;

        // Calcula pagamento para esta dívida
        final payment = _calculateMonthlyPayment(
          scenario: scenario,
          debtId: debtId,
          debtStates: debtStates,
          availableForPayment: scenario.availableForPayment,
        );

        monthlyPayment += payment;
        state.balance -= payment;
        if (state.balance < 0) state.balance = 0;

        debtBalances[debtId] = state.balance;
      }

      totalInterestAccrued += monthlyInterest;
      totalPaid += monthlyPayment;
      paidDebts = currentPaidDebts;

      // Cria snapshot do mês
      final totalBalance = debtStates.values
          .fold<double>(0, (sum, state) => sum + (state.balance > 0 ? state.balance : 0));

      snapshots.add(MonthlySnapshot(
        month: month,
        date: snapshotDate,
        debtBalances: debtBalances,
        totalBalance: totalBalance,
        totalInterestAccrued: totalInterestAccrued,
        totalPaid: totalPaid,
        paidDebts: paidDebts,
      ));

      // Se todas as dívidas foram quitadas, interrompe
      if (totalBalance <= 0) {
        monthsToPayOff = month;
        break;
      }
    }

    // Se não quitou em tempo, usa o último mês simulado
    if (monthsToPayOff == 0) {
      monthsToPayOff = scenario.months;
    }

    return SimulationResult(
      scenario: scenario,
      snapshots: snapshots,
      monthsToPayOff: monthsToPayOff,
      totalInterestPaid: totalInterestAccrued,
      totalPaid: totalPaid,
      allDebtsCleared: debtStates.values.every((state) => state.balance <= 0),
    );
  }

  /// Compara múltiplas estratégias (exclui custom)
  static Map<PaymentStrategy, SimulationResult> compareStrategies({
    required List<Debt> debts,
    required double monthlyIncome,
    required double fixedExpenses,
    required int months,
  }) {
    final results = <PaymentStrategy, SimulationResult>{};

    // Estratégias predefinidas (exclui custom)
    final strategies = [
      PaymentStrategy.minimum,
      PaymentStrategy.aggressive,
      PaymentStrategy.balanced,
    ];

    // Simula cada estratégia
    for (final strategy in strategies) {
      final scenario = SimulationScenario(
        debts: debts,
        monthlyIncome: monthlyIncome,
        fixedExpenses: fixedExpenses,
        strategy: strategy,
        months: months,
      );

      results[strategy] = simulate(scenario);
    }

    return results;
  }

  static double _calculateMonthlyPayment({
    required SimulationScenario scenario,
    required String debtId,
    required Map<String, _DebtState> debtStates,
    required double availableForPayment,
  }) {
    final state = debtStates[debtId];
    if (state == null || state.balance <= 0) return 0;

    final activeDebts = debtStates.values.where((s) => s.balance > 0).length;
    final perDebtBudget = activeDebts > 0
        ? availableForPayment / activeDebts
        : availableForPayment;

    final payment = switch (scenario.strategy) {
      PaymentStrategy.minimum => state.minimumPayment,
      PaymentStrategy.aggressive =>
        (perDebtBudget * 0.9).clamp(state.minimumPayment, double.infinity),
      PaymentStrategy.balanced =>
        (perDebtBudget * 0.7).clamp(state.minimumPayment, double.infinity),
      PaymentStrategy.custom => scenario.customPaymentAmount,
    };

    return payment.clamp(0, state.balance);
  }
}

/// Estado interno de uma dívida durante simulação
class _DebtState {
  double balance;
  final double interestRate;
  final double minimumPayment;

  _DebtState({
    required this.balance,
    required this.interestRate,
    required this.minimumPayment,
  });
}
