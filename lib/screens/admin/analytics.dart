import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/product_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_shell/page_wrapper.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final productsAsync = ref.watch(productsProvider);
    final suppliersAsync = ref.watch(suppliersProvider);
    final salesAsync = ref.watch(salesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: PageWrapper(
        subtitle: 'Track users, inventory, suppliers, sales volume, and revenue.',
        child: salesAsync.when(
          data: (sales) {
            final userCount = usersAsync.maybeWhen(
              data: (items) => items.length,
              orElse: () => 0,
            );
            final userLabel = usersAsync.maybeWhen(
              data: (items) => items.length.toString(),
              orElse: () => '--',
            );
            final products = productsAsync.maybeWhen(
              data: (items) => items,
              orElse: () => const [],
            );
            final productLabel = productsAsync.maybeWhen(
              data: (items) => items.length.toString(),
              orElse: () => '--',
            );
            final supplierCount = suppliersAsync.maybeWhen(
              data: (items) => items.length,
              orElse: () => 0,
            );
            final supplierLabel = suppliersAsync.maybeWhen(
              data: (items) => items.length.toString(),
              orElse: () => '--',
            );
            final totalRevenue = sales.fold<double>(
              0,
              (sum, sale) => sum + sale.total,
            );
            final recentSales = sales.take(7).toList();
            final inStock = products.where((product) => product.stockQuantity > 0).length;
            final outOfStock = products.length - inStock;

            return ListView(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SummaryTile(
                      label: 'Users',
                      value: userLabel,
                      icon: Icons.people_alt_rounded,
                    ),
                    _SummaryTile(
                      label: 'Products',
                      value: productLabel,
                      icon: Icons.inventory_2_rounded,
                    ),
                    _SummaryTile(
                      label: 'Suppliers',
                      value: supplierLabel,
                      icon: Icons.local_shipping_rounded,
                    ),
                    _SummaryTile(
                      label: 'Sales',
                      value: sales.length.toString(),
                      icon: Icons.point_of_sale_rounded,
                    ),
                    _SummaryTile(
                      label: 'Revenue',
                      value: '\$${totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.trending_up_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _PieChartCard(
                      title: 'System Distribution',
                      sections: [
                        _PieSection('Users', userCount.toDouble(), const Color(0xFF2563EB)),
                        _PieSection('Products', products.length.toDouble(), const Color(0xFF0891B2)),
                        _PieSection('Suppliers', supplierCount.toDouble(), const Color(0xFFEA580C)),
                        _PieSection('Sales', sales.length.toDouble(), const Color(0xFF16A34A)),
                      ],
                    ),
                    _PieChartCard(
                      title: 'Inventory Stock',
                      sections: [
                        _PieSection('In stock', inStock.toDouble(), const Color(0xFF16A34A)),
                        _PieSection('Out of stock', outOfStock.toDouble(), const Color(0xFFDC2626)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Sales Revenue',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 260,
                          child: recentSales.isEmpty
                              ? const Center(child: Text('No sales recorded yet.'))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: _chartMax(recentSales.map((s) => s.total)),
                                    gridData: const FlGridData(show: true),
                                    borderData: FlBorderData(show: false),
                                    titlesData: const FlTitlesData(
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                    barGroups: [
                                      for (var i = 0; i < recentSales.length; i++)
                                        BarChartGroupData(
                                          x: i + 1,
                                          barRods: [
                                            BarChartRodData(
                                              toY: recentSales[i].total,
                                              width: 18,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Could not load analytics: $error'),
          ),
        ),
      ),
    );
  }

  double _chartMax(Iterable<double> values) {
    final maxValue = values.fold<double>(0, (max, value) {
      return value > max ? value : max;
    });
    if (maxValue <= 0) return 100;
    return maxValue * 1.2;
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryTile({
    required this.label,
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
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  final String title;
  final List<_PieSection> sections;

  const _PieChartCard({
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final visibleSections = sections.where((section) => section.value > 0).toList();

    return SizedBox(
      width: 360,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: visibleSections.isEmpty
                    ? const Center(child: Text('No data available'))
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 36,
                          sections: [
                            for (final section in visibleSections)
                              PieChartSectionData(
                                value: section.value,
                                title: section.value.toStringAsFixed(0),
                                color: section.color,
                                radius: 54,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  for (final section in sections)
                    _LegendItem(
                      color: section.color,
                      label: section.label,
                      value: section.value.toStringAsFixed(0),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: $value'),
      ],
    );
  }
}

class _PieSection {
  final String label;
  final double value;
  final Color color;

  const _PieSection(this.label, this.value, this.color);
}
