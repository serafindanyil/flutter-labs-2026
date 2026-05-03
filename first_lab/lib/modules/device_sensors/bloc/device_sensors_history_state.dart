import 'package:equatable/equatable.dart';
import 'package:first_lab/modules/device_sensors/models/device_sensor_history_point.dart';

enum DeviceSensorsHistoryStatus { initial, loading, success, failure }

class DeviceSensorsHistoryState extends Equatable {
  const DeviceSensorsHistoryState({
    this.status = DeviceSensorsHistoryStatus.initial,
    this.co2 = const [],
    this.humidity = const [],
  });

  final DeviceSensorsHistoryStatus status;
  final List<DeviceSensorHistoryPoint> co2;
  final List<DeviceSensorHistoryPoint> humidity;

  DeviceSensorsHistoryState copyWith({
    DeviceSensorsHistoryStatus? status,
    List<DeviceSensorHistoryPoint>? co2,
    List<DeviceSensorHistoryPoint>? humidity,
  }) {
    return DeviceSensorsHistoryState(
      status: status ?? this.status,
      co2: co2 ?? this.co2,
      humidity: humidity ?? this.humidity,
    );
  }

  @override
  List<Object?> get props => [status, co2, humidity];
}
