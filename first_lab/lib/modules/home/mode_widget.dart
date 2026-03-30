import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/pressable_button.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:flutter/material.dart';

enum DeviceMode { manual, auto, turbo }

class ModeWidget extends StatelessWidget {
  final DeviceMode mode;
  final ValueChanged<DeviceMode> onModeChanged;

  const ModeWidget({
    required this.mode,
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
              color: AppColors.blue400,
              borderRadius: BorderRadius.circular(30),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double itemWidth = width / 3;
                final int selectedIndex = DeviceMode.values.indexOf(mode);

                return Stack(
                  children: [
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
        onTap: () => onModeChanged(targetMode),
        child: ColoredBox(
          color: Colors.transparent,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: isSelected ? AppColors.primaryText : AppColors.white,
              ),
              child: Text(title),
            ),
          ),
        ),
      ),
    );
  }

  String _getModeName(DeviceMode mode) {
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
