import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Screens/Signup/meals_screen.dart';
import '../services/firestore_service.dart';
import '../utils/user_data.dart';
import '../widgets/components.dart';
import 'workout_screen.dart'; // added import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _saveSignupDataIfNeeded();
  }

  Future<void> _saveSignupDataIfNeeded() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && signupData.name != null) {
      // Check if user data already exists
      final existingData = await FirestoreService.getUserData(user.uid);
      if (existingData == null || existingData.isEmpty) {
        // Save signup data since it doesn't exist
        try {
          await FirestoreService.saveUserData(signupData);
          // Clear signup data after saving
          signupData.name = null;
          signupData.email = null;
          signupData.password = null;
          signupData.googleIdToken = null;
          signupData.googleAccessToken = null;
          signupData.isGoogleSignIn = false;
        } catch (error) {
          // Handle error if needed
          print('Error saving user data: $error');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2EDE9),
      bottomNavigationBar: const AppBottomNav(),
      body: const SafeArea(
        child: Padding(padding: EdgeInsets.all(16), child: HomeBody()),
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        HomeHeader(),
        SizedBox(height: 20),
        CalorieCard(),
        SizedBox(height: 16),
        MacrosRow(),
        SizedBox(height: 20),
        ActionButtons(),
        SizedBox(height: 20),
        WeeklyIntake(),
      ],
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: const [
            CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/Photoes/Profile Photo.png'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good Morning,', style: TextStyle(color: Colors.green)),
                Text(
                  'Alex Johnson',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),

        const Icon(Icons.notifications_none),
      ],
    );
  }
}

class CalorieCard extends StatelessWidget {
  const CalorieCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Column(
          children: [
            Text('REMAINING', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text(
              '1,250',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('GOAL 2,500'),
          ],
        ),
      ),
    );
  }
}

class MacrosRow extends StatelessWidget {
  const MacrosRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MacroCard(title: 'Carbs'),
        MacroCard(title: 'Protein'),
        MacroCard(title: 'Fats'),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              // Navigate to the meals screen
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MealsScreen()));
            },
            icon: const Icon(Icons.restaurant),
            label: const Text('Add Meal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              // Navigate to the workout screen
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const WorkoutScreen()));
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text('Workout'),
          ),
        ),
      ],
    );
  }
}

class WeeklyIntake extends StatelessWidget {
  const WeeklyIntake({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Weekly Intake',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('View Report', style: TextStyle(color: Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
      ],
    );
  }
}
