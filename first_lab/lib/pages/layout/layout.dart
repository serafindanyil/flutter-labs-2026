import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/pages/home/home_page.dart';
import 'package:first_lab/pages/layout/bloc/layout_cubit.dart';
import 'package:first_lab/pages/layout/widgets/layout_header.dart';
import 'package:first_lab/pages/layout/widgets/layout_nav_bar.dart';
import 'package:first_lab/pages/settings/settings_page.dart';
import 'package:first_lab/pages/statistics/statistics_page.dart';
import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
import 'package:first_lab/shared/network/widgets/disabled_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Layout extends StatelessWidget {
  const Layout({super.key});

  static const List<Widget> _pages = [
    HomePage(),
    StatisticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LayoutCubit(),
      child: BlocBuilder<LayoutCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            extendBody: true,
            backgroundColor: const Color(0xFFE2E6EC),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const LayoutHeader(),
                  Expanded(child: _pages[currentIndex]),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: _DisabledNavBar(currentIndex: currentIndex),
            ),
          );
        },
      ),
    );
  }
}

class _DisabledNavBar extends StatelessWidget {
  const _DisabledNavBar({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, networkState) {
        return BlocBuilder<DeviceControlCubit, DeviceControlState>(
          builder: (context, deviceControlState) {
            final isDisabled = DeviceControlAvailability.isDisabled(
              networkStatus: networkState.status,
              deviceControl: deviceControlState,
            );

            return Disabled(
              isDisabled: isDisabled,
              child: LayoutNavBar(
                currentIndex: currentIndex,
                onTabTapped: context.read<LayoutCubit>().selectTab,
              ),
            );
          },
        );
      },
    );
  }
}
