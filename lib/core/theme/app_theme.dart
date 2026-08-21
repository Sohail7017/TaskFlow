import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// Centralized theme entry point for the TaskFlow application
abstract final class AppTheme {
  /// Light theme definition
  static ThemeData get light => lightTheme;

  /// Dark theme definition
  static ThemeData get dark => darkTheme;
}
