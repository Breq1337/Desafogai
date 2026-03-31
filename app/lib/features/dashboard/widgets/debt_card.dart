import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_animations.dart';
import '../models/debt_model.dart';

class DebtCard extends StatelessWidget {
  const DebtCard({
    super.key,
    required this.debt,
    required this.isUrgent,
    this.onTap,
  });

  final Debt debt;
  final bool isUrgent;
  final VoidCallback? onTap;

  Color get statusColor {
    if (debt.isOverdue) return AppColors.danger;
    if (debt.isDueSoon) return const Color(0xFFFFB84D);
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final daysProgress =
        (debt.dueDate.difference(DateTime.now()).inDays / 30).clamp(0.0, 1.0);

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUrgent
                ? AppColors.surfaceContainerHigh.withValues(alpha: 0.85)
                : AppColors.surfaceContainerLow.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUrgent
                  ? statusColor.withValues(alpha: 0.4)
                  : AppColors.divider.withValues(alpha: 0.5),
              width: isUrgent ? 1.5 : 1,
            ),
            boxShadow: isUrgent
                ? [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.12),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.06),
                      blurRadius: 32,
                      spreadRadius: -4,
                    ),
                  ]
                : [
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
              // Header: Creditor + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.creditor,
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Taxa: ${debt.interestRate.toStringAsFixed(1)}% a.m.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    label: debt.isOverdue
                        ? 'Atrasado'
                        : debt.isDueSoon
                            ? 'Urgente'
                            : 'Normal',
                    color: statusColor,
                    pulse: debt.isOverdue,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Amount + Due date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${debt.amount.toStringAsFixed(2)}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Vencimento',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM').format(debt.dueDate),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar with glow
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: daysProgress,
                      minHeight: 4,
                      backgroundColor: AppColors.divider.withValues(alpha: 0.4),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                  // Glow on progress tip
                  if (daysProgress > 0 && daysProgress < 1)
                    Positioned(
                      left: daysProgress *
                          (MediaQuery.of(context).size.width - 96),
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return ScaleOnPress(
      onTap: onTap,
      scaleFactor: 0.97,
      child: card,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    this.pulse = false,
  });

  final String label;
  final Color color;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );

    if (pulse) {
      return PulseAnimation(
        minScale: 0.97,
        maxScale: 1.03,
        child: badge,
      );
    }
    return badge;
  }
}
