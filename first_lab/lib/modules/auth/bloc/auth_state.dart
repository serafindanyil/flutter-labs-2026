import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthInProgress extends AuthState {
  const AuthInProgress();
}

class AuthSuccess extends AuthState {
  const AuthSuccess();
}

class AuthFailure extends AuthState {
  const AuthFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
