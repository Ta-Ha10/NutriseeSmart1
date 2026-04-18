import 'package:flutter/material.dart';

class MacroCard extends StatelessWidget {
  final String title;
  const MacroCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const LinearProgressIndicator(value: 0),
          const SizedBox(height: 4),
          const Text('0/263g', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class MacroProgress extends StatelessWidget {
  final String label;
  final String value;
  final double progress;

  const MacroProgress({super.key, required this.label, required this.value, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value)],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 10),
      ],
    );
  }
}

class FoodItem extends StatelessWidget {
  final String name;
  final String kcal;
  final String? imagePath;

  const FoodItem({super.key, required this.name, required this.kcal, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (imagePath != null)
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Expanded(child: Text(name)),
              ],
            ),
          ),
          Text('$kcal kcal', style: const TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
}

class AddFoodButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap; // added callback

  const AddFoodButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.green)),
        ),
      ),
    );
  }
}
