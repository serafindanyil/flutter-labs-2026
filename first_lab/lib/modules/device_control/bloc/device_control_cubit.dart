import 'package:bloc/bloc.dart';
import 'package:first_lab/modules/device_control/bloc/device_control_state.dart';
import 'package:first_lab/modules/device_control/models/device_control_types.dart';

class DeviceControlCubit extends Cubit<DeviceControlState> {
  DeviceControlCubit() : super(const DeviceControlState());

  void applyUpdateStatus(Map<String, Object?> payload) {
    emit(
      DeviceControlState(
        deviceStatus: DeviceStatus.fromJson(payload['deviceStatus']),
        state: DevicePowerState.fromJson(payload['state']),
        mode: DeviceMode.fromJson(payload['mode']),
        fanInSpd: _parseNumber(payload['fanInSpd']),
        fanOutSpd: _parseNumber(payload['fanOutSpd']),
        turboEndsAt: _parseDateTime(payload['turboEndsAt']),
        hasInitialStatus: true,
      ),
    );
  }

  void reset() {
    emit(const DeviceControlState());
  }

  num? _parseNumber(Object? value) {
    if (value is num && value.isFinite) return value;
    return null;
  }

  DateTime? _parseDateTime(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
