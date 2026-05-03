import 'dart:io';

import 'package:flutter/services.dart';

class ShakeFlashlightUnsupportedException implements Exception {
  const ShakeFlashlightUnsupportedException();

  @override
  String toString() {
    return 'Flashlight is unsupported on this platform';
  }
}

class ShakeFlashlightPlugin {
  const ShakeFlashlightPlugin._();

  static const MethodChannel _channel = MethodChannel(
    'shake_flashlight_plugin',
  );
  static const String _toggleLightMethod = 'toggleLight';

  static Future<bool> toggleLight() async {
    if (!Platform.isAndroid) {
      throw const ShakeFlashlightUnsupportedException();
    }

    final result = await _channel.invokeMethod<bool>(_toggleLightMethod);
    return result ?? false;
  }
}
