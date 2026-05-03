class RealtimeRetryPolicy {
  const RealtimeRetryPolicy();

  static const List<Duration> _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 16),
    Duration(seconds: 30),
  ];

  Duration delay(int attempt) {
    final index = attempt - 1;
    if (index < _retryDelays.length) return _retryDelays[index];
    return _retryDelays.last;
  }
}
