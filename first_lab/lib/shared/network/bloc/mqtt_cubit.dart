import 'dart:async';

import 'package:first_lab/shared/network/bloc/mqtt_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttCubit extends Cubit<MqttState> {
  MqttCubit() : super(const MqttState()) {
    _initConnection();
  }

  static const String _co2Topic = 'sensor/co2';

  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>?
  _updatesSubscription;

  Future<void> _initConnection() async {
    emit(state.copyWith(status: MqttStatus.connecting));

    final client = _createClient();
    _configureClient(client);

    _client = client;

    try {
      await client.connect();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(status: MqttStatus.disconnected));
      }
      client.disconnect();
      return;
    }

    final connectionStatus = client.connectionStatus;
    if (connectionStatus?.state != MqttConnectionState.connected) {
      if (!isClosed) {
        emit(state.copyWith(status: MqttStatus.disconnected));
      }
      client.disconnect();
      return;
    }

    if (!isClosed) {
      emit(state.copyWith(status: MqttStatus.connected));
    }

    client.subscribe(_co2Topic, MqttQos.atMostOnce);
    _listenUpdates(client);
  }

  MqttServerClient _createClient() {
    final url = dotenv.env['MQTT_URL'] ?? 'mqtt-dashboard.com';
    final port = int.tryParse(dotenv.env['MQTT_PORT'] ?? '8884') ?? 8884;
    final clientId =
        dotenv.env['MQTT_CLIENT_ID'] ??
        'clientId-${DateTime.now().millisecondsSinceEpoch}';

    late final MqttServerClient client;

    if (port == 8884 || port == 8000) {
      final scheme = port == 8884 ? 'wss://' : 'ws://';
      final fullUrl = url.startsWith('ws') ? url : '$scheme$url/mqtt';
      client = MqttServerClient(fullUrl, clientId);
      client.useWebSocket = true;
    } else {
      client = MqttServerClient(url, clientId);
      if (port == 8883) {
        client.secure = true;
      }
    }

    client.port = port;
    return client;
  }

  void _configureClient(MqttServerClient client) {
    client.setProtocolV311();
    client.logging(on: false);
    client.keepAlivePeriod = 20;

    client.onDisconnected = () {
      if (!isClosed) {
        emit(state.copyWith(status: MqttStatus.disconnected));
      }
    };

    client.connectionMessage = MqttConnectMessage().startClean().withWillQos(
      MqttQos.atMostOnce,
    );
  }

  void _listenUpdates(MqttServerClient client) {
    final updates = client.updates;
    if (updates == null) return;

    _updatesSubscription = updates.listen((messages) {
      for (final message in messages) {
        final payloadMessage = message.payload;
        if (payloadMessage is! MqttPublishMessage) continue;

        final payload = MqttPublishPayload.bytesToStringAsString(
          payloadMessage.payload.message,
        );

        if (message.topic == _co2Topic && !isClosed) {
          emit(state.copyWith(co2Value: payload));
        }
      }
    });
  }

  void disconnect() {
    _updatesSubscription?.cancel();
    _updatesSubscription = null;
    _client?.disconnect();
    _client = null;

    if (!isClosed) {
      emit(state.copyWith(status: MqttStatus.disconnected));
    }
  }

  @override
  Future<void> close() {
    disconnect();
    return super.close();
  }
}
