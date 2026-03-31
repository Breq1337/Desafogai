import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/debt_model.dart';
import '../models/simulation.dart';

/// Pie chart showing debt distribution by creditor.
class DebtDistributionChart extends StatelessWidget {
  const DebtDistributionChart({super.key, required this.debts});

  final List<Debt> debts;

  static const _colors = [
    AppColors.primaryContainer,
    AppColors.accent,
    AppColors.warning,
    AppColors.danger,
    AppColors.success,
    Color(0xFF9B59B6),
    Color(0xFFE67E22),
    Color(0xFF1ABC9C),
  ];

  @override
  Widget build(BuildContext context) {
    if (debts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Text(
          'Sem dívidas para exibir distribuição.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      );
    }

    final sortedDebts = [...debts]..sort((a, b) => b.amount.compareTo(a.amount));
    final total = sortedDebts.fold<double>(0, (s, d) => s + d.amount);
    final highlighted = sortedDebts.take(5).toList();
    final othersTotal = sortedDebts.skip(5).fold<double>(0, (s, d) => s + d.amount);

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
            'DISTRIBUIÇÃO DE DÍVIDAS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Total: R\$ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        ...highlighted.asMap().entries.map((e) {
                          final i = e.key;
                          final debt = e.value;
                          final pct = (debt.amount / total * 100);
                          return PieChartSectionData(
                            color: _colors[i % _colors.length],
                            value: debt.amount,
                            title: pct >= 7 ? '${pct.toStringAsFixed(0)}%' : '',
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            radius: 42,
                          );
                        }),
                        if (othersTotal > 0)
                          PieChartSectionData(
                            color: AppColors.outlineVariant,
                            value: othersTotal,
                            title: '${(othersTotal / total * 100).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            radius: 42,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...highlighted.asMap().entries.map((e) {
                        final i = e.key;
                        final debt = e.value;
                        final pct = (debt.amount / total * 100);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _colors[i % _colors.length],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${debt.creditor} (${pct.toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (othersTotal > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.outlineVariant,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Outras (${(othersTotal / total * 100).toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (highlighted.isNotEmpty)
            Text(
              'Maior dívida: ${highlighted.first.creditor} (R\$ ${highlighted.first.amount.toStringAsFixed(2)})',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}

/// Line chart showing payoff projection over months.
class PayoffProjectionChart extends StatelessWidget {
  const PayoffProjectionChart({super.key, required this.results});

  final Map<PaymentStrategy, SimulationResult> results;

  static const _strategyColors = {
    PaymentStrategy.minimum: AppColors.danger,
    PaymentStrategy.balanced: AppColors.primaryContainer,
    PaymentStrategy.aggressive: AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();

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
            'PROJEÇÃO DE QUITAÇÃO',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: _strategyColors.entries
                .where((e) => results.containsKey(e.key))
                .map((e) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: e.value,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            e.key.displayName,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.divider,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 6,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}m',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (v, _) => Text(
                        'R\$${(v / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: results.entries
                    .where((e) => _strategyColors.containsKey(e.key))
                    .map((entry) {
                  final color = _strategyColors[entry.key]!;
                  final snapshots = entry.value.snapshots;
                  return LineChartBarData(
                    spots: snapshots
                        .map((s) => FlSpot(
                              s.month.toDouble(),
                              s.totalBalance,
                            ))
                        .toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.08),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated progress bar for debt payoff percentage.
class DebtProgressBar extends StatelessWidget {
  const DebtProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.total,
    this.color = AppColors.primaryContainer,
  });

  final String label;
  final double current;
  final double total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            );
          },
        ),
      ],
    );
  }
}
