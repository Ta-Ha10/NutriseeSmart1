import 'package:flutter/material.dart';

class StatChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const StatChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: Colors.green),
      label: Text(text),
      backgroundColor: Colors.white,
    );
  }
}

