import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/providers/budget_provider.dart';
import '../../expenses/providers/expenses_provider.dart';
import '../../expenses/models/budget_model.dart';
import '../models/debt_model.dart';
import '../providers/debts_provider.dart';
import '../providers/planning_provider.dart';
import '../services/planning_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final debts = ref.watch(debtsProvider).valueOrNull ?? [];
    final planning = ref.watch(planningSettingsProvider).valueOrNull;
    final budgets = ref.watch(budgetsProvider).valueOrNull ?? {};
    final monthlySpent = ref.watch(monthlyExpenseTotalProvider).valueOrNull ?? 0.0;
    final byCategory = ref.watch(monthlyCategoryTotalsProvider).valueOrNull ?? {};

    final monthlyIncome = planning?.monthlyIncome ?? 0;
    final savingsGoal = planning?.savingsGoal ?? 0;
    final totalBudgeted = budgets.values.fold<double>(
      0,
      (sum, budget) => sum + budget.monthlyLimit,
    );
    final reservedForDebts = PlanningService.amountReservedForDebts(
      monthlyIncome: monthlyIncome,
      plannedCategoryBudget: totalBudgeted,
      savingsGoal: savingsGoal,
    );
    final suggestedSavings = PlanningService.suggestedSavingsGoal(
      debts: debts,
      monthlyIncome: monthlyIncome,
      plannedCategoryBudget: totalBudgeted,
    );

    final greeting = _greeting();
    final firstName = (user?.displayName ?? '').split(' ').first;
    final primaryDebt = _pickPrimaryDebt(debts);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName.isNotEmpty ? '$greeting, $firstName' : greeting,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat("EEEE, dd 'de' MMMM", 'pt_BR').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 20),
                    _MonthPlanHero(
                      monthlyIncome: monthlyIncome,
                      totalBudgeted: totalBudgeted,
                      monthlySpent: monthlySpent,
                      savingsGoal: savingsGoal,
                      reservedForDebts: reservedForDebts,
                      suggestedSavings: suggestedSavings,
                      onPlanMonth: () => context.push('/dashboard/expenses/budget'),
                    ),
                    const SizedBox(height: 16),
                    _ActionStrip(
                      onPlan: () => context.push('/dashboard/expenses/budget'),
                      onAddDebt: () => context.push('/dashboard/add-debt'),
                      onAddExpense: () => context.push('/dashboard/expenses/add'),
                    ),
                    const SizedBox(height: 24),
                    if (primaryDebt != null) ...[
                      _FocusCard(
                        debt: primaryDebt,
                        onTap: () => context.push('/dashboard/debt/${primaryDebt.id}'),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'Categorias do mês',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Veja rapidamente onde o orçamento já está apertando.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _buildCategoryRows(
                    context: context,
                    budgets: budgets,
                    byCategory: byCategory,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryRows({
    required BuildContext context,
    required Map<String, CategoryBudget> budgets,
    required Map<String, double> byCategory,
  }) {
    final categoryNames = byCategory.keys.isNotEmpty
        ? byCategory.keys.toList()
        : budgets.keys.cast<String>().toList();

    if (categoryNames.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nenhum orçamento definido ainda.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Monte seu plano do mês para acompanhar alimentação, transporte, lazer e outras categorias.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ];
    }

    final ordered = categoryNames.toSet().toList()
      ..sort((a, b) {
        final aLimit = budgets[a]?.monthlyLimit ?? 0;
        final bLimit = budgets[b]?.monthlyLimit ?? 0;
        final aSpent = byCategory[a] ?? 0;
        final bSpent = byCategory[b] ?? 0;
        final aUsage = aLimit > 0 ? aSpent / aLimit : 0;
        final bUsage = bLimit > 0 ? bSpent / bLimit : 0;
        return bUsage.compareTo(aUsage);
      });

    return ordered.take(4).map((category) {
      final limit = budgets[category]?.monthlyLimit ?? 0;
      final spent = byCategory[category] ?? 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _CategoryStatusCard(
          category: category,
          spent: spent,
          limit: limit,
        ),
      );
    }).toList();
  }

  Debt? _pickPrimaryDebt(List<Debt> debts) {
    if (debts.isEmpty) return null;
    final ordered = List<Debt>.from(debts)
      ..sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));
    return ordered.first;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }
}

class _MonthPlanHero extends StatelessWidget {
  const _MonthPlanHero({
    required this.monthlyIncome,
    required this.totalBudgeted,
    required this.monthlySpent,
    required this.savingsGoal,
    required this.reservedForDebts,
    required this.suggestedSavings,
    required this.onPlanMonth,
  });

  final double monthlyIncome;
  final double totalBudgeted;
  final double monthlySpent;
  final double savingsGoal;
  final double reservedForDebts;
  final double suggestedSavings;
  final VoidCallback onPlanMonth;

  @override
  Widget build(BuildContext context) {
    final hasPlan = monthlyIncome > 0 || totalBudgeted > 0 || savingsGoal > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plano do mês',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            hasPlan
                ? 'Seu mês está organizado em três blocos: categorias, economia e dívida.'
                : 'Comece definindo renda, limites por categoria e meta de economia.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStat(label: 'Renda', value: monthlyIncome),
              _HeroStat(label: 'Orçado', value: totalBudgeted),
              _HeroStat(label: 'Gasto atual', value: monthlySpent),
              _HeroStat(
                label: 'Economizar',
                value: savingsGoal > 0 ? savingsGoal : suggestedSavings,
                isHint: savingsGoal <= 0,
              ),
              _HeroStat(
                label: 'Livre p/ dívidas',
                value: reservedForDebts,
                highlight: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPlanMonth,
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: const Text('Organizar plano do mês'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({
    required this.onPlan,
    required this.onAddDebt,
    required this.onAddExpense,
  });

  final VoidCallback onPlan;
  final VoidCallback onAddDebt;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Planejar',
            icon: Icons.tune_rounded,
            onTap: onPlan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'Dívida',
            icon: Icons.add_card_rounded,
            onTap: onAddDebt,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'Gasto',
            icon: Icons.receipt_long_rounded,
            onTap: onAddExpense,
          ),
        ),
      ],
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.debt,
    required this.onTap,
  });

  final Debt debt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = debt.isOverdue
        ? AppColors.danger
        : debt.isDueSoon
            ? AppColors.warning
            : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: statusColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foco de hoje',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    debt.creditor,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vence ${DateFormat('dd/MM').format(debt.dueDate)} • mínimo R\$ ${debt.minimumPayment.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              'R\$ ${debt.amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStatusCard extends StatelessWidget {
  const _CategoryStatusCard({
    required this.category,
    required this.spent,
    required this.limit,
  });

  final String category;
  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final usage = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final accent = limit == 0
        ? AppColors.textTertiary
        : usage >= 1
            ? AppColors.danger
            : usage >= 0.85
                ? AppColors.warning
                : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                'R\$ ${spent.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (limit > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: usage,
                minHeight: 7,
                backgroundColor: AppColors.surfaceContainerLow,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Limite R\$ ${limit.toStringAsFixed(0)} • ${(usage * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accent,
                  ),
            ),
          ] else
            Text(
              'Sem limite definido.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    this.highlight = false,
    this.isHint = false,
  });

  final String label;
  final double value;
  final bool highlight;
  final bool isHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 142,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'R\$ ${value.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppColors.primary : AppColors.textPrimary,
                ),
          ),
          if (isHint)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'sugestão',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
