import 'package:equatable/equatable.dart';

enum RealtimeStatus {
  initial,
  connecting,
  connected,
  reconnecting,
  disconnected,
}

class RealtimeState extends Equatable {
  const RealtimeState({
    this.status = RealtimeStatus.initial,
    this.retryAttempt = 0,
  });

  final RealtimeStatus status;
  final int retryAttempt;

  RealtimeState copyWith({RealtimeStatus? status, int? retryAttempt}) {
    return RealtimeState(
      status: status ?? this.status,
      retryAttempt: retryAttempt ?? this.retryAttempt,
    );
  }

  @override
  List<Object?> get props => [status, retryAttempt];
}
