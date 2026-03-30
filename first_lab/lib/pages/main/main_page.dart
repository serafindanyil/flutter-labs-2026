import 'package:first_lab/pages/home/home_page.dart';
import 'package:first_lab/pages/statistics/statistics_page.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    StatisticsPage(),
    Scaffold(), 
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E6EC),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _BottomNavItem(
                      icon: Icons.home,
                      isSelected: _currentIndex == 0,
                      onTap: () => _onTabTapped(0),
                    ),
                    _BottomNavItem(
                      icon: Icons.bar_chart,
                      isSelected: _currentIndex == 1,
                      onTap: () => _onTabTapped(1),
                    ),
                    _BottomNavItem(
                      icon: Icons.settings,
                      isSelected: _currentIndex == 2,
                      onTap: () => _onTabTapped(2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            const Icon(Icons.waves, size: 24),
            const SizedBox(width: 8),
            Text(
              'SmartRecu',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(width: 8),
            Text(
              'v 0.1',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText,
                  ),
            ),
            const Spacer(),
            Text(
              'Online',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.blue500,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        size: 32,
        color: isSelected ? AppColors.blue500 : AppColors.blue300,
      ),
    );
  }
}