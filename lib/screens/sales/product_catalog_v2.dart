import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../../models/sale.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sales_provider.dart';
import '../../services/sales_service.dart';
import '../../widgets/app_shell/app_shell.dart';
import '../../widgets/app_shell/page_wrapper.dart';

class ProductCatalogV2 extends ConsumerStatefulWidget {
  const ProductCatalogV2({super.key});

  @override
  ConsumerState<ProductCatalogV2> createState() => _ProductCatalogV2State();
}

class _ProductCatalogV2State extends ConsumerState<ProductCatalogV2> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addToSale(Product product) async {
    final token = ref.read(authProvider)?.token;
    if (token == null) return;

    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController(text: '1');

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_cart_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add to Sale',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Product Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit Price',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: const Color(0xFF10B981)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Available Stock',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product.stockQuantity} units',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: product.stockQuantity > 0
                                      ? const Color(0xFF10B981)
                                      : Colors.red,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quantity Input
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: '1',
                    prefixIcon: Icon(Icons.layers_rounded),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final qty = int.tryParse(value?.trim() ?? '');
                    if (qty == null || qty <= 0) return 'Enter valid quantity';
                    if (qty > product.stockQuantity) {
                      return 'Insufficient stock';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text('Add to Sale'),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final quantity = int.parse(quantityController.text);
                        final totalPrice = product.price * quantity;

                        final authState = ref.read(authProvider);
                        final userId = authState?.user.id;

                        if (userId == null) return;

                        final sale = Sale(
                          id: '',
                          productId: product.id.toString(),
                          quantity: quantity,
                          total: totalPrice,
                          date: DateTime.now().toIso8601String(),
                          userId: userId.toString(),
                        );

                        final service = SalesService();
                        final result = await service.createSale(token, sale);

                        if (result.hasException) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to add: ${result.exception}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        ref.invalidate(salesProvider);
                        ref.invalidate(productsProvider);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added $quantity x ${product.name}',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    final filteredProducts = productsAsync.maybeWhen(
      data: (products) => products
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList(),
      orElse: () => <Product>[],
    );

    return AppShell(
      title: 'Product Catalog',
      showDrawer: true,
      body: PageWrapper(
        subtitle: 'Browse and add products to your sales orders.',
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Products Grid
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.inventory_2_rounded
                                : Icons.search_off_rounded,
                            size: 64,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No products available'
                                : 'No products found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width >= 1100
                          ? 4
                          : width >= 760
                          ? 3
                          : 2;
                      final childAspectRatio = width < 420 ? 0.68 : 0.78;

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final isOutOfStock = product.stockQuantity == 0;

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1.45,
                                      child: Container(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(18),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.72,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.inventory_2_rounded,
                                              size: width < 420 ? 36 : 44,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelLarge,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${product.price.toStringAsFixed(2)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: const Color(
                                                      0xFF10B981,
                                                    ),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isOutOfStock
                                                    ? Colors.red.withValues(
                                                        alpha: 0.1,
                                                      )
                                                    : const Color(
                                                        0xFF10B981,
                                                      ).withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                isOutOfStock
                                                    ? 'Out of stock'
                                                    : '${product.stockQuantity} in stock',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: isOutOfStock
                                                          ? Colors.red
                                                          : const Color(
                                                              0xFF10B981,
                                                            ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isOutOfStock)
                                  Container(
                                    color: Colors.white.withValues(alpha: 0.58),
                                  ),
                                Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: FloatingActionButton.small(
                                    heroTag: 'add_${product.id}',
                                    tooltip: isOutOfStock
                                        ? 'Out of stock'
                                        : 'Add to sale',
                                    onPressed: isOutOfStock
                                        ? null
                                        : () => _addToSale(product),
                                    backgroundColor: isOutOfStock
                                        ? Colors.grey
                                        : Theme.of(context).colorScheme.primary,
                                    child: Icon(
                                      isOutOfStock
                                          ? Icons.block_rounded
                                          : Icons.add_rounded,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text('Failed to load products: $error'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(productsProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
