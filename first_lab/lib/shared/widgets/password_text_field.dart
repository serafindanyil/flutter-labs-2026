import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PasswordTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onFieldSubmitted;

  const PasswordTextField({
    required this.hintText,
    required this.controller,
    this.errorText,
    this.onFieldSubmitted,
    super.key,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscured = true;

  void _toggleObscured() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    return PrimaryTextField(
      hintText: widget.hintText,
      controller: widget.controller,
      obscureText: _obscured,
      errorText: widget.errorText,
      onFieldSubmitted: widget.onFieldSubmitted,
      suffixIcon: GestureDetector(
        onTap: _toggleObscured,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            _obscured ? LucideIcons.eye : LucideIcons.eyeOff,
            color: AppColors.mutedText,
            size: 20,
          ),
        ),
      ),
    );
  }
}
