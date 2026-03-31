import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stitch_background.dart';
import '../models/debt_model.dart';
import '../models/monthly_plan.dart';
import '../services/monthly_plan_service.dart';
import '../services/pdf_export_service.dart';

class MonthlyPlanScreen extends ConsumerStatefulWidget {
  final List<Debt> debts;
  final double monthlyIncome;
  final double fixedExpenses;

  const MonthlyPlanScreen({
    super.key,
    required this.debts,
    required this.monthlyIncome,
    required this.fixedExpenses,
  });

  @override
  ConsumerState<MonthlyPlanScreen> createState() => _MonthlyPlanScreenState();
}

class _MonthlyPlanScreenState extends ConsumerState<MonthlyPlanScreen> {
  MonthlyPlan? _plan;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _generatePlan();
  }

  Future<void> _generatePlan() async {
    setState(() => _loading = true);

    try {
      final plan = MonthlyPlanService.generate(
        debts: widget.debts,
        monthlyIncome: widget.monthlyIncome,
        fixedExpenses: widget.fixedExpenses,
      );

      setState(() {
        _plan = plan;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar plano: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final availableBudget = widget.monthlyIncome - widget.fixedExpenses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.92),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PLANO MENSAL',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.primaryContainer,
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Missão tática',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          if (_plan != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              tooltip: 'Exportar PDF',
              onPressed: () async {
                try {
                  await PdfExportService.exportAndShare(_plan!);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao exportar: $e')),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: StitchBackground(
        child: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _plan == null
                ? Center(
                    child: Text(
                      'Erro ao carregar plano mensal',
                      style: textTheme.bodyMedium,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.monthlyIncome <= 0 || widget.debts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.monthlyIncome <= 0
                                          ? 'Defina sua renda em Configurações > Editar perfil para cálculos precisos.'
                                          : 'Cadastre dívidas para gerar um plano personalizado.',
                                      style: textTheme.bodySmall?.copyWith(color: AppColors.warning, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _baseCalcItem(textTheme, 'Renda', 'R\$ ${widget.monthlyIncome.toStringAsFixed(0)}'),
                              _baseCalcItem(textTheme, 'Gastos', 'R\$ ${widget.fixedExpenses.toStringAsFixed(0)}'),
                              _baseCalcItem(textTheme, 'Sobra', 'R\$ ${availableBudget.toStringAsFixed(0)}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Alocação tática',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Distribuição do orçamento disponível por prioridade',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _BudgetHeaderCard(availableBudget: availableBudget),
                        const SizedBox(height: 28),

                        // Recommendations list
                        Text(
                          'Pagamentos sugeridos',
                          style: textTheme.labelMedium,
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(
                          _plan!.recommendations.length,
                          (index) {
                            final rec = _plan!.recommendations[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RecommendationCard(recommendation: rec),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Summary section
                        _SummaryCard(plan: _plan!),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _baseCalcItem(TextTheme textTheme, String label, String value) {
    return Column(
      children: [
        Text(label, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _BudgetHeaderCard extends StatelessWidget {
  final double availableBudget;

  const _BudgetHeaderCard({required this.availableBudget});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryContainer.withValues(alpha: 0.14),
            AppColors.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orçamento disponível',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${availableBudget.toStringAsFixed(2)}',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Renda − Despesas fixas',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final MonthlyPlanRecommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creditor name
          Text(
            recommendation.creditor,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Suggested payment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pagamento sugerido',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'R\$ ${recommendation.suggestedPayment.toStringAsFixed(2)}',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Interest accrual
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Juros do mês',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'R\$ ${recommendation.interestAccrual.toStringAsFixed(2)}',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Divider
          Divider(
            color: AppColors.divider,
            height: 1,
          ),
          const SizedBox(height: 10),

          // New balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo após pagamento',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'R\$ ${recommendation.newBalance.toStringAsFixed(2)}',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final MonthlyPlan plan;

  const _SummaryCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do plano',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Total suggested
          _SummaryRow(
            label: 'Total sugerido',
            value: 'R\$ ${plan.totalSuggested.toStringAsFixed(2)}',
            valueColor: AppColors.accent,
          ),
          const SizedBox(height: 14),

          // Savings rate
          _SummaryRow(
            label: 'Taxa de poupança',
            value: '${plan.savingsRate.toStringAsFixed(1)}%',
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: 14),

          // Available vs suggested
          _SummaryRow(
            label: 'Disponível para dívidas',
            value: 'R\$ ${plan.availableForPayment.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 20),

          // Aggressive indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: plan.isAggressive
                  ? AppColors.warning.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  plan.isAggressive
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                  color: plan.isAggressive
                      ? AppColors.warning
                      : AppColors.success,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    plan.isAggressive
                        ? 'Plano agressivo — pouca margem de segurança'
                        : 'Plano equilibrado — margem de segurança adequada',
                    style: textTheme.labelSmall?.copyWith(
                      color: plan.isAggressive
                          ? AppColors.warning
                          : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
