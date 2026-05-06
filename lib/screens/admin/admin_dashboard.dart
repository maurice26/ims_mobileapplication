import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/product_provider.dart';
import '../../widgets/role_drawer.dart';
import '../../widgets/role_guard.dart';
import '../admin/manage_products.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statCards = [
      _buildStatCard(
        context,
        icon: Icons.people_outline,
        title: 'Users',
        value: '1,234',
        color: Color(0xFF8B5CF6),
      ),
      ref
          .watch(productsProvider)
          .when(
            data: (products) => _buildStatCard(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              value: '${products.length}',
              color: Color(0xFF06B6D4),
            ),
            loading: () => _buildStatCard(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              value: 'Loading...',
              color: Color(0xFF06B6D4),
            ),
            error: (e, st) => _buildStatCard(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              value: 'Error',
              color: Color(0xFF06B6D4),
            ),
          ),
      _buildStatCard(
        context,
        icon: Icons.trending_up_outlined,
        title: 'Sales',
        value: '\$12.5K',
        color: Color(0xFF10B981),
      ),
      _buildStatCard(
        context,
        icon: Icons.business_outlined,
        title: 'Suppliers',
        value: '89',
        color: Color(0xFFf97316),
      ),
    ];

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'IMS Dashboard',
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF8B5CF6).withOpacity(0.8),
                        Color(0xFFA78BFA).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.all(24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  childAspectRatio: 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => statCards[index],
                  childCount: statCards.length,
                ),
              ),
            ),
          ],
        ),
        drawer: const RoleDrawer(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManageProducts()),
          ),
          backgroundColor: Color(0xFF8B5CF6),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Manage Products',
            style: TextStyle(color: Colors.white),
          ),
        ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
