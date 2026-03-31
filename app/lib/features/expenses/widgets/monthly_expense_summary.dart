import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../providers/expenses_provider.dart';
import '../widgets/stat_card.dart';

class MonthlyExpenseSummary extends ConsumerWidget {
  const MonthlyExpenseSummary({
    super.key,
    this.fadeIndex = 2,
  });

  final int fadeIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAsync = ref.watch(monthlyExpenseTotalProvider);

    return FadeSlideIn(
      index: fadeIndex,
      child: totalAsync.when(
        data: (total) => StatCard(
          title: 'Gastos do mês',
          value: 'R\$ ${total.toStringAsFixed(0)}',
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
    );
  }
}
