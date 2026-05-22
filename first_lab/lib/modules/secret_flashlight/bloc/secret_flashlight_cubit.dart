import 'dart:async';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:first_lab/modules/secret_flashlight/bloc/secret_flashlight_state.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shake_flashlight_plugin/shake_flashlight_plugin.dart';

class SecretFlashlightCubit extends Cubit<SecretFlashlightState> {
  SecretFlashlightCubit() : super(const SecretFlashlightState());

  static const double _shakeThreshold = 22;
  static const Duration _cooldown = Duration(milliseconds: 1200);

  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastToggleAt;
  bool _isToggling = false;

  void start() {
    _subscription ??= accelerometerEventStream().listen(_handleEvent);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handleEvent(AccelerometerEvent event) async {
    if (!_isShake(event) || !_canToggle) return;

    _lastToggleAt = DateTime.now();
    _isToggling = true;

    try {
      final isEnabled = await ShakeFlashlightPlugin.toggleLight();
      _emitEvent(SecretFlashlightStatus.toggled, isEnabled: isEnabled);
    } on ShakeFlashlightUnsupportedException {
      _emitEvent(SecretFlashlightStatus.unsupported);
    } on MissingPluginException {
      _emitEvent(SecretFlashlightStatus.unsupported);
    } catch (_) {
      _emitEvent(SecretFlashlightStatus.failure);
    } finally {
      _isToggling = false;
    }
  }

  bool _isShake(AccelerometerEvent event) {
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    return magnitude > _shakeThreshold;
  }

  bool get _canToggle {
    if (_isToggling) return false;

    final lastToggleAt = _lastToggleAt;
    if (lastToggleAt == null) return true;

    return DateTime.now().difference(lastToggleAt) >= _cooldown;
  }

  void _emitEvent(SecretFlashlightStatus status, {bool? isEnabled}) {
    emit(
      state.copyWith(
        status: status,
        isEnabled: isEnabled,
        eventVersion: state.eventVersion + 1,
      ),
    );
  }

  @override
  Future<void> close() async {
    await stop();
    return super.close();
  }
}
