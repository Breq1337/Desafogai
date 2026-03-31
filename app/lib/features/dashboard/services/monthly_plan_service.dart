import 'dart:math';

import '../models/debt_model.dart';
import '../models/monthly_plan.dart';

class MonthlyPlanService {
  static MonthlyPlan generate({
    required List<Debt> debts,
    required double monthlyIncome,
    double fixedExpenses = 0,
  }) {
    final availableForPayment = max(0.0, monthlyIncome - fixedExpenses);
    final sortedDebts = List<Debt>.from(debts)
      ..sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));

    double remainingBudget = availableForPayment;
    final recommendations = <MonthlyPlanRecommendation>[];

    // Phase 1: guarantee minimum payments for all debts
    final minimums = <String, double>{};
    for (final debt in sortedDebts) {
      final minPay = min(debt.minimumPayment, remainingBudget);
      minimums[debt.id] = minPay;
      remainingBudget -= minPay;
      if (remainingBudget <= 0) break;
    }

    // Phase 2: allocate extra to highest-rate debts first (avalanche)
    final extraAlloc = <String, double>{};
    final byRate = List<Debt>.from(sortedDebts)
      ..sort((a, b) => b.interestRate.compareTo(a.interestRate));
    for (final debt in byRate) {
      if (remainingBudget <= 0) break;
      final interest = (debt.amount * debt.interestRate) / 100;
      final minPaid = minimums[debt.id] ?? 0;
      final ideal = min(debt.amount + interest - minPaid, remainingBudget);
      final extra = max(0.0, ideal);
      extraAlloc[debt.id] = extra;
      remainingBudget -= extra;
    }

    for (final debt in sortedDebts) {
      final monthlyInterest = (debt.amount * debt.interestRate) / 100;
      final suggested = (minimums[debt.id] ?? 0) + (extraAlloc[debt.id] ?? 0);
      final newBalance = debt.amount + monthlyInterest - suggested;

      recommendations.add(MonthlyPlanRecommendation(
        debtId: debt.id,
        creditor: debt.creditor,
        suggestedPayment: suggested,
        interestAccrual: monthlyInterest,
        newBalance: max(0.0, newBalance),
      ));
    }

    return MonthlyPlan(
      month: DateTime.now(),
      debts: debts,
      recommendations: recommendations,
      totalSuggested: availableForPayment - max(0.0, remainingBudget),
      monthlyIncome: monthlyIncome,
      availableForPayment: availableForPayment,
    );
  }

  static int estimateMonthsToPayOff({
    required double debt,
    required double monthlyPayment,
    required double monthlyRate,
  }) {
    if (monthlyPayment <= 0) return 0;
    int months = 0;
    double remaining = debt;
    const maxIterations = 600;

    while (remaining > 0 && months < maxIterations) {
      remaining += (remaining * monthlyRate) / 100;
      remaining -= monthlyPayment;
      months++;
    }

    return months;
  }
}
