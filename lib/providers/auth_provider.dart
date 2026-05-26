import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/graphql_service.dart';

final authInitializedProvider = StateProvider<bool>((ref) => false);

class AuthNotifier extends StateNotifier<AuthState?> {
  final AuthService _authService = AuthService();
  final Ref _ref;

  bool _started = false;
  bool _completed = false;

  AuthNotifier(this._ref) : super(null) {
    _startInit();
  }

  void _startInit() {
    // Prevent multiple starts (can happen in some hot-reload / zone scenarios)
    if (_started || _completed) return;
    _started = true;
    _init();
  }

  Future<void> _init() async {
    try {
      final token = await _authService.getToken();
      final user = await _authService.getUser();

      if (token != null && user != null) {
        state = AuthState(token: token, user: user);
      }
    } finally {
      // Mark initialization complete exactly once
      if (!_completed) {
        _completed = true;
        _ref.read(authInitializedProvider.notifier).state = true;
      }
    }
  }

  Future<void> login(String token, User user) async {
    await _authService.saveToken(token);
    await _authService.saveUser(user);
    state = AuthState(token: token, user: user);
  }

  Future<void> logout() async {
    await _authService.logout();
    ApiService.reset();
    GraphQLService.reset();
    state = null;
  }

  bool canAccess(String requiredRole) {
    final user = state?.user;
    if (user == null) return false;
    return user.canAccess(requiredRole);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState?>((ref) {
  return AuthNotifier(ref);
});
