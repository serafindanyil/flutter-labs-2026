import 'package:bloc/bloc.dart';
import 'package:first_lab/modules/auth/bloc/auth_email_step_state.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/shared/constants/app_constants.dart';

class AuthEmailStepCubit extends Cubit<AuthEmailStepState> {
  AuthEmailStepCubit({required AuthService authService})
    : _authService = authService,
      super(const AuthEmailStepState());

  final AuthService _authService;

  Future<void> submitLoginEmail({
    required String email,
    required bool hasNetworkAccess,
  }) async {
    final emailError = _emailError(email);
    emit(
      state.copyWith(
        emailErrorText: emailError,
        clearEmailErrorText: emailError == null,
        isLoading: false,
        clearLoginEmail: true,
        clearRegisterData: true,
        clearToastError: true,
      ),
    );
    if (emailError != null || !hasNetworkAccess) return;

    emit(state.copyWith(isLoading: true));
    try {
      final exists = await _authService.checkEmailExists(email);
      emit(
        state.copyWith(
          isLoading: false,
          loginEmail: exists ? email : null,
          toastError: exists ? null : 'Акаунт не знайдено',
          clearToastError: exists,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          toastError: 'Помилка підключення. Перевірте інтернет.',
        ),
      );
    }
  }

  Future<void> submitRegisterEmail({
    required String name,
    required String email,
    required bool hasNetworkAccess,
  }) async {
    final nameError = _nameError(name);
    final emailError = _emailError(email);
    emit(
      state.copyWith(
        nameErrorText: nameError,
        clearNameErrorText: nameError == null,
        emailErrorText: emailError,
        clearEmailErrorText: emailError == null,
        isLoading: false,
        clearLoginEmail: true,
        clearRegisterData: true,
        clearToastError: true,
      ),
    );
    if (nameError != null || emailError != null || !hasNetworkAccess) return;

    emit(state.copyWith(isLoading: true));
    try {
      final exists = await _authService.checkEmailExists(email);
      emit(
        state.copyWith(
          isLoading: false,
          registerData: exists
              ? null
              : AuthRegisterData(name: name, email: email),
          toastError: exists ? 'Цей емейл вже зайнятий' : null,
          clearToastError: !exists,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          toastError: 'Помилка підключення. Перевірте інтернет.',
        ),
      );
    }
  }

  String? _emailError(String email) {
    if (email.isEmpty) return 'Емейл не може бути порожнім';
    if (!RegExp(AppConstants.emailRegex).hasMatch(email)) {
      return 'Невірний формат емейлу';
    }
    return null;
  }

  String? _nameError(String name) {
    if (name.isEmpty) return 'Ім\'я не може бути порожнім';
    if (RegExp(r'\d').hasMatch(name)) return 'Ім\'я не може містити цифри';
    return null;
  }
}
