import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/section_header.dart';
import '../models/debt_model.dart';
import '../providers/debts_provider.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: debtsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Erro: $e')),
          data: (debts) => debts.isEmpty
              ? _EmptyState()
              : _DebtsContent(debts: debts),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/dashboard/add-debt'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.credit_card_off_rounded,
                color: AppColors.textTertiary,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sem dívidas registradas',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Comece registrando suas dívidas para receber um plano personalizado.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtsContent extends StatelessWidget {
  const _DebtsContent({required this.debts});

  final List<Debt> debts;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = debts.fold<double>(0, (sum, d) => sum + d.amount);
    final nextDebt = debts.isNotEmpty
        ? (List<Debt>.from(debts)..sort((a, b) => a.dueDate.compareTo(b.dueDate))).first
        : null;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dívidas',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${debts.length} ativa${debts.length != 1 ? 's' : ''}',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Total',
                        value: 'R\$ ${total.toStringAsFixed(0)}',
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (nextDebt != null)
                      Expanded(
                        child: _MiniStat(
                          label: 'Próximo vencimento',
                          value: DateFormat('dd/MM').format(nextDebt.dueDate),
                          color: nextDebt.isOverdue
                              ? AppColors.danger
                              : nextDebt.isDueSoon
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Prioridade sugerida'),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final debt = debts[index];
                return _DebtRow(
                  debt: debt,
                  index: index,
                  onTap: () => context.push('/dashboard/debt/${debt.id}'),
                );
              },
              childCount: debts.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({
    required this.debt,
    required this.index,
    this.onTap,
  });

  final Debt debt;
  final int index;
  final VoidCallback? onTap;

  Color get _statusColor {
    if (debt.isOverdue) return AppColors.danger;
    if (debt.isDueSoon) return AppColors.warning;
    return AppColors.textTertiary;
  }

  String get _statusLabel {
    if (debt.isOverdue) return 'Atrasado';
    if (debt.isDueSoon) return 'Urgente';
    return 'Normal';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PremiumCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
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
                  const SizedBox(height: 2),
                  Text(
                    '${debt.interestRate.toStringAsFixed(1)}% a.m. · Vence ${DateFormat('dd/MM').format(debt.dueDate)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${debt.amount.toStringAsFixed(0)}',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
