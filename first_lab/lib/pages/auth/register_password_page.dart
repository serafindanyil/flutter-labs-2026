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

  @override
  void dispose() {
    _controller.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onNext(BuildContext context) {
    final password = _controller.text;
    final confirmPassword = _confirmController.text;

    final isValid = context.read<PasswordValidationCubit>().validateRegister(
      password: password,
      confirmPassword: confirmPassword,
    );
    if (!isValid) return;

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
    return BlocProvider(
      create: (_) => PasswordValidationCubit(),
      child: BlocListener<AuthBloc, AuthState>(
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
          builder: (context, authState) {
            final isLoading = authState is AuthInProgress;

            return BlocBuilder<
              PasswordValidationCubit,
              PasswordValidationState
            >(
              builder: (context, passwordState) {
                return AuthLayout(
                  title: 'Придумайте\nнадійний пароль',
                  subtitle: 'Ваша безпека - понад усе!',
                  onBack: () => Navigator.of(context).pop(),
                  children: [
                    PasswordTextField(
                      hintText: 'Придумайте пароль',
                      controller: _controller,
                      errorText: passwordState.errorText,
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      hintText: 'Повторіть пароль',
                      controller: _confirmController,
                      errorText: passwordState.confirmErrorText,
                      onFieldSubmitted: () => _onNext(context),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      title: 'Створити акаунт',
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
