import 'package:first_lab/modules/auth/auth_provider.dart';
import 'package:first_lab/modules/auth/models/user_model.dart';
import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/layout/layout.dart';
import 'package:first_lab/shared/constants/auth_constants.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:first_lab/shared/widgets/password_text_field.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class RegisterPasswordPage extends StatefulWidget {
  final String name;
  final String email;

  const RegisterPasswordPage({
    required this.name,
    required this.email,
    super.key,
  });

  @override
  State<RegisterPasswordPage> createState() => _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends State<RegisterPasswordPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _errorText;
  String? _confirmErrorText;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    setState(() {
      _errorText = null;
      _confirmErrorText = null;
    });

    final password = _controller.text;
    final confirmPassword = _confirmController.text;
    bool hasError = false;

    if (password.isEmpty) {
      setState(() => _errorText = 'Пароль не може бути порожнім');
      hasError = true;
    } else if (password.length < AuthConstants.minPasswordLength) {
      setState(
        () =>
            _errorText = 'Мінімум ${AuthConstants.minPasswordLength} символів',
      );
      hasError = true;
    }

    if (password != confirmPassword) {
      setState(() => _confirmErrorText = 'Паролі не співпадають');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final user = UserModel(
        name: widget.name,
        email: widget.email,
        password: password,
      );
      await AuthProvider.repository.register(user);

      if (!mounted) return;
      AppToast.success(context, 'Успішна реєстрація!');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const Layout()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      AppToast.error(context, 'Помилка реєстрації. Спробуйте пізніше.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Придумайте пароль',
      subtitle: 'Створіть надійний пароль',
      onBack: () => Navigator.of(context).pop(),
      children: [
        Text('Пароль', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AuthConstants.spacingXXSmall),
        PasswordTextField(
          hintText: 'Мінімум ${AuthConstants.minPasswordLength} символів',
          controller: _controller,
          errorText: _errorText,
        ),
        const SizedBox(height: AuthConstants.spacingMedium),
        Text(
          'Повторіть пароль',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AuthConstants.spacingXXSmall),
        PasswordTextField(
          hintText: 'Повторіть свій пароль',
          controller: _confirmController,
          errorText: _confirmErrorText,
          onFieldSubmitted: _onNext,
        ),
        const SizedBox(height: AuthConstants.spacingLarge),
        PrimaryButton(
          title: 'Зареєструватись',
          onTap: _onNext,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
