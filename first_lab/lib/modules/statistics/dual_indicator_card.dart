import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:flutter/material.dart';

class DualIndicatorCard extends StatelessWidget {
  final String title1;
  final String suffix1;
  final String? value1;
  final String? unit1;
  final String title2;
  final String suffix2;
  final String? value2;
  final String? unit2;
  final bool isDisabled;

  const DualIndicatorCard({
    required this.title1,
    required this.suffix1,
    required this.value1,
    required this.title2,
    required this.suffix2,
    required this.value2,
    this.unit1,
    this.unit2,
    this.isDisabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _IndicatorSubCard(
            title: title1,
            suffix: suffix1,
            value: value1,
            unit: unit1,
            isDisabled: isDisabled,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _IndicatorSubCard(
            title: title2,
            suffix: suffix2,
            value: value2,
            unit: unit2,
            isDisabled: isDisabled,
          ),
        ),
      ],
    );
  }
}

class _IndicatorSubCard extends StatelessWidget {
  final String title;
  final String suffix;
  final String? value;
  final String? unit;
  final bool isDisabled;

  const _IndicatorSubCard({
    required this.title,
    required this.suffix,
    required this.value,
    required this.isDisabled,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.displayMedium),
              Text(
                suffix,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value ?? '-',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: isDisabled ? AppColors.disabled : AppColors.blue500,
                  fontSize: 28,
                ),
              ),
              if (value != null && unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    unit!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDisabled
                          ? AppColors.disabled
                          : AppColors.mutedText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
