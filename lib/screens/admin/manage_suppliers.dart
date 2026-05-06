import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/supplier_provider.dart';

class ManageSuppliers extends ConsumerStatefulWidget {
  const ManageSuppliers({super.key});

  @override
  ConsumerState<ManageSuppliers> createState() => _ManageSuppliersState();
}

class _ManageSuppliersState extends ConsumerState<ManageSuppliers> {
  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Suppliers'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
      body: suppliersAsync.when(
        data: (suppliers) => ListView.builder(
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(supplier.name),
                subtitle: Text(supplier.contact),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Edit supplier
                  },
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add supplier
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
