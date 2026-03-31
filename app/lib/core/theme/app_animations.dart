import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Durations padronizadas
abstract final class Durations {
  static const fast = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 400);
  static const slow = Duration(milliseconds: 600);
  static const stagger = Duration(milliseconds: 80);
}

/// Curves customizadas para o app
abstract final class AppCurves {
  static const emphasized = Curves.easeOutCubic;
  static const spring = Curves.elasticOut;
  static const smooth = Cubic(0.4, 0.0, 0.2, 1.0);
}

/// Widget que faz fade+slide ao aparecer (staggered)
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.offsetY = 24,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.offsetY),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    final totalDelay = widget.delay +
        Duration(milliseconds: widget.index * Durations.stagger.inMilliseconds);

    Future.delayed(totalDelay, () {
      if (mounted) _controller.forward();
    });
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
      builder: (context, child) => Transform.translate(
        offset: _slideAnimation.value,
        child: Opacity(
          opacity: _fadeAnimation.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Widget que escala ao pressionar (press feedback)
class ScaleOnPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const ScaleOnPress({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
  });

  @override
  State<ScaleOnPress> createState() => _ScaleOnPressState();
}

class _ScaleOnPressState extends State<ScaleOnPress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: const [
                Color(0xFF1A1A1F),
                Color(0xFF2A2A35),
                Color(0xFF1A1A1F),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }
}

/// Animated counter that counts up to the target value
class AnimatedCounter extends StatefulWidget {
  final double targetValue;
  final String prefix;
  final String suffix;
  final int decimals;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.targetValue,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.targetValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.targetValue,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_animation.value.toStringAsFixed(widget.decimals)}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

/// Pulse animation for urgent indicators
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.enabled = true,
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Glow box decoration para containers urgentes
class GlowDecoration extends BoxDecoration {
  GlowDecoration({
    required Color glowColor,
    double intensity = 0.3,
    double blurRadius = 20,
    double borderRadiusValue = 16,
    Color? backgroundColor,
  }) : super(
          color: backgroundColor ?? const Color(0xFF1A1A1F),
          borderRadius: BorderRadius.circular(borderRadiusValue),
          border: Border.all(
            color: glowColor.withValues(alpha: intensity),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: intensity * 0.5),
              blurRadius: blurRadius,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: glowColor.withValues(alpha: intensity * 0.2),
              blurRadius: blurRadius * 2,
              spreadRadius: -4,
            ),
          ],
        );
}

/// Animated gradient background
class AnimatedMeshGradient extends StatefulWidget {
  final Widget child;

  const AnimatedMeshGradient({super.key, required this.child});

  @override
  State<AnimatedMeshGradient> createState() => _AnimatedMeshGradientState();
}

class _AnimatedMeshGradientState extends State<AnimatedMeshGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
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
        final t = _controller.value;
        return Stack(
          children: [
            // Background base
            Container(color: AppColors.background),
            Positioned(
              top: -80 + math.sin(t * 2 * math.pi) * 30,
              right: -40 + math.cos(t * 2 * math.pi) * 20,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryContainer.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60 + math.cos(t * 2 * math.pi + 1) * 25,
              left: -30 + math.sin(t * 2 * math.pi + 1) * 15,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryFixedDim.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
