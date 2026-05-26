import 'package:flutter/material.dart';

class ImsTableRowActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool confirmDelete;
  final String? deleteLabel;

  const ImsTableRowActions({
    super.key,
    this.onEdit,
    this.onDelete,
    this.confirmDelete = true,
    this.deleteLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          Tooltip(
            message: 'Edit',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton.filledTonal(
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  Icons.edit_rounded,
                  color: theme.colorScheme.primary,
                ),
                onPressed: onEdit,
              ),
            ),
          ),
        if (onDelete != null) ...[
          Tooltip(
            message: 'Delete',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.35,
                  ),
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.delete_rounded),
                onPressed: () async {
                  if (!confirmDelete) {
                    onDelete?.call();
                    return;
                  }

                  final ok =
                      await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm delete'),
                          content: Text(
                            deleteLabel ??
                                'Are you sure you want to delete this item?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.errorContainer,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (ok) onDelete?.call();
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
