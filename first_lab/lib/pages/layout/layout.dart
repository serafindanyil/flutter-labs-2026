import 'package:first_lab/pages/home/home_page.dart';
import 'package:first_lab/pages/settings/settings_page.dart';
import 'package:first_lab/pages/statistics/statistics_page.dart';
import 'package:first_lab/shared/network/widgets/disabled_wrapper.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/styles/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    StatisticsPage(),
    SettingsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFE2E6EC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.zero,
          child: Disabled(
            isDisabled: Disabled.of(context),
            child: _NavBar(
              currentIndex: _currentIndex,
              onTabTapped: _onTabTapped,
              disabled: Disabled.of(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.currentIndex,
    required this.onTabTapped,
    this.disabled = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTabTapped;
  final bool disabled;

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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final isDisabled = Disabled.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue100.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.waves, size: 24),
            const SizedBox(width: 8),
            Text('SmartRecu', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(width: 8),
            Text(
              'v 0.1',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            const Spacer(),
            Text(
              isDisabled ? 'Offline' : 'Online',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDisabled ? AppColors.danger : AppColors.blue500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = Disabled.of(context);
    final color = isDisabled
        ? AppColors.gray400
        : (isSelected ? AppColors.blue500 : AppColors.blue300);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, size: 32, color: color),
    );
  }
}
