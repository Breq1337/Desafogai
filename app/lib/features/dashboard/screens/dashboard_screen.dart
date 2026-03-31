import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/stitch_background.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/widgets/monthly_expense_summary.dart';
import '../models/debt_model.dart';
import '../providers/debts_provider.dart';
import '../widgets/charts.dart';
import '../widgets/debt_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/user_avatar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final debtsAsync = ref.watch(debtsProvider);
    final totalAsync = ref.watch(totalDebtsProvider);
    final nextPaymentAsync = ref.watch(nextPaymentProvider);

    return Scaffold(
      body: debtsAsync.when(
        loading: () => _LoadingState(),
        error: (e, st) => Center(child: Text('Erro: $e')),
        data: (debts) => debts.isEmpty
            ? _EmptyState()
            : _DashboardContent(
                user: user,
                debts: debts,
                total: totalAsync,
                nextPayment: nextPaymentAsync,
              ),
      ),
      floatingActionButton: _DashboardFAB(onPressed: () {
        context.push('/dashboard/add-debt');
      }),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StitchBackground(
      child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const ShimmerLoading(width: 180, height: 24, borderRadius: 8),
            const SizedBox(height: 8),
            const ShimmerLoading(width: 140, height: 14, borderRadius: 6),
            const SizedBox(height: 32),
            const ShimmerLoading(height: 100, borderRadius: 18),
            const SizedBox(height: 16),
            const ShimmerLoading(height: 100, borderRadius: 18),
            const SizedBox(height: 24),
            ...List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShimmerLoading(height: 110, borderRadius: 18),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({
    required this.user,
    required this.debts,
    required this.total,
    required this.nextPayment,
  });

  final AsyncValue<double> total;
  final AsyncValue<Debt?> nextPayment;
  final List<Debt> debts;
  final dynamic user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return StitchBackground(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              snap: true,
              toolbarHeight: 88,
              title: FadeSlideIn(
                index: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        color: AppColors.primaryContainer,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'DASHBOARD',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.primaryContainer,
                                fontSize: 9,
                                letterSpacing: 2.4,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Centro de Comando',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat("EEEE, dd MMMM", 'pt_BR')
                                  .format(DateTime.now()),
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      UserAvatar(name: user?.displayName ?? 'U'),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats row
                  FadeSlideIn(
                    index: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: total.when(
                            data: (t) => StatCard(
                              title: 'Saldo total de dívidas',
                              value: 'R\$ ${t.toStringAsFixed(0)}',
                              icon: Icons.account_balance_wallet_rounded,
                              color: AppColors.primaryContainer,
                            ),
                            loading: () => const StatCard(
                              title: 'Saldo total de dívidas',
                              value: '---',
                              icon: Icons.account_balance_wallet_rounded,
                              color: AppColors.primaryContainer,
                            ),
                            error: (err, st) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Next payment
                  FadeSlideIn(
                    index: 2,
                    child: nextPayment.when(
                      data: (debt) {
                        if (debt == null) return const SizedBox.shrink();
                        return StatCard(
                          title: 'Próximo pagamento',
                          value:
                              'R\$ ${debt.minimumPayment.toStringAsFixed(2)}',
                          icon: Icons.calendar_today_rounded,
                          subtitle:
                              '${debt.creditor} - ${DateFormat('dd/MM').format(debt.dueDate)}',
                          color: AppColors.accent,
                        );
                      },
                      loading: () => const StatCard(
                        title: 'Próximo pagamento',
                        value: '---',
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.accent,
                      ),
                      error: (err, st) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Monthly expenses summary
                  const MonthlyExpenseSummary(fadeIndex: 3),
                  const SizedBox(height: 16),

                  // Debt distribution chart
                  FadeSlideIn(
                    index: 4,
                    child: DebtDistributionChart(debts: debts),
                  ),
                  const SizedBox(height: 24),

                  // Debts list header
                  FadeSlideIn(
                    index: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ativos prioritários (${debts.length})',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'Ordenação tática',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Debts cards with staggered animation
                  ...debts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final debt = entry.value;
                    return FadeSlideIn(
                      index: 6 + index,
                      child: DebtCard(
                        debt: debt,
                        isUrgent: index == 0,
                        onTap: () =>
                            context.push('/dashboard/debt/${debt.id}'),
                      ),
                    );
                  }),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StitchBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeSlideIn(
                  index: 0,
                    child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.inbox_rounded,
                      color: AppColors.primaryContainer,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  index: 1,
                  child: Text(
                    'Nenhuma dívida registrada',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                FadeSlideIn(
                  index: 2,
                  child: Text(
                    'Comece a registrar suas dívidas para receber um plano personalizado.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                FadeSlideIn(
                  index: 3,
                  child: ScaleOnPress(
                    onTap: () => context.push('/dashboard/add-debt'),
                    child: Container(
                      height: 54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(colors: AppColors.ctaGradient),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ctaGlow,
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Adicionar dívida',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
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

class _DashboardFAB extends StatelessWidget {
  const _DashboardFAB({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleOnPress(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.ctaGradient),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.ctaGlow,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 22),
            SizedBox(width: 8),
            Text(
              'Adicionar',
              style: TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
