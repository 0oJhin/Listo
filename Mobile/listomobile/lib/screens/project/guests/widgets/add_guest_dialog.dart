import 'package:flutter/material.dart';

class AddGuestResult {
  final String email;
  final int accessLevel;

  const AddGuestResult({required this.email, required this.accessLevel});
}

class AddGuestDialog extends StatefulWidget {
  const AddGuestDialog({super.key});

  @override
  State<AddGuestDialog> createState() => _AddGuestDialogState();
}

class _AddGuestDialogState extends State<AddGuestDialog> {
  final _emailController = TextEditingController();
  int _accessLevel = 2;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;
    Navigator.pop(
      context,
      AddGuestResult(email: email, accessLevel: _accessLevel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar convidado'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail da pessoa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Nível de acesso',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            RadioGroup<int>(
              groupValue: _accessLevel,
              onChanged: (value) {
                if (value != null) setState(() => _accessLevel = value);
              },
              child: const Column(
                children: [
                  RadioListTile(
                    value: 2,
                    title: Text('Nível 2 · Editor'),
                    subtitle: Text(
                      'Pode editar tudo, exceto excluir o projeto.',
                    ),
                  ),
                  RadioListTile(
                    value: 1,
                    title: Text('Nível 1 · Leitor'),
                    subtitle: Text('Pode apenas marcar itens e tarefas.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Convidar')),
      ],
    );
  }
}
