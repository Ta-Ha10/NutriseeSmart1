import 'package:flutter/material.dart';
import '../../widgets/components.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F4EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              DateHeader(),
              SizedBox(height: 16),
              CaloriesSummaryCard(),
              SizedBox(height: 20),
              Expanded(child: MealsList()),
            ],
          ),
        ),
      ),
    );
  }
}

class DateHeader extends StatelessWidget {
  const DateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text('Today, Oct 24', style: TextStyle(fontWeight: FontWeight.bold)),
        Icon(Icons.settings),
      ],
    );
  }
}

class CaloriesSummaryCard extends StatelessWidget {
  const CaloriesSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          Text('CALORIES REMAINING', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 6),
          Text('1,240', style: TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          MacroProgress(label: 'Carbs', value: '12 / 250g', progress: 0.05),
          MacroProgress(label: 'Protein', value: '40 / 140g', progress: 0.3),
          MacroProgress(label: 'Fat', value: '10 / 70g', progress: 0.15),
        ],
      ),
    );
  }
}

class MealsList extends StatelessWidget {
  const MealsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        MealSection(title: 'Breakfast', kcal: '450', foods: [
          FoodItem(name: 'Oatmeal & Berries', kcal: '350', imagePath: 'assets/Photoes/img 1.png'),
          FoodItem(name: 'Orange Juice', kcal: '100', imagePath: 'assets/Photoes/im2.png'),
        ]),
        MealSection(title: 'Lunch', kcal: '310', foods: [
          FoodItem(name: 'Grilled Chicken Salad', kcal: '310', imagePath: 'assets/Photoes/img 3.png'),
        ]),
        MealSection(title: 'Dinner', kcal: '0', foods: []),
        MealSection(title: 'Snacks', kcal: '0', foods: []),
      ],
    );
  }
}

class MealSection extends StatelessWidget {
  final String title;
  final String kcal;
  final List<FoodItem> foods;

  const MealSection({super.key, required this.title, required this.kcal, required this.foods});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('$kcal kcal', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        ...foods,
        AddFoodButton(
          label: title == 'Dinner' ? 'Log Dinner' : 'Add food +',
          onTap: () {
            // Navigate to the LogMealPage (left column) for logging
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

