import '../models/debt_model.dart';
import '../models/monthly_plan.dart';

class MonthlyPlanService {
  /// Gera plano mensal baseado em renda e dívidas
  static MonthlyPlan generate({
    required List<Debt> debts,
    required double monthlyIncome,
    double fixedExpenses = 0,
  }) {
    final availableForPayment = monthlyIncome - fixedExpenses;
    final sortedDebts = List<Debt>.from(debts)
      ..sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));

    double remainingBudget = availableForPayment;
    final recommendations = <MonthlyPlanRecommendation>[];

    for (final debt in sortedDebts) {
      if (remainingBudget <= 0) break;

      // Calcula juros do mês
      final monthlyInterest = (debt.amount * debt.interestRate) / 100;

      // Prioriza pagamento de juros + principal
      final suggestedPayment = _calculatePayment(
        debt: debt,
        monthlyInterest: monthlyInterest,
        availableBudget: remainingBudget,
      );

      final newBalance = debt.amount + monthlyInterest - suggestedPayment;

      recommendations.add(MonthlyPlanRecommendation(
        debtId: debt.id,
        creditor: debt.creditor,
        suggestedPayment: suggestedPayment,
        interestAccrual: monthlyInterest,
        newBalance: newBalance > 0 ? newBalance : 0,
      ));

      remainingBudget -= suggestedPayment;
    }

    return MonthlyPlan(
      month: DateTime.now(),
      debts: debts,
      recommendations: recommendations,
      totalSuggested: availableForPayment - remainingBudget,
      monthlyIncome: monthlyIncome,
      availableForPayment: availableForPayment,
    );
  }

  /// Calcula pagamento otimizado para a dívida
  static double _calculatePayment({
    required Debt debt,
    required double monthlyInterest,
    required double availableBudget,
  }) {
    // Pelo menos o pagamento mínimo
    double payment = debt.minimumPayment;

    // Se tem orçamento, prioriza dívidas com alta taxa
    if (availableBudget > payment && debt.interestRate > 3.0) {
      final extra = (availableBudget - payment) * (debt.interestRate / 100);
      payment += extra;
    }

    return payment.clamp(0, availableBudget);
  }

  /// Estima meses para quitação (simulação simplificada)
  static int estimateMonthsToPayOff({
    required double debt,
    required double monthlyPayment,
    required double monthlyRate,
  }) {
    if (monthlyPayment <= 0) return 0;
    int months = 0;
    double remaining = debt;
    const maxIterations = 600; // 50 anos max

    while (remaining > 0 && months < maxIterations) {
      remaining += (remaining * monthlyRate) / 100;
      remaining -= monthlyPayment;
      months++;
    }

    return months;
  }
}
