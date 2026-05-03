import 'package:bloc/bloc.dart';
import 'package:first_lab/modules/device_control/bloc/device_control_state.dart';
import 'package:first_lab/modules/device_control/models/device_control_command_error.dart';
import 'package:first_lab/modules/device_control/models/device_control_types.dart';
import 'package:first_lab/modules/device_control/services/device_control_command_service.dart';

class DeviceControlCubit extends Cubit<DeviceControlState> {
  DeviceControlCubit({required DeviceControlCommandService commandService})
    : _commandService = commandService,
      super(const DeviceControlState());

  final DeviceControlCommandService _commandService;

  void applyUpdateStatus(Map<String, Object?> payload) {
    final deviceStatus = DeviceStatus.fromJson(payload['deviceStatus']);
    final isDeviceOnline = deviceStatus == DeviceStatus.online;

    emit(
      DeviceControlState(
        deviceStatus: deviceStatus,
        state: isDeviceOnline
            ? DevicePowerState.fromJson(payload['state'])
            : null,
        mode: isDeviceOnline ? DeviceMode.fromJson(payload['mode']) : null,
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

  Future<void> changeMode(DeviceMode mode) async {
    try {
      final result = await _commandService.changeMode(mode);
      _emitCommandSuccess(turboEndsAt: result.turboEndsAt);
    } on DeviceControlCommandException catch (error) {
      _emitCommandFailure(error.error);
    }
  }

  Future<void> changePowerState(DevicePowerState powerState) async {
    try {
      await _commandService.changePowerState(powerState);
      _emitCommandSuccess();
    } on DeviceControlCommandException catch (error) {
      _emitCommandFailure(error.error);
    }
  }

  void _emitCommandSuccess({DateTime? turboEndsAt}) {
    emit(
      state.copyWith(
        commandStatus: DeviceCommandStatus.success,
        commandTurboEndsAt: turboEndsAt,
        clearCommandTurboEndsAt: turboEndsAt == null,
        clearCommandError: true,
        commandVersion: state.commandVersion + 1,
      ),
    );
  }

  void _emitCommandFailure(DeviceControlCommandError error) {
    emit(
      state.copyWith(
        commandStatus: DeviceCommandStatus.failure,
        commandError: error,
        clearCommandTurboEndsAt: true,
        commandVersion: state.commandVersion + 1,
      ),
    );
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
