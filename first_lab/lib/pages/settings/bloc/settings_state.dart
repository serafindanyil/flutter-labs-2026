import 'package:equatable/equatable.dart';

enum SettingsSaveStatus { idle, success, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.isEditing = false,
    this.name = 'Користувач',
    this.email = 'email@example.com',
    this.saveStatus = SettingsSaveStatus.idle,
    this.errorMessage,
  });

  final bool isEditing;
  final String name;
  final String email;
  final SettingsSaveStatus saveStatus;
  final String? errorMessage;

  SettingsState copyWith({
    bool? isEditing,
    String? name,
    String? email,
    SettingsSaveStatus? saveStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SettingsState(
      isEditing: isEditing ?? this.isEditing,
      name: name ?? this.name,
      email: email ?? this.email,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isEditing, name, email, saveStatus, errorMessage];
}
