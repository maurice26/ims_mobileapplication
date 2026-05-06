import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthNotifier extends StateNotifier<AuthState?> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(null) {
    _init();
  }

  Future<void> _init() async {
    final token = await _authService.getToken();
    final user = await _authService.getUser();
    if (token != null && user != null) {
      state = AuthState(token: token, user: user);
    }
  }

  Future<void> login(String token, User user) async {
    await _authService.saveToken(token);
    await _authService.saveUser(user);
    state = AuthState(token: token, user: user);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }

  bool canAccess(String requiredRole) {
    final user = state?.user;
    if (user == null) return false;
    return user.canAccess(requiredRole);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState?>((ref) {
  return AuthNotifier();
});
