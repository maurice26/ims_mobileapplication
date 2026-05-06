import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import 'auth_provider.dart';

final usersProvider = FutureProvider<List<User>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState?.token == null) return [];
  final token = authState!.token!;

  final result = await UserService().getUsers(token);
  final List<dynamic> usersJson = result.data?['users'] ?? [];
  return usersJson.map((json) => User.fromJson(json)).toList();
});
