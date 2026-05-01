import 'dart:math' as math;

import 'package:equatable/equatable.dart';

class DeviceSensorsState extends Equatable {
  const DeviceSensorsState({
    this.co2,
    this.humidity,
    this.innerTemp,
    this.outerTemp,
    this.fanInSpd,
    this.fanOutSpd,
  });

  static const num invalidTemperatureValue = -127;
  static const num invalidZeroValue = 0;
  static const int maxEfficiencyPercent = 100;

  final num? co2;
  final num? humidity;
  final num? innerTemp;
  final num? outerTemp;
  final num? fanInSpd;
  final num? fanOutSpd;

  int? get efficiencyPercent {
    final inner = innerTemp;
    final outer = outerTemp;
    if (inner == null || outer == null) return null;

    final maxTemp = math.max(inner.abs(), outer.abs());
    if (maxTemp == 0) return null;

    final minTemp = math.min(inner.abs(), outer.abs());
    return ((minTemp / maxTemp) * maxEfficiencyPercent)
        .round()
        .clamp(0, maxEfficiencyPercent)
        .toInt();
  }

  @override
  List<Object?> get props => [
    co2,
    humidity,
    innerTemp,
    outerTemp,
    fanInSpd,
    fanOutSpd,
    efficiencyPercent,
  ];
}
