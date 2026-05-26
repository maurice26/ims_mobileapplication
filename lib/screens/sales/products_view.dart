import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/product_provider.dart';
import '../../widgets/role_guard.dart';

class ProductsViewScreen extends ConsumerWidget {
  const ProductsViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return RoleGuard(
      requiredRole: 'sales',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products View'),
          backgroundColor: const Color(0xFF8B5CF6),
        ),
        body: productsAsync.when(
          data: (products) => ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  title: Text(product.name),
                  trailing: Text('\$${product.price}'),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
