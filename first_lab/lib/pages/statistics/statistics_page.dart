import 'package:first_lab/modules/statistics/statistics_module.dart';
import 'package:first_lab/shared/network/bloc/mqtt_cubit.dart';
import 'package:first_lab/shared/network/bloc/mqtt_state.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
      children: [
        Text('Показники', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 24),
        BlocBuilder<MqttCubit, MqttState>(
          builder: (context, state) {
            final co2Value = state.co2Value;
            final int? co2Int = co2Value != null
                ? int.tryParse(co2Value)
                : null;
            String status = 'Невідомо';
            Color statusColor = AppColors.mutedText;

            if (co2Int != null) {
              if (co2Int < 800) {
                status = 'Нормально';
                statusColor = AppColors.success;
              } else if (co2Int < 1200) {
                status = 'Задовільно';
                statusColor = AppColors.yellow;
              } else {
                status = 'Дуже погано';
                statusColor = AppColors.red;
              }
            }

            return IndicatorCard(
              title: 'Рівень CO₂',
              value: co2Value,
              unit: 'ppm',
              status: status,
              statusColor: statusColor,
            );
          },
        ),
        // const SizedBox(height: 16),
        // const IndicatorCard(
        //   title: 'Вологість',
        //   value: '50',
        //   unit: '%',
        //   status: 'Нормально',
        //   statusColor: AppColors.yellow,
        // ),
        // const SizedBox(height: 16),
        // const IndicatorCard(
        //   title: 'Оберти вентиляторів',
        //   value: '2800',
        //   unit: 'rpm',
        // ),
        // const SizedBox(height: 16),
        // const IndicatorCard(
        //   title: 'ККД рекуператора',
        //   value: '60',
        //   unit: '%',
        // ),
        // const SizedBox(height: 16),
        // const DualIndicatorCard(
        //   title1: 'Темп',
        //   suffix1: 'Вхідна',
        //   value1: '12',
        //   unit1: '°C',
        //   title2: 'Темп',
        //   suffix2: 'Вихідна',
        //   value2: '20',
        //   unit2: '°C',
        // ),
      ],
    );
  }
}
