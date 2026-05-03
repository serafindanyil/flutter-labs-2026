part of 'realtime_cubit.dart';

mixin RealtimeRetryActions on Cubit<RealtimeState> {
  bool get _shouldStayConnected;
  Timer? get _retryTimer;
  set _retryTimer(Timer? value);
  int get _retryAttempt;
  set _retryAttempt(int value);

  Future<void> _connect({required bool forceRefresh});

  void _retryNowWithFreshToken() {
    if (!_shouldStayConnected || isClosed) return;

    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempt += 1;

    emit(
      state.copyWith(
        status: RealtimeStatus.reconnecting,
        retryAttempt: _retryAttempt,
      ),
    );

    unawaited(_connect(forceRefresh: true));
  }

  void _scheduleRetry({required bool forceRefresh}) {
    if (!_shouldStayConnected || isClosed) return;
    if (_retryTimer?.isActive ?? false) return;

    _retryAttempt += 1;
    final delay = RealtimeCubit._retryPolicy.delay(_retryAttempt);

    emit(
      state.copyWith(
        status: RealtimeStatus.reconnecting,
        retryAttempt: _retryAttempt,
      ),
    );

    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      _connect(forceRefresh: forceRefresh);
    });
  }
}
