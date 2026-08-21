import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Dark theme configuration for TaskFlow
ThemeData get darkTheme {
  final baseTextTheme = GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.backgroundDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.primaryContainerLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.backgroundDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.secondaryContainerLight,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.borderSubtleDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.cardDark,
    dividerColor: AppColors.borderDark,
    textTheme: baseTextTheme.copyWith(
      displayLarge: AppTextStyles.displayLarge(color: AppColors.textPrimaryDark),
      displayMedium: AppTextStyles.displayMedium(color: AppColors.textPrimaryDark),
      headlineLarge: AppTextStyles.headlineLarge(color: AppColors.textPrimaryDark),
      headlineMedium: AppTextStyles.headlineMedium(color: AppColors.textPrimaryDark),
      titleLarge: AppTextStyles.titleLarge(color: AppColors.textPrimaryDark),
      titleMedium: AppTextStyles.titleMedium(color: AppColors.textPrimaryDark),
      titleSmall: AppTextStyles.titleSmall(color: AppColors.textSecondaryDark),
      bodyLarge: AppTextStyles.bodyLarge(color: AppColors.textPrimaryDark),
      bodyMedium: AppTextStyles.bodyMedium(color: AppColors.textPrimaryDark),
      bodySmall: AppTextStyles.bodySmall(color: AppColors.textSecondaryDark),
      labelLarge: AppTextStyles.labelLarge(color: AppColors.textPrimaryDark),
      labelMedium: AppTextStyles.labelMedium(color: AppColors.textSecondaryDark),
      labelSmall: AppTextStyles.labelSmall(color: AppColors.textDisabledDark),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.titleLarge(color: AppColors.textPrimaryDark),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.backgroundDark,
        textStyle: AppTextStyles.button(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.primaryLight),
        textStyle: AppTextStyles.button(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        textStyle: AppTextStyles.button(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      hintStyle: AppTextStyles.bodyMedium(color: AppColors.textDisabledDark),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
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
      backgroundColor: AppColors.surfaceDark,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      indicatorColor: AppColors.primaryContainerDark,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.labelMedium(color: AppColors.primaryLight);
        }
        return AppTextStyles.labelMedium(color: AppColors.textSecondaryDark);
      }),
    ),
  );
}
