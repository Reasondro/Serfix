import 'package:flutter/widgets.dart';

class AppColors {
  AppColors._();

  // Primary - Teal/Medical theme
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);

  // Secondary - Deep purple for accents
  static const Color secondary = Color(0xFF5E35B1);
  static const Color secondaryLight = Color(0xFF9575CD);

  // Neutral - Light Mode
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color gray = Color(0xFF9CA3AF);
  static const Color lightGray = Color(0xFFE5E7EB);

  // Neutral - Dark Mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceDarkElevated = Color(0xFF2C2C2C);
  static const Color textPrimaryDark = Color(0xFFE1E1E1);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color grayDark = Color(0xFF6B7280);
  static const Color lightGrayDark = Color(0xFF374151);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Legacy (for compatibility)
  static const Color white = Color(0xFFFAFAFA);
}
