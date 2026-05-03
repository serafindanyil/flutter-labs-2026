import 'package:equatable/equatable.dart';

enum SecretFlashlightStatus { idle, toggled, unsupported, failure }

class SecretFlashlightState extends Equatable {
  const SecretFlashlightState({
    this.status = SecretFlashlightStatus.idle,
    this.isEnabled = false,
    this.eventVersion = 0,
  });

  final SecretFlashlightStatus status;
  final bool isEnabled;
  final int eventVersion;

  SecretFlashlightState copyWith({
    SecretFlashlightStatus? status,
    bool? isEnabled,
    int? eventVersion,
  }) {
    return SecretFlashlightState(
      status: status ?? this.status,
      isEnabled: isEnabled ?? this.isEnabled,
      eventVersion: eventVersion ?? this.eventVersion,
    );
  }

  @override
  List<Object> get props => [status, isEnabled, eventVersion];
}
