import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/shared/realtime/bloc/realtime_state.dart';
import 'package:first_lab/shared/realtime/services/realtime_socket_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RealtimeCubit extends Cubit<RealtimeState> {
  RealtimeCubit({
    required AuthService authService,
    required RealtimeSocketService socketService,
    required UpdateStatusHandler onUpdateStatus,
    required SensorsHandler onSensors,
  }) : _authService = authService,
       _socketService = socketService,
       _onUpdateStatus = onUpdateStatus,
       _onSensors = onSensors,
       super(const RealtimeState());

  static const List<Duration> _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 16),
    Duration(seconds: 30),
  ];

  final AuthService _authService;
  final RealtimeSocketService _socketService;
  final UpdateStatusHandler _onUpdateStatus;
  final SensorsHandler _onSensors;

  Timer? _retryTimer;
  bool _shouldStayConnected = false;
  int _retryAttempt = 0;

  Future<void> connect() async {
    if (_shouldStayConnected &&
        (state.status == RealtimeStatus.connecting ||
            state.status == RealtimeStatus.connected ||
            state.status == RealtimeStatus.reconnecting)) {
      return;
    }

    _shouldStayConnected = true;
    _retryAttempt = 0;
    _retryTimer?.cancel();
    await _connect(forceRefresh: false);
  }

  void disconnect() {
    _shouldStayConnected = false;
    _retryAttempt = 0;
    _retryTimer?.cancel();
    _retryTimer = null;
    _socketService.disconnect();

    if (!isClosed) {
      emit(const RealtimeState(status: RealtimeStatus.disconnected));
    }
  }

  Future<void> _connect({required bool forceRefresh}) async {
    if (!_shouldStayConnected || isClosed) return;

    emit(
      state.copyWith(
        status: _retryAttempt == 0
            ? RealtimeStatus.connecting
            : RealtimeStatus.reconnecting,
        retryAttempt: _retryAttempt,
      ),
    );

    final token = await _authService.getIdToken(forceRefresh: forceRefresh);
    if (!_shouldStayConnected || isClosed) return;

    if (token == null || token.trim().isEmpty) {
      _scheduleRetry(forceRefresh: true);
      return;
    }

    _socketService.connect(
      url: dotenv.env['SOCKET_URL'] ?? 'http://localhost:3000',
      token: token,
      onConnect: _handleConnect,
      onDisconnect: _handleDisconnect,
      onError: _handleError,
      onUpdateStatus: _onUpdateStatus,
      onSensors: _onSensors,
    );
  }

  void _handleConnect() {
    if (!_shouldStayConnected || isClosed) return;

    _retryAttempt = 0;
    _retryTimer?.cancel();
    _retryTimer = null;
    emit(const RealtimeState(status: RealtimeStatus.connected));
  }

  void _handleDisconnect() {
    if (!_shouldStayConnected || isClosed) return;
    _scheduleRetry(forceRefresh: true);
  }

  void _handleError(Object? error) {
    if (!_shouldStayConnected || isClosed) return;
    _socketService.disconnect();
    _scheduleRetry(forceRefresh: true);
  }

  void _scheduleRetry({required bool forceRefresh}) {
    if (!_shouldStayConnected || isClosed) return;
    if (_retryTimer?.isActive ?? false) return;

    _retryAttempt += 1;
    final delay = _retryDelay(_retryAttempt);

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

  Duration _retryDelay(int attempt) {
    final index = attempt - 1;
    if (index < _retryDelays.length) return _retryDelays[index];
    return _retryDelays.last;
  }

  @override
  Future<void> close() {
    disconnect();
    return super.close();
  }
}
