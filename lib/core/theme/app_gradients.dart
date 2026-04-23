import 'dart:ui';
import 'package:flutter/material.dart';

class AppGradients {
  AppGradients._();

  // Feature gradients
  static const LinearGradient period = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient medicine = LinearGradient(
    colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient water = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mood = LinearGradient(
    colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bmi = LinearGradient(
    colors: [Color(0xFF26A69A), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streak = LinearGradient(
    colors: [Color(0xFFFF7043), Color(0xFFE64A19)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient analytics = LinearGradient(
    colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunset = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFC850C0), Color(0xFF4158D0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient health = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glassmorphism decoration
  static BoxDecoration glassMorphism({
    double borderRadius = 20,
    double opacity = 0.15,
    bool isDark = false,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: opacity),
      border: Border.all(
        color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.25),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Gradient card decoration
  static BoxDecoration gradientCard({
    required LinearGradient gradient,
    double borderRadius = 20,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: boxShadow ??
          [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
    );
  }
}
