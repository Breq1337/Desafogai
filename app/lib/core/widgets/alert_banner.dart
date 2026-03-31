import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum AlertSeverity { info, warning, danger, success }

class AlertBanner extends StatelessWidget {
  const AlertBanner({
    super.key,
    required this.message,
    this.severity = AlertSeverity.info,
    this.icon,
    this.onTap,
  });

  final String message;
  final AlertSeverity severity;
  final IconData? icon;
  final VoidCallback? onTap;

  Color get _color => switch (severity) {
        AlertSeverity.info => AppColors.primaryContainer,
        AlertSeverity.warning => AppColors.warning,
        AlertSeverity.danger => AppColors.danger,
        AlertSeverity.success => AppColors.success,
      };

  IconData get _icon => icon ?? switch (severity) {
        AlertSeverity.info => Icons.info_outline_rounded,
        AlertSeverity.warning => Icons.warning_amber_rounded,
        AlertSeverity.danger => Icons.error_outline_rounded,
        AlertSeverity.success => Icons.check_circle_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final banner = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: _color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _color,
                    height: 1.4,
                  ),
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: _color, size: 18),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: banner,
      );
    }
    return banner;
  }
}
