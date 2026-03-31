import '../models/debt_model.dart';

/// Priority Engine — ordena dívidas por urgência
/// Factores:
/// 1. Taxa de juros (quanto maior, mais urgente)
/// 2. Dias até vencimento (quanto menor, mais urgente)
/// 3. Atraso (se atrasado, máxima prioridade)
class PriorityEngine {
  /// Ordena dívidas por urgência (descendente)
  static List<Debt> prioritize(List<Debt> debts) {
    final sorted = List<Debt>.from(debts);
    sorted.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));
    return sorted;
  }

  /// Calcula urgência de 0-100
  /// - Overdue: 100
  /// - Due soon (< 7 dias): 70-99
  /// - Normal: base em taxa de juros
  static double calculateUrgency(Debt debt) {
    if (debt.isOverdue) return 100.0;

    final daysUntil = debt.dueDate.difference(DateTime.now()).inDays;
    if (daysUntil <= 0) return 100.0;

    if (daysUntil <= 7) {
      return 70.0 + (30.0 * (1 - daysUntil / 7));
    }

    // Normal case: base em taxa de juros + dias
    final rateScore = (debt.interestRate * 2).clamp(0.0, 50.0);
    final timeScore = (30 - daysUntil).clamp(0.0, 30.0);
    return (rateScore + timeScore).clamp(0.0, 100.0);
  }

  /// Agrupa dívidas por nível de urgência
  static Map<String, List<Debt>> groupByUrgency(List<Debt> debts) {
    final sorted = prioritize(debts);
    return {
      'critical': sorted.where((d) => d.urgencyScore >= 70).toList(),
      'important': sorted.where((d) => d.urgencyScore >= 40 && d.urgencyScore < 70).toList(),
      'normal': sorted.where((d) => d.urgencyScore < 40).toList(),
    };
  }
}
