class PlanningSettings {
  const PlanningSettings({
    required this.monthlyIncome,
    required this.savingsGoal,
  });

  final double monthlyIncome;
  final double savingsGoal;

  bool get hasIncome => monthlyIncome > 0;
  bool get hasSavingsGoal => savingsGoal > 0;
}
