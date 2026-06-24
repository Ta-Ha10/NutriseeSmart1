import 'package:flutter/material.dart';

class StatChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const StatChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(icon, color: scheme.primary),
      label: Text(text),
      backgroundColor: scheme.surface,
    );
  }
}
