import 'package:first_lab/modules/auth/bloc/auth_bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_event.dart';
import 'package:first_lab/modules/auth/bloc/auth_state.dart';
import 'package:first_lab/modules/auth/bloc/password_validation_cubit.dart';
import 'package:first_lab/modules/auth/bloc/password_validation_state.dart';
import 'package:first_lab/modules/auth/utils/auth_network_checker.dart';
import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/layout/layout.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext(BuildContext context) {
    final password = _controller.text;

    final isValid = context.read<PasswordValidationCubit>().validateLogin(
      password,
    );
    if (!isValid) return;

    if (!context.hasNetworkAccess) return;

    context.read<AuthBloc>().add(
      AuthLoginRequested(email: widget.email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordValidationCubit(),
      child: BlocListener<AuthBloc, AuthState>(
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
          builder: (context, authState) {
            final isLoading = authState is AuthInProgress;

            return BlocBuilder<
              PasswordValidationCubit,
              PasswordValidationState
            >(
              builder: (context, passwordState) {
                return AuthLayout(
                  title: 'Введіть пароль,\nщоб увійти',
                  subtitle: 'З поверненням!',
                  onBack: () => Navigator.of(context).pop(),
                  children: [
                    PasswordTextField(
                      hintText: 'Введіть пароль',
                      controller: _controller,
                      errorText: passwordState.errorText,
                      onFieldSubmitted: () => _onNext(context),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      title: 'Продовжити',
                      onTap: () => _onNext(context),
                      isLoading: isLoading,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
