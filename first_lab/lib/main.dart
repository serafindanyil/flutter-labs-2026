import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_lab/firebase_options.dart';
import 'package:first_lab/modules/auth/bloc/auth_bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_event.dart';
import 'package:first_lab/modules/auth/bloc/auth_state.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/modules/device_control/device_control_module.dart';
import 'package:first_lab/modules/device_sensors/device_sensors_module.dart';
import 'package:first_lab/pages/auth/login_email_page.dart';
import 'package:first_lab/pages/layout/layout.dart';
import 'package:first_lab/shared/network/bloc/network_cubit.dart';
import 'package:first_lab/shared/network/bloc/network_state.dart';
import 'package:first_lab/shared/network/widgets/disabled_wrapper.dart';
import 'package:first_lab/shared/realtime/realtime_module.dart';
import 'package:first_lab/shared/storage/secure_storage_service.dart';
import 'package:first_lab/shared/theme/app_theme.dart';
import 'package:first_lab/shared/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) =>
              FirebaseAuthService(firebaseAuth: FirebaseAuth.instance),
        ),
        RepositoryProvider<StorageService>(
          create: (context) =>
              const SecureStorageService(secureStorage: FlutterSecureStorage()),
        ),
        RepositoryProvider<DeviceControlCommandService>(
          create: (context) => DeviceControlCommandService(
            authService: context.read<AuthService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
              storageService: context.read<StorageService>(),
            )..add(const AuthCheckRequested()),
          ),
          BlocProvider<NetworkCubit>(
            create: (context) => NetworkCubit(Connectivity()),
          ),
          BlocProvider<DeviceControlCubit>(
            create: (context) => DeviceControlCubit(),
          ),
          BlocProvider<DeviceSensorsCubit>(
            create: (context) => DeviceSensorsCubit(),
          ),
          BlocProvider<RealtimeCubit>(
            create: (context) => RealtimeCubit(
              authService: context.read<AuthService>(),
              socketService: RealtimeSocketService(),
              onUpdateStatus: context
                  .read<DeviceControlCubit>()
                  .applyUpdateStatus,
              onSensors: context.read<DeviceSensorsCubit>().applySensors,
            ),
          ),
        ],
        child: BlocBuilder<NetworkCubit, NetworkState>(
          builder: (context, networkState) {
            final isOffline = networkState.status != NetworkStatus.online;
            return Disabled(
              isDisabled: isOffline,
              child: MaterialApp(
                title: 'SmartRecu',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                builder: (context, child) {
                  return ToastificationWrapper(
                    child: MultiBlocListener(
                      listeners: [
                        BlocListener<NetworkCubit, NetworkState>(
                          listenWhen: (previous, current) {
                            if (previous.status == current.status) {
                              return false;
                            }
                            if (previous.status == NetworkStatus.initial &&
                                current.status == NetworkStatus.online) {
                              return false;
                            }
                            return true;
                          },
                          listener: (context, state) {
                            if (state.status == NetworkStatus.offline) {
                              context.read<RealtimeCubit>().disconnect();
                              AppToast.warning(
                                context,
                                'Немає підключення до інтернету',
                              );
                            } else if (state.status == NetworkStatus.online) {
                              if (context.read<AuthBloc>().state
                                  is AuthSuccess) {
                                context.read<RealtimeCubit>().connect();
                              }
                              AppToast.success(
                                context,
                                'Підключення відновлено',
                              );
                            }
                          },
                        ),
                        BlocListener<AuthBloc, AuthState>(
                          listenWhen: (previous, current) {
                            if (previous is AuthInitial &&
                                current is AuthSuccess) {
                              return true;
                            }
                            if (previous is AuthInProgress &&
                                current is AuthSuccess) {
                              return true;
                            }
                            if (previous is AuthSuccess &&
                                current is AuthUnauthenticated) {
                              return true;
                            }
                            return false;
                          },
                          listener: (context, state) {
                            if (state is AuthSuccess) {
                              final isOnline =
                                  context.read<NetworkCubit>().state.status ==
                                  NetworkStatus.online;
                              if (isOnline) {
                                context.read<RealtimeCubit>().connect();
                              }
                            } else if (state is AuthUnauthenticated) {
                              context.read<RealtimeCubit>().disconnect();
                              context.read<DeviceControlCubit>().reset();
                              context.read<DeviceSensorsCubit>().reset();
                            }
                          },
                        ),
                      ],
                      child: child!,
                    ),
                  );
                },
                home: const InitialScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        if (previous is AuthInitial && current is AuthSuccess) {
          return true;
        }
        if (previous is AuthInitial && current is AuthUnauthenticated) {
          return true;
        }
        if (previous is AuthSuccess && current is AuthUnauthenticated) {
          return true;
        }
        if (previous is AuthUnauthenticated && current is AuthSuccess) {
          return true;
        }
        if (previous is AuthInProgress && current is AuthSuccess) {
          return true;
        }

        return false;
      },
      builder: (context, state) {
        if (state is AuthSuccess) {
          return const Layout();
        } else if (state is AuthUnauthenticated || state is AuthFailure) {
          return const LoginEmailPage();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
