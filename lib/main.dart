import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/auth/login_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/sales/sales_dashboard.dart';
import 'screens/user/user_dashboard.dart';

void main() {
  runApp(const ProviderScope(child: IMSApp()));
}

Widget getHomeByRole(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return const AdminDashboard();
    case 'sales':
      return const SalesDashboard();
    default:
      return const UserDashboard();
  }
}

class IMSApp extends ConsumerWidget {
  const IMSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    Widget home;
    if (authState?.isAuthenticated != true) {
      home = const LoginScreen();
    } else {
      home = getHomeByRole(authState!.role);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IMS System',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => home,
        '/products': (context) => const ProductsScreen(),
      },
    );
  }
}
