import 'package:first_lab/modules/home/home_module.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, String? title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DeviceMode _currentMode = DeviceMode.manual;
  bool _isOn = true;

  void _onModeChanged(DeviceMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  void _onToggleState(bool isOn) {
    setState(() {
      _isOn = isOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Text(
          'Керування',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 24),
        ModeWidget(
          mode: _currentMode,
          onModeChanged: _onModeChanged,
        ),
        const SizedBox(height: 16),
        StateWidget(
          isOn: _isOn,
          onToggle: _onToggleState,
        ),
        const SizedBox(height: 32),
        Text(
          'Термінові сповіщення',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 16),
        const EmergencyNotification(
          title: 'Перевищено рівень CO2',
          icon: Icons.cloud,
        ),
        const SizedBox(height: 16),
        const EmergencyNotification(
          title: 'Велика різниця температур',
          icon: Icons.thermostat,
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
