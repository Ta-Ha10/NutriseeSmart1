import 'package:flutter/material.dart';
import 'workout_details_screen.dart';
import '../widgets/workout_card.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WorkoutCard(
            title: "Low Intensity Burn",
            level: "Beginner",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WorkoutDetailsScreen(),
                ),
              );
            },
          ),
          WorkoutCard(
            title: "Medium Intensity Burn",
            level: "Moderate",
            onTap: () {},
          ),
          WorkoutCard(
            title: "High Intensity Burn",
            level: "Advanced",
            onTap: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}
