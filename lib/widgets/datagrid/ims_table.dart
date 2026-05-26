import 'package:flutter/material.dart';

typedef RowBuilder<T> = DataRow Function(T item);

class ImsTable<T> extends StatelessWidget {
  final List<T> items;
  final List<DataColumn> columns;
  final RowBuilder<T> rowBuilder;
  final Widget? empty;

  const ImsTable({
    super.key,
    required this.items,
    required this.columns,
    required this.rowBuilder,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return empty ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No data available',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useList = constraints.maxWidth < 520;
        if (useList) {
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final row = rowBuilder(items[index]);
              final cells = row.cells;
              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < cells.length; i++) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _columnLabel(columns[i].label),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 3),
                              cells[i].child,
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemCount: items.length,
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns,
            rows: items.map(rowBuilder).toList(),
            headingRowColor: WidgetStateProperty.resolveWith(
              (states) => Theme.of(context).colorScheme.primaryContainer,
            ),
            dataRowColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.hovered)
                  ? Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.45)
                  : Colors.transparent,
            ),
            dataRowMinHeight: 56,
            dataRowMaxHeight: 72,
            columnSpacing: 20,
            horizontalMargin: 12,
          ),
        );
      },
    );
  }

  String _columnLabel(Widget label) {
    if (label is Text) return label.data ?? '';
    return '';
  }
}
