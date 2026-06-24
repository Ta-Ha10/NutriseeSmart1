import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final String level;
  final VoidCallback onTap;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, color: scheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(level, style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onTap,
              child: const Text("Start Workout"),
            ),
          ],
        ),
      ),
    );
  }
}
