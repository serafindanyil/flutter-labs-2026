import 'package:socket_io_client/socket_io_client.dart' as io;

typedef UpdateStatusHandler = void Function(Map<String, Object?> payload);
typedef SensorsHandler = void Function(Map<String, Object?> payload);
typedef RealtimeVoidHandler = void Function();
typedef RealtimeErrorHandler = void Function(Object? error);

class RealtimeSocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String url,
    required String token,
    required RealtimeVoidHandler onConnect,
    required RealtimeVoidHandler onDisconnect,
    required RealtimeErrorHandler onError,
    required UpdateStatusHandler onUpdateStatus,
    required SensorsHandler onSensors,
  }) {
    disconnect();

    final socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .disableReconnection()
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.onConnect((_) => onConnect());
    socket.onDisconnect((_) => onDisconnect());
    socket.onConnectError(onError);
    socket.onError(onError);
    socket.on('updateStatus', (Object? data) {
      final payload = _parsePayload(data);
      if (payload != null) {
        onUpdateStatus(payload);
      }
    });
    socket.on('sensors', (Object? data) {
      final payload = _parsePayload(data);
      if (payload != null) {
        onSensors(payload);
      }
    });

    _socket = socket;
    socket.connect();
  }

  void disconnect() {
    final socket = _socket;
    if (socket == null) return;

    socket.dispose();
    _socket = null;
  }

  Map<String, Object?>? _parsePayload(Object? data) {
    if (data is Map<String, Object?>) return data;
    if (data is Map) {
      final payload = <String, Object?>{};
      for (final entry in data.entries) {
        payload[entry.key.toString()] = entry.value;
      }
      return payload;
    }
    return null;
  }
}
