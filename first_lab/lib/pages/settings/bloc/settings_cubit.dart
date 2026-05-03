import 'package:bloc/bloc.dart';
import 'package:first_lab/modules/auth/services/auth_service.dart';
import 'package:first_lab/pages/settings/bloc/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required AuthService authService})
    : _authService = authService,
      super(const SettingsState()) {
    loadUser();
  }

  final AuthService _authService;

  void loadUser() {
    final user = _authService.currentUser;
    if (user == null) return;

    emit(
      state.copyWith(
        name: user.displayName ?? 'Користувач',
        email: user.email ?? 'no-email@example.com',
      ),
    );
  }

  void startEditing() {
    emit(
      state.copyWith(
        isEditing: true,
        saveStatus: SettingsSaveStatus.idle,
        clearErrorMessage: true,
      ),
    );
  }

  bool saveName({required String name, required bool hasNetworkAccess}) {
    if (!state.isEditing) return false;

    if (_isInvalidName(name) || !hasNetworkAccess) {
      emit(
        state.copyWith(
          isEditing: false,
          saveStatus: _isInvalidName(name)
              ? SettingsSaveStatus.failure
              : SettingsSaveStatus.idle,
          errorMessage: _isInvalidName(name)
              ? 'Некоректне ім\'я (порожнє або містить цифри)'
              : null,
          clearErrorMessage: !_isInvalidName(name),
        ),
      );
      return false;
    }

    if (name == state.name) {
      emit(
        state.copyWith(
          isEditing: false,
          saveStatus: SettingsSaveStatus.idle,
          clearErrorMessage: true,
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        name: name,
        isEditing: false,
        saveStatus: SettingsSaveStatus.success,
        clearErrorMessage: true,
      ),
    );
    return true;
  }

  bool _isInvalidName(String name) {
    return name.isEmpty || RegExp(r'\d').hasMatch(name);
  }
}
