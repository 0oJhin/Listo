import 'package:flutter/material.dart';

class AddProjectCard extends StatelessWidget {
  final VoidCallback onPressed;

  const AddProjectCard({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF42443F)
          : const Color(0xFFD0D0D6),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: const Center(
          child: Icon(Icons.add, size: 42, color: Color(0xFF596247)),
        ),
      ),
    );
  }
}
