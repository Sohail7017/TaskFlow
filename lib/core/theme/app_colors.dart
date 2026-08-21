import 'package:flutter/material.dart';

/// Centralized color palette for the TaskFlow application
abstract final class AppColors {
  // Primary - Deep Indigo
  static const Color primary = Color(0xFF3730A3); // Deep Indigo
  static const Color primaryLight = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF1E1B4B); // Indigo 950
  static const Color primaryContainerLight = Color(0xFFE0E7FF);
  static const Color primaryContainerDark = Color(0xFF312E81);

  // Secondary / Accent - Mint & Teal
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryDark = Color(0xFF115E59); // Teal 800
  static const Color mintAccent = Color(0xFF2DD4BF); // Mint / Teal 400
  static const Color secondaryContainerLight = Color(0xFFCCFBF1);
  static const Color secondaryContainerDark = Color(0xFF134E4A);

  // Semantic Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Priority Colors
  static const Color priorityLow = Color(0xFF16A34A);
  static const Color priorityMedium = Color(0xFFD97706);
  static const Color priorityHigh = Color(0xFFEA580C);
  static const Color priorityUrgent = Color(0xFFDC2626);

  // Light Theme Neutrals
  static const Color backgroundLight = Color(0xFFF8FAFC); // Soft cool-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color elevatedSurfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtleLight = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF0F172A); // Dark navy/charcoal
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textDisabledLight = Color(0xFF94A3B8);

  // Dark Theme Neutrals
  static const Color backgroundDark = Color(0xFF0F172A); // Deep charcoal/navy
  static const Color surfaceDark = Color(0xFF1E293B); // Slightly lighter card/surface
  static const Color elevatedSurfaceDark = Color(0xFF334155);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color borderSubtleDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Off-white
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Muted
  static const Color textDisabledDark = Color(0xFF64748B);
}
