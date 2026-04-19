import 'package:flutter/widgets.dart';

class Disabled extends InheritedWidget {
  const Disabled({required this.isDisabled, required super.child, super.key});

  final bool isDisabled;

  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Disabled>()?.isDisabled ??
        false;
  }

  @override
  bool updateShouldNotify(Disabled oldWidget) {
    return isDisabled != oldWidget.isDisabled;
  }
}
