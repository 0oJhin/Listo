import 'package:flutter/material.dart';

import '../../../models/lista_model.dart';

enum ListAction { rename, duplicate, delete }

class ProjectListCard extends StatelessWidget {
  final ListaModel lista;
  final Color color;
  final int itemCount;
  final VoidCallback onOpen;
  final ValueChanged<ListAction> onAction;

  const ProjectListCard({
    super.key,
    required this.lista,
    required this.color,
    required this.itemCount,
    required this.onOpen,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 58,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lista.nomeLista,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'itens'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<ListAction>(
                tooltip: 'Opções da lista',
                onSelected: onAction,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: ListAction.rename,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Renomear'),
                    ),
                  ),
                  PopupMenuItem(
                    value: ListAction.duplicate,
                    child: ListTile(
                      leading: Icon(Icons.copy_outlined),
                      title: Text('Gerar uma cópia'),
                    ),
                  ),
                  PopupMenuItem(
                    value: ListAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Apagar'),
                    ),
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
