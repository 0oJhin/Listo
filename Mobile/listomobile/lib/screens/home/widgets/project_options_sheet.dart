import 'package:flutter/material.dart';

enum ProjectAction { rename, delete }

class ProjectOptionsSheet extends StatelessWidget {
  final String projectName;

  const ProjectOptionsSheet({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              projectName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _OptionTile(
              icon: Icons.edit_outlined,
              title: 'Alterar nome',
              onTap: () => Navigator.pop(context, ProjectAction.rename),
            ),
            const _OptionTile(
              icon: Icons.group_outlined,
              title: 'Gerenciar membros',
              subtitle: 'Em breve',
              enabled: false,
            ),
            _OptionTile(
              icon: Icons.delete_outline,
              title: 'Apagar projeto',
              destructive: true,
              onTap: () => Navigator.pop(context, ProjectAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool enabled;
  final bool destructive;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.enabled = true,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      enabled: enabled,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: enabled ? color : null),
      title: Text(title, style: enabled ? TextStyle(color: color) : null),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: enabled
          ? const Icon(Icons.chevron_right)
          : const Icon(Icons.lock_outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
