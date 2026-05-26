import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class RoleGuard extends ConsumerWidget {
  final Widget child;
  final String requiredRole; // 'Admin', 'Sales', etc.

  const RoleGuard({super.key, required this.child, required this.requiredRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState?.isAuthenticated != true) {
      return const LoginScreen();
    }

    final userRole = authState!.role;
    bool hasAccess = _canAccess(userRole, requiredRole);

    if (!hasAccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'You need $requiredRole role for this screen.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }

  bool _canAccess(String userRole, String requiredRole) {
    const roleHierarchy = {'admin': 3, 'sales': 2, 'user': 1};

    // Normalize both roles to lowercase for comparison
    final userRoleLower = userRole.trim().toLowerCase();
    final requiredRoleLower = requiredRole.trim().toLowerCase();

    final userLevel = roleHierarchy[userRoleLower] ?? 0;
    final requiredLevel = roleHierarchy[requiredRoleLower] ?? 0;

    return userLevel >= requiredLevel;
  }
}
