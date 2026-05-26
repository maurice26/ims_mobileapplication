import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/supplier.dart';
import '../../providers/auth_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../services/supplier_service.dart';
import '../../widgets/app_shell/page_wrapper.dart';
import '../../widgets/datagrid/ims_table.dart';
import '../../widgets/datagrid/ims_table_row_actions.dart';
import '../../widgets/role_guard.dart';

class ManageSuppliers extends ConsumerStatefulWidget {
  const ManageSuppliers({super.key});

  @override
  ConsumerState<ManageSuppliers> createState() => _ManageSuppliersState();
}

class _ManageSuppliersState extends ConsumerState<ManageSuppliers> {
  Future<void> _showSupplierDialog({Supplier? supplier}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final contactController = TextEditingController(
      text: supplier?.contact ?? '',
    );
    final isEdit = supplier != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit supplier' : 'Create supplier'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Supplier name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact information',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Contact is required'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final token = ref.read(authProvider)?.token;
              final supplierId = int.tryParse(supplier?.id ?? '');
              if (token == null) return;

              final input = {
                'name': nameController.text.trim(),
                'contactInfo': contactController.text.trim(),
              };
              final service = SupplierService();
              final result = isEdit
                  ? await service.updateSupplier(token, supplierId!, input)
                  : await service.createSupplier(token, input);

              if (result.hasException) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Save failed: ${result.exception}')),
                  );
                }
                return;
              }

              await ref.refresh(suppliersProvider.future);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEdit ? 'Supplier updated' : 'Supplier created',
                    ),
                  ),
                );
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSupplier(Supplier supplier) async {
    final token = ref.read(authProvider)?.token;
    final supplierId = int.tryParse(supplier.id);
    if (token == null || supplierId == null) return;

    final result = await SupplierService().deleteSupplier(token, supplierId);
    if (result.hasException) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${result.exception}')),
        );
      }
      return;
    }

    await ref.refresh(suppliersProvider.future);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${supplier.name} deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersProvider);

    return RoleGuard(
      requiredRole: 'admin',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Suppliers'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.invalidate(suppliersProvider),
            ),
          ],
        ),
        body: PageWrapper(
          subtitle: 'Manage vendor records and supply contacts.',
          child: suppliersAsync.when(
            data: (suppliers) => ImsTable<Supplier>(
              items: suppliers,
              columns: const [
                DataColumn(label: Text('Supplier')),
                DataColumn(label: Text('Contact')),
                DataColumn(label: Text('Actions')),
              ],
              rowBuilder: (supplier) => DataRow(
                cells: [
                  DataCell(Text(supplier.name)),
                  DataCell(Text(supplier.contact)),
                  DataCell(
                    ImsTableRowActions(
                      onEdit: () => _showSupplierDialog(supplier: supplier),
                      onDelete: () => _deleteSupplier(supplier),
                      deleteLabel: 'Delete ${supplier.name}?',
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _RetryState(
              message: 'Could not load suppliers: $error',
              onRetry: () => ref.invalidate(suppliersProvider),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showSupplierDialog(),
          icon: const Icon(Icons.local_shipping_rounded),
          label: const Text('New supplier'),
        ),
      ),
    );
  }
}

class _RetryState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RetryState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
