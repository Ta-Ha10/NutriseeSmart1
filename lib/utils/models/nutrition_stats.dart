import 'daily_nutrition_log.dart';

class NutritionStats {
  final List<DailyNutritionLog> logs;

  const NutritionStats({required this.logs});

  double get averageCalories {
    if (logs.isEmpty) return 0;
    return logs.fold(0.0, (total, log) => total + log.consumedCalories) /
        logs.length;
  }

  double get totalCalories =>
      logs.fold(0, (total, log) => total + log.consumedCalories);

  double get totalCarbs =>
      logs.fold(0, (total, log) => total + log.consumedCarbs);
  double get totalProtein =>
      logs.fold(0, (total, log) => total + log.consumedProtein);
  double get totalFat => logs.fold(0, (total, log) => total + log.consumedFat);
}
