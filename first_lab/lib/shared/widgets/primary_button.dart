import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/pressable_button.dart';
import 'package:flutter/material.dart';

enum PrimaryButtonVariant { primary, danger }

enum PrimaryButtonSize { small, medium, large }

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final PrimaryButtonVariant variant;
  final PrimaryButtonSize size;

  const PrimaryButton({
    required this.title,
    required this.onTap,
    super.key,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.variant = PrimaryButtonVariant.primary,
    this.size = PrimaryButtonSize.large,
  });

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle();
    final effectivelyDisabled = isDisabled || isLoading;

    return PressableButton(
      onTap: effectivelyDisabled ? () {} : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: effectivelyDisabled ? 0.6 : 1.0,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: style.verticalPadding),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(style.borderRadius),
            boxShadow: [
              BoxShadow(
                color: style.backgroundColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: style.loaderSize,
                    width: style.loaderSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        style.textColor,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: style.textColor,
                          size: style.iconSize,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        title,
                        style: TextStyle(
                          color: style.textColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          fontSize: style.fontSize,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  _PrimaryButtonStyle _resolveStyle() {
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

    return _PrimaryButtonStyle(
      backgroundColor: variantStyle.backgroundColor,
      textColor: variantStyle.textColor,
      verticalPadding: sizeStyle.verticalPadding,
      borderRadius: sizeStyle.borderRadius,
      iconSize: sizeStyle.iconSize,
      loaderSize: sizeStyle.loaderSize,
      fontSize: sizeStyle.fontSize,
    );
  }
}

class _PrimaryButtonStyle {
  final Color backgroundColor;
  final Color textColor;
  final double verticalPadding;
  final double borderRadius;
  final double iconSize;
  final double loaderSize;
  final double fontSize;

  const _PrimaryButtonStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.verticalPadding,
    required this.borderRadius,
    required this.iconSize,
    required this.loaderSize,
    required this.fontSize,
  });
}

class _PrimaryButtonVariantStyle {
  final Color backgroundColor;
  final Color textColor;

  const _PrimaryButtonVariantStyle({
    required this.backgroundColor,
    required this.textColor,
  });
}

class _PrimaryButtonSizeStyle {
  final double verticalPadding;
  final double borderRadius;
  final double iconSize;
  final double loaderSize;
  final double fontSize;

  const _PrimaryButtonSizeStyle({
    required this.verticalPadding,
    required this.borderRadius,
    required this.iconSize,
    required this.loaderSize,
    required this.fontSize,
  });
}
