import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/product_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/role_drawer.dart';
import '../admin/analytics.dart';
import '../admin/manage_products_v2.dart';
import '../admin/manage_suppliers.dart';
import '../admin/manage_users.dart';
import '../admin/reports.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final products = ref.watch(productsProvider);
    final suppliers = ref.watch(suppliersProvider);
    final sales = ref.watch(salesProvider);
    final revenue = sales.maybeWhen(
      data: (items) => items.fold<double>(0, (sum, sale) => sum + sale.total),
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: const RoleDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                icon: Icons.people_alt_rounded,
                title: 'Users',
                value: users.maybeWhen(
                  data: (items) => '${items.length}',
                  orElse: () => '--',
                ),
                color: const Color(0xFF2563EB),
              ),
              _StatCard(
                icon: Icons.inventory_2_rounded,
                title: 'Products',
                value: products.maybeWhen(
                  data: (items) => '${items.length}',
                  orElse: () => '--',
                ),
                color: const Color(0xFF0891B2),
              ),
              _StatCard(
                icon: Icons.local_shipping_rounded,
                title: 'Suppliers',
                value: suppliers.maybeWhen(
                  data: (items) => '${items.length}',
                  orElse: () => '--',
                ),
                color: const Color(0xFFEA580C),
              ),
              _StatCard(
                icon: Icons.point_of_sale_rounded,
                title: 'Sales',
                value: sales.maybeWhen(
                  data: (items) => '${items.length}',
                  orElse: () => '--',
                ),
                color: const Color(0xFF16A34A),
              ),
              _StatCard(
                icon: Icons.trending_up_rounded,
                title: 'Revenue',
                value: '\$${revenue.toStringAsFixed(2)}',
                color: const Color(0xFF7C3AED),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Admin Tools', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.inventory_2_rounded,
            title: 'Manage Products',
            subtitle: 'Create, edit, delete, and refresh backend products.',
            onTap: () => _open(context, const ManageProductsV2()),
          ),
          _ActionTile(
            icon: Icons.people_rounded,
            title: 'Manage Users',
            subtitle: 'Maintain system users and roles.',
            onTap: () => _open(context, const ManageUsers()),
          ),
          _ActionTile(
            icon: Icons.business_rounded,
            title: 'Manage Suppliers',
            subtitle: 'Create, edit, and delete suppliers.',
            onTap: () => _open(context, const ManageSuppliers()),
          ),
          _ActionTile(
            icon: Icons.bar_chart_rounded,
            title: 'Analytics',
            subtitle: 'Review sales activity and operational totals.',
            onTap: () => _open(context, const AnalyticsScreen()),
          ),
          _ActionTile(
            icon: Icons.assessment_rounded,
            title: 'Reports',
            subtitle: 'Generate full system PDF and sales reports.',
            onTap: () => _open(context, const ReportsScreen()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(context, const ManageProductsV2()),
        icon: const Icon(Icons.inventory_2_rounded),
        label: const Text('Manage Products'),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
