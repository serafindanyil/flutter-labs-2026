import 'package:first_lab/shared/constants/auth_constants.dart';
import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:flutter/material.dart';

class PrimaryTextField extends StatefulWidget {
  final String hintText;
  final String? label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final VoidCallback? onFieldSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;

  const PrimaryTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
  });

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  Color get _borderColor {
    if (widget.errorText != null) return AppColors.red;
    if (_isFocused) return AppColors.blue500;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AuthConstants.spacingLabelInput),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor,
              width: _isFocused || widget.errorText != null ? 1.5 : 1,
            ),
            boxShadow: _isFocused && widget.errorText == null
                ? [
                    BoxShadow(
                      color: AppColors.blue500.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                widget.prefixIcon!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  autofocus: widget.autofocus,
                  style: Theme.of(context).textTheme.bodyLarge,
                  cursorColor: AppColors.blue500,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintStyle: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
                  ),
                  onSubmitted: (_) => widget.onFieldSubmitted?.call(),
                ),
              ),
              if (widget.suffixIcon != null) ...[
                const SizedBox(width: 12),
                widget.suffixIcon!,
              ],
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: widget.errorText != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: AppColors.red,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.errorText!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: AppColors.red),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
