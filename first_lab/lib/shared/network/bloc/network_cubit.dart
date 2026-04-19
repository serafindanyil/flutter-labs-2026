import 'dart:async';
import 'dart:io';
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

  Future<void> _updateStatus(List<ConnectivityResult> results) async {
    final hasInterface =
        results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);

    if (!hasInterface) {
      emit(state.copyWith(status: NetworkStatus.offline));
      return;
    }

    try {
      final lookupResult = await InternetAddress.lookup('google.com');
      if (lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty) {
        emit(state.copyWith(status: NetworkStatus.online));
      } else {
        emit(state.copyWith(status: NetworkStatus.offline));
      }
    } on SocketException catch (_) {
      emit(state.copyWith(status: NetworkStatus.offline));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
