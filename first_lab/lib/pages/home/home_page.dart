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
    return BlocListener<DeviceControlCubit, DeviceControlState>(
      listenWhen: (previous, current) =>
          previous.commandVersion != current.commandVersion,
      listener: _listenCommandResult,
      child: BlocBuilder<NetworkCubit, NetworkState>(
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
                    onModeChanged: context
                        .read<DeviceControlCubit>()
                        .changeMode,
                  ),
                  const SizedBox(height: 16),
                  StateWidget(
                    state: deviceControlState.state,
                    isDisabled: isControlsDisabled,
                    onStateChanged: context
                        .read<DeviceControlCubit>()
                        .changePowerState,
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
      ),
    );
  }

  void _listenCommandResult(BuildContext context, DeviceControlState state) {
    if (state.commandStatus == DeviceCommandStatus.success &&
        state.commandTurboEndsAt != null) {
      AppToast.success(
        context,
        'Турбо завершиться о ${_formatTime(state.commandTurboEndsAt!)}',
      );
      return;
    }
    final error = state.commandError;
    if (state.commandStatus == DeviceCommandStatus.failure && error != null) {
      _showCommandError(context, error);
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
