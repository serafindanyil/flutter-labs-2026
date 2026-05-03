import 'package:equatable/equatable.dart';

class PasswordValidationState extends Equatable {
  const PasswordValidationState({this.errorText, this.confirmErrorText});

  final String? errorText;
  final String? confirmErrorText;

  @override
  List<Object?> get props => [errorText, confirmErrorText];
}
