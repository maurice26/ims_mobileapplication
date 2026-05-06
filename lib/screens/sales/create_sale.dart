import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../../models/sale.dart';
import '../../providers/product_provider.dart';

class CreateSaleScreen extends ConsumerStatefulWidget {
  const CreateSaleScreen({super.key});

  @override
  ConsumerState<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends ConsumerState<CreateSaleScreen> {
  Product? selectedProduct;
  int quantity = 1;

  double get total =>
      selectedProduct != null ? selectedProduct!.price * quantity : 0.0;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Sale'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            productsAsync.when(
              data: (products) => DropdownButtonFormField<Product>(
                decoration: const InputDecoration(labelText: 'Product'),
                items: products
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (p) => setState(() => selectedProduct = p),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => quantity = int.tryParse(v) ?? 1),
            ),
            const SizedBox(height: 20),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedProduct != null ? _createSale : null,
              child: const Text('Create Sale'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSale() async {
    final sale = Sale(
      id: '',
      productId: selectedProduct!.id.toString(),
      quantity: quantity,
      total: total,
      date: DateTime.now().toIso8601String(),
      userId: 'current',
    );
    // ref.read(salesProvider.notifier).createSale(sale);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sale created!')));
    Navigator.pop(context);
  }
}
