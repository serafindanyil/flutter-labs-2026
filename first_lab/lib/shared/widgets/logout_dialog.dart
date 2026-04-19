import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Підтвердження виходу',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ви впевнені, що хочете вийти?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  title: 'Закрити',
                  onTap: () => Navigator.of(context).pop(false),
                  variant: PrimaryButtonVariant.danger,
                  size: PrimaryButtonSize.small,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  title: 'Вийти',
                  onTap: () => Navigator.of(context).pop(true),
                  size: PrimaryButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
