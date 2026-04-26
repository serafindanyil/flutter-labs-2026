import 'package:equatable/equatable.dart';

enum NetworkStatus { initial, online, offline }

class NetworkState extends Equatable {
  const NetworkState({this.status = NetworkStatus.initial});

  final NetworkStatus status;

  @override
  List<Object?> get props => [status];

  NetworkState copyWith({NetworkStatus? status}) {
    return NetworkState(status: status ?? this.status);
  }
}
