import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingStepGoal extends StatelessWidget {
  const OnboardingStepGoal({
    super.key,
    required this.onGoalSelected,
    this.initialValue,
  });

  final Function(String) onGoalSelected;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.04),

          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          SizedBox(height: screenHeight * 0.04),

          // Title
          Text(
            'Qual é seu objetivo?',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Escolha a opção que melhor descreve sua situação',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.06),

          // Options
          _GoalOption(
            title: 'Pagar dívidas',
            subtitle: 'Quero eliminar minhas dívidas o quanto antes',
            icon: Icons.flash_on_rounded,
            color: AppColors.danger,
            selected: initialValue == 'pay_debt',
            onTap: () => onGoalSelected('pay_debt'),
          ),
          const SizedBox(height: 12),
          _GoalOption(
            title: 'Reorganizar',
            subtitle: 'Preciso estruturar meu orçamento',
            icon: Icons.tune_rounded,
            color: AppColors.accent,
            selected: initialValue == 'organize',
            onTap: () => onGoalSelected('organize'),
          ),
          const SizedBox(height: 12),
          _GoalOption(
            title: 'Planejar futuro',
            subtitle: 'Quero evitar dívidas no futuro',
            icon: Icons.trending_up_rounded,
            color: AppColors.primary,
            selected: initialValue == 'plan_future',
            onTap: () => onGoalSelected('plan_future'),
          ),

          SizedBox(height: screenHeight * 0.1),
        ],
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  const _GoalOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.divider,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}
