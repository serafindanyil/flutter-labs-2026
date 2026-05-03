import 'package:equatable/equatable.dart';

class AuthEmailStepState extends Equatable {
  const AuthEmailStepState({
    this.nameErrorText,
    this.emailErrorText,
    this.isLoading = false,
    this.loginEmail,
    this.registerData,
    this.toastError,
  });

  final String? nameErrorText;
  final String? emailErrorText;
  final bool isLoading;
  final String? loginEmail;
  final AuthRegisterData? registerData;
  final String? toastError;

  AuthEmailStepState copyWith({
    String? nameErrorText,
    bool clearNameErrorText = false,
    String? emailErrorText,
    bool clearEmailErrorText = false,
    bool? isLoading,
    String? loginEmail,
    bool clearLoginEmail = false,
    AuthRegisterData? registerData,
    bool clearRegisterData = false,
    String? toastError,
    bool clearToastError = false,
  }) {
    return AuthEmailStepState(
      nameErrorText: clearNameErrorText
          ? null
          : nameErrorText ?? this.nameErrorText,
      emailErrorText: clearEmailErrorText
          ? null
          : emailErrorText ?? this.emailErrorText,
      isLoading: isLoading ?? this.isLoading,
      loginEmail: clearLoginEmail ? null : loginEmail ?? this.loginEmail,
      registerData: clearRegisterData
          ? null
          : registerData ?? this.registerData,
      toastError: clearToastError ? null : toastError ?? this.toastError,
    );
  }

  @override
  List<Object?> get props => [
    nameErrorText,
    emailErrorText,
    isLoading,
    loginEmail,
    registerData,
    toastError,
  ];
}

class AuthRegisterData extends Equatable {
  const AuthRegisterData({required this.name, required this.email});

  final String name;
  final String email;

  @override
  List<Object> get props => [name, email];
}
