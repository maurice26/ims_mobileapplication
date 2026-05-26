import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/supplier_provider.dart';
import '../../widgets/role_drawer.dart';
import '../../widgets/role_guard.dart';

class SuppliersViewScreen extends ConsumerWidget {
  const SuppliersViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(suppliersProvider);

    return RoleGuard(
      requiredRole: 'user',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Suppliers'),
          backgroundColor: const Color(0xFF8B5CF6),
        ),
        drawer: const RoleDrawer(),
        body: suppliersAsync.when(
          data: (suppliers) => ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return Card(
                child: ListTile(
                  title: Text(supplier.name),
                  subtitle: Text(supplier.contact),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) =>
              const Center(child: Text('Error loading suppliers')),
        ),
      ),
    );
  }
}
