import 'package:flutter/material.dart';

class EmptyProjectsPrompt extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyProjectsPrompt({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF354025) : const Color(0xFFD5E898),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(Icons.create_new_folder_outlined, size: 54),
          const SizedBox(height: 16),
          const Text(
            'Vamos fazer o seu primeiro projeto?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Criar projeto'),
          ),
        ],
      ),
    );
  }
}
