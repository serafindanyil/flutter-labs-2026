import 'package:first_lab/shared/styles/app_colors.dart';
import 'package:first_lab/shared/styles/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

enum ToastType { success, error }

class AppToast {
  static String? _lastMessage;
  static DateTime? _lastTime;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.error,
    Duration duration = const Duration(seconds: 3),
  }) {
    final now = DateTime.now();
    if (_lastMessage == message && _lastTime != null) {
      if (now.difference(_lastTime!) < duration) {
        return;
      }
    }
    _lastMessage = message;
    _lastTime = now;

    final backgroundColor = type == ToastType.error
        ? AppColors.danger
        : AppColors.success;

    final icon = type == ToastType.error
        ? LucideIcons.triangleAlert
        : LucideIcons.check;

    toastification.show(
      context: context,
      title: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      type: type == ToastType.error
          ? ToastificationType.error
          : ToastificationType.success,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: duration,
      icon: Icon(icon, color: AppColors.white, size: 20),
      primaryColor: backgroundColor,
      backgroundColor: backgroundColor,
      foregroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      sizeConstraints: const BoxConstraints(minHeight: 0, minWidth: 300),
      borderRadius: BorderRadius.circular(12),
      boxShadow: AppShadows.button,
      showProgressBar: false,
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      dragToClose: true,
      dismissDirection: DismissDirection.down,
      animationDuration: const Duration(milliseconds: 300),
      applyBlurEffect: false,
      closeButtonShowType: CloseButtonShowType.none,
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, 1), // Slide from bottom
                end: const Offset(0, 0),
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                  reverseCurve: Curves.easeIn,
                ),
              ),
          child: child,
        );
      },
    );
  }

  static void error(BuildContext context, String message) =>
      show(context, message: message);

  static void success(BuildContext context, String message) =>
      show(context, message: message, type: ToastType.success);
}
