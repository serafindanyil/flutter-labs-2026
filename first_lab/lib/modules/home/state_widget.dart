import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/pressable_button.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StateWidget extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool> onToggle;

  const StateWidget({required this.isOn, required this.onToggle, super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Стан', style: Theme.of(context).textTheme.displayMedium),
              Text(
                isOn ? 'Увімк.' : 'Вимк.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: PressableButton(
              onTap: () => onToggle(!isOn),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isOn ? AppColors.blue500 : AppColors.blue200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.power,
                  size: 32,
                  color: isOn ? AppColors.white : AppColors.blue500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
