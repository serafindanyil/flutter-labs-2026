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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _nameErrorText;
  String? _emailErrorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onNext() {
    setState(() {
      _nameErrorText = null;
      _emailErrorText = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    bool hasError = false;

    if (name.isEmpty) {
      setState(() => _nameErrorText = 'Ім\'я не може бути порожнім');
      hasError = true;
    } else if (RegExp(r'\d').hasMatch(name)) {
      setState(() => _nameErrorText = 'Ім\'я не може містити цифри');
      hasError = true;
    }

    if (email.isEmpty) {
      setState(() => _emailErrorText = 'Емейл не може бути порожнім');
      hasError = true;
    } else if (!RegExp(AppConstants.emailRegex).hasMatch(email)) {
      setState(() => _emailErrorText = 'Невірний формат емейлу');
      hasError = true;
    }

    if (hasError) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegisterPasswordPage(name: name, email: email),
      ),
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
        Text(
          'Введіть ваше ім\'я',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AuthConstants.spacingXXSmall),
        PrimaryTextField(
          hintText: 'Ім\'я',
          controller: _nameController,
          errorText: _nameErrorText,
          keyboardType: TextInputType.name,
          onFieldSubmitted: _onNext,
        ),
        const SizedBox(height: AuthConstants.spacingMedium),
        Text('Емейл', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AuthConstants.spacingXXSmall),
        PrimaryTextField(
          hintText: 'example@mail.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailErrorText,
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
