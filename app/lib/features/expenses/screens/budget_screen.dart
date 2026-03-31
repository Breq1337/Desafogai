import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/stitch_background.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';
import '../providers/expenses_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final budgetsAsync = ref.watch(budgetsProvider);
    final categoryExpensesAsync = ref.watch(monthlyExpenseByCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Orçamentos'),
      ),
      body: StitchBackground(
        child: SafeArea(
          child: budgetsAsync.when(
            loading: () => _LoadingState(),
            error: (e, st) => Center(child: Text('Erro: $e')),
            data: (budgets) => categoryExpensesAsync.when(
              data: (expenses) => _BudgetContent(
                budgets: budgets,
                expenses: expenses,
              ),
              loading: () => _LoadingState(),
              error: (e, st) => Center(child: Text('Erro: $e')),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(
              9,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ShimmerLoading(height: 120, borderRadius: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetContent extends ConsumerStatefulWidget {
  const _BudgetContent({
    required this.budgets,
    required this.expenses,
  });

  final Map<String, CategoryBudget> budgets;
  final Map<String, double> expenses;

  @override
  ConsumerState<_BudgetContent> createState() => _BudgetContentState();
}

class _BudgetContentState extends ConsumerState<_BudgetContent> {
  final _editingCategory = <String, bool>{};
  final _tempLimitControllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    for (final category in kExpenseCategories) {
      _editingCategory[category] = false;
      _tempLimitControllers[category] = TextEditingController(
        text: (widget.budgets[category]?.monthlyLimit ?? 0).toStringAsFixed(2),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _tempLimitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveBudget(String category, double limit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .doc(category)
          .set(
            {
              'monthlyLimit': limit,
              'updatedAt': Timestamp.now(),
            },
            SetOptions(merge: true),
          );

      setState(() => _editingCategory[category] = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orçamento atualizado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            index: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orçamentos por categoria',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Defina limites e acompanhe seus gastos',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...kExpenseCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final budget = widget.budgets[category];
            final monthlyExpense = widget.expenses[category] ?? 0.0;
            final monthlyLimit = budget?.monthlyLimit ?? 0.0;
            final isEditing = _editingCategory[category] ?? false;

            final percentUsed = monthlyLimit > 0
                ? (monthlyExpense / monthlyLimit).clamp(0.0, 1.0)
                : 0.0;
            final isOverBudget = monthlyExpense > monthlyLimit && monthlyLimit > 0;

            return FadeSlideIn(
              index: index + 1,
              child: _BudgetCategoryCard(
                category: category,
                monthlyLimit: monthlyLimit,
                monthlyExpense: monthlyExpense,
                percentUsed: percentUsed,
                isOverBudget: isOverBudget,
                isEditing: isEditing,
                limitController: _tempLimitControllers[category]!,
                onEdit: () {
                  setState(() => _editingCategory[category] = true);
                },
                onSave: () {
                  final newLimit =
                      double.tryParse(_tempLimitControllers[category]!.text) ??
                          0.0;
                  _saveBudget(category, newLimit);
                },
                onCancel: () {
                  _tempLimitControllers[category]!.text =
                      (monthlyLimit).toStringAsFixed(2);
                  setState(() => _editingCategory[category] = false);
                },
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BudgetCategoryCard extends StatelessWidget {
  const _BudgetCategoryCard({
    required this.category,
    required this.monthlyLimit,
    required this.monthlyExpense,
    required this.percentUsed,
    required this.isOverBudget,
    required this.isEditing,
    required this.limitController,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
  });

  final String category;
  final double monthlyLimit;
  final double monthlyExpense;
  final double percentUsed;
  final bool isOverBudget;
  final bool isEditing;
  final TextEditingController limitController;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  Color get _barColor {
    if (!isOverBudget) return AppColors.primary;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverBudget
              ? AppColors.danger.withValues(alpha: 0.3)
              : AppColors.divider,
          width: isOverBudget ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gasto: R\$ ${monthlyExpense.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: isOverBudget ? AppColors.danger : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isEditing)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isEditing)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: limitController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'Limite mensal',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onSave,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onCancel,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            )
          else if (monthlyLimit > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentUsed,
                minHeight: 6,
                backgroundColor: AppColors.divider.withValues(alpha: 0.4),
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Limite: R\$ ${monthlyLimit.toStringAsFixed(2)}',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(percentUsed * 100).toStringAsFixed(0)}%',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _barColor,
                  ),
                ),
              ],
            ),
          ] else
            Center(
              child: Text(
                'Sem limite definido',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
