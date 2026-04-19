import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/modules/auth/utils/auth_network_checker.dart';
import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/auth/login_email_page.dart';
import 'package:first_lab/pages/auth/register_password_page.dart';
import 'package:first_lab/shared/constants/app_constants.dart';
import 'package:first_lab/shared/constants/auth_constants.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:first_lab/shared/widgets/auth_toggle.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:first_lab/shared/widgets/primary_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
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

    if (!context.hasNetworkAccess) return;

    setState(() => _isLoading = true);

    // Check if email is already taken
    final authService = context.read<AuthService>();
    final exists = await authService.checkEmailExists(email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (exists) {
      AppToast.error(context, 'Цей емейл вже зайнятий');
      return;
    }

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
        PrimaryButton(
          title: 'Продовжити',
          onTap: _onNext,
          isLoading: _isLoading,
        ),
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
