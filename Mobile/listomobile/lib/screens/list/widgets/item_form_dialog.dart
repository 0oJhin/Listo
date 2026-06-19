import 'package:flutter/material.dart';

class ItemFormResult {
  final String name;
  final bool isTask;
  final int quantity;

  const ItemFormResult({
    required this.name,
    required this.isTask,
    required this.quantity,
  });
}

class ItemFormDialog extends StatefulWidget {
  const ItemFormDialog({super.key});

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  bool _isTask = true;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (name.isEmpty || (!_isTask && quantity < 1)) return;
    Navigator.pop(
      context,
      ItemFormResult(
        name: name,
        isTask: _isTask,
        quantity: _isTask ? 1 : quantity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar à lista'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.check_circle_outline),
                  label: Text('Tarefa'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.inventory_2_outlined),
                  label: Text('Item'),
                ),
              ],
              selected: {_isTask},
              onSelectionChanged: (value) {
                setState(() => _isTask = value.first);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: _isTask ? 'Nome da tarefa' : 'Nome do item',
                border: const OutlineInputBorder(),
              ),
            ),
            if (!_isTask) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade inicial',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Adicionar')),
      ],
    );
  }
}
