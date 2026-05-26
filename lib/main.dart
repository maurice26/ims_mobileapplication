import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/sales/sales_dashboard.dart';
import 'screens/user/user_dashboard.dart';

void main() {
  runApp(const ProviderScope(child: IMSApp()));
}

class IMSApp extends ConsumerWidget {
  const IMSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isInitialized = ref.watch(authInitializedProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        // '/landing' removed from startup flow.
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      home: _resolveScreen(authState, isInitialized),
    );
  }

  Widget _resolveScreen(dynamic authState, bool isInitialized) {
    if (!isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        ),
      );
    }

    // Remove landing page: always go to login when not authenticated.
    if (authState?.isAuthenticated != true) {
      return const LoginScreen();
    }

    switch (authState!.role.toLowerCase()) {
      case 'admin':
        return const AdminDashboard();
      case 'sales':
        return const SalesDashboard();
      default:
        return const UserDashboard();
    }
  }
}
