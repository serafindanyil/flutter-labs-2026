import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/auth/login_email_page.dart';
import 'package:first_lab/pages/auth/register_password_page.dart';
import 'package:first_lab/shared/constants/app_constants.dart';
import 'package:first_lab/shared/constants/auth_constants.dart';
import 'package:first_lab/shared/widgets/auth_toggle.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:first_lab/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';

class RegisterEmailPage extends StatefulWidget {
  const RegisterEmailPage({super.key});

  @override
  State<RegisterEmailPage> createState() => _RegisterEmailPageState();
}

class _RegisterEmailPageState extends State<RegisterEmailPage> {
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
      MaterialPageRoute<void>(builder: (_) => const RegisterPasswordPage()),
    );
  }

  void _onLoginTap() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginEmailPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Створити акаунт',
      subtitle: 'Приєднайтесь до нас, коли небудь',
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
          text: 'Вже є акаунт? ',
          actionText: 'Увійти',
          onTap: _onLoginTap,
        ),
      ],
    );
  }
}
