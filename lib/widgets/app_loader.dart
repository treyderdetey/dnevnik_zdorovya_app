import 'dart:math';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Premium animated loader with pulsing hearts and orbiting dots
class AppLoader extends StatefulWidget {
  final String? message;
  final double size;
  final bool showMessage;

  const AppLoader({
    super.key,
    this.message,
    this.size = 80,
    this.showMessage = true,
  });

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseController, _orbitController]),
              builder: (context, child) {
                return CustomPaint(
                  painter: _LoaderPainter(
                    pulseValue: _pulseAnimation.value,
                    orbitValue: _orbitController.value,
                    primaryColor: AppColors.primary,
                    secondaryColor: AppColors.secondary,
                    accentColor: AppColors.accent,
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: _pulseAnimation.value,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ).createShader(bounds),
                        child: Icon(
                          Icons.favorite,
                          size: widget.size * 0.35,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.showMessage) ...[
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                widget.message ?? 'Загрузка...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final double pulseValue;
  final double orbitValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  _LoaderPainter({
    required this.pulseValue,
    required this.orbitValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer glow ring
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.15 * pulseValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius * pulseValue, glowPaint);

    // Dashed orbit circle
    final orbitPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.85, orbitPaint);

    // Orbiting dots (3 dots at different angles)
    final dotColors = [primaryColor, secondaryColor, accentColor];
    for (int i = 0; i < 3; i++) {
      final angle = (orbitValue * 2 * pi) + (i * 2 * pi / 3);
      final dotRadius = 4.0 - (i * 0.5);
      final orbitRadius = radius * 0.85;

      final x = center.dx + orbitRadius * cos(angle);
      final y = center.dy + orbitRadius * sin(angle);

      // Dot shadow
      final shadowPaint = Paint()
        ..color = dotColors[i].withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), dotRadius + 2, shadowPaint);

      // Dot
      final dotPaint = Paint()..color = dotColors[i];
      canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);

      // Trail
      for (int t = 1; t <= 4; t++) {
        final trailAngle = angle - (t * 0.15);
        final tx = center.dx + orbitRadius * cos(trailAngle);
        final ty = center.dy + orbitRadius * sin(trailAngle);
        final trailPaint = Paint()
          ..color = dotColors[i].withValues(alpha: 0.15 - (t * 0.03));
        canvas.drawCircle(Offset(tx, ty), dotRadius - (t * 0.8), trailPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) => true;
}

/// Full-screen loader overlay
class FullScreenLoader extends StatelessWidget {
  final String? message;

  const FullScreenLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark.withValues(alpha: 0.9)
          : AppColors.backgroundLight.withValues(alpha: 0.9),
      body: AppLoader(message: message),
    );
  }
}

/// Inline loader for cards/sections
class InlineLoader extends StatelessWidget {
  final double size;

  const InlineLoader({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return AppLoader(size: size, showMessage: false);
  }
}

/// Animated page transition wrapper with loader
class LoaderPageWrapper extends StatefulWidget {
  final Widget child;
  final Duration loadDelay;
  final String? loadingMessage;

  const LoaderPageWrapper({
    super.key,
    required this.child,
    this.loadDelay = const Duration(milliseconds: 600),
    this.loadingMessage,
  });

  @override
  State<LoaderPageWrapper> createState() => _LoaderPageWrapperState();
}

class _LoaderPageWrapperState extends State<LoaderPageWrapper>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _transitionController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(widget.loadDelay, () {
      if (mounted) {
        setState(() => _isLoading = false);
        _transitionController.forward();
      }
    });
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return FullScreenLoader(message: widget.loadingMessage);
    }

    return FadeTransition(
      opacity: _fadeIn,
      child: widget.child,
    );
  }
}

/// Mini bouncing dots loader for buttons/inline
class BouncingDotsLoader extends StatefulWidget {
  final Color? color;
  final double dotSize;

  const BouncingDotsLoader({super.key, this.color, this.dotSize = 8});

  @override
  State<BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true);
    });

    // Stagger the animations
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].forward();
      });
    }

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.translate(
                offset: Offset(0, _animations[i].value),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: Offset(0, -_animations[i].value * 0.3),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Skeleton shimmer loader for list items
class SkeletonLoader extends StatefulWidget {
  final int itemCount;

  const SkeletonLoader({super.key, this.itemCount = 4});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return Column(
          children: List.generate(widget.itemCount, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + 2.0 * _shimmerController.value, 0),
                  end: Alignment(1.0 + 2.0 * _shimmerController.value, 0),
                  colors: isDark
                      ? [
                          AppColors.cardDark,
                          AppColors.cardDark.withValues(alpha: 0.6),
                          AppColors.cardDark,
                        ]
                      : [
                          Colors.grey.shade200,
                          Colors.grey.shade100,
                          Colors.grey.shade200,
                        ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
