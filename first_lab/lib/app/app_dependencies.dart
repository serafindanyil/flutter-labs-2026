import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_lab/modules/auth/bloc/auth_bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_event.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/modules/device_sensors/device_sensors_module.dart';
import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/realtime/realtime_module.dart';
import 'package:first_lab/shared/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppDependencies extends StatelessWidget {
  const AppDependencies({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (_) =>
              FirebaseAuthService(firebaseAuth: FirebaseAuth.instance),
        ),
        RepositoryProvider<StorageService>(
          create: (_) =>
              const SecureStorageService(secureStorage: FlutterSecureStorage()),
        ),
        RepositoryProvider<DeviceControlCommandService>(
          create: (context) => DeviceControlCommandService(
            authService: context.read<AuthService>(),
          ),
        ),
        RepositoryProvider<DeviceSensorsHistoryService>(
          create: (context) => DeviceSensorsHistoryService(
            authService: context.read<AuthService>(),
          ),
        ),
        RepositoryProvider<RealtimeSocketService>(
          create: (_) => RealtimeSocketService(),
        ),
      ],
      child: _AppBlocProviders(child: child),
    );
  }
}

class _AppBlocProviders extends StatelessWidget {
  const _AppBlocProviders({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: context.read<AuthService>(),
            storageService: context.read<StorageService>(),
          )..add(const AuthCheckRequested()),
        ),
        BlocProvider<NetworkCubit>(create: (_) => NetworkCubit(Connectivity())),
        BlocProvider<DeviceControlCubit>(
          create: (context) => DeviceControlCubit(
            commandService: context.read<DeviceControlCommandService>(),
          ),
        ),
        BlocProvider<DeviceSensorsCubit>(create: (_) => DeviceSensorsCubit()),
        BlocProvider<DeviceSensorsHistoryCubit>(
          create: (context) => DeviceSensorsHistoryCubit(
            service: context.read<DeviceSensorsHistoryService>(),
          ),
        ),
        BlocProvider<RealtimeCubit>(create: _createRealtimeCubit),
      ],
      child: child,
    );
  }

  RealtimeCubit _createRealtimeCubit(BuildContext context) {
    return RealtimeCubit(
      authService: context.read<AuthService>(),
      socketService: context.read<RealtimeSocketService>(),
      onUpdateStatus: context.read<DeviceControlCubit>().applyUpdateStatus,
      onSensors: context.read<DeviceSensorsCubit>().applySensors,
    );
  }
}
