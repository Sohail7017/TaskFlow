import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Light theme configuration for TaskFlow
ThemeData get lightTheme {
  final baseTextTheme = GoogleFonts.montserratTextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainerLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainerLight,
      onSecondaryContainer: AppColors.secondaryDark,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.error,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.borderSubtleLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.cardLight,
    dividerColor: AppColors.borderLight,
    textTheme: baseTextTheme.copyWith(
      displayLarge: AppTextStyles.displayLarge(color: AppColors.textPrimaryLight),
      displayMedium: AppTextStyles.displayMedium(color: AppColors.textPrimaryLight),
      headlineLarge: AppTextStyles.headlineLarge(color: AppColors.textPrimaryLight),
      headlineMedium: AppTextStyles.headlineMedium(color: AppColors.textPrimaryLight),
      titleLarge: AppTextStyles.titleLarge(color: AppColors.textPrimaryLight),
      titleMedium: AppTextStyles.titleMedium(color: AppColors.textPrimaryLight),
      titleSmall: AppTextStyles.titleSmall(color: AppColors.textSecondaryLight),
      bodyLarge: AppTextStyles.bodyLarge(color: AppColors.textPrimaryLight),
      bodyMedium: AppTextStyles.bodyMedium(color: AppColors.textPrimaryLight),
      bodySmall: AppTextStyles.bodySmall(color: AppColors.textSecondaryLight),
      labelLarge: AppTextStyles.labelLarge(color: AppColors.textPrimaryLight),
      labelMedium: AppTextStyles.labelMedium(color: AppColors.textSecondaryLight),
      labelSmall: AppTextStyles.labelSmall(color: AppColors.textDisabledLight),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.titleLarge(color: AppColors.textPrimaryLight),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        textStyle: AppTextStyles.button(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.button(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      hintStyle: AppTextStyles.bodyMedium(color: AppColors.textDisabledLight),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      indicatorColor: AppColors.primaryContainerLight,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.labelMedium(color: AppColors.primary);
        }
        return AppTextStyles.labelMedium(color: AppColors.textSecondaryLight);
      }),
    ),
  );
}
