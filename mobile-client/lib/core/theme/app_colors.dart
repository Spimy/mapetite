import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary
  static const Color primary = Color(0xFF065F46);
  static const Color primaryLight = Color(0xFFD1FAE5);
  static const Color primaryDark = Color(0xFF044035);

  // Secondary
  static const Color secondary = Color(0xFF0E7490);
  static const Color secondaryLight = Color(0xFFCFFAFE);
  static const Color secondaryDark = Color(0xFF0A5068);

  // Tertiary
  static const Color tertiary = Color(0xFFF0FDF4);
  static const Color tertiaryDark = Color(0xFFDCFCE7);

  // Neutral
  static const Color neutral = Color(0xFF1F2937);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral600 = Color(0xFF6B7280);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  // Surface
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);

  // Dietary tag colours
  static const Color tagHalal = Color(0xFF065F46);
  static const Color tagVegan = Color(0xFF0E7490);
  static const Color tagVegetarian = Color(0xFF10B981);
  static const Color tagAllergen = Color(0xFFF59E0B);

  // Dark mode surfaces
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkText = Color(0xFFF9FAFB);
}
