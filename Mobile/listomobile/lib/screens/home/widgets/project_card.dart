import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onOptionsPressed;

  const ProjectCard({
    super.key,
    required this.name,
    required this.color,
    this.onTap,
    this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      shadowColor: const Color(0x33000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 34, 16, 16),
              child: Center(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (onOptionsPressed != null)
              Positioned(
                top: 2,
                right: 2,
                child: IconButton(
                  onPressed: onOptionsPressed,
                  tooltip: 'Opções do projeto',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.more_vert),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
