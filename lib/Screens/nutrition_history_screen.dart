import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../services/daily_nutrition_service.dart';
import '../services/firestore_service.dart';
import '../utils/models/daily_nutrition_log.dart';
import '../utils/models/meal_log_entry.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/components.dart';

class NutritionHistoryScreen extends StatefulWidget {
  const NutritionHistoryScreen({super.key});

  @override
  State<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends State<NutritionHistoryScreen> {
  late final Future<_HistoryData?> _historyFuture;
  int selectedDayIndex = DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<_HistoryData?> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userData = await FirestoreService.getUserData(user.uid);
    final dietPlan = _readMap(userData, 'dietPlan');
    final targetCalories =
        _readNum(dietPlan, 'targetCalories')?.toDouble() ??
        _readNum(dietPlan, 'tdee')?.toDouble() ??
        0;
    final targetCarbs = _readNum(dietPlan, 'carbGrams')?.toDouble() ?? 0;
    final targetProtein = _readNum(dietPlan, 'proteinGrams')?.toDouble() ?? 0;
    final targetFat = _readNum(dietPlan, 'fatGrams')?.toDouble() ?? 0;

    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 6));
    final logs = await DailyNutritionService.getLogsForRange(
      uid: user.uid,
      start: start,
      end: end,
      targetCalories: targetCalories,
      targetCarbs: targetCarbs,
      targetProtein: targetProtein,
      targetFat: targetFat,
    );

    return _HistoryData(
      userData: userData,
      logs: logs,
      startDate: start,
      endDate: end,
    );
  }

  List<DateTime> _weekDays() {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  String _formatDateLabel(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[date.month - 1]} ${AppLocaleController.formatNumber(date.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(AppStrings.nutritionHistory(context)),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
      body: SafeArea(
        child: FutureBuilder<_HistoryData?>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }

            final history = snapshot.data;
            if (history == null) {
              return Center(
                child: Text(AppStrings.pleaseSignInMealLogs(context)),
              );
            }

            final days = _weekDays();
            final selectedDate = days[selectedDayIndex];
            final selectedKey = DailyNutritionService.dateString(selectedDate);
            final selectedLogIndex = history.logs.indexWhere(
              (log) => log.dateString == selectedKey,
            );
            final selectedLog = selectedLogIndex >= 0
                ? history.logs[selectedLogIndex]
                : DailyNutritionLog.empty(
                    dateString: selectedKey,
                    targetCalories:
                        _readNum(
                          _readMap(history.userData, 'dietPlan'),
                          'targetCalories',
                        )?.toDouble() ??
                        _readNum(
                          _readMap(history.userData, 'dietPlan'),
                          'tdee',
                        )?.toDouble() ??
                        0,
                    targetCarbs:
                        _readNum(
                          _readMap(history.userData, 'dietPlan'),
                          'carbGrams',
                        )?.toDouble() ??
                        0,
                    targetProtein:
                        _readNum(
                          _readMap(history.userData, 'dietPlan'),
                          'proteinGrams',
                        )?.toDouble() ??
                        0,
                    targetFat:
                        _readNum(
                          _readMap(history.userData, 'dietPlan'),
                          'fatGrams',
                        )?.toDouble() ??
                        0,
                  );

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppStrings.today(context)}, ${_formatDateLabel(DateTime.now())}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.calendar_month_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.thisWeek(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildWeekDaySelector(days),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DailySummaryCard(log: selectedLog),
                          const SizedBox(height: 16),
                          _MealsForDay(log: selectedLog),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeekDaySelector(List<DateTime> weekDays) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = weekDays[index];
          final isSelected = index == selectedDayIndex;
          final isToday =
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return GestureDetector(
            onTap: () => setState(() => selectedDayIndex = index),
            child: Container(
              width: 55,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : (isToday
                          ? colorScheme.secondaryContainer
                          : colorScheme.surface),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : (isToday
                            ? colorScheme.secondary
                            : colorScheme.outlineVariant),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.weekdayShortLabel(context, index),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : (isToday
                                ? colorScheme.secondary
                                : colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : (isToday
                                ? colorScheme.secondaryContainer
                                : colorScheme.surfaceContainerHighest),
                    ),
                    child: Center(
                      child: Text(
                        AppLocaleController.formatNumber(date.day),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? colorScheme.primary
                              : (isToday
                                    ? colorScheme.secondary
                                    : colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  final DailyNutritionLog log;

  const _DailySummaryCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.nutritionSummary(context),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 14),
          MacroProgress(
            label: AppStrings.calories(context),
            value:
                '${AppLocaleController.formatNumber(log.consumedCalories.round())} / ${AppLocaleController.formatNumber(log.targetCalories.round())} kcal',
            progress: log.targetCalories > 0
                ? log.consumedCalories / log.targetCalories
                : 0,
          ),
          MacroProgress(
            label: AppStrings.carbs(context),
            value:
                '${AppLocaleController.formatNumber(log.consumedCarbs.round())} / ${AppLocaleController.formatNumber(log.targetCarbs.round())} g',
            progress: log.targetCarbs > 0
                ? log.consumedCarbs / log.targetCarbs
                : 0,
          ),
          MacroProgress(
            label: AppStrings.protein(context),
            value:
                '${AppLocaleController.formatNumber(log.consumedProtein.round())} / ${AppLocaleController.formatNumber(log.targetProtein.round())} g',
            progress: log.targetProtein > 0
                ? log.consumedProtein / log.targetProtein
                : 0,
          ),
          MacroProgress(
            label: AppStrings.fat(context),
            value:
                '${AppLocaleController.formatNumber(log.consumedFat.round())} / ${AppLocaleController.formatNumber(log.targetFat.round())} g',
            progress: log.targetFat > 0 ? log.consumedFat / log.targetFat : 0,
          ),
        ],
      ),
    );
  }
}

class _MealsForDay extends StatelessWidget {
  final DailyNutritionLog log;

  const _MealsForDay({required this.log});

  @override
  Widget build(BuildContext context) {
    final mealsByType = log.mealsByType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.meals(context),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        _MealGroup(
          title: AppStrings.breakfast(context),
          meals: mealsByType['breakfast'] ?? const [],
        ),
        _MealGroup(title: AppStrings.lunch(context), meals: mealsByType['lunch'] ?? const []),
        _MealGroup(title: AppStrings.dinner(context), meals: mealsByType['dinner'] ?? const []),
        _MealGroup(title: AppStrings.snacks(context), meals: mealsByType['snacks'] ?? const []),
      ],
    );
  }
}

class _MealGroup extends StatelessWidget {
  final String title;
  final List<MealLogEntry> meals;

  const _MealGroup({required this.title, required this.meals});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (meals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            '$title: ${AppStrings.noMealsLogged(context)}',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...meals.map(
            (meal) => FoodItem(
              name: meal.recipeName,
              kcal: AppLocaleController.formatNumber(meal.calories.round()),
              imagePath: meal.imageUrl,
              isNetworkImage:
                  meal.imageUrl != null && meal.imageUrl!.startsWith('http'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryData {
  final Map<String, dynamic>? userData;
  final List<DailyNutritionLog> logs;
  final DateTime startDate;
  final DateTime endDate;

  const _HistoryData({
    required this.userData,
    required this.logs,
    required this.startDate,
    required this.endDate,
  });
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
