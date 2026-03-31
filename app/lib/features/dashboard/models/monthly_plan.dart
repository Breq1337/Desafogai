import 'debt_model.dart';

class MonthlyPlanRecommendation {
  final String debtId;
  final String creditor;
  final double suggestedPayment;
  final double interestAccrual;
  final double newBalance;

  MonthlyPlanRecommendation({
    required this.debtId,
    required this.creditor,
    required this.suggestedPayment,
    required this.interestAccrual,
    required this.newBalance,
  });
}

class MonthlyPlan {
  final DateTime month;
  final List<Debt> debts;
  final List<MonthlyPlanRecommendation> recommendations;
  final double totalSuggested;
  final double monthlyIncome;
  final double availableForPayment;

  MonthlyPlan({
    required this.month,
    required this.debts,
    required this.recommendations,
    required this.totalSuggested,
    required this.monthlyIncome,
    required this.availableForPayment,
  });

  double get savingsRate {
    if (monthlyIncome == 0) return 0;
    return ((monthlyIncome - totalSuggested) / monthlyIncome) * 100;
  }

  bool get isAggressive => totalSuggested > availableForPayment * 0.7;
}
