import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:flutter/material.dart';

class DualIndicatorCard extends StatelessWidget {
  final String title1;
  final String suffix1;
  final String value1;
  final String title2;
  final String suffix2;
  final String value2;

  const DualIndicatorCard({
    super.key,
    required this.title1,
    required this.suffix1,
    required this.value1,
    required this.title2,
    required this.suffix2,
    required this.value2,
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
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _IndicatorSubCard(
            title: title2,
            suffix: suffix2,
            value: value2,
          ),
        ),
      ],
    );
  }
}

class _IndicatorSubCard extends StatelessWidget {
  final String title;
  final String suffix;
  final String value;

  const _IndicatorSubCard({
    required this.title,
    required this.suffix,
    required this.value,
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
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppColors.blue500,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
