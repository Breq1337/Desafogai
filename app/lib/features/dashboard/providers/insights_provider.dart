import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../expenses/providers/expenses_provider.dart';
import '../models/debt_model.dart';
import '../providers/debts_provider.dart';
import '../providers/income_provider.dart';
import '../services/insights_engine.dart';

final insightsProvider = FutureProvider<List<Insight>>((ref) async {
  final debts = ref.watch(debtsProvider).valueOrNull ?? <Debt>[];
  final income = ref.watch(monthlyIncomeProvider);
  final totalExpenses = ref.watch(monthlyExpenseTotalProvider).valueOrNull ?? 0.0;
  final categorySpending = ref.watch(monthlyExpenseByCategoryProvider).valueOrNull ?? <String, double>{};
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? {};

  final categoryLimits = <String, double>{};
  for (final entry in budgets.entries) {
    categoryLimits[entry.key] = entry.value.monthlyLimit;
  }

  return InsightsEngine.generate(
    monthlyIncome: income,
    monthlyExpenses: totalExpenses,
    categorySpending: categorySpending,
    categoryLimits: categoryLimits,
    debts: debts,
  );
});
