import 'package:flutter/material.dart';

import '../../../../models/pessoa_projeto_model.dart';

enum GuestAction { levelOne, levelTwo, transferOwnership }

class GuestTile extends StatelessWidget {
  final PessoaProjetoModel member;
  final bool canManage;
  final bool canTransferOwnership;
  final ValueChanged<GuestAction> onAction;

  const GuestTile({
    super.key,
    required this.member,
    required this.canManage,
    required this.canTransferOwnership,
    required this.onAction,
  });

  String get _role {
    return switch (member.nivelAcesso) {
      3 => 'Dono',
      2 => 'Editor',
      _ => 'Leitor',
    };
  }

  @override
  Widget build(BuildContext context) {
    final canShowMenu =
        member.nivelAcesso != 3 && (canManage || canTransferOwnership);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            member.pessoa.nomePessoa.trim().isEmpty
                ? '?'
                : member.pessoa.nomePessoa.trim()[0].toUpperCase(),
          ),
        ),
        title: Text(member.pessoa.nomePessoa),
        subtitle: Text(member.pessoa.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(label: Text(_role)),
            if (canShowMenu)
              PopupMenuButton<GuestAction>(
                onSelected: onAction,
                itemBuilder: (_) => [
                  if (canManage && member.nivelAcesso != 2)
                    const PopupMenuItem(
                      value: GuestAction.levelTwo,
                      child: Text('Tornar editor · nível 2'),
                    ),
                  if (canManage && member.nivelAcesso != 1)
                    const PopupMenuItem(
                      value: GuestAction.levelOne,
                      child: Text('Tornar leitor · nível 1'),
                    ),
                  if (canTransferOwnership)
                    const PopupMenuItem(
                      value: GuestAction.transferOwnership,
                      child: Text('Transferir propriedade'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
