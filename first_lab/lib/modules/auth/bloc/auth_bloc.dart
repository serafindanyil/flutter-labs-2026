import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_lab/modules/auth/bloc/auth_event.dart';
import 'package:first_lab/modules/auth/bloc/auth_state.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/shared/storage/secure_storage_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthService authService,
    required StorageService storageService,
  }) : _authService = authService,
       _storageService = storageService,
       super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);
  }

  final AuthService _authService;
  final StorageService _storageService;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _storageService.getToken();

    if (token != null) {
      final user = _authService.currentUser;
      if (user != null) {
        emit(const AuthSuccess());
        return;
      }
    }
    emit(const AuthUnauthenticated());
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress());
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        event.email,
        event.password,
      );

      final token = await credential.user?.getIdToken();
      if (token != null) {
        await _storageService.saveToken(token);
        emit(const AuthSuccess());
      } else {
        emit(const AuthFailure('Token generation failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Unknown authentication error'));
    } catch (_) {
      emit(const AuthFailure('An unexpected error occurred'));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress());
    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        event.name,
        event.email,
        event.password,
      );

      final token = await credential.user?.getIdToken();
      if (token != null) {
        await _storageService.saveToken(token);
        emit(const AuthSuccess());
      } else {
        emit(const AuthFailure('Token generation failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Unknown authentication error'));
    } catch (_) {
      emit(const AuthFailure('An unexpected error occurred'));
    }
  }

  Future<void> _onAuthUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress());
    try {
      await _authService.updateDisplayName(event.name);
      emit(const AuthSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Update error'));
    } catch (_) {
      emit(const AuthFailure('An unexpected error occurred'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.signOut();
      await _storageService.deleteToken();
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthFailure('Logout failed'));
    }
  }
}
