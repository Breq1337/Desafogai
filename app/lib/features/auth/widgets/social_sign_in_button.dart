import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.divider, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: iconColor ?? AppColors.textPrimary),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
