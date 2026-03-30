import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.brandSeed);

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: const TextTheme(
        bodyMedium: AppTextStyles.counterLabel,
        headlineMedium: AppTextStyles.counterValue,
      ),
      useMaterial3: true,
    );
  }
}
