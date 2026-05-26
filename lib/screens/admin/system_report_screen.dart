import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../providers/payment_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/system_report_pdf_service.dart';

class SystemReportScreen extends ConsumerWidget {
  const SystemReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> generateAndPrint() async {
      final loadedUsers = await ref.read(usersProvider.future);
      final loadedProducts = await ref.read(productsProvider.future);
      final loadedSuppliers = await ref.read(suppliersProvider.future);
      final loadedSales = await ref.read(salesProvider.future);
      final loadedPayments = await ref.read(paymentsProvider.future);
      final totalRevenue = loadedSales.fold<double>(
        0,
        (sum, sale) => sum + sale.total,
      );
      final totalPayments = loadedPayments.fold<double>(
        0,
        (sum, payment) => sum + payment.amount,
      );

      final bytes = await SystemReportPdfService().generateSystemPdf(
        totalUsers: loadedUsers.length,
        totalProducts: loadedProducts.length,
        totalSuppliers: loadedSuppliers.length,
        totalSales: loadedSales.length,
        totalRevenue: totalRevenue,
        totalPayments: totalPayments,
        users: loadedUsers
            .map((u) => {'name': u.name, 'email': u.email, 'role': u.role})
            .toList(),
        suppliers: loadedSuppliers
            .map((s) => {'name': s.name, 'contactInfo': s.contact})
            .toList(),
        products: loadedProducts
            .map(
              (p) => {
                'name': p.name,
                'price': p.price,
                'stockQuantity': p.stockQuantity,
              },
            )
            .toList(),
        sales: loadedSales
            .map(
              (sale) => {
                'id': sale.id,
                'productId': sale.productId,
                'quantity': sale.quantity,
                'total': sale.total,
              },
            )
            .toList(),
        payments: loadedPayments
            .map(
              (pay) => {
                'id': pay.id,
                'saleId': pay.saleId,
                'amount': pay.amount,
                'method': pay.method,
              },
            )
            .toList(),
      );

      await Printing.layoutPdf(onLayout: (_) async => bytes);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Report (PDF)'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Generate a full system PDF summary: users, products, suppliers, total sales, and total revenue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Generate & Print PDF'),
                onPressed: () async {
                  await generateAndPrint();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
