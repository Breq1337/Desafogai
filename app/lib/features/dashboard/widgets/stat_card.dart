import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';


class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color = AppColors.primary,
    this.numericValue,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final Color color;
  final double? numericValue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.18),
                AppColors.surfaceContainer.withValues(alpha: 0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 1.0],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 32,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle!,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
