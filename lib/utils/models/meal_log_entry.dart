import 'package:cloud_firestore/cloud_firestore.dart';

class MealLogEntry {
  final String id;
  final String mealType;
  final String recipeId;
  final String recipeName;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final String? imageUrl;
  final DateTime loggedAt;

  const MealLogEntry({
    required this.id,
    required this.mealType,
    required this.recipeId,
    required this.recipeName,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.imageUrl,
    required this.loggedAt,
  });

  factory MealLogEntry.fromMap(Map<String, dynamic> data) {
    return MealLogEntry(
      id: _stringValue(data['id']) ?? '',
      mealType: _stringValue(data['mealType']) ?? 'meal',
      recipeId: _stringValue(data['recipeId']) ?? '',
      recipeName: _stringValue(data['recipeName']) ?? 'Meal',
      calories: _doubleValue(data['calories']),
      carbs: _doubleValue(data['carbs']),
      protein: _doubleValue(data['protein']),
      fat: _doubleValue(data['fat']),
      imageUrl: _stringValue(data['imageUrl']),
      loggedAt: _dateValue(data['loggedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mealType': mealType,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'loggedAt': Timestamp.fromDate(loggedAt),
    };
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final direct = double.tryParse(value.trim());
      if (direct != null) return direct;
      final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(value);
      if (match != null) return double.tryParse(match.group(0)!) ?? 0;
    }
    return 0;
  }

  static DateTime _dateValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
