import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
                subtitle: Text('Total: \$${sale.total}\nDate: ${sale.date}'),
                trailing: IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () async {
                    await _generateAndPrintInvoice(context, sale);
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

  Future<void> _generateAndPrintInvoice(BuildContext context, sale) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Invoice #: ${sale.id}'),
            pw.Text('Date: ${sale.date}'),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.Text('Product ID: ${sale.productId}'),
            pw.Text('Quantity: ${sale.quantity}'),
            pw.Text('Total: \$${sale.total.toStringAsFixed(2)}'),
            pw.SizedBox(height: 16),
            pw.Text('Thank you for your business!'),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
