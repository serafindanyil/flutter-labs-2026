import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LayoutHeader extends StatelessWidget {
  const LayoutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceControlCubit, DeviceControlState>(
      buildWhen: (previous, current) =>
          previous.deviceStatus != current.deviceStatus,
      builder: (context, state) {
        final isDeviceOnline = state.deviceStatus == DeviceStatus.online;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue100.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.waves, size: 24),
                const SizedBox(width: 8),
                Text(
                  'SmartRecu',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  'v 0.1',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                ),
                const Spacer(),
                Text(
                  isDeviceOnline ? 'Online' : 'Offline',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDeviceOnline
                        ? AppColors.blue500
                        : AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
