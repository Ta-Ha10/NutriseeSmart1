import 'meal_log_entry.dart';

class DailyNutritionLog {
  final String dateString;
  final List<MealLogEntry> meals;
  final double targetCalories;
  final double targetCarbs;
  final double targetProtein;
  final double targetFat;

  const DailyNutritionLog({
    required this.dateString,
    required this.meals,
    required this.targetCalories,
    required this.targetCarbs,
    required this.targetProtein,
    required this.targetFat,
  });

  factory DailyNutritionLog.empty({
    required String dateString,
    required double targetCalories,
    required double targetCarbs,
    required double targetProtein,
    required double targetFat,
  }) {
    return DailyNutritionLog(
      dateString: dateString,
      meals: const [],
      targetCalories: targetCalories,
      targetCarbs: targetCarbs,
      targetProtein: targetProtein,
      targetFat: targetFat,
    );
  }

  factory DailyNutritionLog.fromMap(
    String dateString,
    Map<String, dynamic>? data,
  ) {
    final rawMeals = data?['meals'];
    final meals = rawMeals is List
        ? rawMeals
              .whereType<Map>()
              .map(
                (meal) => MealLogEntry.fromMap(
                  meal.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList()
        : <MealLogEntry>[];

    return DailyNutritionLog(
      dateString: dateString,
      meals: meals,
      targetCalories: _doubleValue(data?['targetCalories']),
      targetCarbs: _doubleValue(data?['targetCarbs']),
      targetProtein: _doubleValue(data?['targetProtein']),
      targetFat: _doubleValue(data?['targetFat']),
    );
  }

  double get consumedCalories =>
      meals.fold(0, (total, meal) => total + meal.calories);
  double get consumedCarbs =>
      meals.fold(0, (total, meal) => total + meal.carbs);
  double get consumedProtein =>
      meals.fold(0, (total, meal) => total + meal.protein);
  double get consumedFat => meals.fold(0, (total, meal) => total + meal.fat);

  double get remainingCalories => _remaining(targetCalories, consumedCalories);
  double get remainingCarbs => _remaining(targetCarbs, consumedCarbs);
  double get remainingProtein => _remaining(targetProtein, consumedProtein);
  double get remainingFat => _remaining(targetFat, consumedFat);

  Map<String, List<MealLogEntry>> get mealsByType {
    final grouped = <String, List<MealLogEntry>>{};
    for (final meal in meals) {
      grouped.putIfAbsent(meal.mealType, () => []).add(meal);
    }
    return grouped;
  }

  Map<String, dynamic> toMap() {
    return {
      'dateString': dateString,
      'targetCalories': targetCalories,
      'targetCarbs': targetCarbs,
      'targetProtein': targetProtein,
      'targetFat': targetFat,
      'totalCalories': consumedCalories,
      'totalCarbs': consumedCarbs,
      'totalProtein': consumedProtein,
      'totalFat': consumedFat,
      'remainingCalories': remainingCalories,
      'remainingCarbs': remainingCarbs,
      'remainingProtein': remainingProtein,
      'remainingFat': remainingFat,
      'meals': meals.map((meal) => meal.toMap()).toList(),
    };
  }

  static double _remaining(double target, double consumed) {
    final value = target - consumed;
    return value < 0 ? 0 : value;
  }

  static double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0;
    return 0;
  }
}
