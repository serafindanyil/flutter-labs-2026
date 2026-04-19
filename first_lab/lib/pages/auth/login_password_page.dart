import 'package:first_lab/modules/auth/bloc/auth_bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_event.dart';
import 'package:first_lab/modules/auth/bloc/auth_state.dart';
import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/layout/layout.dart';
import 'package:first_lab/shared/constants/auth_constants.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:first_lab/shared/widgets/password_text_field.dart';
import 'package:first_lab/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPasswordPage extends StatefulWidget {
  final String email;

  const LoginPasswordPage({required this.email, super.key});

  @override
  State<LoginPasswordPage> createState() => _LoginPasswordPageState();
}

class _LoginPasswordPageState extends State<LoginPasswordPage> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
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

    context.read<AuthBloc>().add(
      AuthLoginRequested(email: widget.email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          AppToast.error(context, state.error);
        } else if (state is AuthSuccess) {
          AppToast.success(context, 'Успішний вхід!');
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
            title: 'Введіть пароль,\nщоб увійти',
            subtitle: 'З поверненням!',
            onBack: () => Navigator.of(context).pop(),
            children: [
              PasswordTextField(
                hintText: 'Введіть пароль',
                controller: _controller,
                errorText: _errorText,
                onFieldSubmitted: _onNext,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                title: 'Продовжити',
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
