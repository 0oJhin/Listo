import 'package:flutter/material.dart';

import '../../models/item_lista_model.dart';
import '../../models/lista_model.dart';
import '../../models/projeto_model.dart';
import '../../services/item_lista_service.dart';
import '../../services/lista_service.dart';
import '../list/list_screen.dart';
import 'guests/guests_screen.dart';
import 'widgets/list_form_dialog.dart';
import 'widgets/project_list_card.dart';

class ProjectScreen extends StatefulWidget {
  final ProjetoModel projeto;
  final int idPessoa;

  const ProjectScreen({
    super.key,
    required this.projeto,
    required this.idPessoa,
  });

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final _listService = ListaService();
  final _itemService = ItemListaService();
  final List<ListaModel> _lists = [];
  final Map<int, List<ItemListaModel>> _itemsByList = {};
  late ProjetoModel _project = widget.projeto;
  bool _loading = false;

  bool get _canEdit => _project.nivelAcesso >= 2;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final idProjeto = _project.idProjeto;
    if (idProjeto == null) return;
    setState(() => _loading = true);
    try {
      final lists = await _listService.listarPorProjeto(idProjeto);
      final itemGroups = await Future.wait(
        lists.map((list) async {
          final id = list.idLista;
          return MapEntry(
            id ?? -1,
            id == null
                ? <ItemListaModel>[]
                : await _itemService.listarPorLista(id),
          );
        }),
      );
      if (!mounted) return;
      setState(() {
        _lists
          ..clear()
          ..addAll(lists);
        _itemsByList
          ..clear()
          ..addEntries(itemGroups);
      });
    } catch (error) {
      _message(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createList() async {
    if (!_canEdit) return;
    final result = await showDialog<ListFormResult>(
      context: context,
      builder: (_) => const ListFormDialog(dialogTitle: 'Nova lista'),
    );
    final idProjeto = _project.idProjeto;
    if (result == null || idProjeto == null) return;
    await _run(() async {
      final created = await _listService.criarLista(
        ListaModel(nomeLista: result.title, idProjeto: idProjeto),
        idPessoa: widget.idPessoa,
      );
      final list = created.copyWith(idProjeto: idProjeto);
      if (!mounted) return;
      setState(() {
        _lists.add(list);
        if (list.idLista != null) {
          _itemsByList[list.idLista!] = [];
        }
      });
    }, successMessage: 'Lista criada.');
  }

  Future<void> _rename(ListaModel list) async {
    final result = await showDialog<ListFormResult>(
      context: context,
      builder: (_) => ListFormDialog(
        dialogTitle: 'Renomear lista',
        initialTitle: list.nomeLista,
      ),
    );
    if (result == null) return;
    final updated = list.copyWith(nomeLista: result.title);
    await _run(() async {
      await _listService.atualizarLista(updated, idPessoa: widget.idPessoa);
      _replaceList(updated);
    }, successMessage: 'Lista atualizada.');
  }

  Future<void> _duplicate(ListaModel source) async {
    if (!_canEdit) return;
    final idProjeto = _project.idProjeto;
    final sourceId = source.idLista;
    if (idProjeto == null || sourceId == null) return;

    await _run(() async {
      final sourceItems =
          _itemsByList[sourceId] ?? await _itemService.listarPorLista(sourceId);
      final created = await _listService.criarLista(
        ListaModel(
          nomeLista: '${source.nomeLista} - cópia',
          idProjeto: idProjeto,
        ),
        idPessoa: widget.idPessoa,
      );
      final createdId = created.idLista;
      if (createdId == null) throw Exception('A cópia foi criada sem ID.');
      final copiedItems = <ItemListaModel>[];
      for (final item in sourceItems) {
        final copied = await _itemService.criarItem(
          ItemListaModel(
            nomeItem: item.nomeItem,
            idLista: createdId,
            quantidade: item.quantidade,
            concluido: item.concluido,
            isTarefa: item.isTarefa,
          ),
          idPessoa: widget.idPessoa,
        );
        copiedItems.add(copied.copyWith(idLista: createdId));
      }
      if (!mounted) return;
      final copiedList = created.copyWith(idProjeto: idProjeto);
      setState(() {
        _lists.add(copiedList);
        _itemsByList[createdId] = copiedItems;
      });
    }, successMessage: 'Lista e itens copiados.');
  }

  Future<void> _delete(ListaModel list) async {
    if (!_canEdit) return;
    final id = list.idLista;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar lista?'),
        content: Text(
          '"${list.nomeLista}" e todos os seus itens serão apagados.',
        ),
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
    await _run(() async {
      final items = _itemsByList[id] ?? await _itemService.listarPorLista(id);
      for (final item in items) {
        if (item.idItem != null) {
          await _itemService.deletarItem(
            item.idItem!,
            idPessoa: widget.idPessoa,
          );
        }
      }
      await _listService.deletarLista(id, idPessoa: widget.idPessoa);
      if (!mounted) return;
      setState(() {
        _lists.removeWhere((value) => value.idLista == id);
        _itemsByList.remove(id);
      });
    }, successMessage: 'Lista apagada.');
  }

  Future<void> _open(ListaModel list) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListScreen(
          lista: list,
          idPessoa: widget.idPessoa,
          accessLevel: _project.nivelAcesso,
        ),
        settings: const RouteSettings(name: 'list'),
      ),
    );
    await _load();
  }

  Future<void> _handleAction(ListaModel list, ListAction action) async {
    if (!_canEdit) return;
    switch (action) {
      case ListAction.rename:
        await _rename(list);
        break;
      case ListAction.duplicate:
        await _duplicate(list);
        break;
      case ListAction.delete:
        await _delete(list);
        break;
    }
  }

  Future<void> _openGuests() async {
    final accessLevel = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GuestsScreen(project: _project, loggedPersonId: widget.idPessoa),
      ),
    );
    if (accessLevel != null && mounted) {
      setState(() {
        _project = _project.copyWith(nivelAcesso: accessLevel);
      });
    }
  }

  void _close() {
    Navigator.pop(context, _project);
  }

  Future<void> _run(
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    setState(() => _loading = true);
    try {
      await action();
      if (successMessage != null) _messageText(successMessage);
    } catch (error) {
      _message(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _replaceList(ListaModel updated) {
    if (!mounted) return;
    setState(() {
      final index = _lists.indexWhere(
        (value) => value.idLista == updated.idLista,
      );
      if (index >= 0) _lists[index] = updated;
    });
  }

  void _message(Object error) {
    _messageText(error.toString().replaceFirst('Exception: ', ''));
  }

  void _messageText(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_loading) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _loading ? null : _close,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(_project.nomeProjeto),
          actions: [
            TextButton.icon(
              onPressed: _openGuests,
              icon: const Icon(Icons.group_outlined),
              label: const Text('Convidados'),
            ),
          ],
        ),
        floatingActionButton: _canEdit
            ? FloatingActionButton.extended(
                onPressed: _loading ? null : _createList,
                icon: const Icon(Icons.playlist_add),
                label: const Text('Nova lista'),
              )
            : null,
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              Text(
                'Listas do projeto',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Organize tarefas e itens do seu jeito.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (_loading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
              const SizedBox(height: 22),
              if (!_loading && _lists.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 70),
                  child: Column(
                    children: [
                      Icon(Icons.view_list_outlined, size: 64),
                      SizedBox(height: 12),
                      Text(
                        'Este projeto ainda não tem listas.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Crie a primeira para começar a organizar.'),
                    ],
                  ),
                ),
              ..._lists.map(
                (list) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProjectListCard(
                    lista: list,
                    color: Theme.of(context).colorScheme.primary,
                    itemCount: _itemsByList[list.idLista]?.length ?? 0,
                    onOpen: () => _open(list),
                    onAction: _canEdit
                        ? (action) => _handleAction(list, action)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
