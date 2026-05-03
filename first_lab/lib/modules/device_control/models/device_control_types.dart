enum DeviceStatus {
  offline('offline'),
  online('online');

  const DeviceStatus(this.value);

  final String value;

  static DeviceStatus fromJson(Object? value) {
    return DeviceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DeviceStatus.offline,
    );
  }
}

enum DevicePowerState {
  on('on'),
  off('off');

  const DevicePowerState(this.value);

  final String value;

  static DevicePowerState? fromJson(Object? value) {
    for (final state in DevicePowerState.values) {
      if (state.value == value) return state;
    }
    return null;
  }
}

enum DeviceMode {
  manual('manual'),
  auto('auto'),
  turbo('turbo');

  const DeviceMode(this.value);

  final String value;

  static DeviceMode? fromJson(Object? value) {
    for (final mode in DeviceMode.values) {
      if (mode.value == value) return mode;
    }
    return null;
  }
}
