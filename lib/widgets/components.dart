import 'package:flutter/material.dart';

class MacroCard extends StatelessWidget {
  final String title;
  final String amountLabel;
  final double progress;
  final Color accentColor;

  const MacroCard({
    super.key,
    required this.title,
    this.amountLabel = '0g',
    this.progress = 0,
    this.accentColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amountLabel,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7A7A7A),
            ),
          ),
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
