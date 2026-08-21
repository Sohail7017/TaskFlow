import 'package:flutter/material.dart';

/// Centralized color palette and semantic tokens for the TaskFlow application
abstract final class AppColors {
  // ==========================================
  // Brand Colors - Deep Indigo Primary
  // ==========================================
  static const Color primary = Color(0xFF3730A3); // Deep Indigo
  static const Color primaryLight = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF1E1B4B); // Indigo 950
  static const Color primaryContainerLight = Color(0xFFE0E7FF);
  static const Color primaryContainerDark = Color(0xFF312E81);

  // ==========================================
  // Brand Colors - Mint & Teal Accent
  // ==========================================
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryDark = Color(0xFF115E59); // Teal 800
  static const Color mintAccent = Color(0xFF2DD4BF); // Mint / Teal 400
  static const Color secondaryContainerLight = Color(0xFFCCFBF1);
  static const Color secondaryContainerDark = Color(0xFF134E4A);

  // ==========================================
  // Semantic Feedback Colors
  // ==========================================
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF14532D);

  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF78350F);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF7F1D1D);

  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color infoDark = Color(0xFF0C4A6E);

  // ==========================================
  // Task Status Colors & Tints
  // ==========================================
  static const Color statusTodo = Color(0xFF64748B); // Slate
  static const Color statusTodoBgLight = Color(0xFFF1F5F9);
  static const Color statusTodoBgDark = Color(0xFF1E293B);

  static const Color statusInProgress = Color(0xFF2563EB); // Royal Blue
  static const Color statusInProgressBgLight = Color(0xFFEFF6FF);
  static const Color statusInProgressBgDark = Color(0xFF1E3A8A);

  static const Color statusReview = Color(0xFFD97706); // Amber
  static const Color statusReviewBgLight = Color(0xFFFFFBEB);
  static const Color statusReviewBgDark = Color(0xFF78350F);

  static const Color statusDone = Color(0xFF16A34A); // Emerald
  static const Color statusDoneBgLight = Color(0xFFF0FDF4);
  static const Color statusDoneBgDark = Color(0xFF14532D);

  // ==========================================
  // Task Priority Colors & Tints
  // ==========================================
  static const Color priorityLow = Color(0xFF16A34A);
  static const Color priorityLowDark = Color(0xFF4ADE80);
  static const Color priorityLowBgLight = Color(0xFFF0FDF4);
  static const Color priorityLowBgDark = Color(0xFF14532D);

  static const Color priorityMedium = Color(0xFFD97706);
  static const Color priorityMediumDark = Color(0xFFFBBF24);
  static const Color priorityMediumBgLight = Color(0xFFFFFBEB);
  static const Color priorityMediumBgDark = Color(0xFF78350F);

  static const Color priorityHigh = Color(0xFFEA580C);
  static const Color priorityHighDark = Color(0xFFFB923C);
  static const Color priorityHighBgLight = Color(0xFFFFEDD5);
  static const Color priorityHighBgDark = Color(0xFF7C2D12);

  static const Color priorityUrgent = Color(0xFFDC2626);
  static const Color priorityUrgentDark = Color(0xFFF87171);
  static const Color priorityUrgentBgLight = Color(0xFFFEF2F2);
  static const Color priorityUrgentBgDark = Color(0xFF7F1D1D);

  // ==========================================
  // Light Theme Neutrals
  // ==========================================
  static const Color backgroundLight = Color(0xFFF8FAFC); // Subtle cool off-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color elevatedSurfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inputBackgroundLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtleLight = Color(0xFFF1F5F9);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A); // Dark navy/charcoal
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);
  static const Color iconLight = Color(0xFF475569);
  static const Color disabledLight = Color(0xFFE2E8F0);
  static const Color overlayLight = Color(0x660F172A);

  // ==========================================
  // Dark Theme Neutrals
  // ==========================================
  static const Color backgroundDark = Color(0xFF0F172A); // Deep charcoal/navy
  static const Color surfaceDark = Color(0xFF1E293B); // Slightly lighter card/surface
  static const Color elevatedSurfaceDark = Color(0xFF334155);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color inputBackgroundDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color borderSubtleDark = Color(0xFF1E293B);
  static const Color dividerDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Off-white
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Muted
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color textDisabledDark = Color(0xFF475569);
  static const Color iconDark = Color(0xFF94A3B8);
  static const Color disabledDark = Color(0xFF334155);
  static const Color overlayDark = Color(0x99000000);
}
