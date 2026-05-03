import 'dart:math' as math;

import 'package:first_lab/modules/device_sensors/device_sensors_module.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorLineChart extends StatelessWidget {
  const SensorLineChart({
    required this.points,
    required this.minY,
    required this.defaultMaxY,
    required this.yInterval,
    required this.lineColor,
    required this.areaColor,
    required this.areaOpacity,
    super.key,
  });

  static const double _leftTitleWidth = 38;
  static const double _gridStrokeWidth = 0.8;
  static const double _lineWidth = 2.2;
  static const List<int> _gridDashArray = [3, 4];

  final List<DeviceSensorHistoryPoint> points;
  final double minY;
  final double defaultMaxY;
  final double yInterval;
  final Color lineColor;
  final Color areaColor;
  final double areaOpacity;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: math.max(points.length - 1, 1).toDouble(),
        minY: minY,
        maxY: _maxY,
        gridData: FlGridData(
          horizontalInterval: yInterval,
          verticalInterval: _verticalInterval,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.gray100,
            strokeWidth: _gridStrokeWidth,
            dashArray: _gridDashArray,
          ),
          getDrawingVerticalLine: (_) => const FlLine(
            color: AppColors.gray100,
            strokeWidth: _gridStrokeWidth,
            dashArray: _gridDashArray,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: _leftTitleWidth,
              interval: yInterval,
              getTitlesWidget: _leftTitle,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: _spots,
            isCurved: true,
            color: lineColor,
            barWidth: _lineWidth,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: areaColor.withValues(alpha: areaOpacity),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> get _spots {
    return points.indexed
        .map((entry) => FlSpot(entry.$1.toDouble(), entry.$2.value.toDouble()))
        .toList(growable: false);
  }

  double get _maxY {
    final valueMax = points.fold<double>(
      defaultMaxY,
      (max, point) => math.max(max, point.value.toDouble()),
    );

    return (valueMax / yInterval).ceil() * yInterval;
  }

  double get _verticalInterval {
    return math.max(1, (points.length - 1) / 5);
  }

  Widget _leftTitle(double value, TitleMeta meta) {
    if (value <= minY || value > meta.max) return const SizedBox.shrink();

    return Text(
      value.toInt().toString(),
      style: const TextStyle(
        color: AppColors.mutedText,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
