import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import 'auth_provider.dart';

final usersProvider = FutureProvider<List<User>>((ref) async {
  // ✅ ref.read instead of ref.watch — prevents double-completion
  final authState = ref.read(authProvider);
  if (authState == null || !authState.isAuthenticated) {
    return [];
  }
  final result = await UserService().getUsers(authState.token);
  if (result.hasException) throw result.exception!;
  final data = result.data?['users'] as List<dynamic>? ?? [];
  return data
      .map((json) => User.fromJson(json as Map<String, dynamic>))
      .toList();
});
