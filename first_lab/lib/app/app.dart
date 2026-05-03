import 'package:first_lab/app/app_dependencies.dart';
import 'package:first_lab/app/app_effects.dart';
import 'package:first_lab/modules/auth/bloc/auth_bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_state.dart';
import 'package:first_lab/pages/auth/login_email_page.dart';
import 'package:first_lab/pages/layout/layout.dart';
import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
import 'package:first_lab/shared/network/widgets/disabled_wrapper.dart';
import 'package:first_lab/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDependencies(
      child: BlocBuilder<NetworkCubit, NetworkState>(
        builder: (context, networkState) {
          return Disabled(
            isDisabled: networkState.status != NetworkStatus.online,
            child: MaterialApp(
              title: 'SmartRecu',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              builder: (context, child) {
                return ToastificationWrapper(child: AppEffects(child: child!));
              },
              home: const InitialScreen(),
            ),
          );
        },
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: _shouldBuild,
      builder: (context, state) {
        if (state is AuthSuccess) return const Layout();
        if (state is AuthUnauthenticated || state is AuthFailure) {
          return const LoginEmailPage();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  bool _shouldBuild(AuthState previous, AuthState current) {
    if (previous is AuthInitial && current is AuthSuccess) return true;
    if (previous is AuthInitial && current is AuthUnauthenticated) return true;
    if (previous is AuthSuccess && current is AuthUnauthenticated) return true;
    if (previous is AuthUnauthenticated && current is AuthSuccess) return true;
    if (previous is AuthInProgress && current is AuthSuccess) return true;
    return false;
  }
}
