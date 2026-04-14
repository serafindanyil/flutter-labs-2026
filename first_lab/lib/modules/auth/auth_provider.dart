import 'package:first_lab/modules/auth/repositories/auth_repository.dart';
import 'package:first_lab/modules/auth/repositories/auth_repository_local.dart';

abstract final class AuthProvider {
  static final AuthRepository repository = AuthRepositoryLocal();
}
