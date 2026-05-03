import 'package:flutter/material.dart';

class PressableButton extends StatefulWidget {
  const PressableButton({required this.child, required this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _isPressed = false;

  bool get _isDisabled => widget.onTap == null;

  void _handleTapDown(TapDownDetails details) {
    if (_isDisabled) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isDisabled) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (_isDisabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? 0.6 : 1.0,
        child: widget.child,
      ),
    );
  }
}
