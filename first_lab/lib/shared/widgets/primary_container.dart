import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/styles/app_shadows.dart';
import 'package:flutter/material.dart';

class PrimaryContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PrimaryContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.button,
      ),
      child: child,
    );
  }
}
