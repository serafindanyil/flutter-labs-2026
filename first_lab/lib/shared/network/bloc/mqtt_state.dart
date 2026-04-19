import 'package:equatable/equatable.dart';

enum MqttStatus { initial, connecting, connected, disconnected }

class MqttState extends Equatable {
  const MqttState({this.status = MqttStatus.initial, this.co2Value});

  final MqttStatus status;
  final String? co2Value;

  MqttState copyWith({MqttStatus? status, String? co2Value}) {
    return MqttState(
      status: status ?? this.status,
      co2Value: co2Value ?? this.co2Value,
    );
  }

  @override
  List<Object?> get props => [status, co2Value];
}
