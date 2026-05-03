import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:flutter/material.dart';

class PrimaryTextFieldError extends StatelessWidget {
  const PrimaryTextFieldError({required this.errorText, super.key});

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 4,
      right: 0,
      bottom: -22,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        opacity: errorText != null ? 1.0 : 0.0,
        child: errorText != null
            ? Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: AppColors.red,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      errorText!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.red),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
