import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography definitions using Montserrat
abstract final class AppTextStyles {
  // Display / Large Headings
  static TextStyle displayLarge({Color? color}) => GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700, // Bold
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w700, // Bold
        letterSpacing: -0.25,
        color: color,
      );

  // Headlines
  static TextStyle headlineLarge({Color? color}) => GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w600, // SemiBold
        letterSpacing: -0.15,
        color: color,
      );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600, // SemiBold
        color: color,
      );

  // Titles
  static TextStyle titleLarge({Color? color}) => GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600, // SemiBold
        color: color,
      );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        color: color,
      );

  static TextStyle titleSmall({Color? color}) => GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500, // Medium
        color: color,
      );

  // Body
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0.15,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0.25,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0.4,
        color: color,
      );

  // Labels & Button Text
  static TextStyle labelLarge({Color? color}) => GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600, // SemiBold (Buttons/Action Labels)
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500, // Medium
        letterSpacing: 0.5,
        color: color,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.montserrat(
        fontSize: 10,
        fontWeight: FontWeight.w500, // Medium
        letterSpacing: 0.5,
        color: color,
      );

  // Captions
  static TextStyle caption({Color? color}) => GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Regular
        letterSpacing: 0.4,
        color: color,
      );

  static TextStyle button({Color? color}) => GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600, // SemiBold
        letterSpacing: 0.2,
        color: color,
      );
}
