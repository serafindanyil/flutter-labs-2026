import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit(this._connectivity) : super(const NetworkState()) {
    _init();
  }

  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  void _init() {
    _connectivity.checkConnectivity().then(_updateStatus);
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      emit(state.copyWith(status: NetworkStatus.offline));
    } else {
      emit(state.copyWith(status: NetworkStatus.online));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
