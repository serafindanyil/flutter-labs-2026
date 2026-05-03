import 'package:first_lab/shared/network/widgets/disabled_wrapper.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/styles/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LayoutNavBar extends StatelessWidget {
  const LayoutNavBar({
    required this.currentIndex,
    required this.onTabTapped,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: AppShadows.button,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomNavItem(
                icon: LucideIcons.house,
                isSelected: currentIndex == 0,
                onTap: () => onTabTapped(0),
              ),
              _BottomNavItem(
                icon: LucideIcons.chartColumnBig,
                isSelected: currentIndex == 1,
                onTap: () => onTabTapped(1),
              ),
              _BottomNavItem(
                icon: LucideIcons.settings,
                isSelected: currentIndex == 2,
                onTap: () => onTabTapped(2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = Disabled.of(context);
    final color = isDisabled
        ? (isSelected ? AppColors.disabledAccent : AppColors.disabled)
        : (isSelected ? AppColors.blue500 : AppColors.blue300);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, size: 32, color: color),
    );
  }
}
