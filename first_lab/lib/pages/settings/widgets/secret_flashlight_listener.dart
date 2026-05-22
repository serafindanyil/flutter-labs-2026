import 'package:first_lab/modules/secret_flashlight/secret_flashlight_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecretFlashlightListener extends StatelessWidget {
  const SecretFlashlightListener({required this.child, super.key});

  static const String _title = 'Функція недоступна';
  static const String _message =
      'Секретний ліхтарик не підтримується на цій платформі.';
  static const String _action = 'Зрозуміло';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SecretFlashlightCubit()..start(),
      child: BlocListener<SecretFlashlightCubit, SecretFlashlightState>(
        listenWhen: (previous, current) {
          return previous.eventVersion != current.eventVersion &&
              current.status == SecretFlashlightStatus.unsupported;
        },
        listener: _showUnsupportedDialog,
        child: child,
      ),
    );
  }

  void _showUnsupportedDialog(
    BuildContext context,
    SecretFlashlightState state,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(_title),
          content: const Text(_message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(_action),
            ),
          ],
        );
      },
    );
  }
}
