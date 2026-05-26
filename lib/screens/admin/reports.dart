import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/report_service.dart';
import '../../services/system_report_pdf_service.dart';
import '../../widgets/app_shell/page_wrapper.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final products = ref.watch(productsProvider);
    final suppliers = ref.watch(suppliersProvider);
    final sales = ref.watch(salesProvider);
    final payments = ref.watch(paymentsProvider);

    final totalRevenue = sales.maybeWhen(
      data: (items) => items.fold<double>(0, (sum, sale) => sum + sale.total),
      orElse: () => 0,
    );
    final totalPaid = payments.maybeWhen(
      data: (items) =>
          items.fold<double>(0, (sum, payment) => sum + payment.amount),
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: PageWrapper(
        subtitle:
            'Operational summary across users, inventory, sales, and payments.',
        child: ListView(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  title: 'Users',
                  value: users.maybeWhen(
                    data: (items) => '${items.length}',
                    orElse: () => '--',
                  ),
                  icon: Icons.people_alt_rounded,
                ),
                _MetricCard(
                  title: 'Products',
                  value: products.maybeWhen(
                    data: (items) => '${items.length}',
                    orElse: () => '--',
                  ),
                  icon: Icons.inventory_2_rounded,
                ),
                _MetricCard(
                  title: 'Suppliers',
                  value: suppliers.maybeWhen(
                    data: (items) => '${items.length}',
                    orElse: () => '--',
                  ),
                  icon: Icons.local_shipping_rounded,
                ),
                _MetricCard(
                  title: 'Sales',
                  value: sales.maybeWhen(
                    data: (items) => '${items.length}',
                    orElse: () => '--',
                  ),
                  icon: Icons.point_of_sale_rounded,
                ),
                _MetricCard(
                  title: 'Revenue',
                  value: '\$${totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.trending_up_rounded,
                ),
                _MetricCard(
                  title: 'Payments',
                  value: '\$${totalPaid.toStringAsFixed(2)}',
                  icon: Icons.payments_rounded,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Generate full system PDF'),
              onPressed: () => _generateSystemReport(context, ref),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download sales CSV'),
              onPressed: () => _downloadSalesReport(context, ref),
            ),
            const SizedBox(height: 16),
            sales.when(
              data: (items) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent sales',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (items.isEmpty)
                        const Text('No sales recorded yet.')
                      else
                        for (final sale in items.take(8))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.receipt_long_rounded),
                            title: Text(
                              'Sale ${sale.id} - \$${sale.total.toStringAsFixed(2)}',
                            ),
                            subtitle: Text(
                              'Product ${sale.productId} | Qty ${sale.quantity}',
                            ),
                            trailing: Text(_shortDate(sale.date)),
                          ),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Could not load sales: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadSalesReport(BuildContext context, WidgetRef ref) async {
    final token = ref.read(authProvider)?.token;
    if (token == null) return;

    try {
      final bytes = await ReportService().downloadReport(token, 'sales', 'csv');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sales CSV generated (${bytes.lengthInBytes} bytes).',
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report download failed: $error')),
        );
      }
    }
  }

  Future<void> _generateSystemReport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
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
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('System report failed: $error')));
      }
    }
  }

  String _shortDate(String value) {
    if (value.length >= 10) return value.substring(0, 10);
    return value;
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(height: 14),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
