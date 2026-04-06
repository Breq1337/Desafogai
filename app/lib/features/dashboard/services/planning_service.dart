import '../models/debt_model.dart';

abstract final class PlanningService {
  static double suggestedSavingsGoal({
    required List<Debt> debts,
    required double monthlyIncome,
    required double plannedCategoryBudget,
  }) {
    if (monthlyIncome <= 0) return 0;

    final totalMinimumPayments = debts.fold<double>(
      0,
      (sum, debt) => sum + debt.minimumPayment,
    );
    final fallbackDebtPressure = debts.fold<double>(
      0,
      (sum, debt) => sum + (debt.amount * 0.01),
    );

    final debtPressure = totalMinimumPayments > 0
        ? totalMinimumPayments * 0.45
        : fallbackDebtPressure;
    final baseReserve = monthlyIncome * 0.08;
    final freeMargin = (monthlyIncome - plannedCategoryBudget).clamp(0.0, monthlyIncome);
    final cappedGoal = freeMargin * 0.35;
    final rawGoal = baseReserve + debtPressure;

    final suggested = rawGoal.clamp(50.0, cappedGoal > 0 ? cappedGoal : rawGoal);
    return _roundToNearestTen(suggested);
  }

  static String suggestedSavingsReason(List<Debt> debts) {
    if (debts.isEmpty) {
      return 'Sugestão baseada em uma reserva mensal saudável.';
    }

    final totalMinimumPayments = debts.fold<double>(
      0,
      (sum, debt) => sum + debt.minimumPayment,
    );

    if (totalMinimumPayments > 0) {
      return 'Sugestão baseada no peso das parcelas mínimas das suas dívidas.';
    }

    return 'Sugestão baseada no volume total das dívidas ativas.';
  }

  static double amountReservedForDebts({
    required double monthlyIncome,
    required double plannedCategoryBudget,
    required double savingsGoal,
  }) {
    return (monthlyIncome - plannedCategoryBudget - savingsGoal).clamp(0.0, monthlyIncome);
  }

  static double _roundToNearestTen(double value) {
    return (value / 10).roundToDouble() * 10;
  }
}
