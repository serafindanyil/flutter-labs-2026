import 'package:first_lab/modules/device_sensors/device_sensors_module.dart';
import 'package:first_lab/modules/statistics/statistics_module.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:flutter/material.dart';

class SensorIndicatorsList extends StatelessWidget {
  const SensorIndicatorsList({
    required this.isDisabled,
    required this.sensorsState,
    required this.historyData,
    super.key,
  });

  final bool isDisabled;
  final DeviceSensorsState sensorsState;
  final DeviceSensorsHistoryData historyData;

  @override
  Widget build(BuildContext context) {
    final co2Status = _co2Status(sensorsState.co2);

    return ListView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
      children: [
        Text('Показники', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 24),
        IndicatorCard(
          title: 'Рівень CO₂',
          value: _formatNumber(sensorsState.co2),
          unit: 'ppm',
          status: co2Status.text,
          statusColor: co2Status.color,
          isDisabled: isDisabled,
        ),
        const SizedBox(height: 16),
        SensorChartCard(
          title: 'Графік CO₂',
          unit: 'ppm',
          points: historyData.co2,
          minY: 0,
          defaultMaxY: 1000,
          yInterval: 250,
          isDisabled: isDisabled,
        ),
        const SizedBox(height: 16),
        IndicatorCard(
          title: 'Вологість',
          value: _formatNumber(sensorsState.humidity),
          unit: '%',
          isDisabled: isDisabled,
        ),
        const SizedBox(height: 16),
        SensorChartCard(
          title: 'Графік вологості',
          unit: '%',
          points: historyData.humidity,
          minY: 0,
          defaultMaxY: 60,
          yInterval: 15,
          isDisabled: isDisabled,
        ),
        const SizedBox(height: 16),
        IndicatorCard(
          title: 'Внутр. вентилятор',
          value: _formatNumber(sensorsState.fanInSpd),
          unit: '%',
          isDisabled: isDisabled,
        ),
        const SizedBox(height: 16),
        IndicatorCard(
          title: 'Зовн. вентилятор',
          value: _formatNumber(sensorsState.fanOutSpd),
          unit: '%',
          isDisabled: isDisabled,
        ),
        const SizedBox(height: 16),
        IndicatorCard(
          title: 'ККД рекуператора',
          value: _formatNumber(sensorsState.efficiencyPercent),
          unit: '%',
          isDisabled: isDisabled,
        ),
        const SizedBox(height: 16),
        DualIndicatorCard(
          title1: 'Темп',
          suffix1: 'Вхідна',
          value1: _formatNumber(sensorsState.innerTemp),
          unit1: '°C',
          title2: 'Темп',
          suffix2: 'Вихідна',
          value2: _formatNumber(sensorsState.outerTemp),
          unit2: '°C',
          isDisabled: isDisabled,
        ),
      ],
    );
  }

  String? _formatNumber(num? value) {
    if (value == null) return null;
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  _SensorStatus _co2Status(num? value) {
    if (value == null) {
      return const _SensorStatus('Невідомо', AppColors.mutedText);
    }
    if (value < 800) {
      return const _SensorStatus('Нормально', AppColors.success);
    }
    if (value < 1200) {
      return const _SensorStatus('Задовільно', AppColors.warning);
    }
    if (value < 3000) {
      return const _SensorStatus('Погано', AppColors.danger);
    }
    return const _SensorStatus('Дуже погано', AppColors.danger);
  }
}

class _SensorStatus {
  const _SensorStatus(this.text, this.color);

  final String text;
  final Color color;
}
