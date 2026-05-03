import 'package:bloc/bloc.dart';
import 'package:first_lab/modules/auth/bloc/password_validation_state.dart';
import 'package:first_lab/shared/constants/auth_constants.dart';

class PasswordValidationCubit extends Cubit<PasswordValidationState> {
  PasswordValidationCubit() : super(const PasswordValidationState());

  bool validateLogin(String password) {
    final errorText = _passwordError(password);
    emit(PasswordValidationState(errorText: errorText));
    return errorText == null;
  }

  bool validateRegister({
    required String password,
    required String confirmPassword,
  }) {
    final errorText = _passwordError(password);
    final confirmErrorText = password == confirmPassword
        ? null
        : 'Паролі не співпадають';
    emit(
      PasswordValidationState(
        errorText: errorText,
        confirmErrorText: confirmErrorText,
      ),
    );
    return errorText == null && confirmErrorText == null;
  }

  String? _passwordError(String password) {
    if (password.isEmpty) return 'Пароль не може бути порожнім';
    if (password.length < AuthConstants.minPasswordLength) {
      return 'Мінімум ${AuthConstants.minPasswordLength} символів';
    }
    return null;
  }
}
