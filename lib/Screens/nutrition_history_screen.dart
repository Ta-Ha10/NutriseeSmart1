import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    return '${monthNames[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2EDE9),
      appBar: AppBar(
        backgroundColor: const Color(0xffF2EDE9),
        elevation: 0,
        title: const Text('Nutrition History'),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
      body: SafeArea(
        child: FutureBuilder<_HistoryData?>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            }

            final history = snapshot.data;
            if (history == null) {
              return const Center(
                child: Text('Please sign in to view your meal logs.'),
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
                        'Today, ${_formatDateLabel(DateTime.now())}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.calendar_month_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This Week',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black87,
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
    final weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
                    ? Colors.green
                    : (isToday ? Colors.orange.shade50 : Colors.white),
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
                      ? Colors.green
                      : (isToday
                            ? Colors.orange.shade300
                            : Colors.grey.shade200),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdayLabels[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isToday ? Colors.orange : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : (isToday
                                ? Colors.orange.shade100
                                : Colors.grey.shade100),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.green
                              : (isToday ? Colors.orange : Colors.black87),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 14),
          MacroProgress(
            label: 'Calories',
            value:
                '${log.consumedCalories.round()} / ${log.targetCalories.round()} kcal',
            progress: log.targetCalories > 0
                ? log.consumedCalories / log.targetCalories
                : 0,
          ),
          MacroProgress(
            label: 'Carbs',
            value:
                '${log.consumedCarbs.round()} / ${log.targetCarbs.round()} g',
            progress: log.targetCarbs > 0
                ? log.consumedCarbs / log.targetCarbs
                : 0,
          ),
          MacroProgress(
            label: 'Protein',
            value:
                '${log.consumedProtein.round()} / ${log.targetProtein.round()} g',
            progress: log.targetProtein > 0
                ? log.consumedProtein / log.targetProtein
                : 0,
          ),
          MacroProgress(
            label: 'Fat',
            value: '${log.consumedFat.round()} / ${log.targetFat.round()} g',
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
        const Text(
          'Meals',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        _MealGroup(
          title: 'Breakfast',
          meals: mealsByType['breakfast'] ?? const [],
        ),
        _MealGroup(title: 'Lunch', meals: mealsByType['lunch'] ?? const []),
        _MealGroup(title: 'Dinner', meals: mealsByType['dinner'] ?? const []),
        _MealGroup(title: 'Snacks', meals: mealsByType['snacks'] ?? const []),
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
    if (meals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$title: no meals logged yet.',
            style: const TextStyle(color: Colors.black54),
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
              kcal: meal.calories.round().toString(),
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
