import 'package:first_lab/modules/auth/bloc/auth_email_step_cubit.dart';
import 'package:first_lab/modules/auth/bloc/auth_email_step_state.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/modules/auth/utils/auth_network_checker.dart';
import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/auth/login_password_page.dart';
import 'package:first_lab/pages/auth/register_email_page.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext(BuildContext context) {
    context.read<AuthEmailStepCubit>().submitLoginEmail(
      email: _controller.text.trim(),
      hasNetworkAccess: context.hasNetworkAccess,
    );
  }

  void _onRegisterTap() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RegisterEmailPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthEmailStepCubit(authService: context.read<AuthService>()),
      child: BlocConsumer<AuthEmailStepCubit, AuthEmailStepState>(
        listener: _listenState,
        builder: (context, state) {
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
                errorText: state.emailErrorText,
                onFieldSubmitted: () => _onNext(context),
              ),
              const SizedBox(height: AuthConstants.spacingLarge),
              PrimaryButton(
                title: 'Продовжити',
                onTap: () => _onNext(context),
                isLoading: state.isLoading,
              ),
              const SizedBox(height: AuthConstants.spacingMedium),
              AuthToggle(
                text: 'Немає акаунту? ',
                actionText: 'Зареєструватись',
                onTap: _onRegisterTap,
              ),
            ],
          );
        },
      ),
    );
  }

  void _listenState(BuildContext context, AuthEmailStepState state) {
    final toastError = state.toastError;
    if (toastError != null) AppToast.error(context, toastError);

    final loginEmail = state.loginEmail;
    if (loginEmail == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoginPasswordPage(email: loginEmail),
      ),
    );
  }
}
