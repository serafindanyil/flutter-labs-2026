import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/auth/login_password_page.dart';
import 'package:first_lab/pages/auth/register_email_page.dart';
import 'package:first_lab/shared/constants/app_constants.dart';
import 'package:first_lab/shared/constants/auth_constants.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:first_lab/shared/widgets/auth_toggle.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:first_lab/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginEmailPage extends StatefulWidget {
  const LoginEmailPage({super.key});

  @override
  State<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
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
    final email = _controller.text.trim();

    if (email.isEmpty) {
      setState(() => _errorText = 'Емейл не може бути порожнім');
      return;
    }

    if (!RegExp(AppConstants.emailRegex).hasMatch(email)) {
      setState(() => _errorText = 'Невірний формат емейлу');
      return;
    }

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final exists = await authService.checkEmailExists(email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!exists) {
      AppToast.error(context, 'Акаунт не знайдено');
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
        const SizedBox(height: AuthConstants.spacingXXSmall),
        PrimaryTextField(
          hintText: 'example@mail.com',
          controller: _controller,
          keyboardType: TextInputType.emailAddress,
          errorText: _errorText,
          onFieldSubmitted: _onNext,
        ),
        const SizedBox(height: AuthConstants.spacingLarge),
        PrimaryButton(
          title: 'Продовжити',
          onTap: _onNext,
          isLoading: _isLoading,
        ),
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
