import 'dart:convert';
import 'dart:io';

import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/modules/device_sensors/models/device_sensor_history_point.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum DeviceSensorsHistoryError { unauthorized, serverError, unknown }

class DeviceSensorsHistoryException implements Exception {
  const DeviceSensorsHistoryException(this.error);

  final DeviceSensorsHistoryError error;
}

class DeviceSensorsHistoryService {
  DeviceSensorsHistoryService({required AuthService authService})
    : _authService = authService;

  static const int _okStatusCode = 200;
  static const int _unauthorizedStatusCode = 401;
  static const int _serverErrorStatusCode = 500;
  static const int defaultLimit = 20;

  final AuthService _authService;

  Future<DeviceSensorsHistoryData> getHistory({
    int limit = defaultLimit,
  }) async {
    final token = await _authService.getIdToken();
    if (token == null || token.trim().isEmpty) {
      throw const DeviceSensorsHistoryException(
        DeviceSensorsHistoryError.unauthorized,
      );
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(_buildUri(limit));
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == _okStatusCode) {
        return _decodeResponse(responseBody);
      }

      throw DeviceSensorsHistoryException(_mapStatusCode(response.statusCode));
    } on DeviceSensorsHistoryException {
      rethrow;
    } catch (_) {
      throw const DeviceSensorsHistoryException(
        DeviceSensorsHistoryError.serverError,
      );
    } finally {
      client.close(force: true);
    }
  }

  Uri _buildUri(int limit) {
    final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    return Uri.parse(
      baseUrl,
    ).resolve('/sensors/history').replace(queryParameters: {'limit': '$limit'});
  }

  DeviceSensorsHistoryData _decodeResponse(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return const DeviceSensorsHistoryData.empty();
    }

    final Object? decoded = jsonDecode(responseBody);
    if (decoded is! Map<Object?, Object?>) {
      return const DeviceSensorsHistoryData.empty();
    }

    return DeviceSensorsHistoryData(
      co2: _parsePoints(decoded['co2'], 'co2'),
      humidity: _parsePoints(decoded['humidity'], 'humidity'),
    );
  }

  List<DeviceSensorHistoryPoint> _parsePoints(Object? value, String field) {
    if (value is! List<Object?>) return const [];

    final points = <DeviceSensorHistoryPoint>[];
    for (final item in value) {
      if (item is! Map<Object?, Object?>) continue;
      final pointValue = item[field];
      final timestamp = item['timestamp'];
      if (pointValue is! num || !pointValue.isFinite) continue;
      if (timestamp is! String || timestamp.trim().isEmpty) continue;
      points.add(
        DeviceSensorHistoryPoint(
          value: pointValue,
          timestamp: timestamp.trim(),
        ),
      );
    }

    return points.reversed.toList(growable: false);
  }

  DeviceSensorsHistoryError _mapStatusCode(int statusCode) {
    if (statusCode == _unauthorizedStatusCode) {
      return DeviceSensorsHistoryError.unauthorized;
    }
    if (statusCode >= _serverErrorStatusCode) {
      return DeviceSensorsHistoryError.serverError;
    }
    return DeviceSensorsHistoryError.unknown;
  }
}
