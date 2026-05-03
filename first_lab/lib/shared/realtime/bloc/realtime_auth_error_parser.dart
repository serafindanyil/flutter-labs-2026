class RealtimeAuthErrorParser {
  const RealtimeAuthErrorParser();

  static const Set<String> _authErrorCodes = {
    'auth/missing-bearer',
    'auth/id-token-expired',
    'auth/id-token-invalid',
  };

  bool isAuthError(Object? error) {
    final code = _extractAuthErrorCode(error);
    return code != null && _authErrorCodes.contains(code);
  }

  String? _extractAuthErrorCode(Object? error) {
    final payload = _parsePayload(error);
    final code = payload?['code'];
    if (code is String) return code;

    final data = payload?['data'];
    final dataPayload = _parsePayload(data);
    final dataCode = dataPayload?['code'];
    if (dataCode is String) return dataCode;

    return null;
  }

  Map<String, Object?>? _parsePayload(Object? data) {
    if (data is Map<String, Object?>) return data;
    if (data is Map<Object?, Object?>) {
      final payload = <String, Object?>{};
      for (final entry in data.entries) {
        payload[entry.key.toString()] = entry.value;
      }
      return payload;
    }
    return null;
  }
}
