import 'package:first_lab/modules/device_sensors/device_sensors_module.dart';
import 'package:first_lab/modules/statistics/sensor_line_chart.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
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
  static const double _areaOpacity = 0.42;
  static const double _disabledAreaOpacity = 0.28;

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
    final areaOpacity = isDisabled ? _disabledAreaOpacity : _areaOpacity;

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
                      child: SensorLineChart(
                        points: points,
                        minY: minY,
                        defaultMaxY: defaultMaxY,
                        yInterval: yInterval,
                        lineColor: lineColor,
                        areaColor: areaColor,
                        areaOpacity: areaOpacity,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
