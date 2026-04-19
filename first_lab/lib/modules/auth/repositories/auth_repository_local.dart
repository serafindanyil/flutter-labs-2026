import 'dart:convert';
import 'package:first_lab/modules/auth/models/user_model.dart';
import 'package:first_lab/modules/auth/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepositoryLocal implements AuthRepository {
  final _storage = const FlutterSecureStorage();
  static const _userKey = 'current_user';
  static const _loggedInKey = 'is_logged_in';

  @override
  Future<void> register(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
    await _storage.write(key: _loggedInKey, value: 'true');
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      final user = UserModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      if (user.email == email && user.password == password) {
        await _storage.write(key: _loggedInKey, value: 'true');
        return user;
      }
    }
    return null;
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      final user = UserModel.fromJson(
        jsonDecode(userJson) as Map<String, dynamic>,
      );
      return user.email == email;
    }
    return false;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final isLoggedIn = await _storage.read(key: _loggedInKey);
    if (isLoggedIn == 'true') {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      }
    }
    return null;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }

  @override
  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _loggedInKey);
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: _loggedInKey);
  }
}
