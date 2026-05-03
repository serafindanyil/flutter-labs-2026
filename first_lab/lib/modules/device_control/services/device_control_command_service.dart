import 'dart:convert';
import 'dart:io';

import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/modules/device_control/models/device_control_types.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum DeviceControlCommandError {
  deviceOffline,
  serverError,
  unauthorized,
  unknown,
}

class DeviceControlCommandException implements Exception {
  const DeviceControlCommandException(this.error);

  final DeviceControlCommandError error;
}

class DeviceControlModeCommandResult {
  const DeviceControlModeCommandResult({this.turboEndsAt});

  final DateTime? turboEndsAt;
}

class DeviceControlCommandService {
  DeviceControlCommandService({required AuthService authService})
    : _authService = authService;

  static const int _turboDurationSeconds = 10;
  static const Duration _throttleDuration = Duration(milliseconds: 500);
  static const int _okStatusCode = 200;
  static const int _unauthorizedStatusCode = 401;
  static const int _conflictStatusCode = 409;
  static const int _serverErrorStatusCode = 500;

  final AuthService _authService;
  DateTime? _lastCommandAt;

  Future<DeviceControlModeCommandResult> changeMode(DeviceMode mode) async {
    if (_isThrottled()) return const DeviceControlModeCommandResult();

    final body = <String, Object>{'mode': mode.value};
    if (mode == DeviceMode.turbo) {
      body['turboDurationSec'] = _turboDurationSeconds;
    }
    final response = await _post('/device/mode', body);
    return DeviceControlModeCommandResult(
      turboEndsAt: _parseDateTime(
        response['turboEndsAt'] ?? response['turboEndAt'],
      ),
    );
  }

  Future<void> changePowerState(DevicePowerState state) {
    if (_isThrottled()) return Future<void>.value();
    return _post('/device/state', {'state': state.value});
  }

  Future<Map<String, Object?>> _post(
    String path,
    Map<String, Object> body,
  ) async {
    final token = await _authService.getIdToken();
    if (token == null || token.trim().isEmpty) {
      throw const DeviceControlCommandException(
        DeviceControlCommandError.unauthorized,
      );
    }

    final client = HttpClient();
    try {
      final request = await client.postUrl(_buildUri(path));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.write(jsonEncode(body));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == _okStatusCode) {
        return _decodeResponse(responseBody);
      }
      throw DeviceControlCommandException(_mapStatusCode(response.statusCode));
    } on DeviceControlCommandException {
      rethrow;
    } catch (_) {
      throw const DeviceControlCommandException(
        DeviceControlCommandError.serverError,
      );
    } finally {
      client.close(force: true);
    }
  }

  Uri _buildUri(String path) {
    final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    return Uri.parse(baseUrl).resolve(path);
  }

  bool _isThrottled() {
    final now = DateTime.now();
    final lastCommandAt = _lastCommandAt;
    if (lastCommandAt != null &&
        now.difference(lastCommandAt) < _throttleDuration) {
      return true;
    }
    _lastCommandAt = now;
    return false;
  }

  Map<String, Object?> _decodeResponse(String responseBody) {
    if (responseBody.trim().isEmpty) return const {};
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map) return const {};

    final response = <String, Object?>{};
    for (final entry in decoded.entries) {
      response[entry.key.toString()] = entry.value;
    }
    return response;
  }

  DateTime? _parseDateTime(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  DeviceControlCommandError _mapStatusCode(int statusCode) {
    if (statusCode == _conflictStatusCode) {
      return DeviceControlCommandError.deviceOffline;
    }
    if (statusCode == _unauthorizedStatusCode) {
      return DeviceControlCommandError.unauthorized;
    }
    if (statusCode >= _serverErrorStatusCode) {
      return DeviceControlCommandError.serverError;
    }
    return DeviceControlCommandError.unknown;
  }
}
