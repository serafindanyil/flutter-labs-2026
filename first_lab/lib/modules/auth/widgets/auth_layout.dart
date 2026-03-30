import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/pressable_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final List<Widget> children;

  const AuthLayout({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              if (onBack != null)
                Row(
                  children: [
                    PressableButton(
                      onTap: onBack!,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          LucideIcons.chevronLeft,
                          size: 24,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(height: 48),
              const SizedBox(height: 48),
              Text(title, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(height: 48),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
