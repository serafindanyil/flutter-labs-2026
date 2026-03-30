import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 120),
      child: Center(
        child: Text(
          'Сторінка ще в розробці',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
