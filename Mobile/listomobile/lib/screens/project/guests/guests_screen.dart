import 'package:flutter/material.dart';

import '../../../models/pessoa_projeto_model.dart';
import '../../../models/projeto_model.dart';
import '../../../services/pessoa_projeto_service.dart';
import 'widgets/add_guest_dialog.dart';
import 'widgets/guest_tile.dart';

class GuestsScreen extends StatefulWidget {
  final ProjetoModel project;
  final int loggedPersonId;

  const GuestsScreen({
    super.key,
    required this.project,
    required this.loggedPersonId,
  });

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  final _service = PessoaProjetoService();
  final List<PessoaProjetoModel> _members = [];
  late int _loggedAccessLevel = widget.project.nivelAcesso;
  bool _loading = false;

  bool get _canManage => _loggedAccessLevel >= 2;
  bool get _isOwner => _loggedAccessLevel == 3;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final idProjeto = widget.project.idProjeto;
    if (idProjeto == null) return;
    setState(() => _loading = true);
    try {
      final members = await _service.listarConvidados(idProjeto);
      if (!mounted) return;
      final loggedMember = members.where(
        (member) => member.pessoa.idPessoa == widget.loggedPersonId,
      );
      setState(() {
        _members
          ..clear()
          ..addAll(
            members..sort((a, b) => b.nivelAcesso.compareTo(a.nivelAcesso)),
          );
        if (loggedMember.isNotEmpty) {
          _loggedAccessLevel = loggedMember.first.nivelAcesso;
        }
      });
    } catch (error) {
      _message(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addGuest() async {
    final result = await showDialog<AddGuestResult>(
      context: context,
      builder: (_) => const AddGuestDialog(),
    );
    final idProjeto = widget.project.idProjeto;
    if (result == null || idProjeto == null) return;
    await _run(() async {
      await _service.adicionarPorEmail(
        idPessoaLogada: widget.loggedPersonId,
        idProjeto: idProjeto,
        email: result.email,
        nivelAcesso: result.accessLevel,
      );
      await _load();
    }, 'Convidado adicionado.');
  }

  Future<void> _changeLevel(PessoaProjetoModel member, int newLevel) async {
    final idProjeto = widget.project.idProjeto;
    final personId = member.pessoa.idPessoa;
    if (idProjeto == null || personId == null) return;
    await _run(() async {
      await _service.alterarNivel(
        idPessoaLogada: widget.loggedPersonId,
        idPessoaAlvo: personId,
        idProjeto: idProjeto,
        novoNivel: newLevel,
      );
      await _load();
    }, 'Nível de acesso atualizado.');
  }

  Future<void> _transferOwnership(PessoaProjetoModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.swap_horiz_rounded),
        title: const Text('Transferir propriedade?'),
        content: Text(
          '${member.pessoa.nomePessoa} se tornará a nova pessoa dona do '
          'projeto. Seu acesso passará para o nível 2.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Transferir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final idProjeto = widget.project.idProjeto;
    final newOwnerId = member.pessoa.idPessoa;
    if (idProjeto == null || newOwnerId == null) return;

    await _run(() async {
      await _service.transferirPropriedade(
        idDonoAtual: widget.loggedPersonId,
        idNovoDono: newOwnerId,
        idProjeto: idProjeto,
      );
      _loggedAccessLevel = 2;
      await _load();
    }, 'Propriedade transferida.');
  }

  Future<void> _handleAction(
    PessoaProjetoModel member,
    GuestAction action,
  ) async {
    switch (action) {
      case GuestAction.levelOne:
        await _changeLevel(member, 1);
        break;
      case GuestAction.levelTwo:
        await _changeLevel(member, 2);
        break;
      case GuestAction.transferOwnership:
        await _transferOwnership(member);
        break;
    }
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() => _loading = true);
    try {
      await action();
      _messageText(success);
    } catch (error) {
      _message(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(Object error) {
    _messageText(error.toString().replaceFirst('Exception: ', ''));
  }

  void _messageText(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _close() {
    Navigator.pop(context, _loggedAccessLevel);
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
          title: const Text('Convidados'),
        ),
        floatingActionButton: _canManage
            ? FloatingActionButton.extended(
                onPressed: _loading ? null : _addGuest,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Convidar'),
              )
            : null,
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              Text(
                'Pessoas do projeto',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Nível 2 edita o conteúdo. Nível 1 apenas marca itens.',
              ),
              if (_loading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
              const SizedBox(height: 20),
              ..._members.map(
                (member) => GuestTile(
                  member: member,
                  canManage: _canManage,
                  canTransferOwnership: _isOwner,
                  onAction: (action) => _handleAction(member, action),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
