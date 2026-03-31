import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingStepWelcome extends StatelessWidget {
  const OnboardingStepWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: screenHeight * 0.04),
          Text(
            'Fase um: libertação',
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.primaryContainer.withValues(alpha: 0.85),
              fontSize: 11,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
              children: [
                const TextSpan(text: 'QUEBRE O '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: AppColors.ctaGradient,
                    ).createShader(bounds),
                    child: Text(
                      'CICLO.',
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Dívida não é apenas um número; é gravidade. '
            'Implante inteligência tática para retomar seu futuro.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w300,
              height: 1.55,
            ),
          ),
          SizedBox(height: screenHeight * 0.06),
          _FeatureItem(
            icon: Icons.hub_rounded,
            title: 'Análise tática',
            subtitle: 'Mapa completo da sua situação',
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.route_rounded,
            title: 'Plano de quitação',
            subtitle: 'Priorização por urgência e juros',
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.smart_toy_rounded,
            title: 'Assistente estrategista',
            subtitle: 'IA alinhada ao seu orçamento',
          ),
          SizedBox(height: screenHeight * 0.08),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryContainer, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
