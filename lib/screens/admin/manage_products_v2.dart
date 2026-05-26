import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/product_service.dart';
import '../../widgets/app_shell/page_wrapper.dart';
import '../../widgets/datagrid/ims_table.dart';
import '../../widgets/datagrid/ims_table_row_actions.dart';

class ManageProductsV2 extends ConsumerStatefulWidget {
  const ManageProductsV2({super.key});

  @override
  ConsumerState<ManageProductsV2> createState() => _ManageProductsV2State();
}

class _ManageProductsV2State extends ConsumerState<ManageProductsV2> {
  Future<void> _showProductDialog({Product? initial}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: initial?.name ?? '');
    final priceController = TextEditingController(
      text: initial?.price.toStringAsFixed(2) ?? '',
    );
    final stockController = TextEditingController(
      text: (initial?.stockQuantity ?? 0).toString(),
    );
    final isEdit = initial != null;

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEdit ? Icons.edit_rounded : Icons.add_box_rounded,
                          color: const Color(0xFF8B5CF6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? 'Edit Product' : 'New Product',
                              style: Theme.of(
                                dialogContext,
                              ).textTheme.headlineSmall,
                            ),
                            Text(
                              isEdit
                                  ? 'Update product information'
                                  : 'Add a new product to inventory',
                              style: Theme.of(
                                dialogContext,
                              ).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Product Name ──
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      hintText: 'Enter product name',
                      prefixIcon: Icon(Icons.inventory_2_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Product name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Price ──
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final price = double.tryParse(v?.trim() ?? '');
                      if (price == null || price <= 0) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Stock Quantity ──
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity',
                      hintText: '0',
                      prefixIcon: Icon(Icons.layers_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final stock = int.tryParse(v?.trim() ?? '');
                      if (stock == null || stock < 0) {
                        return 'Enter available stock';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Action Buttons ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        icon: Icon(
                          isEdit ? Icons.save_rounded : Icons.add_rounded,
                        ),
                        label: Text(isEdit ? 'Save' : 'Create'),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final token = ref.read(authProvider)?.token;
                          if (token == null) return;

                          final input = {
                            if (isEdit) 'productId': initial.id,
                            'name': nameController.text.trim(),
                            'price': double.parse(priceController.text.trim()),
                            'stockQuantity': int.parse(
                              stockController.text.trim(),
                            ),
                            'categoryId': 1,
                          };

                          final service = ProductService();
                          final result = isEdit
                              ? await service.updateProduct(token, input)
                              : await service.createProduct(token, input);

                          if (result.hasException) {
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Save failed: ${result.exception}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          // ✅ Pop FIRST before any provider refresh
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }

                          // ✅ Then refresh the list
                          ref.invalidate(productsProvider);
                          await ref.read(productsProvider.future);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEdit
                                      ? 'Product updated successfully'
                                      : 'Product created successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final token = ref.read(authProvider)?.token;
    if (token == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${product.name}"?',
              style: Theme.of(dialogContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone',
                      style: Theme.of(
                        dialogContext,
                      ).textTheme.bodySmall?.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ProductService().deleteProduct(token, product.id);

    if (result.hasException) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: ${result.exception}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // ✅ Refresh after delete — no dialog to pop here
    ref.invalidate(productsProvider);
    await ref.read(productsProvider.future);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} deleted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ref.invalidate(productsProvider);
              await ref.read(productsProvider.future);
            },
          ),
        ],
      ),
      body: PageWrapper(
        subtitle:
            'Maintain your product catalog with pricing and stock information.',
        child: productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        size: 64,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Products Yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first product to get started',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ImsTable<Product>(
              items: products,
              columns: const [
                DataColumn(label: Text('Product Name')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Actions')),
              ],
              rowBuilder: (product) => DataRow(
                cells: [
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              size: 20,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: product.stockQuantity > 0
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.stockQuantity} units',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: product.stockQuantity > 0
                              ? const Color(0xFF10B981)
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    ImsTableRowActions(
                      onEdit: () => _showProductDialog(initial: product),
                      onDelete: () => _deleteProduct(product),
                      deleteLabel: 'Delete ${product.name}?',
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                SizedBox(height: 16),
                Text('Loading products...'),
              ],
            ),
          ),
          error: (error, stack) => _RetryState(
            message: 'Could not load products: $error',
            onRetry: () async {
              ref.invalidate(productsProvider);
              await ref.read(productsProvider.future);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        icon: const Icon(Icons.add_box_rounded),
        label: const Text('New Product'),
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
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
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
