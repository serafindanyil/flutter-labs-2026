import 'package:first_lab/modules/device_control/bloc/device_control_state.dart';
import 'package:first_lab/modules/device_control/models/device_control_types.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';

abstract final class DeviceControlAvailability {
  static bool isDisabled({
    required NetworkStatus networkStatus,
    required DeviceControlState deviceControl,
  }) {
    return networkStatus != NetworkStatus.online ||
        !deviceControl.hasInitialStatus ||
        deviceControl.deviceStatus == DeviceStatus.offline;
  }
}
