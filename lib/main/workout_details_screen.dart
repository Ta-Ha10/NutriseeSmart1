import 'package:flutter/material.dart';
import 'workout_timer_screen.dart';
import '../widgets/stat_chip.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  const WorkoutDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Details"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "LOW INTENSITY BURN",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "15 : 20",
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              StatChip(icon: Icons.local_fire_department, text: "125 kcal"),
              SizedBox(width: 12),
              StatChip(icon: Icons.favorite, text: "140 bpm"),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text("Jumping Jacks"),
                  trailing: Text("03:00"),
                ),
                ListTile(
                  leading: Icon(Icons.radio_button_unchecked),
                  title: Text("High Knees"),
                  trailing: Text("02:00"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkoutTimerScreen(),
                  ),
                );
              },
              child: const Text("Start Workout"),
            ),
          ),
        ],
      ),
    );
  }
}

