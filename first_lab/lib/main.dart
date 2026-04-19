import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_lab/firebase_options.dart';
import 'package:first_lab/modules/auth/bloc/auth_bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_event.dart';
import 'package:first_lab/modules/auth/bloc/auth_state.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/pages/auth/login_email_page.dart';
import 'package:first_lab/pages/layout/layout.dart';
import 'package:first_lab/shared/storage/secure_storage_service.dart';
import 'package:first_lab/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      ],
      child: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          authService: context.read<AuthService>(),
          storageService: context.read<StorageService>(),
        )..add(const AuthCheckRequested()),
        child: MaterialApp(
          title: 'SmartRecu',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: const InitialScreen(),
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
