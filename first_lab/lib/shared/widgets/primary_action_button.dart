import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/styles/app_shadows.dart';
import 'package:first_lab/shared/widgets/pressable_button.dart';
import 'package:flutter/material.dart';

class PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const PrimaryActionButton({
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PressableButton(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.blue500,
          shape: BoxShape.circle,
          boxShadow: AppShadows.button,
        ),
        child: Icon(icon, size: 32, color: AppColors.white),
      ),
    );
  }
}
