import 'package:first_lab/shared/widgets/pressable_button.dart';
import 'package:first_lab/shared/widgets/primary_button_style.dart';
import 'package:first_lab/shared/widgets/primary_button_types.dart';
import 'package:flutter/material.dart';

export 'package:first_lab/shared/widgets/primary_button_types.dart';

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
    final style = resolvePrimaryButtonStyle(variant: variant, size: size);
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
}
