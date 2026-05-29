import 'package:flutter/material.dart';
import 'package:gap/gap.dart';



class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  const Header(),
                  const SizedBox(height: 16),
                  const Tabs(),
                  const SizedBox(height: 16),
              WorkoutCard(
                title: "Low Intensity Burn",
                level: "Beginner",
                image:
                "assets/Photoes/exercise1.png",
              ),
              const SizedBox(height: 16),
              WorkoutCard(
                title: "Medium Intensity Burn",
                level: "Moderate",
                image: "assets/Photoes/exercise2.png",
              ),

              WorkoutCard(
                title: "High Intensity Burn",
                level: "Advanced",
                image: "assets/Photoes/exercies3.png",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class Header extends StatelessWidget {
  const Header({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back) , iconSize: 30,),
        Gap(90),
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(
              "assets/Photoes/Profile Photo.png"),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Good Morning,",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text("Alex Johnson",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        )
      ],
    );
  }
}

class Tabs extends StatelessWidget {
  const Tabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.green, borderRadius: BorderRadius.circular(20)),
          child: const Text("Home", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(20)),
          child: const Text("GYM", style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final String title;
  final String level;
  final String image;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.level,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(image, height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(level,
                          style: const TextStyle(
                              color: Colors.green, fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("20 min",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(width: 12),
                    Icon(Icons.local_fire_department,
                        size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text("300 Kcal",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Start Workout"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
