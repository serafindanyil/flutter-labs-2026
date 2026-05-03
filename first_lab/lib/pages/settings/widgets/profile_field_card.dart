import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileFieldCard extends StatelessWidget {
  const ProfileFieldCard({
    required this.label,
    required this.child,
    this.trailing,
    this.hasStaticChildHeight = false,
    super.key,
  });

  final String label;
  final Widget child;
  final Widget? trailing;
  final bool hasStaticChildHeight;

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      children: [
        Expanded(child: child),
        if (trailing != null) ...[const SizedBox(width: 16), trailing!],
      ],
    );

    if (hasStaticChildHeight) {
      content = SizedBox(height: 60, child: content);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
