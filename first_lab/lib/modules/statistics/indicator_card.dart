import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_container.dart';
import 'package:flutter/material.dart';

class IndicatorCard extends StatelessWidget {
  final String title;
  final String value;
  final String? status;
  final Color? statusColor;

  const IndicatorCard({
    super.key,
    required this.title,
    required this.value,
    this.status,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.displayMedium),
              if (status != null)
                Text(
                  status!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: statusColor ?? AppColors.mutedText,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppColors.blue500,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}
