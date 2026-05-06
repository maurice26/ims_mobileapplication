import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> saveUser(User user) async {
    final jsonString = json.encode(user.toJson());
    await _storage.write(key: 'user', value: jsonString);
  }

  Future<User?> getUser() async {
    final jsonString = await _storage.read(key: 'user');
    if (jsonString == null) return null;
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return User.fromJson(map);
  }

  Future<String?> getRole() async {
    final user = await getUser();
    return user?.role;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
