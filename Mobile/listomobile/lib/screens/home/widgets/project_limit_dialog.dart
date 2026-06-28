import 'package:flutter/material.dart';

class ProjectLimitDialog extends StatelessWidget {
  final VoidCallback onManagePlan;

  const ProjectLimitDialog({super.key, required this.onManagePlan});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.workspace_premium_outlined, size: 36),
      title: const Text('Limite do plano Default'),
      content: const Text(
        'O plano Default permite controlar apenas 1 projeto. '
        'Assine o Premium para criar projetos ilimitados.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Agora não'),
        ),
        FilledButton(
          onPressed: onManagePlan,
          child: const Text('Conhecer Premium'),
        ),
      ],
    );
  }
}
