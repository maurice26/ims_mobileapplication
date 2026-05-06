import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/admin/analytics.dart';
import '../screens/admin/invoices.dart';
import '../screens/admin/manage_suppliers.dart';
import '../screens/admin/manage_users.dart';
import '../screens/admin/reports.dart';
import '../screens/sales/create_sale.dart';
import '../screens/sales/payments.dart';
import '../screens/sales/suppliers.dart';
import '../screens/user/suppliers_view.dart';

class RoleDrawer extends ConsumerWidget {
  const RoleDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final role = authState?.role ?? 'user';
    final userName = authState?.user?.name ?? 'User';

    List<ListTile> tiles = [
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Dashboard'),
        onTap: () {},
      ),
      ListTile(
        leading: const Icon(Icons.inventory_2),
        title: const Text('Products'),
        onTap: () => Navigator.pushNamed(context, '/products'),
      ),
    ];

    switch (role) {
      case 'Admin':
        tiles.addAll([
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Users'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageUsers()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Manage Suppliers'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageSuppliers()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Analytics'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Reports'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Invoices'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InvoicesScreen()),
            ),
          ),
        ]);
        break;
      case 'Sales':
        tiles.addAll([
          ListTile(
            leading: const Icon(Icons.add_shopping_cart),
            title: const Text('Create Sale'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateSaleScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payments'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Suppliers'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SuppliersScreen()),
            ),
          ),
        ]);
        break;
      case 'User':
        tiles.add(
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Suppliers'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SuppliersViewScreen()),
            ),
          ),
        );
        break;
    }

    tiles.add(
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: () => authNotifier.logout(),
      ),
    );

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(role, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ...tiles,
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    // Same as dashboard stat card
    return Container(/* ... */); // Simplified
  }
}
