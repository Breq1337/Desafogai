import '../models/debt_model.dart';

class Insight {
  final String message;
  final InsightType type;
  final double? potentialSaving;

  Insight({
    required this.message,
    required this.type,
    this.potentialSaving,
  });
}

enum InsightType { budgetAlert, savingTip, debtAcceleration, spending }

class InsightsEngine {
  static List<Insight> generate({
    required double monthlyIncome,
    required double monthlyExpenses,
    required Map<String, double> categorySpending,
    required Map<String, double> categoryLimits,
    required List<Debt> debts,
  }) {
    final insights = <Insight>[];

    // Budget alerts
    for (final entry in categorySpending.entries) {
      final limit = categoryLimits[entry.key];
      if (limit == null || limit <= 0) continue;
      final pct = entry.value / limit;

      if (pct >= 1.0) {
        insights.add(Insight(
          message: '${entry.key} passou do limite em R\$ ${(entry.value - limit).toStringAsFixed(0)}.',
          type: InsightType.budgetAlert,
        ));
      } else if (pct >= 0.9) {
        insights.add(Insight(
          message: '${entry.key} está quase no limite (${(pct * 100).toStringAsFixed(0)}%).',
          type: InsightType.budgetAlert,
        ));
      } else if (pct >= 0.7) {
        insights.add(Insight(
          message: 'Atenção: ${entry.key} já atingiu ${(pct * 100).toStringAsFixed(0)}% do limite.',
          type: InsightType.budgetAlert,
        ));
      }
    }

    // Top spending categories with saving tips
    final sorted = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isNotEmpty) {
      final top = sorted.first;
      if (top.value > 0) {
        final dailyAvg = top.value / 30;
        final reduction = dailyAvg * 0.2;
        final monthlySaving = reduction * 30;

        if (monthlySaving >= 30) {
          insights.add(Insight(
            message: 'Reduzindo 20% em ${top.key}, você libera R\$ ${monthlySaving.toStringAsFixed(0)}/mês.',
            type: InsightType.savingTip,
            potentialSaving: monthlySaving,
          ));
        }
      }
    }

    // Debt acceleration
    if (monthlyIncome > 0 && debts.isNotEmpty) {
      final available = monthlyIncome - monthlyExpenses;

      if (available > 0) {
        final highestRate = debts.reduce((a, b) => a.interestRate > b.interestRate ? a : b);
        insights.add(Insight(
          message: 'Com R\$ ${available.toStringAsFixed(0)} livres, priorize ${highestRate.creditor} (maior taxa: ${highestRate.interestRate.toStringAsFixed(1)}%).',
          type: InsightType.debtAcceleration,
          potentialSaving: available,
        ));
      }

      if (available < monthlyIncome * 0.1) {
        insights.add(Insight(
          message: 'Seus gastos consomem mais de 90% da renda. Tente liberar pelo menos 10% para dívidas.',
          type: InsightType.spending,
        ));
      }
    }

    // Combined saving + debt impact
    final totalPotentialSaving = insights
        .where((i) => i.potentialSaving != null)
        .fold<double>(0, (sum, i) => sum + (i.potentialSaving ?? 0));

    if (totalPotentialSaving > 0 && debts.isNotEmpty) {
      final smallestDebt = debts.reduce((a, b) => a.amount < b.amount ? a : b);
      final monthsToPayOff = (smallestDebt.amount / totalPotentialSaving).ceil();

      if (monthsToPayOff <= 12) {
        insights.add(Insight(
          message: 'Aplicando economia em ${smallestDebt.creditor}, você quita em ~$monthsToPayOff mês${monthsToPayOff > 1 ? 'es' : ''}.',
          type: InsightType.debtAcceleration,
        ));
      }
    }

    return insights;
  }
}
