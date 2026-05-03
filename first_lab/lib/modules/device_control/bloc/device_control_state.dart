import 'package:equatable/equatable.dart';
import 'package:first_lab/modules/device_control/models/device_control_command_error.dart';
import 'package:first_lab/modules/device_control/models/device_control_types.dart';

class DeviceControlState extends Equatable {
  const DeviceControlState({
    this.deviceStatus = DeviceStatus.offline,
    this.state,
    this.mode,
    this.fanInSpd,
    this.fanOutSpd,
    this.turboEndsAt,
    this.hasInitialStatus = false,
    this.commandStatus = DeviceCommandStatus.idle,
    this.commandError,
    this.commandTurboEndsAt,
    this.commandVersion = 0,
  });

  final DeviceStatus deviceStatus;
  final DevicePowerState? state;
  final DeviceMode? mode;
  final num? fanInSpd;
  final num? fanOutSpd;
  final DateTime? turboEndsAt;
  final bool hasInitialStatus;
  final DeviceCommandStatus commandStatus;
  final DeviceControlCommandError? commandError;
  final DateTime? commandTurboEndsAt;
  final int commandVersion;

  DeviceControlState copyWith({
    DeviceStatus? deviceStatus,
    DevicePowerState? state,
    bool clearState = false,
    DeviceMode? mode,
    bool clearMode = false,
    num? fanInSpd,
    bool clearFanInSpd = false,
    num? fanOutSpd,
    bool clearFanOutSpd = false,
    DateTime? turboEndsAt,
    bool clearTurboEndsAt = false,
    bool? hasInitialStatus,
    DeviceCommandStatus? commandStatus,
    DeviceControlCommandError? commandError,
    bool clearCommandError = false,
    DateTime? commandTurboEndsAt,
    bool clearCommandTurboEndsAt = false,
    int? commandVersion,
  }) {
    return DeviceControlState(
      deviceStatus: deviceStatus ?? this.deviceStatus,
      state: clearState ? null : state ?? this.state,
      mode: clearMode ? null : mode ?? this.mode,
      fanInSpd: clearFanInSpd ? null : fanInSpd ?? this.fanInSpd,
      fanOutSpd: clearFanOutSpd ? null : fanOutSpd ?? this.fanOutSpd,
      turboEndsAt: clearTurboEndsAt ? null : turboEndsAt ?? this.turboEndsAt,
      hasInitialStatus: hasInitialStatus ?? this.hasInitialStatus,
      commandStatus: commandStatus ?? this.commandStatus,
      commandError: clearCommandError
          ? null
          : commandError ?? this.commandError,
      commandTurboEndsAt: clearCommandTurboEndsAt
          ? null
          : commandTurboEndsAt ?? this.commandTurboEndsAt,
      commandVersion: commandVersion ?? this.commandVersion,
    );
  }

  @override
  List<Object?> get props => [
    deviceStatus,
    state,
    mode,
    fanInSpd,
    fanOutSpd,
    turboEndsAt,
    hasInitialStatus,
    commandStatus,
    commandError,
    commandTurboEndsAt,
    commandVersion,
  ];
}

enum DeviceCommandStatus { idle, success, failure }
