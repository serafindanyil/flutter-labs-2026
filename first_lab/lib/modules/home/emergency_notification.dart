import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EmergencyNotification extends StatelessWidget {
  final String title;
  final IconData icon;

  const EmergencyNotification({
    required this.title,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryText, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const Icon(
            LucideIcons.chevronRight,
            color: AppColors.mutedText,
            size: 24,
          ),
        ],
      ),
    );
  }
}
