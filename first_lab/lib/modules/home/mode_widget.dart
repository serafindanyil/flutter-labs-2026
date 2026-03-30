import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:flutter/material.dart';

enum DeviceMode { manual, auto, turbo }

class ModeWidget extends StatelessWidget {
  final DeviceMode mode;
  final ValueChanged<DeviceMode> onModeChanged;

  const ModeWidget({
    super.key,
    required this.mode,
    required this.onModeChanged,
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
              Text(
                'Режим',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                _getModeName(mode),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.blue400,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildModeButton(DeviceMode.manual, 'Ручний', context),
                _buildModeButton(DeviceMode.auto, 'Авто', context),
                _buildModeButton(DeviceMode.turbo, 'Турбо', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(DeviceMode targetMode, String title, BuildContext context) {
    final isSelected = mode == targetMode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(targetMode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.primaryText : AppColors.white,
                  ),
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