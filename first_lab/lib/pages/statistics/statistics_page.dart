import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/modules/device_sensors/device_sensors_module.dart';
import 'package:first_lab/pages/statistics/widgets/sensor_indicators_list.dart';
import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, networkState) {
        return BlocBuilder<DeviceControlCubit, DeviceControlState>(
          builder: (context, deviceControlState) {
            final isDisabled = DeviceControlAvailability.isDisabled(
              networkStatus: networkState.status,
              deviceControl: deviceControlState,
            );

            return BlocBuilder<DeviceSensorsCubit, DeviceSensorsState>(
              builder: (context, sensorsState) {
                return FutureBuilder<DeviceSensorsHistoryData>(
                  future: context
                      .read<DeviceSensorsHistoryService>()
                      .getHistory(),
                  builder: (context, snapshot) {
                    final historyData =
                        snapshot.data ?? const DeviceSensorsHistoryData.empty();

                    return SensorIndicatorsList(
                      isDisabled: isDisabled,
                      sensorsState: sensorsState,
                      historyData: historyData,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
