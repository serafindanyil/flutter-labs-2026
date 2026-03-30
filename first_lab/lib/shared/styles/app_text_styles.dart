import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const TextStyle tertiaryHeader = TextStyle(
    fontSize: 20,
    color: AppColors.primaryText,
  );

  static const TextStyle counterLabel = TextStyle(
    fontSize: 16,
    color: AppColors.primaryText,
  );

  static const TextStyle counterValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
}
