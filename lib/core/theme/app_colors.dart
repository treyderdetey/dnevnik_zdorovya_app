import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette – soft pink/purple
  static const Color primary = Color(0xFFE91E8C);
  static const Color primaryLight = Color(0xFFF8BBD0);
  static const Color primaryDark = Color(0xFFC2185B);

  // Secondary – soft purple
  static const Color secondary = Color(0xFF9C27B0);
  static const Color secondaryLight = Color(0xFFE1BEE7);

  // Accent colors
  static const Color accent = Color(0xFFFF6B9D);

  // Background
  static const Color backgroundLight = Color(0xFFFFF5F8);
  static const Color backgroundDark = Color(0xFF1A1A2E);

  // Surface
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF252547);

  // Card colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D2D50);

  // Text
  static const Color textPrimaryLight = Color(0xFF2D2D2D);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Feature colors
  static const Color periodColor = Color(0xFFE91E63);
  static const Color medicineColor = Color(0xFF9C27B0);
  static const Color waterColor = Color(0xFF2196F3);
  static const Color healthColor = Color(0xFF4CAF50);
  static const Color moodColor = Color(0xFFFFB74D);
  static const Color bmiColor = Color(0xFF26A69A);
  static const Color streakColor = Color(0xFFFF7043);
  static const Color analyticsColor = Color(0xFF5C6BC0);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFCE4EC), Color(0xFFF3E5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
