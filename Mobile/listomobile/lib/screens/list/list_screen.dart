import 'package:flutter/material.dart';

import '../../models/item_lista_model.dart';
import '../../models/lista_model.dart';
import '../../services/item_lista_service.dart';
import 'widgets/item_form_dialog.dart';
import 'widgets/list_item_tile.dart';

class ListScreen extends StatefulWidget {
  final ListaModel lista;
  final int idPessoa;

  const ListScreen({super.key, required this.lista, required this.idPessoa});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _service = ItemListaService();
  final List<ItemListaModel> _items = [];
  final Set<int> _busyItems = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final idLista = widget.lista.idLista;
    if (idLista == null) return;
    setState(() => _loading = true);
    try {
      final items = await _service.listarPorLista(idLista);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(items);
      });
    } catch (error) {
      _message(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final result = await showDialog<ItemFormResult>(
      context: context,
      builder: (_) => const ItemFormDialog(),
    );
    final idLista = widget.lista.idLista;
    if (result == null || idLista == null) return;
    setState(() => _loading = true);
    try {
      final created = await _service.criarItem(
        ItemListaModel(
          nomeItem: result.name,
          idLista: idLista,
          isTarefa: result.isTask,
          quantidade: result.quantity,
        ),
        idPessoa: widget.idPessoa,
      );
      if (!mounted) return;
      setState(() => _items.add(created.copyWith(idLista: idLista)));
    } catch (error) {
      _message(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(ItemListaModel item, bool completed) async {
    final updated = item.copyWith(concluido: completed);
    await _runItemAction(item, () async {
      await _service.alterarConcluido(item: updated, idPessoa: widget.idPessoa);
      _replace(updated);
    });
  }

  Future<void> _changeQuantity(ItemListaModel item, int delta) async {
    final quantity = item.quantidade + delta;
    if (quantity < 1) return;
    final updated = item.copyWith(quantidade: quantity);
    await _runItemAction(item, () async {
      await _service.atualizarItem(updated, idPessoa: widget.idPessoa);
      _replace(updated);
    });
  }

  Future<void> _delete(ItemListaModel item) async {
    final id = item.idItem;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apagar ${item.isTarefa ? 'tarefa' : 'item'}?'),
        content: Text(item.nomeItem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runItemAction(item, () async {
      await _service.deletarItem(id, idPessoa: widget.idPessoa);
      if (mounted) {
        setState(() => _items.removeWhere((value) => value.idItem == id));
      }
    });
  }

  Future<void> _runItemAction(
    ItemListaModel item,
    Future<void> Function() action,
  ) async {
    final id = item.idItem;
    if (id == null) return;
    setState(() => _busyItems.add(id));
    try {
      await action();
    } catch (error) {
      _message(error);
    } finally {
      if (mounted) setState(() => _busyItems.remove(id));
    }
  }

  void _replace(ItemListaModel updated) {
    if (!mounted) return;
    setState(() {
      final index = _items.indexWhere((item) => item.idItem == updated.idItem);
      if (index >= 0) _items[index] = updated;
    });
  }

  void _message(Object error) {
    if (!mounted) return;
    final text = error.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final completed = _items.where((item) => item.concluido).length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.lista.nomeLista)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _add,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.checklist, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_items.length} itens na lista',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('$completed concluídos'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_loading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 20),
            if (!_loading && _items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 56),
                child: Column(
                  children: [
                    Icon(Icons.playlist_add, size: 56),
                    SizedBox(height: 12),
                    Text('Esta lista ainda está vazia.'),
                    Text('Adicione uma tarefa ou um item para começar.'),
                  ],
                ),
              ),
            ..._items.map(
              (item) => ListItemTile(
                item: item,
                busy: item.idItem != null && _busyItems.contains(item.idItem),
                onCompletedChanged: (value) => _toggle(item, value),
                onDecrease: () => _changeQuantity(item, -1),
                onIncrease: () => _changeQuantity(item, 1),
                onDelete: () => _delete(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
