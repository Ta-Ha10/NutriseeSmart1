import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_nutrition_service.dart';
import '../services/firestore_service.dart';
import '../utils/models/daily_nutrition_log.dart';

class NutritionHistoryScreen extends StatefulWidget {
  const NutritionHistoryScreen({super.key});

  @override
  State<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends State<NutritionHistoryScreen> {
  late final Future<List<DailyNutritionLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = _loadLogs();
  }

  Future<List<DailyNutritionLog>> _loadLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const [];

    final userData = await FirestoreService.getUserData(user.uid);
    final dietPlan = _readMap(userData, 'dietPlan');
    final targetCalories =
        _readNum(dietPlan, 'targetCalories')?.toDouble() ??
        _readNum(dietPlan, 'tdee')?.toDouble() ??
        0;
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 6));

    return DailyNutritionService.getLogsForRange(
      uid: user.uid,
      start: start,
      end: end,
      targetCalories: targetCalories,
      targetCarbs: _readNum(dietPlan, 'carbGrams')?.toDouble() ?? 0,
      targetProtein: _readNum(dietPlan, 'proteinGrams')?.toDouble() ?? 0,
      targetFat: _readNum(dietPlan, 'fatGrams')?.toDouble() ?? 0,
    );
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
      body: SafeArea(
        child: FutureBuilder<List<DailyNutritionLog>>(
          future: _logsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            }
            final logs = snapshot.data ?? const [];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Intake',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (index) {
                            final date = DateTime.now().subtract(
                              Duration(days: 6 - index),
                            );
                            final key = DailyNutritionService.dateString(date);
                            final log = logs
                                .where((item) => item.dateString == key)
                                .cast<DailyNutritionLog?>()
                                .firstOrNull;
                            final target = log?.targetCalories ?? 0;
                            final consumed = log?.consumedCalories ?? 0;
                            final progress = target > 0
                                ? (consumed / target).clamp(0.05, 1.0)
                                : 0.05;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 120 * progress,
                                      width: 18,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _weekdayLabel(date.weekday),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (logs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text('No nutrition history yet.'),
                  )
                else
                  ...logs.reversed.map(
                    (log) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              log.dateString,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text('${log.consumedCalories.round()} kcal'),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return labels[weekday - 1];
  }
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
