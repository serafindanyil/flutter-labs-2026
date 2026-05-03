import 'package:first_lab/modules/auth/bloc/auth_email_step_cubit.dart';
import 'package:first_lab/modules/auth/bloc/auth_email_step_state.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/modules/auth/utils/auth_network_checker.dart';
import 'package:first_lab/modules/auth/widgets/auth_layout.dart';
import 'package:first_lab/pages/auth/login_email_page.dart';
import 'package:first_lab/pages/auth/register_password_page.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onNext(BuildContext context) {
    context.read<AuthEmailStepCubit>().submitRegisterEmail(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      hasNetworkAccess: context.hasNetworkAccess,
    );
  }

  void _onLoginTap() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginEmailPage()),
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
                errorText: state.nameErrorText,
                keyboardType: TextInputType.name,
                onFieldSubmitted: () => _onNext(context),
              ),
              const SizedBox(height: AuthConstants.spacingMedium),
              Text('Емейл', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AuthConstants.spacingXXSmall),
              PrimaryTextField(
                hintText: 'example@mail.com',
                controller: _emailController,
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
                text: 'Вже є акаунт? ',
                actionText: 'Увійти',
                onTap: _onLoginTap,
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

    final registerData = state.registerData;
    if (registerData == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegisterPasswordPage(
          name: registerData.name,
          email: registerData.email,
        ),
      ),
    );
  }
}
