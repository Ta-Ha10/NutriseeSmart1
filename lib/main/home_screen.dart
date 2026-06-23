import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:nutriseesmart1/main/menu_screen.dart';

import '../services/daily_nutrition_service.dart';
import '../services/firestore_service.dart';
import '../services/water_intake_service.dart';
import '../utils/models/daily_nutrition_log.dart';
import '../utils/models/daily_water_log.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/components.dart';
import 'water_tracker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<Map<String, dynamic>?> _userDataFuture;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUserData();
  }

  Future<Map<String, dynamic>?> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return FirestoreService.getUserData(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2EDE9),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _userDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Couldn\'t load your profile data.'),
                );
              }

              final name =
                  _readString(
                    _readMap(snapshot.data, 'personalData'),
                    'name',
                  ) ??
                  'Athlete';
              final menuWidth = MediaQuery.of(context).size.width * 0.6;
              return Stack(
                children: [
                  HomeBody(
                    userData: snapshot.data,
                    onMenuTap: () => setState(() => _isMenuOpen = true),
                  ),
                  if (_isMenuOpen) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: menuWidth,
                        height: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: MenuScreen(
                            userName: name,
                            onClose: () => setState(() => _isMenuOpen = false),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onMenuTap;

  const HomeBody({super.key, this.userData, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final personalData = _readMap(userData, 'personalData');
    final dietPlan = _readMap(userData, 'dietPlan');
    final user = FirebaseAuth.instance.currentUser;
    final targetCalories =
        _readNum(dietPlan, 'targetCalories')?.toDouble() ??
        _readNum(dietPlan, 'tdee')?.toDouble() ??
        0;
    final targetCarbs = _readNum(dietPlan, 'carbGrams')?.toDouble() ?? 0;
    final targetProtein = _readNum(dietPlan, 'proteinGrams')?.toDouble() ?? 0;
    final targetFats = _readNum(dietPlan, 'fatGrams')?.toDouble() ?? 0;
    final currentWeight = _readNum(personalData, 'currentWeight');
    final waterGoalMl = _waterGoalFromWeight(currentWeight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeHeader(
          name: _readString(personalData, 'name') ?? 'Athlete',
          onMenuTap: onMenuTap,
        ),
        const SizedBox(height: 20),
        if (user == null)
          NutritionOverview(
            targetCalories: targetCalories,
            remainingCalories: targetCalories,
            carbs: targetCarbs,
            remainingCarbs: targetCarbs,
            protein: targetProtein,
            remainingProtein: targetProtein,
            fats: targetFats,
            remainingFats: targetFats,
          )
        else
          StreamBuilder<DailyNutritionLog>(
            stream: DailyNutritionService.watchTodayLog(
              uid: user.uid,
              targetCalories: targetCalories,
              targetCarbs: targetCarbs,
              targetProtein: targetProtein,
              targetFat: targetFats,
            ),
            builder: (context, snapshot) {
              final log = snapshot.data;
              return NutritionOverview(
                targetCalories: targetCalories,
                remainingCalories: log?.remainingCalories ?? targetCalories,
                carbs: targetCarbs,
                remainingCarbs: log?.remainingCarbs ?? targetCarbs,
                protein: targetProtein,
                remainingProtein: log?.remainingProtein ?? targetProtein,
                fats: targetFats,
                remainingFats: log?.remainingFat ?? targetFats,
              );
            },
          ),
        const SizedBox(height: 20),
        const ActionButtons(),
        const SizedBox(height: 20),
        WaterIntakeGraph(uid: user?.uid, targetMl: waterGoalMl),
      ],
    );
  }
}

class HomeHeader extends StatelessWidget {
  final String name;
  final VoidCallback onMenuTap;

  const HomeHeader({super.key, required this.name, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(onPressed: onMenuTap, icon: const Icon(Icons.menu)),
              Row(
                children: [
                  Gap(75),
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage(
                      'assets/Photoes/Profile Photo.png',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Good Morning,',
                        style: TextStyle(color: Colors.green),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.notifications_none),
      ],
    );
  }
}

class CalorieCard extends StatelessWidget {
  final double? targetCalories;
  final double? remainingCalories;

  const CalorieCard({super.key, this.targetCalories, this.remainingCalories});

  @override
  Widget build(BuildContext context) {
    final goalCalories = (targetCalories ?? 0).round();
    final remaining = (remainingCalories ?? targetCalories ?? 0).round();
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFF16A34A), width: 2.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'REMAINING',
              style: TextStyle(
                color: Color(0xFF616161),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              remaining > 0 ? '$remaining' : '--',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'GOAL ${goalCalories > 0 ? _formatCalories(goalCalories) : '--'}',
              style: const TextStyle(
                color: Color(0xFF7A7A7A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NutritionOverview extends StatelessWidget {
  final double? targetCalories;
  final double? remainingCalories;
  final double? carbs;
  final double? remainingCarbs;
  final double? protein;
  final double? remainingProtein;
  final double? fats;
  final double? remainingFats;

  const NutritionOverview({
    super.key,
    this.targetCalories,
    this.remainingCalories,
    this.carbs,
    this.remainingCarbs,
    this.protein,
    this.remainingProtein,
    this.fats,
    this.remainingFats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          CalorieCard(
            targetCalories: targetCalories,
            remainingCalories: remainingCalories,
          ),
          const SizedBox(height: 30),
          MacrosRow(
            carbs: carbs,
            remainingCarbs: remainingCarbs,
            protein: protein,
            remainingProtein: remainingProtein,
            fats: fats,
            remainingFats: remainingFats,
          ),
        ],
      ),
    );
  }
}

class MacrosRow extends StatelessWidget {
  final double? carbs;
  final double? remainingCarbs;
  final double? protein;
  final double? remainingProtein;
  final double? fats;
  final double? remainingFats;

  const MacrosRow({
    super.key,
    this.carbs,
    this.remainingCarbs,
    this.protein,
    this.remainingProtein,
    this.fats,
    this.remainingFats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MacroCard(
          title: 'Carbs',
          amountLabel: _macroLabel(remainingCarbs, carbs),
          accentColor: const Color(0xFF3B82F6),
        ),
        MacroCard(
          title: 'Protein',
          amountLabel: _macroLabel(remainingProtein, protein),
          accentColor: const Color(0xFF16A34A),
        ),
        MacroCard(
          title: 'Fats',
          amountLabel: _macroLabel(remainingFats, fats),
          accentColor: const Color(0xFFEAB308),
        ),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WaterTrackerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.water_drop_outlined),
                label: const Text('Water Tracker'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WaterIntakeGraph extends StatelessWidget {
  final String? uid;
  final int targetMl;

  const WaterIntakeGraph({
    super.key,
    required this.uid,
    required this.targetMl,
  });

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Expanded(
        child: Center(
          child: Text(
            'Sign in to view your water history.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return Expanded(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('dailyWater')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          final logsByDate = <String, DailyWaterLog>{
            for (final doc in snapshot.data?.docs ?? const [])
              doc.id: DailyWaterLog.fromMap(doc.id, doc.data()),
          };
          final weekStart = DateTime.now().subtract(const Duration(days: 6));
          final days = List.generate(
            7,
            (index) => weekStart.add(Duration(days: index)),
          );
          final maxValue = [
            targetMl,
            ...logsByDate.values.map((log) => log.consumedMl),
          ].fold<int>(1, (max, value) => value > max ? value : max);
          const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
          final todayKey = WaterIntakeService.dateString();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Water Intake',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Last 7 Days', style: TextStyle(color: Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(days.length, (index) {
                            final day = days[index];
                            final key = WaterIntakeService.dateString(day);
                            final log = logsByDate[key];
                            final consumed = log?.consumedMl ?? 0;
                            final isToday = key == todayKey;
                            final barHeight =
                                180 *
                                (maxValue == 0 ? 0.0 : consumed / maxValue);

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          width: 18,
                                          height: barHeight,
                                          decoration: BoxDecoration(
                                            color: isToday
                                                ? const Color(0xFF49B44E)
                                                : const Color(0xFFBFE8C3),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      labels[index],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isToday
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isToday
                                            ? const Color(0xFF49B44E)
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$consumed ml',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Goal $targetMl ml per day',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Map<String, dynamic>? _readMap(Map<String, dynamic>? source, String key) {
  final value = source?[key];
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map(
      (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
    );
  }
  return null;
}

String? _readString(Map<String, dynamic>? source, String key) {
  final value = source?[key];
  return value is String && value.trim().isNotEmpty ? value : null;
}

num? _readNum(Map<String, dynamic>? source, String key) {
  final value = source?[key];
  return value is num ? value : null;
}

String _macroLabel(double? remainingGrams, double? targetGrams) {
  final remaining = remainingGrams?.round() ?? 0;
  final target = targetGrams?.round() ?? 0;
  return '${remaining > 0 ? remaining : 0}/${target > 0 ? target : '--'}g';
}

String _formatCalories(int value) {
  final text = value.toString();
  if (text.length <= 3) {
    return text;
  }

  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    buffer.write(text[i]);
    final remaining = text.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

int _waterGoalFromWeight(num? currentWeight) {
  if (currentWeight == null || currentWeight <= 0) {
    return 2000;
  }
  return (currentWeight * 35).round();
}
