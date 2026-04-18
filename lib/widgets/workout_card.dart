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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(level, style: const TextStyle(color: Colors.grey)),
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

