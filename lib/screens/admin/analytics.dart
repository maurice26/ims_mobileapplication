import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/report_provider.dart';
import '../../providers/sales_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesProvider);
    final reportAsync = ref.watch(reportProvider('monthly'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sales Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 200,
            child: salesAsync.when(
              data: (sales) {
                final spots = sales
                    .take(7)
                    .map(
                      (sale) =>
                          FlSpot(sales.indexOf(sale).toDouble(), sale.total),
                    )
                    .toList();
                return BarChart(
                  BarChartData(
                    barGroups: spots
                        .map(
                          (spot) => BarChartGroupData(
                            x: spot.x.toInt(),
                            barRods: [BarChartRodData(toY: spot.y)],
                          ),
                        )
                        .toList(),
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
          ),
          Expanded(
            child: reportAsync.when(
              data: (report) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Total Sales: ${report.totalSales}'),
                  Text('Total Revenue: \$${report.totalRevenue}'),
                  Text('Period: ${report.period}'),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }
}
