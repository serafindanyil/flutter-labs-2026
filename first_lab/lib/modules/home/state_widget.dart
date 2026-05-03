import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/pressable_button.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StateWidget extends StatelessWidget {
  final DevicePowerState? state;
  final bool isDisabled;
  final ValueChanged<DevicePowerState>? onStateChanged;

  const StateWidget({
    required this.state,
    required this.isDisabled,
    required this.onStateChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = state == DevicePowerState.on;
    final buttonColor = isDisabled
        ? AppColors.disabledAccent
        : isOn
        ? AppColors.blue500
        : AppColors.blue200;
    final iconColor = isDisabled || isOn ? AppColors.white : AppColors.blue500;

    return PrimaryContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Стан', style: Theme.of(context).textTheme.displayMedium),
              Text(
                _getStateName(state),
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
              onTap: isDisabled || state == null
                  ? null
                  : () => onStateChanged?.call(_nextState(state!)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: buttonColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.power, size: 32, color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStateName(DevicePowerState? state) {
    switch (state) {
      case DevicePowerState.on:
        return 'Увімк.';
      case DevicePowerState.off:
        return 'Вимк.';
      case null:
        return 'Невідомо';
    }
  }

  DevicePowerState _nextState(DevicePowerState state) {
    return state == DevicePowerState.on
        ? DevicePowerState.off
        : DevicePowerState.on;
  }
}
