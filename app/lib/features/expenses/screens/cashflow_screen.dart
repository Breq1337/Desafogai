import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/stitch_background.dart';
import '../../dashboard/providers/debts_provider.dart';
import '../../dashboard/providers/income_provider.dart';
import '../providers/expenses_provider.dart';
import '../widgets/stat_card.dart';

class CashflowScreen extends ConsumerWidget {
  const CashflowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final incomeAsync = ref.watch(monthlyIncomeProvider);
    final expensesAsync = ref.watch(monthlyExpenseTotalProvider);
    final debtsAsync = ref.watch(debtsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Fluxo de Caixa'),
      ),
      body: StitchBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(
                  index: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fluxo de Caixa',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Visualize sua saúde financeira mensal',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Income
                FadeSlideIn(
                  index: 1,
                  child: incomeAsync.when(
                    data: (income) => StatCard(
                      title: 'Renda mensal',
                      value: 'R\$ ${income.toStringAsFixed(0)}',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.primary,
                    ),
                    loading: () => StatCard(
                      title: 'Renda mensal',
                      value: '---',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.primary,
                    ),
                    error: (err, st) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 16),

                // Expenses
                FadeSlideIn(
                  index: 2,
                  child: expensesAsync.when(
                    data: (expenses) => StatCard(
                      title: 'Gastos do mês',
                      value: 'R\$ ${expenses.toStringAsFixed(0)}',
                      icon: Icons.trending_down_rounded,
                      color: AppColors.danger,
                    ),
                    loading: () => StatCard(
                      title: 'Gastos do mês',
                      value: '---',
                      icon: Icons.trending_down_rounded,
                      color: AppColors.danger,
                    ),
                    error: (err, st) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 16),

                // Minimum debt payments
                FadeSlideIn(
                  index: 3,
                  child: debtsAsync.when(
                    data: (debts) {
                      final totalMinimum = debts.fold<double>(
                        0.0,
                        (sum, debt) => sum + debt.minimumPayment,
                      );
                      return StatCard(
                        title: 'Pagamentos mínimos',
                        value: 'R\$ ${totalMinimum.toStringAsFixed(0)}',
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.accent,
                      );
                    },
                    loading: () => StatCard(
                      title: 'Pagamentos mínimos',
                      value: '---',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.accent,
                    ),
                    error: (err, st) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                Container(
                  height: 1,
                  color: AppColors.divider.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 24),

                // Available balance
                FadeSlideIn(
                  index: 4,
                  child: _CashflowSummary(
                    incomeAsync: incomeAsync,
                    expensesAsync: expensesAsync,
                    debtsAsync: debtsAsync,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CashflowSummary extends ConsumerWidget {
  const _CashflowSummary({
    required this.incomeAsync,
    required this.expensesAsync,
    required this.debtsAsync,
  });

  final AsyncValue<double> incomeAsync;
  final AsyncValue<double> expensesAsync;
  final AsyncValue<List<dynamic>> debtsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return incomeAsync.when(
      data: (income) => expensesAsync.when(
        data: (expenses) => debtsAsync.when(
          data: (debts) {
            final totalMinimum =
                debts.fold<double>(0.0, (sum, debt) => sum + debt.minimumPayment);
            final available = income - expenses - totalMinimum;
            final isPositive = available >= 0;

            return StatCard(
              title: 'Sobra real',
              value: 'R\$ ${available.abs().toStringAsFixed(0)}',
              icon: isPositive ? Icons.savings_rounded : Icons.warning_rounded,
              color: isPositive ? const Color(0xFF4CAF50) : AppColors.danger,
              subtitle: isPositive
                  ? 'Você tem saldo positivo'
                  : 'Atenção: déficit no mês',
              numericValue: available,
            );
          },
          loading: () => StatCard(
            title: 'Sobra real',
            value: '---',
            icon: Icons.savings_rounded,
            color: AppColors.primary,
          ),
          error: (err, st) => const SizedBox.shrink(),
        ),
        loading: () => StatCard(
          title: 'Sobra real',
          value: '---',
          icon: Icons.savings_rounded,
          color: AppColors.primary,
        ),
        error: (err, st) => const SizedBox.shrink(),
      ),
      loading: () => StatCard(
        title: 'Sobra real',
        value: '---',
        icon: Icons.savings_rounded,
        color: AppColors.primary,
      ),
      error: (err, st) => const SizedBox.shrink(),
    );
  }
}
