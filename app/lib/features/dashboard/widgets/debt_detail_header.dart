import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../models/debt_model.dart';

/// Header card showing creditor name, total amount, and status badge.
class DebtDetailHeader extends StatelessWidget {
  const DebtDetailHeader({super.key, required this.debt});

  final Debt debt;

  static final _currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  debt.creditor,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _StatusBadge(status: debt.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currencyFormat.format(debt.amount),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  Color get _color {
    switch (status) {
      case 'paid':
        return AppColors.accent;
      case 'paused':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  String get _label {
    switch (status) {
      case 'paid':
        return 'Pago';
      case 'paused':
        return 'Pausado';
      default:
        return 'Ativo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
