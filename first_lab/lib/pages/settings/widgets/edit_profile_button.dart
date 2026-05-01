import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({
    required this.isEnabled,
    required this.onTap,
    super.key,
  });

  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.blue100 : AppColors.gray100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          LucideIcons.pencil,
          color: isEnabled ? AppColors.blue500 : AppColors.gray500,
          size: 24,
        ),
      ),
    );
  }
}
