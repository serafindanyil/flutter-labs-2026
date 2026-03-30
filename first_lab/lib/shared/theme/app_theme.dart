import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/styles/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.blue500,
    onPrimary: AppColors.white,
    secondary: AppColors.blue400,
    onSecondary: AppColors.white,
    error: AppColors.red,
    onError: AppColors.white,
    surface: AppColors.surface,
    onSurface: AppColors.primaryText,
  );

  static ThemeData light() {
    const baseTextTheme = TextTheme(
      displayLarge: AppTextStyles.header1,
      displayMedium: AppTextStyles.header2,
      headlineSmall: AppTextStyles.header3,
      titleMedium: AppTextStyles.text1,
      bodyLarge: AppTextStyles.text1,
      bodyMedium: AppTextStyles.text2,
      bodySmall: AppTextStyles.text3,
      labelSmall: AppTextStyles.text4,
    );
    final comfortaaTextTheme = GoogleFonts.comfortaaTextTheme(baseTextTheme)
        .apply(
          bodyColor: AppColors.primaryText,
          displayColor: AppColors.primaryText,
        );
    final comfortaaFontFamily = GoogleFonts.comfortaa().fontFamily;

    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      fontFamily: comfortaaFontFamily,
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: comfortaaTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceAccent,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        titleTextStyle: comfortaaTextTheme.headlineSmall,
        toolbarTextStyle: comfortaaTextTheme.bodyMedium,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.blue500,
        foregroundColor: AppColors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.blue500,
        linearTrackColor: AppColors.gray100,
      ),
    );
  }
}
