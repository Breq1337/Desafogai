import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../models/expense_model.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onDismissed,
  });

  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  static const _categoryIcons = {
    'Alimentação': Icons.restaurant_rounded,
    'Transporte': Icons.directions_bus_rounded,
    'Moradia': Icons.home_rounded,
    'Saúde': Icons.health_and_safety_rounded,
    'Educação': Icons.school_rounded,
    'Lazer': Icons.sports_volleyball_rounded,
    'Vestuário': Icons.shopping_bag_rounded,
    'Dívidas': Icons.credit_card_rounded,
    'Outros': Icons.more_horiz_rounded,
  };

  IconData get categoryIcon =>
      _categoryIcons[expense.category] ?? Icons.more_horiz_rounded;

  Color get categoryColor {
    switch (expense.category) {
      case 'Alimentação':
        return const Color(0xFFFF6B6B);
      case 'Transporte':
        return const Color(0xFF4ECDC4);
      case 'Moradia':
        return const Color(0xFFFFBE0B);
      case 'Saúde':
        return const Color(0xFF95E1D3);
      case 'Educação':
        return const Color(0xFF6A4C93);
      case 'Lazer':
        return const Color(0xFFA8E6CF);
      case 'Vestuário':
        return const Color(0xFFFF8B94);
      case 'Dívidas':
        return AppColors.danger;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category + Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            categoryIcon,
                            color: categoryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.category,
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              if (expense.note.isNotEmpty)
                                Text(
                                  expense.note,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${expense.amount.toStringAsFixed(2)}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                      Text(
                        expense.source == 'telegram' ? 'Bot' : 'App',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(expense.date),
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    Widget result = ScaleOnPress(
      onTap: onTap,
      scaleFactor: 0.97,
      child: card,
    );

    if (onDismissed != null) {
      result = Dismissible(
        key: Key(expense.id),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete_rounded, color: AppColors.danger),
        ),
        onDismissed: (_) => onDismissed?.call(),
        child: result,
      );
    }

    return result;
  }
}
