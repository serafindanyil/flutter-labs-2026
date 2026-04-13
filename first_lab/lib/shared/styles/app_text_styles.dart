import 'package:first_lab/shared/styles/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const TextStyle header1 = TextStyle(
    fontSize: AppTypography.header1,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle header2 = TextStyle(
    fontSize: AppTypography.header2,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle header3 = TextStyle(
    fontSize: AppTypography.header3,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle text1 = TextStyle(
    fontSize: AppTypography.text1,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle text2 = TextStyle(
    fontSize: AppTypography.text2,
    height: 1.45,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle text3 = TextStyle(
    fontSize: AppTypography.text3,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle text4 = TextStyle(
    fontSize: AppTypography.text4,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );
}
