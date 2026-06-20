import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/models/daily_nutrition_log.dart';
import '../utils/models/meal_log_entry.dart';

class DailyNutritionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String dateString([DateTime? date]) {
    final value = date ?? DateTime.now();
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  static Stream<DailyNutritionLog> watchTodayLog({
    required String uid,
    required double targetCalories,
    required double targetCarbs,
    required double targetProtein,
    required double targetFat,
  }) {
    final today = dateString();
    return _dailyDoc(uid, today).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return DailyNutritionLog.empty(
          dateString: today,
          targetCalories: targetCalories,
          targetCarbs: targetCarbs,
          targetProtein: targetProtein,
          targetFat: targetFat,
        );
      }

      final log = DailyNutritionLog.fromMap(today, snapshot.data());
      return _withFallbackTargets(
        log,
        targetCalories: targetCalories,
        targetCarbs: targetCarbs,
        targetProtein: targetProtein,
        targetFat: targetFat,
      );
    });
  }

  static Future<DailyNutritionLog> getLog({
    required String uid,
    DateTime? date,
    required double targetCalories,
    required double targetCarbs,
    required double targetProtein,
    required double targetFat,
  }) async {
    final key = dateString(date);
    final snapshot = await _dailyDoc(uid, key).get();
    if (!snapshot.exists) {
      return DailyNutritionLog.empty(
        dateString: key,
        targetCalories: targetCalories,
        targetCarbs: targetCarbs,
        targetProtein: targetProtein,
        targetFat: targetFat,
      );
    }

    final log = DailyNutritionLog.fromMap(key, snapshot.data());
    return _withFallbackTargets(
      log,
      targetCalories: targetCalories,
      targetCarbs: targetCarbs,
      targetProtein: targetProtein,
      targetFat: targetFat,
    );
  }

  static Future<List<DailyNutritionLog>> getLogsForRange({
    required String uid,
    required DateTime start,
    required DateTime end,
    required double targetCalories,
    required double targetCarbs,
    required double targetProtein,
    required double targetFat,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyNutrition')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: dateString(start))
        .where(FieldPath.documentId, isLessThanOrEqualTo: dateString(end))
        .orderBy(FieldPath.documentId)
        .get();

    return snapshot.docs.map((doc) {
      final log = DailyNutritionLog.fromMap(doc.id, doc.data());
      return _withFallbackTargets(
        log,
        targetCalories: targetCalories,
        targetCarbs: targetCarbs,
        targetProtein: targetProtein,
        targetFat: targetFat,
      );
    }).toList();
  }

  static Future<void> logMeal({
    required String uid,
    required String mealType,
    required Map<String, dynamic> recipe,
    required double targetCalories,
    required double targetCarbs,
    required double targetProtein,
    required double targetFat,
  }) async {
    final today = dateString();
    final docRef = _dailyDoc(uid, today);
    final now = DateTime.now();
    final entry = MealLogEntry(
      id: '${now.microsecondsSinceEpoch}',
      mealType: mealType,
      recipeId: _recipeId(recipe),
      recipeName: _recipeName(recipe),
      calories: _nutritionValue(recipe, const [
        'calories',
        'kcal',
        'calories_kcal',
        'energy_kcal',
        'energy',
      ]),
      carbs: _nutritionValue(recipe, const [
        'carbs',
        'carb',
        'carbohydrates',
        'carbohydrate',
        'carbohydrate_g',
      ]),
      protein: _nutritionValue(recipe, const [
        'protein',
        'proteins',
        'protein_g',
      ]),
      fat: _nutritionValue(recipe, const [
        'fat',
        'fats',
        'total_fat',
        'fat_g',
        'fat_grams',
      ]),
      imageUrl: _imageUrl(recipe),
      loggedAt: now,
    );

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final existing = snapshot.exists
          ? DailyNutritionLog.fromMap(today, snapshot.data())
          : DailyNutritionLog.empty(
              dateString: today,
              targetCalories: targetCalories,
              targetCarbs: targetCarbs,
              targetProtein: targetProtein,
              targetFat: targetFat,
            );

      final updated = DailyNutritionLog(
        dateString: today,
        meals: [...existing.meals, entry],
        targetCalories: targetCalories,
        targetCarbs: targetCarbs,
        targetProtein: targetProtein,
        targetFat: targetFat,
      );

      transaction.set(docRef, {
        ...updated.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  static DocumentReference<Map<String, dynamic>> _dailyDoc(
    String uid,
    String date,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyNutrition')
        .doc(date);
  }

  static DailyNutritionLog _withFallbackTargets(
    DailyNutritionLog log, {
    required double targetCalories,
    required double targetCarbs,
    required double targetProtein,
    required double targetFat,
  }) {
    return DailyNutritionLog(
      dateString: log.dateString,
      meals: log.meals,
      targetCalories: log.targetCalories > 0
          ? log.targetCalories
          : targetCalories,
      targetCarbs: log.targetCarbs > 0 ? log.targetCarbs : targetCarbs,
      targetProtein: log.targetProtein > 0 ? log.targetProtein : targetProtein,
      targetFat: log.targetFat > 0 ? log.targetFat : targetFat,
    );
  }

  static String _recipeName(Map<String, dynamic> recipe) {
    return (recipe['recipe_name'] ??
            recipe['recipeName'] ??
            recipe['name'] ??
            'Meal')
        .toString();
  }

  static String _recipeId(Map<String, dynamic> recipe) {
    for (final key in ['id', 'recipe_id', 'recipeId', 'uri', 'url']) {
      final value = recipe[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return _recipeName(recipe)
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static String? _imageUrl(Map<String, dynamic> recipe) {
    for (final key in [
      'image_url',
      'imageUrl',
      'image',
      'photo',
      'thumbnail',
    ]) {
      final value = recipe[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static double _nutritionValue(
    Map<String, dynamic> recipe,
    List<String> keys,
  ) {
    final nutrition = recipe['nutrition'];
    for (final key in keys.expand((key) => [key, _camelCase(key)])) {
      final value = nutrition is Map ? _lookup(nutrition, key) : null;
      final parsed = _number(value);
      if (parsed != null) return parsed;
    }

    for (final key in keys.expand((key) => [key, _camelCase(key)])) {
      final parsed = _number(_lookup(recipe, key));
      if (parsed != null) return parsed;
    }
    return 0;
  }

  static dynamic _lookup(Map<dynamic, dynamic> data, String key) {
    if (data.containsKey(key)) return data[key];
    final normalized = _normalize(key);
    for (final entry in data.entries) {
      if (_normalize(entry.key.toString()) == normalized) {
        return entry.value;
      }
    }
    return null;
  }

  static double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final direct = double.tryParse(value.trim());
      if (direct != null) return direct;
      final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(value);
      if (match != null) return double.tryParse(match.group(0)!);
    }
    return null;
  }

  static String _normalize(String key) {
    return key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static String _camelCase(String key) {
    final parts = key.split('_');
    if (parts.length < 2) return key;
    return parts.first +
        parts
            .skip(1)
            .map(
              (part) => part.isEmpty
                  ? ''
                  : '${part[0].toUpperCase()}${part.substring(1)}',
            )
            .join();
  }
}
