import 'dart:math' as math;

import 'package:first_lab/modules/device_sensors/device_sensors_module.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorChartCard extends StatelessWidget {
  const SensorChartCard({
    required this.title,
    required this.unit,
    required this.points,
    required this.minY,
    required this.defaultMaxY,
    required this.yInterval,
    required this.isDisabled,
    super.key,
  });

  static const double _height = 188;
  static const double _chartHeight = 128;
  static const double _lineWidth = 2.2;
  static const double _leftTitleWidth = 38;
  static const double _gridStrokeWidth = 0.8;
  static const double _areaOpacity = 0.42;
  static const double _disabledAreaOpacity = 0.28;
  static const List<int> _gridDashArray = [3, 4];

  final String title;
  final String unit;
  final List<DeviceSensorHistoryPoint> points;
  final double minY;
  final double defaultMaxY;
  final double yInterval;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final lineColor = isDisabled ? AppColors.disabled : AppColors.blue500;
    final areaColor = isDisabled ? AppColors.gray200 : AppColors.blue100;
    final maxY = _maxY;

    return PrimaryContainer(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: SizedBox(
        height: _height,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.displayMedium),
                Text(
                  unit,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: points.isEmpty
                  ? Center(
                      child: Text(
                        '-',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: isDisabled
                                  ? AppColors.disabled
                                  : AppColors.blue500,
                            ),
                      ),
                    )
                  : SizedBox(
                      height: _chartHeight,
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: math.max(points.length - 1, 1).toDouble(),
                          minY: minY,
                          maxY: maxY,
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
                                color: areaColor.withValues(
                                  alpha: isDisabled
                                      ? _disabledAreaOpacity
                                      : _areaOpacity,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
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
    if (value <= minY || value > meta.max) {
      return const SizedBox.shrink();
    }

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
