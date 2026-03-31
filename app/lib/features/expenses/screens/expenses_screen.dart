import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/stitch_background.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/expense_model.dart';
import '../providers/expenses_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/stat_card.dart';

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

    return Scaffold(
      body: expensesAsync.when(
        loading: () => _LoadingState(),
        error: (e, st) => Center(child: Text('Erro: $e')),
        data: (expenses) => expenses.isEmpty
            ? _EmptyState()
            : _ExpensesContent(
                expenses: expenses,
                total: totalAsync,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/dashboard/expenses/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo gasto'),
      ),
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StitchBackground(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Sem gastos ainda',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Registre seus gastos para começar',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpensesContent extends ConsumerWidget {
  const _ExpensesContent({
    required this.expenses,
    required this.total,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<Expense> expenses;
  final AsyncValue<double> total;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // Filter expenses by selected category
    final filteredExpenses = selectedCategory == null
        ? expenses
        : expenses.where((e) => e.category == selectedCategory).toList();

    // Group expenses by month
    final groupedExpenses = <String, List<Expense>>{};
    for (final expense in filteredExpenses) {
      final monthKey = DateFormat('MMMM/yyyy', 'pt_BR').format(expense.date);
      groupedExpenses.putIfAbsent(monthKey, () => []).add(expense);
    }

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
                        Icons.receipt_long_rounded,
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
                              'GASTOS',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.primaryContainer,
                                fontSize: 9,
                                letterSpacing: 2.4,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Acompanhe seus gastos',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  // Total stat
                  FadeSlideIn(
                    index: 1,
                    child: total.when(
                      data: (t) => StatCard(
                        title: 'Gastos do mês',
                        value: 'R\$ ${t.toStringAsFixed(0)}',
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
                  const SizedBox(height: 20),

                  // Category filter chips
                  FadeSlideIn(
                    index: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Todas'),
                            selected: selectedCategory == null,
                            onSelected: (selected) {
                              onCategorySelected(null);
                            },
                          ),
                          const SizedBox(width: 8),
                          ...kExpenseCategories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: selectedCategory == category,
                                onSelected: (selected) {
                                  onCategorySelected(
                                    selected ? category : null,
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Expenses list grouped by month
                  if (filteredExpenses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'Sem gastos nesta categoria',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...groupedExpenses.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeSlideIn(
                            index: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                entry.key,
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          ...entry.value.map((expense) {
                            return FadeSlideIn(
                              index: 4,
                              child: ExpenseCard(
                                expense: expense,
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
