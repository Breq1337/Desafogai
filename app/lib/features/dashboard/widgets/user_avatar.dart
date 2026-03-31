import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class UserAvatar extends StatefulWidget {
  const UserAvatar({super.key, required this.name});

  final String name;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String get initials {
    final parts = widget.name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.name.substring(0, 1).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: SweepGradient(
              startAngle: _controller.value * 6.28,
              colors: const [
                AppColors.primaryContainer,
                AppColors.primaryFixedDim,
                AppColors.primary,
                AppColors.primaryContainer,
              ],
              stops: const [0.0, 0.33, 0.66, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.25),
                blurRadius: 10,
                spreadRadius: -2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: child,
        );
      },
        child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
