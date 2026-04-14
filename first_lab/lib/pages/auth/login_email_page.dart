import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/auth/login_password_page.dart';
import 'package:first_lab/pages/auth/register_email_page.dart';
import 'package:first_lab/shared/constants/app_constants.dart';
import 'package:first_lab/shared/constants/auth_constants.dart';
import 'package:first_lab/shared/widgets/auth_toggle.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:first_lab/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';

class LoginEmailPage extends StatefulWidget {
  const LoginEmailPage({super.key});

  @override
  State<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    setState(() => _errorText = null);
    final email = _controller.text.trim();

    if (email.isEmpty) {
      setState(() => _errorText = 'Емейл не може бути порожнім');
      return;
    }

    if (!RegExp(AppConstants.emailRegex).hasMatch(email)) {
      setState(() => _errorText = 'Невірний формат емейлу');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LoginPasswordPage(email: email)),
    );
  }

  void _onRegisterTap() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RegisterEmailPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'З поверненням!',
      subtitle: 'Отримайте доступ до свого акаунту',
      children: [
        Text('Емейл', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AuthConstants.spacingSmall),
        PrimaryTextField(
          hintText: 'example@mail.com',
          controller: _controller,
          keyboardType: TextInputType.emailAddress,
          errorText: _errorText,
          onFieldSubmitted: _onNext,
        ),
        const SizedBox(height: AuthConstants.spacingLarge),
        PrimaryButton(title: 'Продовжити', onTap: _onNext),
        const SizedBox(height: AuthConstants.spacingMedium),
        AuthToggle(
          text: 'Немає акаунту? ',
          actionText: 'Зареєструватись',
          onTap: _onRegisterTap,
        ),
      ],
    );
  }
}
