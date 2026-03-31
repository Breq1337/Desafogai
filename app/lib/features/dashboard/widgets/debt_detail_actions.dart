import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/debt_model.dart';

/// Urgency score card with colored progress bar.
class DebtUrgencyCard extends StatelessWidget {
  const DebtUrgencyCard({super.key, required this.debt});

  final Debt debt;

  Color _urgencyColor(double score) {
    if (score < 40) return AppColors.accent;
    if (score <= 70) return AppColors.warning;
    return AppColors.danger;
  }

  String _urgencyLabel(double score) {
    if (score < 40) return 'Baixa';
    if (score <= 70) return 'Média';
    return 'Alta';
  }

  @override
  Widget build(BuildContext context) {
    final score = debt.urgencyScore;
    final color = _urgencyColor(score);
    final label = _urgencyLabel(score);

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
              const Text(
                'Urgência',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${score.toStringAsFixed(0)}/100',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Warning banner for overdue / due-soon debts.
class DebtWarningBanner extends StatelessWidget {
  const DebtWarningBanner({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Action buttons: mark paid, edit, delete.
class DebtDetailActionButtons extends StatelessWidget {
  const DebtDetailActionButtons({
    super.key,
    required this.debt,
    required this.isSaving,
    required this.onMarkPaid,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePause,
    required this.onReactivate,
  });

  final Debt debt;
  final bool isSaving;
  final VoidCallback onMarkPaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePause;
  final VoidCallback onReactivate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Paid → show reactivate only
        if (debt.status == 'paid') ...[
          _ActionButton(
            onPressed: isSaving ? null : onReactivate,
            icon: Icons.replay,
            label: 'Reativar dívida',
            isSaving: isSaving,
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
          ),
          const SizedBox(height: 12),
        ],

        // Active → mark paid, pause, edit, delete
        if (debt.status == 'active') ...[
          _ActionButton(
            onPressed: isSaving ? null : onMarkPaid,
            icon: Icons.check_circle_outline,
            label: 'Marcar como pago',
            isSaving: isSaving,
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
          ),
          const SizedBox(height: 12),
          _ActionButton(
            onPressed: isSaving ? null : onTogglePause,
            icon: Icons.pause_circle_outline,
            label: 'Pausar dívida',
            isSaving: isSaving,
            outlined: true,
            outlineColor: AppColors.warning,
          ),
          const SizedBox(height: 12),
        ],

        // Paused → resume, edit, delete
        if (debt.status == 'paused') ...[
          _ActionButton(
            onPressed: isSaving ? null : onTogglePause,
            icon: Icons.play_circle_outline,
            label: 'Retomar dívida',
            isSaving: isSaving,
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
          ),
          const SizedBox(height: 12),
        ],

        // Edit & Delete always available (except paid)
        if (debt.status != 'paid') ...[
          _ActionButton(
            onPressed: onEdit,
            icon: Icons.edit_outlined,
            label: 'Editar',
            outlined: true,
            outlineColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
        ],
        _ActionButton(
          onPressed: isSaving ? null : onDelete,
          icon: Icons.delete_outline,
          label: 'Excluir',
          outlined: true,
          outlineColor: AppColors.danger,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isSaving = false,
    this.backgroundColor,
    this.foregroundColor,
    this.outlined = false,
    this.outlineColor,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isSaving;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool outlined;
  final Color? outlineColor;

  @override
  Widget build(BuildContext context) {
    final color = outlineColor ?? AppColors.primary;

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textPrimary,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

/// Save button shown during edit mode.
class DebtDetailSaveButton extends StatelessWidget {
  const DebtDetailSaveButton({
    super.key,
    required this.isSaving,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onSave,
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textPrimary,
                ),
              )
            : const Icon(Icons.save_outlined, size: 20),
        label: const Text(
          'Salvar alterações',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
