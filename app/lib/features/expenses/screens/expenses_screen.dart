import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/alert_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../models/expense_model.dart';
import '../providers/expenses_provider.dart';
import '../providers/budget_provider.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final expensesAsync = ref.watch(expensesProvider);
    final totalAsync = ref.watch(monthlyExpenseTotalProvider);
    final budgetsAsync = ref.watch(budgetsProvider);
    final categoryTotals = ref.watch(monthlyCategoryTotalsProvider);

    return Scaffold(
      body: SafeArea(
        child: expensesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Erro: $e')),
          data: (expenses) => _ExpensesContent(
            expenses: expenses,
            totalAsync: totalAsync,
            budgets: (budgetsAsync.valueOrNull ?? {}).map((k, v) => MapEntry(k, v.monthlyLimit)),
            categoryTotals: categoryTotals.valueOrNull ?? {},
            selectedCategory: _selectedCategory,
            onCategorySelected: (c) => setState(() => _selectedCategory = c),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/dashboard/expenses/add'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _ExpensesContent extends StatelessWidget {
  const _ExpensesContent({
    required this.expenses,
    required this.totalAsync,
    required this.budgets,
    required this.categoryTotals,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<Expense> expenses;
  final AsyncValue<double> totalAsync;
  final Map<String, double> budgets;
  final Map<String, double> categoryTotals;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = totalAsync.valueOrNull ?? 0.0;

    final filteredExpenses = selectedCategory == null
        ? expenses
        : expenses.where((e) => e.category == selectedCategory).toList();

    final groupedExpenses = <String, List<Expense>>{};
    for (final expense in filteredExpenses) {
      final key = DateFormat('MMMM yyyy', 'pt_BR').format(expense.date);
      groupedExpenses.putIfAbsent(key, () => []).add(expense);
    }

    // Find categories near/over budget
    final alerts = <String>[];
    for (final cat in categoryTotals.keys) {
      final limit = budgets[cat];
      if (limit == null || limit <= 0) continue;
      final spent = categoryTotals[cat] ?? 0;
      final pct = spent / limit;
      if (pct >= 1.0) {
        alerts.add('$cat está acima do limite.');
      } else if (pct >= 0.9) {
        alerts.add('$cat está quase no limite (${(pct * 100).toStringAsFixed(0)}%).');
      }
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gastos', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${total.toStringAsFixed(0)} este mês',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Budget alerts
                ...alerts.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AlertBanner(
                        message: a,
                        severity: a.contains('acima') ? AlertSeverity.danger : AlertSeverity.warning,
                      ),
                    )),
                if (alerts.isNotEmpty) const SizedBox(height: 8),

                // Category budgets overview
                if (budgets.isNotEmpty) ...[
                  const SectionHeader(title: 'Limites por categoria'),
                  ...kExpenseCategories
                      .where((c) => budgets.containsKey(c) && (budgets[c] ?? 0) > 0)
                      .map((cat) {
                    final limit = budgets[cat]!;
                    final spent = categoryTotals[cat] ?? 0;
                    final pct = (spent / limit).clamp(0.0, 1.5);
                    return _CategoryBudgetRow(
                      category: cat,
                      spent: spent,
                      limit: limit,
                      percentage: pct,
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.push('/dashboard/expenses/budget'),
                      child: const Text('Gerenciar limites'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Category filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Todas',
                        selected: selectedCategory == null,
                        onTap: () => onCategorySelected(null),
                      ),
                      ...kExpenseCategories.map((cat) => Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _FilterChip(
                              label: cat,
                              selected: selectedCategory == cat,
                              onTap: () => onCategorySelected(selectedCategory == cat ? null : cat),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        if (filteredExpenses.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  expenses.isEmpty ? 'Sem gastos registrados' : 'Sem gastos nesta categoria',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          )
        else
          ...groupedExpenses.entries.map((entry) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...entry.value.map(
                        (expense) => _ExpenseRow(
                          expense: expense,
                          onTap: () => context.push('/dashboard/expenses/${expense.id}'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              )),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _CategoryBudgetRow extends StatelessWidget {
  const _CategoryBudgetRow({
    required this.category,
    required this.spent,
    required this.limit,
    required this.percentage,
  });

  final String category;
  final double spent;
  final double limit;
  final double percentage;

  Color get _color {
    if (percentage >= 1.0) return AppColors.danger;
    if (percentage >= 0.9) return AppColors.warning;
    if (percentage >= 0.7) return AppColors.warning;
    return AppColors.primaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
              Text(
                'R\$ ${spent.toStringAsFixed(0)} / R\$ ${limit.toStringAsFixed(0)}',
                style: textTheme.bodySmall?.copyWith(
                  color: _color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer.withValues(alpha: 0.12)
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.primaryContainer.withValues(alpha: 0.3)
                : AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.primaryContainer : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.expense,
    this.onTap,
  });

  final Expense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _categoryIcon(expense.category),
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.note.isNotEmpty ? expense.note : expense.category,
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          expense.category,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        if (expense.source == 'telegram') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF26A5E4).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Telegram',
                              style: TextStyle(fontSize: 9, color: Color(0xFF26A5E4), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${expense.amount.toStringAsFixed(2)}',
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Alimentação' => Icons.restaurant_rounded,
      'Transporte' => Icons.directions_car_rounded,
      'Moradia' => Icons.home_rounded,
      'Saúde' => Icons.favorite_rounded,
      'Educação' => Icons.school_rounded,
      'Lazer' => Icons.sports_esports_rounded,
      'Vestuário' => Icons.checkroom_rounded,
      'Dívidas' => Icons.credit_card_rounded,
      _ => Icons.receipt_long_rounded,
    };
  }
}
