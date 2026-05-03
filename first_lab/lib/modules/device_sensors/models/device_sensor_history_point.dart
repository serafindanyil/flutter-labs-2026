import 'package:equatable/equatable.dart';

class DeviceSensorHistoryPoint extends Equatable {
  const DeviceSensorHistoryPoint({
    required this.value,
    required this.timestamp,
  });

  final num value;
  final String timestamp;

  @override
  List<Object?> get props => [value, timestamp];
}

class DeviceSensorsHistoryData extends Equatable {
  const DeviceSensorsHistoryData({required this.co2, required this.humidity});

  const DeviceSensorsHistoryData.empty() : co2 = const [], humidity = const [];

  final List<DeviceSensorHistoryPoint> co2;
  final List<DeviceSensorHistoryPoint> humidity;

  @override
  List<Object?> get props => [co2, humidity];
}
