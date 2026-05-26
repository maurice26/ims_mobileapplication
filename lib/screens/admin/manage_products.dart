import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/product_service.dart';
import '../../widgets/app_shell/page_wrapper.dart';
import '../../widgets/datagrid/ims_table.dart';
import '../../widgets/datagrid/ims_table_row_actions.dart';

class ManageProducts extends ConsumerStatefulWidget {
  const ManageProducts({super.key});

  @override
  ConsumerState<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends ConsumerState<ManageProducts> {
  Future<void> _showProductDialog({Product? initial}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: initial?.name ?? '');
    final priceController = TextEditingController(
      text: initial?.price.toStringAsFixed(2) ?? '',
    );
    final stockController = TextEditingController(
      text: (initial?.stockQuantity ?? 10).toString(),
    );
    final isEdit = initial != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit product' : 'Create product'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product name'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Unit price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final price = double.tryParse(value?.trim() ?? '');
                    if (price == null || price <= 0) return 'Enter a valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final stock = int.tryParse(value?.trim() ?? '');
                    if (stock == null || stock < 0) return 'Enter available stock';
                    return null;
                  },
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
              if (token == null) return;

              final input = {
                if (isEdit) 'productId': initial.id,
                'name': nameController.text.trim(),
                'price': double.parse(priceController.text.trim()),
                'stockQuantity': int.parse(stockController.text.trim()),
                'categoryId': 1,
              };

              final service = ProductService();
              final result = isEdit
                  ? await service.updateProduct(token, input)
                  : await service.createProduct(token, input);

              if (result.hasException) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Save failed: ${result.exception}')),
                  );
                }
                return;
              }

              ref.invalidate(productsProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Product updated' : 'Product created')),
                );
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final token = ref.read(authProvider)?.token;
    if (token == null) return;

    final result = await ProductService().deleteProduct(token, product.id);
    if (result.hasException) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${result.exception}')),
        );
      }
      return;
    }

    ref.invalidate(productsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(productsProvider),
          ),
        ],
      ),
      body: PageWrapper(
        subtitle: 'Maintain catalog pricing and stock available for sales.',
        child: productsAsync.when(
          data: (products) => ImsTable<Product>(
            items: products,
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Stock')),
              DataColumn(label: Text('Actions')),
            ],
            rowBuilder: (product) => DataRow(
              cells: [
                DataCell(Text(product.name)),
                DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                DataCell(Text(product.stockQuantity.toString())),
                DataCell(
                  ImsTableRowActions(
                    onEdit: () => _showProductDialog(initial: product),
                    onDelete: () => _deleteProduct(product),
                    deleteLabel: 'Delete ${product.name}?',
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _RetryState(
            message: 'Could not load products: $error',
            onRetry: () => ref.invalidate(productsProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        icon: const Icon(Icons.add_box_rounded),
        label: const Text('New product'),
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
