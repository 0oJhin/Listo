import 'package:flutter/material.dart';

import '../../../models/item_lista_model.dart';

class ListItemTile extends StatelessWidget {
  final ItemListaModel item;
  final bool busy;
  final ValueChanged<bool> onCompletedChanged;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onDelete;

  const ListItemTile({
    super.key,
    required this.item,
    required this.busy,
    required this.onCompletedChanged,
    required this.onDecrease,
    required this.onIncrease,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final muted = item.concluido
        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)
        : Theme.of(context).colorScheme.onSurface;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: item.concluido,
              onChanged: busy
                  ? null
                  : (value) => onCompletedChanged(value ?? false),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nomeItem,
                    style: TextStyle(
                      color: muted,
                      fontWeight: FontWeight.w600,
                      decoration: item.concluido
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  Text(
                    item.isTarefa ? 'Tarefa' : 'Item',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!item.isTarefa)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: busy || item.quantidade <= 1
                          ? null
                          : onDecrease,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.remove, size: 18),
                    ),
                    Text(
                      '${item.quantidade}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: busy ? null : onIncrease,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),
            IconButton(
              onPressed: busy ? null : onDelete,
              tooltip: 'Apagar',
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
