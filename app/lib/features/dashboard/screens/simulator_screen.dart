import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stitch_background.dart';
import '../models/debt_model.dart';
import '../models/simulation.dart';
import '../services/simulator_service.dart';
import '../widgets/charts.dart';

class SimulatorScreen extends ConsumerStatefulWidget {
  final List<Debt> debts;
  final double monthlyIncome;
  final double fixedExpenses;

  const SimulatorScreen({
    super.key,
    required this.debts,
    required this.monthlyIncome,
    required this.fixedExpenses,
  });

  @override
  ConsumerState<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends ConsumerState<SimulatorScreen> {
  Map<PaymentStrategy, SimulationResult>? _results;
  bool _loading = false;
  PaymentStrategy? _selectedStrategy;

  @override
  void initState() {
    super.initState();
    _runSimulation();
  }

  Future<void> _runSimulation() async {
    setState(() => _loading = true);

    try {
      final results = SimulatorService.compareStrategies(
        debts: widget.debts,
        monthlyIncome: widget.monthlyIncome,
        fixedExpenses: widget.fixedExpenses,
        months: 36,
      );

      setState(() {
        _results = results;
        _selectedStrategy = PaymentStrategy.balanced;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na simulação: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selectedResult = _selectedStrategy != null && _results != null
        ? _results![_selectedStrategy]
        : null;

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
              'SIMULADOR',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.primaryContainer,
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Cenários de pagamento',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: StitchBackground(
        child: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _results == null
                ? Center(
                    child: Text(
                      'Erro ao carregar simulação',
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
                                          ? 'Defina sua renda para simulações precisas.'
                                          : 'Cadastre dívidas para simular cenários.',
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
                              _simBaseItem(textTheme, 'Renda', 'R\$ ${widget.monthlyIncome.toStringAsFixed(0)}'),
                              _simBaseItem(textTheme, 'Gastos', 'R\$ ${widget.fixedExpenses.toStringAsFixed(0)}'),
                              _simBaseItem(textTheme, 'Sobra', 'R\$ ${(widget.monthlyIncome - widget.fixedExpenses).toStringAsFixed(0)}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Compare estratégias de pagamento',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Veja como cada estratégia afeta seu tempo de quitação',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Strategy selector
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estratégias',
                              style: textTheme.labelMedium,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              children: [
                                for (final strategy in [
                                  PaymentStrategy.minimum,
                                  PaymentStrategy.balanced,
                                  PaymentStrategy.aggressive,
                                ])
                                  _StrategyButton(
                                    strategy: strategy,
                                    isSelected:
                                        _selectedStrategy == strategy,
                                    onTap: () {
                                      setState(
                                        () =>
                                            _selectedStrategy = strategy,
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Selected strategy details
                        if (selectedResult != null) ...[
                          _StrategyDetailsCard(result: selectedResult),
                          const SizedBox(height: 24),

                          // Payoff projection chart
                          PayoffProjectionChart(results: _results!),
                          const SizedBox(height: 24),

                          // Comparison
                          _ComparisonSection(results: _results!),
                        ],
                      ],
                    ),
                  ),
      ),
      ),
    );
  }

  Widget _simBaseItem(TextTheme textTheme, String label, String value) {
    return Column(
      children: [
        Text(label, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _StrategyButton extends StatelessWidget {
  final PaymentStrategy strategy;
  final bool isSelected;
  final VoidCallback onTap;

  const _StrategyButton({
    required this.strategy,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          strategy.displayName,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _StrategyDetailsCard extends StatelessWidget {
  final SimulationResult result;

  const _StrategyDetailsCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payoff time
          _DetailRow(
            label: 'Tempo para quitação',
            value: '${result.monthsToPayOff} meses',
            isPrimary: true,
          ),
          const SizedBox(height: 16),

          // Total paid
          _DetailRow(
            label: 'Total a pagar',
            value: 'R\$ ${result.totalPaid.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),

          // Total interest
          _DetailRow(
            label: 'Juros pagos',
            value: 'R\$ ${result.totalInterestPaid.toStringAsFixed(2)}',
            valueColor: AppColors.danger,
          ),
          const SizedBox(height: 16),

          // Savings rate
          _DetailRow(
            label: 'Taxa de poupança',
            value: '${result.projectedSavingRate.toStringAsFixed(1)}%',
            valueColor: AppColors.success,
          ),

          // Status
          const SizedBox(height: 20),
          if (result.allDebtsCleared)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Todas as dívidas quitadas',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_rounded,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sem quitação em 3 anos',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isPrimary;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isPrimary = false,
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
          style: (isPrimary ? textTheme.titleSmall : textTheme.bodySmall)
              ?.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  final Map<PaymentStrategy, SimulationResult> results;

  const _ComparisonSection({required this.results});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparativo de estratégias',
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 12),
        ...results.entries.map((entry) {
          final strategy = entry.key;
          final result = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ComparisonCard(
              strategy: strategy,
              result: result,
            ),
          );
        }),
      ],
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final PaymentStrategy strategy;
  final SimulationResult result;

  const _ComparisonCard({
    required this.strategy,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Strategy name
          Expanded(
            flex: 2,
            child: Text(
              strategy.displayName,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Months
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.monthsToPayOff}m',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'meses',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Interest
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'R\$ ${result.totalInterestPaid.toStringAsFixed(0)}',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
                Text(
                  'juros',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
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
