import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Purple

  // Background Colors - Light
  static const Color bgPrimary = Color(0xFFFAFAFA); // Very light gray
  static const Color bgSecondary = Color(0xFFFFFFFF); // White
  static const Color bgTertiary = Color(0xFFE5E7EB); // Light gray

  // Text Colors - Light
  static const Color textPrimary = Color(0xFF111827); // Dark gray
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray

  // Dark Theme Colors
  static const Color primaryDark = Color(
    0xFF818CF8,
  ); // Lighter indigo for dark theme
  static const Color secondaryDark = Color(
    0xFFA78BFA,
  ); // Lighter purple for dark theme

  // Background Colors - Dark
  static const Color bgPrimaryDark = Color(0xFF111827); // Dark gray
  static const Color bgSecondaryDark = Color(
    0xFF1F2937,
  ); // Slightly lighter dark gray
  static const Color bgTertiaryDark = Color(0xFF374151); // Medium dark gray

  // Text Colors - Dark
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Very light gray
  static const Color textSecondaryDark = Color(0xFFD1D5DB); // Light gray

  // Status Colors (used in both themes)
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Additional Utility Colors
  static const Color transparent = Colors.transparent;
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
}
