import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/pressable_button.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:flutter/material.dart';

class ModeWidget extends StatefulWidget {
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
  State<ModeWidget> createState() => _ModeWidgetState();
}

class _ModeWidgetState extends State<ModeWidget> {
  static const Duration _throttleDuration = Duration(milliseconds: 500);

  DateTime? _lastTapAt;

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
                _getModeName(widget.mode),
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
              color: widget.isDisabled ? AppColors.disabled : AppColors.blue400,
              borderRadius: BorderRadius.circular(30),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double itemWidth = width / 3;
                final selectedIndex = widget.mode == null
                    ? -1
                    : DeviceMode.values.indexOf(widget.mode!);

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
    final isSelected = widget.mode == targetMode;
    return Expanded(
      child: PressableButton(
        onTap: widget.isDisabled || isSelected
            ? null
            : () => _onModeTap(targetMode),
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
    if (widget.isDisabled) {
      return isSelected ? AppColors.disabledAccent : AppColors.white;
    }
    return isSelected ? AppColors.primaryText : AppColors.white;
  }

  void _onModeTap(DeviceMode mode) {
    final now = DateTime.now();
    final lastTapAt = _lastTapAt;
    if (lastTapAt != null && now.difference(lastTapAt) < _throttleDuration) {
      return;
    }
    _lastTapAt = now;
    widget.onModeChanged?.call(mode);
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
