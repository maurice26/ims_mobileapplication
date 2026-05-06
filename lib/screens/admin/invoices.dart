import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sales_provider.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: salesAsync.when(
        data: (sales) => ListView.builder(
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('Invoice #${sale.id}'),
                subtitle: Text('Total: \$${sale.total}'),
                trailing: IconButton(
                  icon: Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    // TODO: Generate PDF invoice
                  },
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
