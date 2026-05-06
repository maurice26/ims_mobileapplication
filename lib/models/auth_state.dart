import 'user.dart';

class AuthState {
  final String? token;
  final User? user;

  const AuthState({this.token, this.user});

  bool get isAuthenticated => token != null && user != null;
  String get role => user?.role ?? 'user';
}
