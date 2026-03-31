import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/alert_banner.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/providers/expenses_provider.dart';
import '../models/debt_model.dart';
import '../providers/debts_provider.dart';
import '../providers/income_provider.dart';
import '../providers/insights_provider.dart';
import '../services/insights_engine.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final debtsAsync = ref.watch(debtsProvider);
    final totalDebtAsync = ref.watch(totalDebtsProvider);
    final expenseTotalAsync = ref.watch(monthlyExpenseTotalProvider);
    final incomeAsync = ref.watch(monthlyIncomeProvider);
    final textTheme = Theme.of(context).textTheme;

    final insightsAsync = ref.watch(insightsProvider);

    final debts = debtsAsync.valueOrNull ?? [];
    final totalDebt = totalDebtAsync.valueOrNull ?? 0.0;
    final monthExpenses = expenseTotalAsync.valueOrNull ?? 0.0;
    final income = incomeAsync.valueOrNull ?? 0.0;
    final insights = insightsAsync.valueOrNull ?? [];

    final greeting = _greeting();
    final firstName = (user?.displayName ?? '').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      firstName.isNotEmpty ? '$greeting, $firstName' : greeting,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat("EEEE, dd 'de' MMMM", 'pt_BR').format(DateTime.now()),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Financial summary
                    _FinancialSummary(
                      totalDebt: totalDebt,
                      monthExpenses: monthExpenses,
                      income: income,
                    ),
                    const SizedBox(height: 16),

                    // Priority alert
                    if (debts.isNotEmpty) ...[
                      _PriorityAlert(debts: debts),
                      const SizedBox(height: 16),
                    ],

                    // Smart insights
                    if (insights.isNotEmpty) ...[
                      ...insights.take(2).map((insight) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _InsightCard(insight: insight),
                          )),
                      const SizedBox(height: 16),
                    ] else if (income > 0 && monthExpenses > 0) ...[
                      _SmartRecommendation(
                        income: income,
                        expenses: monthExpenses,
                        totalDebt: totalDebt,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Quick actions
                    const SectionHeader(title: 'Ações rápidas'),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.add_rounded,
                            label: 'Nova dívida',
                            onTap: () => context.push('/dashboard/add-debt'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.receipt_long_rounded,
                            label: 'Novo gasto',
                            onTap: () => context.push('/dashboard/expenses/add'),
                          ),
                        ),
                      ],
                    ),

                    if (debts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Dívidas prioritárias',
                        trailing: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Ver todas',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Top 3 debts
            if (debts.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final debt = debts[index];
                      return _CompactDebtRow(
                        debt: debt,
                        onTap: () => context.push('/dashboard/debt/${debt.id}'),
                      );
                    },
                    childCount: debts.length.clamp(0, 3),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }
}

class _FinancialSummary extends StatelessWidget {
  const _FinancialSummary({
    required this.totalDebt,
    required this.monthExpenses,
    required this.income,
  });

  final double totalDebt;
  final double monthExpenses;
  final double income;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final available = income - monthExpenses;

    return PremiumCard(
      padding: AppSpacing.cardPaddingLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do mês',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Dívida total',
                  value: 'R\$ ${totalDebt.toStringAsFixed(0)}',
                  color: totalDebt > 0 ? AppColors.danger : AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Gastos do mês',
                  value: 'R\$ ${monthExpenses.toStringAsFixed(0)}',
                  color: AppColors.textPrimary,
                ),
              ),
              if (income > 0) ...[
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Disponível',
                    value: 'R\$ ${available.toStringAsFixed(0)}',
                    color: available >= 0 ? AppColors.success : AppColors.danger,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PriorityAlert extends StatelessWidget {
  const _PriorityAlert({required this.debts});

  final List<Debt> debts;

  @override
  Widget build(BuildContext context) {
    final overdue = debts.where((d) => d.isOverdue).toList();
    final dueSoon = debts.where((d) => d.isDueSoon && !d.isOverdue).toList();

    if (overdue.isNotEmpty) {
      final d = overdue.first;
      return AlertBanner(
        message: '${d.creditor} está atrasado. Pague o quanto antes para evitar juros extras.',
        severity: AlertSeverity.danger,
      );
    }

    if (dueSoon.isNotEmpty) {
      final d = dueSoon.first;
      final days = d.dueDate.difference(DateTime.now()).inDays;
      return AlertBanner(
        message: '${d.creditor} vence em $days dia${days != 1 ? 's' : ''}. Parcela de R\$ ${d.minimumPayment.toStringAsFixed(0)}.',
        severity: AlertSeverity.warning,
      );
    }

    return const SizedBox.shrink();
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final Insight insight;

  IconData get _icon => switch (insight.type) {
        InsightType.budgetAlert => Icons.warning_amber_rounded,
        InsightType.savingTip => Icons.lightbulb_outline_rounded,
        InsightType.debtAcceleration => Icons.speed_rounded,
        InsightType.spending => Icons.trending_up_rounded,
      };

  Color get _color => switch (insight.type) {
        InsightType.budgetAlert => AppColors.warning,
        InsightType.savingTip => AppColors.primaryContainer,
        InsightType.debtAcceleration => AppColors.success,
        InsightType.spending => AppColors.accent,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: _color.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _color,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartRecommendation extends StatelessWidget {
  const _SmartRecommendation({
    required this.income,
    required this.expenses,
    required this.totalDebt,
  });

  final double income;
  final double expenses;
  final double totalDebt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ratio = expenses / income;

    String message;
    if (ratio > 0.9) {
      message = 'Seus gastos estão muito próximos da renda. Tente reduzir para liberar pelo menos 10% para dívidas.';
    } else if (ratio > 0.7) {
      final available = income - expenses;
      message = 'Você tem R\$ ${available.toStringAsFixed(0)} disponíveis. Direcionar esse valor para dívidas pode encurtar o prazo.';
    } else {
      final available = income - expenses;
      message = 'Boa margem este mês. Com R\$ ${available.toStringAsFixed(0)} livres, você pode acelerar o pagamento das suas dívidas.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryContainer, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.primaryContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
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
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryContainer),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactDebtRow extends StatelessWidget {
  const _CompactDebtRow({required this.debt, this.onTap});

  final Debt debt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor = debt.isOverdue
        ? AppColors.danger
        : debt.isDueSoon
            ? AppColors.warning
            : AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.creditor,
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Vence ${DateFormat('dd/MM').format(debt.dueDate)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'R\$ ${debt.amount.toStringAsFixed(0)}',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
