import 'package:first_lab/modules/auth/bloc/auth_bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_state.dart';
import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/modules/device_sensors/device_sensors_module.dart';
import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
import 'package:first_lab/shared/realtime/realtime_module.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppEffects extends StatelessWidget {
  const AppEffects({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NetworkCubit, NetworkState>(
          listenWhen: _listenNetwork,
          listener: _handleNetwork,
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: _listenAuth,
          listener: _handleAuth,
        ),
      ],
      child: child,
    );
  }

  bool _listenNetwork(NetworkState previous, NetworkState current) {
    if (previous.status == current.status) return false;
    if (previous.status == NetworkStatus.initial &&
        current.status == NetworkStatus.online) {
      return false;
    }
    return true;
  }

  void _handleNetwork(BuildContext context, NetworkState state) {
    if (state.status == NetworkStatus.offline) {
      context.read<RealtimeCubit>().disconnect();
      context.read<DeviceSensorsHistoryCubit>().stop();
      AppToast.warning(context, 'Немає підключення до інтернету');
      return;
    }

    if (state.status != NetworkStatus.online) return;
    if (context.read<AuthBloc>().state is AuthSuccess) {
      context.read<RealtimeCubit>().connect();
      context.read<DeviceSensorsHistoryCubit>().start();
    }
    AppToast.success(context, 'Підключення відновлено');
  }

  bool _listenAuth(AuthState previous, AuthState current) {
    if (previous is AuthInitial && current is AuthSuccess) return true;
    if (previous is AuthInProgress && current is AuthSuccess) return true;
    if (previous is AuthSuccess && current is AuthUnauthenticated) return true;
    return false;
  }

  void _handleAuth(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      final isOnline =
          context.read<NetworkCubit>().state.status == NetworkStatus.online;
      if (!isOnline) return;
      context.read<RealtimeCubit>().connect();
      context.read<DeviceSensorsHistoryCubit>().start();
      return;
    }

    if (state is! AuthUnauthenticated) return;
    context.read<RealtimeCubit>().disconnect();
    context.read<DeviceSensorsHistoryCubit>().stop(shouldReset: true);
    context.read<DeviceControlCubit>().reset();
    context.read<DeviceSensorsCubit>().reset();
  }
}
