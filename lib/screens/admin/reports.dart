import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/report_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download Sales Report (CSV)'),
              onPressed: () {
                // ref.read(reportServiceProvider).downloadReport('sales', 'csv');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Downloading...')));
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate Sales Report (PDF)'),
              onPressed: () {
                // TODO: PDF generation with printing/pdf
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ref
                  .watch(reportProvider('sales'))
                  .when(
                    data: (report) => ListView(
                      children: [
                        ListTile(title: Text('Type: ${report.type}')),
                        ListTile(title: Text('Period: ${report.period}')),
                        ListTile(
                          title: Text('Total Sales: ${report.totalSales}'),
                        ),
                        ListTile(
                          title: Text('Revenue: \$${report.totalRevenue}'),
                        ),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text('Error: $e'),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
