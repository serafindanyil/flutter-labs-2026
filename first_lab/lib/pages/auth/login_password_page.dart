import 'package:first_lab/modules/auth/auth_provider.dart';
import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/layout/layout.dart';
import 'package:first_lab/shared/constants/auth_constants.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:first_lab/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';

class LoginPasswordPage extends StatefulWidget {
  final String email;

  const LoginPasswordPage({required this.email, super.key});

  @override
  State<LoginPasswordPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<LoginPasswordPage> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    setState(() => _errorText = null);
    final password = _controller.text;

    if (password.isEmpty) {
      setState(() => _errorText = 'Пароль не може бути порожнім');
      return;
    }

    if (password.length < AuthConstants.minPasswordLength) {
      setState(
        () =>
            _errorText = 'Мінімум ${AuthConstants.minPasswordLength} символів',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthProvider.repository.login(widget.email, password);

      if (!mounted) return;

      if (user != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const Layout()),
          (_) => false,
        );
      } else {
        setState(() {
          _errorText = 'Невірний емейл або пароль';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Помилка входу: перевірте ваші дані')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Сталася помилка';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Авторизація',
      subtitle: 'Введіть ваш пароль',
      onBack: () => Navigator.of(context).pop(),
      children: [
        Text('Пароль', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AuthConstants.spacingXXSmall),
        PrimaryTextField(
          hintText: 'Ваш пароль',
          controller: _controller,
          obscureText: true,
          errorText: _errorText,
          onFieldSubmitted: _onNext,
        ),
        const SizedBox(height: AuthConstants.spacingLarge),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          PrimaryButton(title: 'Увійти', onTap: _onNext),
      ],
    );
  }
}
