import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../models/debt_model.dart';

/// Read-only card displaying debt details (rate, min payment, dates).
class DebtDetailInfoCard extends StatelessWidget {
  const DebtDetailInfoCard({super.key, required this.debt});

  final Debt debt;

  static final _currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final _dateFormat = DateFormat('dd/MM/yyyy');

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
        children: [
          _DetailRow(
            icon: Icons.percent,
            label: 'Taxa de juros',
            value: '${debt.interestRate.toStringAsFixed(2)}% a.m.',
          ),
          Divider(color: AppColors.divider, height: 1),
          _DetailRow(
            icon: Icons.payments_outlined,
            label: 'Pagamento mínimo',
            value: _currencyFormat.format(debt.minimumPayment),
          ),
          Divider(color: AppColors.divider, height: 1),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Vencimento',
            value: _dateFormat.format(debt.dueDate),
          ),
          Divider(color: AppColors.divider, height: 1),
          _DetailRow(
            icon: Icons.access_time_outlined,
            label: 'Criado em',
            value: _dateFormat.format(debt.createdAt),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline edit card for amount, rate, min payment, and due date.
class DebtDetailEditCard extends StatelessWidget {
  const DebtDetailEditCard({
    super.key,
    required this.amountController,
    required this.rateController,
    required this.minPaymentController,
    required this.dueDateController,
    required this.onPickDate,
  });

  final TextEditingController amountController;
  final TextEditingController rateController;
  final TextEditingController minPaymentController;
  final TextEditingController dueDateController;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Modo de edição',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: amountController,
            label: 'Valor (R\$)',
            icon: Icons.attach_money,
            numeric: true,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: rateController,
            label: 'Taxa de juros (% a.m.)',
            icon: Icons.percent,
            numeric: true,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: minPaymentController,
            label: 'Pagamento mínimo (R\$)',
            icon: Icons.payments_outlined,
            numeric: true,
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onPickDate,
            child: AbsorbPointer(
              child: _buildField(
                controller: dueDateController,
                label: 'Data de vencimento',
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool numeric = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      inputFormatters: numeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))]
          : null,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
