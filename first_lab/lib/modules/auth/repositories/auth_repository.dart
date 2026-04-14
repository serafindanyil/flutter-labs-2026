import 'package:first_lab/modules/auth/models/user_model.dart';

abstract interface class AuthRepository {
  Future<void> register(UserModel user);
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser();
  Future<void> logout();
}
