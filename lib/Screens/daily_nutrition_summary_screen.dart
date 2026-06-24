import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../services/daily_nutrition_service.dart';
import '../services/firestore_service.dart';
import '../utils/models/daily_nutrition_log.dart';
import 'nutrition_history_screen.dart';

class DailyNutritionSummaryScreen extends StatefulWidget {
  const DailyNutritionSummaryScreen({super.key});

  @override
  State<DailyNutritionSummaryScreen> createState() =>
      _DailyNutritionSummaryScreenState();
}

class _DailyNutritionSummaryScreenState
    extends State<DailyNutritionSummaryScreen> {
  late final Future<_SummaryData?> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<_SummaryData?> _loadSummary() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userData = await FirestoreService.getUserData(user.uid);
    final dietPlan = _readMap(userData, 'dietPlan');
    final targetCalories =
        _readNum(dietPlan, 'targetCalories')?.toDouble() ??
        _readNum(dietPlan, 'tdee')?.toDouble() ??
        0;

    final log = await DailyNutritionService.getLog(
      uid: user.uid,
      targetCalories: targetCalories,
      targetCarbs: _readNum(dietPlan, 'carbGrams')?.toDouble() ?? 0,
      targetProtein: _readNum(dietPlan, 'proteinGrams')?.toDouble() ?? 0,
      targetFat: _readNum(dietPlan, 'fatGrams')?.toDouble() ?? 0,
    );
    return _SummaryData(uid: user.uid, log: log);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Daily Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: 'Nutrition history',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NutritionHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<_SummaryData?>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Could not load nutrition.'));
            }
            final data = snapshot.data;
            if (data == null) {
              return const Center(child: Text('Please sign in to view stats.'));
            }
            return _SummaryBody(log: data.log);
          },
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  final DailyNutritionLog log;

  const _SummaryBody({required this.log});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final grouped = log.mealsByType;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Text(
                'CALORIES REMAINING',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocaleController.formatNumber(log.remainingCalories.round()),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _MacroLine(
                label: 'Carbs',
                consumed: log.consumedCarbs,
                target: log.targetCarbs,
              ),
              _MacroLine(
                label: 'Protein',
                consumed: log.consumedProtein,
                target: log.targetProtein,
              ),
              _MacroLine(
                label: 'Fat',
                consumed: log.consumedFat,
                target: log.targetFat,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Meal Breakdown',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        if (log.meals.isEmpty)
          _EmptyMealCard()
        else
          ...['breakfast', 'lunch', 'dinner', 'snacks'].map((type) {
            return _MealTypeSection(
              title: _title(type),
              meals: grouped[type] ?? const [],
            );
          }),
      ],
    );
  }

  static String _title(String value) {
    return value.isEmpty
        ? value
        : '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _MacroLine extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;

  const _MacroLine({
    required this.label,
    required this.consumed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = target > 0 ? consumed / target : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${consumed.round()} / ${target.round()}g'),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            color: colorScheme.primary,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

class _MealTypeSection extends StatelessWidget {
  final String title;
  final List<dynamic> meals;

  const _MealTypeSection({required this.title, required this.meals});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (meals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...meals.map(
            (meal) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.restaurant, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meal.recipeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('${meal.calories.round()} kcal'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMealCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Text('No meals logged today.'),
    );
  }
}

class _SummaryData {
  final String uid;
  final DailyNutritionLog log;

  const _SummaryData({required this.uid, required this.log});
}

Map<String, dynamic>? _readMap(Map<String, dynamic>? source, String key) {
  final value = source?[key];
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map(
      (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
    );
  }
  return null;
}

num? _readNum(Map<String, dynamic>? source, String key) {
  final value = source?[key];
  return value is num ? value : null;
}
