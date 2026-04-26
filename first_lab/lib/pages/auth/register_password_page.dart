import 'package:first_lab/modules/auth/bloc/auth_bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_event.dart';
import 'package:first_lab/modules/auth/bloc/auth_state.dart';
import 'package:first_lab/modules/auth/utils/auth_network_checker.dart';
import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/layout/layout.dart';
import 'package:first_lab/shared/constants/auth_constants.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:first_lab/shared/widgets/password_text_field.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onNext() {
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

    if (!context.hasNetworkAccess) return;

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        name: widget.name,
        email: widget.email,
        password: password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          AppToast.error(context, state.error);
        } else if (state is AuthSuccess) {
          AppToast.success(context, 'Успішна реєстрація!');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const Layout()),
            (_) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthInProgress;

          return AuthLayout(
            title: 'Придумайте\nнадійний пароль',
            subtitle: 'Ваша безпека - понад усе!',
            onBack: () => Navigator.of(context).pop(),
            children: [
              PasswordTextField(
                hintText: 'Придумайте пароль',
                controller: _controller,
                errorText: _errorText,
              ),
              const SizedBox(height: 16),
              PasswordTextField(
                hintText: 'Повторіть пароль',
                controller: _confirmController,
                errorText: _confirmErrorText,
                onFieldSubmitted: _onNext,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                title: 'Створити акаунт',
                onTap: _onNext,
                isLoading: isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}
