import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fundo cinematográfico: radial cyan suave + vinheta (Stitch).
class StitchBackground extends StatelessWidget {
  const StitchBackground({
    super.key,
    required this.child,
    this.showGrain = true,
  });

  final Widget child;
  final bool showGrain;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _CinematicBase(),
        if (showGrain) const _NoiseOverlay(),
        child,
      ],
    );
  }
}

class _CinematicBase extends StatelessWidget {
  const _CinematicBase();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        gradient: RadialGradient(
          center: const Alignment(0, -0.25),
          radius: 1.2,
          colors: [
            AppColors.primaryContainer.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.65],
        ),
      ),
    );
  }
}

class _NoiseOverlay extends StatelessWidget {
  const _NoiseOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GrainPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1;
    const step = 4.0;
    for (var x = 0.0; x < size.width; x += step) {
      for (var y = 0.0; y < size.height; y += step) {
        if ((x + y).toInt() % 7 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Barra superior estilo Stitch (blur + logo).
class StitchTopBar extends StatelessWidget {
  const StitchTopBar({
    super.key,
    this.title = 'COMANDO ESTRATÉGICO',
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.12),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: AppColors.primaryContainer,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryContainer,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
