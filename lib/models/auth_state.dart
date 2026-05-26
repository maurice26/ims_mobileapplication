import 'user.dart';

class AuthState {
  final String token;
  final User user;

  AuthState({required this.token, required this.user});

  bool get isAuthenticated => token.isNotEmpty;

  String get role => user.role;
}
