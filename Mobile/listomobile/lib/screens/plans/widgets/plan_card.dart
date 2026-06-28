import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final List<String> benefits;
  final Widget? action;
  final bool current;

  const PlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.benefits,
    this.action,
    this.current = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: current
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (current)
                const Chip(
                  avatar: Icon(Icons.check_circle, size: 18),
                  label: Text('Plano atual'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle),
          const SizedBox(height: 16),
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_rounded, size: 20),
                  const SizedBox(width: 9),
                  Expanded(child: Text(benefit)),
                ],
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: action),
          ],
        ],
      ),
    );
  }
}
