import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/pressable_button.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:flutter/material.dart';

class ModeWidget extends StatelessWidget {
  final DeviceMode? mode;
  final bool isDisabled;
  final ValueChanged<DeviceMode>? onModeChanged;

  const ModeWidget({
    required this.mode,
    required this.isDisabled,
    required this.onModeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Режим', style: Theme.of(context).textTheme.displayMedium),
              Text(
                _getModeName(mode),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 56,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDisabled ? AppColors.disabled : AppColors.blue400,
              borderRadius: BorderRadius.circular(30),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double itemWidth = width / 3;
                final selectedIndex = mode == null
                    ? -1
                    : DeviceMode.values.indexOf(mode!);

                return Stack(
                  children: [
                    if (selectedIndex >= 0)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: selectedIndex * itemWidth,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        _buildModeButton(DeviceMode.manual, 'Ручний', context),
                        _buildModeButton(DeviceMode.auto, 'Авто', context),
                        _buildModeButton(DeviceMode.turbo, 'Турбо', context),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    DeviceMode targetMode,
    String title,
    BuildContext context,
  ) {
    final isSelected = mode == targetMode;
    return Expanded(
      child: PressableButton(
        onTap: isDisabled || isSelected
            ? null
            : () => onModeChanged?.call(targetMode),
        child: ColoredBox(
          color: Colors.transparent,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: _getButtonTextColor(isSelected),
              ),
              child: Text(title),
            ),
          ),
        ),
      ),
    );
  }

  Color _getButtonTextColor(bool isSelected) {
    if (isDisabled) {
      return isSelected ? AppColors.disabledAccent : AppColors.white;
    }
    return isSelected ? AppColors.primaryText : AppColors.white;
  }

  String _getModeName(DeviceMode? mode) {
    if (mode == null) return 'Невідомо';

    switch (mode) {
      case DeviceMode.manual:
        return 'Ручний';
      case DeviceMode.auto:
        return 'Авто';
      case DeviceMode.turbo:
        return 'Турбо';
    }
  }
}
