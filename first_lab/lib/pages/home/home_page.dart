import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/modules/home/home_module.dart';
import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, String? title});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, networkState) {
        return BlocBuilder<DeviceControlCubit, DeviceControlState>(
          builder: (context, deviceControlState) {
            final isControlsDisabled = DeviceControlAvailability.isDisabled(
              networkStatus: networkState.status,
              deviceControl: deviceControlState,
            );

            return ListView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 120,
              ),
              children: [
                Text(
                  'Керування',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 24),
                ModeWidget(
                  mode: deviceControlState.mode,
                  isDisabled: isControlsDisabled,
                  onModeChanged: (mode) => _changeMode(context, mode),
                ),
                const SizedBox(height: 16),
                StateWidget(
                  state: deviceControlState.state,
                  isDisabled: isControlsDisabled,
                  onStateChanged: (state) => _changeState(context, state),
                ),
                const SizedBox(height: 32),
                Text(
                  'Термінові сповіщення',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                const EmergencyNotification(
                  title: 'Перевищено рівень CO2',
                  icon: LucideIcons.cloud,
                ),
                const SizedBox(height: 16),
                const EmergencyNotification(
                  title: 'Велика різниця температур',
                  icon: LucideIcons.thermometer,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _changeMode(BuildContext context, DeviceMode mode) async {
    try {
      final result = await context
          .read<DeviceControlCommandService>()
          .changeMode(mode);
      if (!context.mounted) return;
      if (mode == DeviceMode.turbo && result.turboEndsAt != null) {
        AppToast.success(
          context,
          'Турбо завершиться о ${_formatTime(result.turboEndsAt!)}',
        );
      }
    } on DeviceControlCommandException catch (error) {
      if (!context.mounted) return;
      _showCommandError(context, error.error);
    }
  }

  Future<void> _changeState(
    BuildContext context,
    DevicePowerState state,
  ) async {
    try {
      await context.read<DeviceControlCommandService>().changePowerState(state);
    } on DeviceControlCommandException catch (error) {
      if (!context.mounted) return;
      _showCommandError(context, error.error);
    }
  }

  void _showCommandError(
    BuildContext context,
    DeviceControlCommandError error,
  ) {
    switch (error) {
      case DeviceControlCommandError.deviceOffline:
        AppToast.error(context, 'Пристрій є offline');
        return;
      case DeviceControlCommandError.serverError:
        AppToast.error(context, 'Помилка на сервері');
        return;
      case DeviceControlCommandError.unauthorized:
      case DeviceControlCommandError.unknown:
        AppToast.error(context, 'Не вдалося виконати команду');
        return;
    }
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
