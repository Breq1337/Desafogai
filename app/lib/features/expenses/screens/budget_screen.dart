import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../dashboard/providers/planning_provider.dart';
import '../../dashboard/providers/debts_provider.dart';
import '../../dashboard/services/planning_service.dart';
import '../models/expense_model.dart';
import '../providers/expenses_provider.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _editingCategory = <String, bool>{};
  final _limitControllers = <String, TextEditingController>{};
  final _savingsGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final category in kExpenseCategories) {
      _editingCategory[category] = false;
      _limitControllers[category] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _savingsGoalController.dispose();
    for (final controller in _limitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _normalizeDecimal(String text) => text.replaceAll(',', '.');

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
          SnackBar(
            content: Text('Limite de $category atualizado.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveSavingsGoal(double goal) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('main')
          .set(
            {
              'savingsGoal': goal,
              'updatedAt': Timestamp.now(),
            },
            SetOptions(merge: true),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meta de economia atualizada.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar meta: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final categoryExpensesAsync = ref.watch(monthlyExpenseByCategoryProvider);
    final planningAsync = ref.watch(planningSettingsProvider);
    final debtsAsync = ref.watch(debtsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Plano do mês'),
      ),
      body: SafeArea(
        child: budgetsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (budgets) => categoryExpensesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (expensesByCategory) => planningAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (planning) {
                final debts = debtsAsync.valueOrNull ?? [];
                final totalBudgeted = budgets.values.fold<double>(
                  0,
                  (totalBudget, budget) => totalBudget + budget.monthlyLimit,
                );
                final totalSpent = expensesByCategory.values.fold<double>(
                  0,
                  (totalSpent, value) => totalSpent + value,
                );
                final suggestedSavings = PlanningService.suggestedSavingsGoal(
                  debts: debts,
                  monthlyIncome: planning.monthlyIncome,
                  plannedCategoryBudget: totalBudgeted,
                );
                final savingsGoal = planning.savingsGoal;
                final reservedForDebts = PlanningService.amountReservedForDebts(
                  monthlyIncome: planning.monthlyIncome,
                  plannedCategoryBudget: totalBudgeted,
                  savingsGoal: savingsGoal,
                );

                if (_savingsGoalController.text.isEmpty ||
                    double.tryParse(_normalizeDecimal(_savingsGoalController.text)) != savingsGoal) {
                  _savingsGoalController.text = savingsGoal > 0
                      ? savingsGoal.toStringAsFixed(0)
                      : suggestedSavings.toStringAsFixed(0);
                }

                for (final category in kExpenseCategories) {
                  final currentText = _limitControllers[category]!.text;
                  final currentValue = budgets[category]?.monthlyLimit ?? 0;
                  if (currentText.isEmpty ||
                      double.tryParse(_normalizeDecimal(currentText)) != currentValue) {
                    _limitControllers[category]!.text = currentValue == 0
                        ? ''
                        : currentValue.toStringAsFixed(0);
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organize quanto vai para o mês, quanto quer guardar e quanto sobra para atacar as dívidas.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 20),
                      _PlanSummaryCard(
                        monthlyIncome: planning.monthlyIncome,
                        totalBudgeted: totalBudgeted,
                        totalSpent: totalSpent,
                        savingsGoal: savingsGoal,
                        reservedForDebts: reservedForDebts,
                      ),
                      const SizedBox(height: 20),
                      _SavingsGoalCard(
                        controller: _savingsGoalController,
                        suggestedValue: suggestedSavings,
                        suggestedReason: PlanningService.suggestedSavingsReason(debts),
                        onUseSuggestion: () {
                          setState(() {
                            _savingsGoalController.text =
                                suggestedSavings.toStringAsFixed(0);
                          });
                        },
                        onSave: () {
                          final value = double.tryParse(
                            _normalizeDecimal(_savingsGoalController.text),
                          );
                          if (value == null || value < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Informe um valor válido para a meta.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          _saveSavingsGoal(value);
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Orçamento por categoria',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Defina um teto por categoria para o mês ficar previsível.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ...kExpenseCategories.map((category) {
                        final budget = budgets[category];
                        final limit = budget?.monthlyLimit ?? 0;
                        final spent = expensesByCategory[category] ?? 0;
                        final isEditing = _editingCategory[category] ?? false;

                        return _CategoryPlannerRow(
                          category: category,
                          spent: spent,
                          limit: limit,
                          controller: _limitControllers[category]!,
                          isEditing: isEditing,
                          onEdit: () => setState(() => _editingCategory[category] = true),
                          onCancel: () {
                            _limitControllers[category]!.text =
                                limit > 0 ? limit.toStringAsFixed(0) : '';
                            setState(() => _editingCategory[category] = false);
                          },
                          onSave: () {
                            final value = double.tryParse(
                              _normalizeDecimal(_limitControllers[category]!.text),
                            );
                            if (value == null || value < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Valor inválido para $category.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            _saveBudget(category, value);
                          },
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({
    required this.monthlyIncome,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.savingsGoal,
    required this.reservedForDebts,
  });

  final double monthlyIncome;
  final double totalBudgeted;
  final double totalSpent;
  final double savingsGoal;
  final double reservedForDebts;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mapa do mês',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryPill(label: 'Renda', value: monthlyIncome),
              _SummaryPill(label: 'Orçado', value: totalBudgeted),
              _SummaryPill(label: 'Gasto até agora', value: totalSpent),
              _SummaryPill(label: 'Meta de economia', value: savingsGoal),
              _SummaryPill(
                label: 'Livre para dívidas',
                value: reservedForDebts,
                highlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavingsGoalCard extends StatelessWidget {
  const _SavingsGoalCard({
    required this.controller,
    required this.suggestedValue,
    required this.suggestedReason,
    required this.onUseSuggestion,
    required this.onSave,
  });

  final TextEditingController controller;
  final double suggestedValue;
  final String suggestedReason;
  final VoidCallback onUseSuggestion;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quanto quero economizar',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            suggestedReason,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Meta mensal (R\$)',
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.savings_outlined, size: 20),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: onUseSuggestion,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: Text('Usar sugestão: R\$ ${suggestedValue.toStringAsFixed(0)}'),
              ),
              ElevatedButton(
                onPressed: onSave,
                child: const Text('Salvar meta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryPlannerRow extends StatelessWidget {
  const _CategoryPlannerRow({
    required this.category,
    required this.spent,
    required this.limit,
    required this.controller,
    required this.isEditing,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  final String category;
  final double spent;
  final double limit;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final usage = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOver = limit > 0 && spent > limit;
    final accent = isOver
        ? AppColors.danger
        : usage >= 0.85
            ? AppColors.warning
            : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gasto atual: R\$ ${spent.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (!isEditing)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppColors.textSecondary,
                ),
            ],
          ),
          if (isEditing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Limite mensal',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onSave,
                  icon: const Icon(Icons.check_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            if (limit > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: usage,
                  minHeight: 7,
                  backgroundColor: AppColors.surfaceContainerLow,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Limite: R\$ ${limit.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    '${(usage * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ] else
              Text(
                'Sem teto definido ainda.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final double value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'R\$ ${value.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppColors.primary : AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
