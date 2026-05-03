import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:first_lab/modules/device_sensors/bloc/device_sensors_history_state.dart';
import 'package:first_lab/modules/device_sensors/services/device_sensors_history_service.dart';

class DeviceSensorsHistoryCubit extends Cubit<DeviceSensorsHistoryState> {
  DeviceSensorsHistoryCubit({required DeviceSensorsHistoryService service})
    : _service = service,
      super(const DeviceSensorsHistoryState());

  static const Duration refreshInterval = Duration(minutes: 5);

  final DeviceSensorsHistoryService _service;
  Timer? _refreshTimer;
  bool _isLoading = false;
  int _requestGeneration = 0;

  void start() {
    if (_refreshTimer != null) return;

    unawaited(load());
    _refreshTimer = Timer.periodic(refreshInterval, (_) => unawaited(load()));
  }

  void stop({bool shouldReset = false}) {
    _requestGeneration++;
    _isLoading = false;
    _refreshTimer?.cancel();
    _refreshTimer = null;

    if (shouldReset) {
      emit(const DeviceSensorsHistoryState());
    }
  }

  Future<void> load() async {
    if (_isLoading || isClosed) return;

    _isLoading = true;
    final requestGeneration = _requestGeneration;
    emit(state.copyWith(status: DeviceSensorsHistoryStatus.loading));

    try {
      final history = await _service.getHistory();
      if (isClosed || requestGeneration != _requestGeneration) return;

      emit(
        DeviceSensorsHistoryState(
          status: DeviceSensorsHistoryStatus.success,
          co2: history.co2,
          humidity: history.humidity,
        ),
      );
    } catch (_) {
      if (isClosed || requestGeneration != _requestGeneration) return;
      emit(state.copyWith(status: DeviceSensorsHistoryStatus.failure));
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
