import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_button_types.dart';
import 'package:flutter/material.dart';

class PrimaryButtonStyle {
  const PrimaryButtonStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.verticalPadding,
    required this.borderRadius,
    required this.iconSize,
    required this.loaderSize,
    required this.fontSize,
  });

  final Color backgroundColor;
  final Color textColor;
  final double verticalPadding;
  final double borderRadius;
  final double iconSize;
  final double loaderSize;
  final double fontSize;
}

PrimaryButtonStyle resolvePrimaryButtonStyle({
  required PrimaryButtonVariant variant,
  required PrimaryButtonSize size,
}) {
  final variantStyle = switch (variant) {
    PrimaryButtonVariant.primary => const _PrimaryButtonVariantStyle(
      backgroundColor: AppColors.blue500,
      textColor: Colors.white,
    ),
    PrimaryButtonVariant.danger => const _PrimaryButtonVariantStyle(
      backgroundColor: Colors.red,
      textColor: Colors.white,
    ),
  };

  final sizeStyle = switch (size) {
    PrimaryButtonSize.small => const _PrimaryButtonSizeStyle(
      verticalPadding: 12,
      borderRadius: 12,
      iconSize: 16,
      loaderSize: 18,
      fontSize: 14,
    ),
    PrimaryButtonSize.medium => const _PrimaryButtonSizeStyle(
      verticalPadding: 14,
      borderRadius: 14,
      iconSize: 18,
      loaderSize: 20,
      fontSize: 15,
    ),
    PrimaryButtonSize.large => const _PrimaryButtonSizeStyle(
      verticalPadding: 18,
      borderRadius: 16,
      iconSize: 20,
      loaderSize: 22,
      fontSize: 16,
    ),
  };

  return PrimaryButtonStyle(
    backgroundColor: variantStyle.backgroundColor,
    textColor: variantStyle.textColor,
    verticalPadding: sizeStyle.verticalPadding,
    borderRadius: sizeStyle.borderRadius,
    iconSize: sizeStyle.iconSize,
    loaderSize: sizeStyle.loaderSize,
    fontSize: sizeStyle.fontSize,
  );
}

class _PrimaryButtonVariantStyle {
  const _PrimaryButtonVariantStyle({
    required this.backgroundColor,
    required this.textColor,
  });

  final Color backgroundColor;
  final Color textColor;
}

class _PrimaryButtonSizeStyle {
  const _PrimaryButtonSizeStyle({
    required this.verticalPadding,
    required this.borderRadius,
    required this.iconSize,
    required this.loaderSize,
    required this.fontSize,
  });

  final double verticalPadding;
  final double borderRadius;
  final double iconSize;
  final double loaderSize;
  final double fontSize;
}
