import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final bool darkModeEnabled;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onLogout;

  const SettingsDialog({
    super.key,
    required this.darkModeEnabled,
    required this.onDarkModeChanged,
    required this.onLogout,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _darkModeEnabled = widget.darkModeEnabled;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurações'),
      content: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.dark_mode_outlined),
        title: const Text('Modo escuro'),
        value: _darkModeEnabled,
        onChanged: (enabled) {
          setState(() => _darkModeEnabled = enabled);
          widget.onDarkModeChanged(enabled);
        },
      ),
      actions: [
        TextButton.icon(
          onPressed: widget.onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
