import 'package:flutter/material.dart';

/// Centralized layout, spacing, and border radius tokens
abstract final class AppDimensions {
  // Spacing System (in dp/pixels)
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Corner Radius Tokens
  static const double radiusXS = 4.0;
  static const double radiusSM = 6.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radius2XL = 24.0;
  static const double radiusFull = 999.0;

  // BorderRadius Helpers
  static final BorderRadius borderRadiusXS = BorderRadius.circular(radiusXS);
  static final BorderRadius borderRadiusSM = BorderRadius.circular(radiusSM);
  static final BorderRadius borderRadiusMD = BorderRadius.circular(radiusMD);
  static final BorderRadius borderRadiusLG = BorderRadius.circular(radiusLG);
  static final BorderRadius borderRadiusXL = BorderRadius.circular(radiusXL);
  static final BorderRadius borderRadius2XL = BorderRadius.circular(radius2XL);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // Common Icon Sizes
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;

  // Minimum Touch Target
  static const double minTouchTarget = 44.0;
}

/// Centralized animation durations and curves
abstract final class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);

  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve decelerateCurve = Curves.easeOutCubic;
  static const Curve springCurve = Curves.fastOutSlowIn;
}
