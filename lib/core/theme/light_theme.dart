import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_dimensions.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Complete Light Theme configuration for TaskFlow
ThemeData get lightTheme {
  final baseTextTheme = GoogleFonts.montserratTextTheme(ThemeData.light().textTheme);

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
      onSurfaceVariant: AppColors.textSecondaryLight,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.errorDark,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.borderSubtleLight,
      shadow: Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.cardLight,
    dividerColor: AppColors.borderLight,
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 1,
    ),
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
      labelSmall: AppTextStyles.labelSmall(color: AppColors.textTertiaryLight),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.iconLight,
      size: AppDimensions.iconMD,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.titleLarge(color: AppColors.textPrimaryLight),
      iconTheme: const IconThemeData(color: AppColors.iconLight),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLG,
        side: const BorderSide(color: AppColors.borderLight),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.disabledLight,
        disabledForegroundColor: AppColors.textDisabledLight,
        textStyle: AppTextStyles.button(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMD,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        disabledForegroundColor: AppColors.textDisabledLight,
        textStyle: AppTextStyles.button(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMD,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.button(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackgroundLight,
      hintStyle: AppTextStyles.bodyMedium(color: AppColors.textTertiaryLight),
      labelStyle: AppTextStyles.labelMedium(color: AppColors.textSecondaryLight),
      prefixIconColor: AppColors.textSecondaryLight,
      suffixIconColor: AppColors.textSecondaryLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusMD,
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusMD,
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusMD,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusMD,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusMD,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusXL),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
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
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimaryLight,
      contentTextStyle: AppTextStyles.bodyMedium(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMD),
      behavior: SnackBarBehavior.floating,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLG),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundLight,
      side: const BorderSide(color: AppColors.borderLight),
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusSM),
      labelStyle: AppTextStyles.labelSmall(color: AppColors.textPrimaryLight),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.primaryContainerLight,
    ),
  );
}
