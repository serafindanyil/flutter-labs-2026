import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/modules/home/home_module.dart';
import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
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
                ),
                const SizedBox(height: 16),
                StateWidget(
                  state: deviceControlState.state,
                  isDisabled: isControlsDisabled,
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
}
