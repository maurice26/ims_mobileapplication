import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/admin/analytics.dart';
import '../screens/admin/invoices.dart';
import '../screens/admin/manage_products_v2.dart';
import '../screens/admin/manage_suppliers.dart';
import '../screens/admin/manage_users.dart';
import '../screens/admin/reports.dart';
import '../screens/auth/login_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/sales/create_sale.dart';
import '../screens/sales/payments.dart';
import '../screens/sales/suppliers.dart';
import '../screens/user/suppliers_view.dart';

class RoleDrawer extends ConsumerWidget {
  const RoleDrawer({super.key});

  void _goTo(BuildContext context, Widget screen) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => screen));
  }

  void _goHome(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final role = (authState?.role ?? 'user').toLowerCase();

    String canonicalRole(String r) {
      final roleTrim = r.trim().toLowerCase();
      if (roleTrim == 'admin') return 'admin';
      if (roleTrim == 'sales') return 'sales';
      return 'user';
    }

    final canonical = canonicalRole(role);
    final userName = authState?.user.name ?? 'User';
    final colorScheme = Theme.of(context).colorScheme;

    final tiles = <Widget>[
      _DrawerTile(
        leading: const Icon(Icons.dashboard_rounded),
        title: const Text('Dashboard'),
        onTap: () => _goHome(context),
      ),
    ];

    switch (canonical) {
      case 'admin':
        tiles.addAll([
          const _DrawerSection('Administration'),
          _DrawerTile(
            leading: const Icon(Icons.inventory_2_rounded),
            title: const Text('Manage Products'),
            onTap: () => _goTo(context, const ManageProductsV2()),
          ),
          _DrawerTile(
            leading: const Icon(Icons.people_rounded),
            title: const Text('Manage Users'),
            onTap: () => _goTo(context, const ManageUsers()),
          ),
          _DrawerTile(
            leading: const Icon(Icons.business_rounded),
            title: const Text('Manage Suppliers'),
            onTap: () => _goTo(context, const ManageSuppliers()),
          ),
          _DrawerTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: const Text('Analytics'),
            onTap: () => _goTo(context, const AnalyticsScreen()),
          ),
          _DrawerTile(
            leading: const Icon(Icons.assessment_rounded),
            title: const Text('Reports'),
            onTap: () => _goTo(context, const ReportsScreen()),
          ),
          _DrawerTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: const Text('Invoices'),
            onTap: () => _goTo(context, const InvoicesScreen()),
          ),
        ]);
        break;
      case 'sales':
        tiles.addAll([
          const _DrawerSection('Sales'),
          _DrawerTile(
            leading: const Icon(Icons.inventory_2_rounded),
            title: const Text('Products'),
            onTap: () => _goTo(context, const ProductsScreen()),
          ),
          _DrawerTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Manage Products'),
            onTap: () => _goTo(context, const ManageProductsV2()),
          ),
          _DrawerTile(
            leading: const Icon(Icons.add_shopping_cart_rounded),
            title: const Text('Create Sale'),
            onTap: () => _goTo(context, const CreateSaleScreen()),
          ),
          _DrawerTile(
            leading: const Icon(Icons.payment_rounded),
            title: const Text('Payments'),
            onTap: () => _goTo(context, const PaymentsScreen()),
          ),
          _DrawerTile(
            leading: const Icon(Icons.business_rounded),
            title: const Text('Suppliers'),
            onTap: () => _goTo(context, const SuppliersScreen()),
          ),
        ]);
        break;
      case 'user':
        tiles.addAll([
          _DrawerTile(
            leading: const Icon(Icons.inventory_2_rounded),
            title: const Text('Products'),
            onTap: () => _goTo(context, const ProductsScreen()),
          ),
          _DrawerTile(
            leading: const Icon(Icons.business_rounded),
            title: const Text('Suppliers'),
            onTap: () => _goTo(context, const SuppliersViewScreen()),
          ),
        ]);
        break;
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Text(
                      userName.trim().isEmpty
                          ? 'U'
                          : userName.trim()[0].toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          canonical.toUpperCase(),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: tiles,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _DrawerTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Logout'),
                isDestructive: true,
                onTap: () async {
                  Navigator.pop(context);
                  await authNotifier.logout();
                  // Redirect to login screen and remove all previous routes
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String label;

  const _DrawerSection(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerTile({
    required this.leading,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: IconTheme(
          data: IconThemeData(color: color),
          child: leading,
        ),
        title: DefaultTextStyle.merge(
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
          child: title,
        ),
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
