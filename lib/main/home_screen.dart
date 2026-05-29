import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:nutriseesmart1/main/workout_screen.dart';
import 'package:nutriseesmart1/main/menu_screen.dart';

import '../Screens/Signup/meals_screen.dart';
import '../services/firestore_service.dart';
import '../widgets/components.dart';

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
      bottomNavigationBar: const AppBottomNav(),
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
                  child: Text('Could not load your profile data.'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeHeader(
          name: _readString(personalData, 'name') ?? 'Athlete',
          onMenuTap: onMenuTap,
        ),
        const SizedBox(height: 20),
        NutritionOverview(
          targetCalories: _readNum(dietPlan, 'targetCalories')?.toDouble() ?? _readNum(dietPlan, 'tdee')?.toDouble(),
          carbs: _readNum(dietPlan, 'carbGrams')?.toDouble(),
          protein: _readNum(dietPlan, 'proteinGrams')?.toDouble(),
          fats: _readNum(dietPlan, 'fatGrams')?.toDouble(),
        ),
        const SizedBox(height: 20),
        const ActionButtons(),
        const SizedBox(height: 20),
        const WeeklyIntake(),
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

  const CalorieCard({super.key, this.targetCalories});

  @override
  Widget build(BuildContext context) {
    final goalCalories = (targetCalories ?? 0).round();
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
              goalCalories > 0 ? '$goalCalories' : '--',
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
  final double? carbs;
  final double? protein;
  final double? fats;

  const NutritionOverview({
    super.key,
    this.targetCalories,
    this.carbs,
    this.protein,
    this.fats,
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
          CalorieCard(targetCalories: targetCalories),
          const SizedBox(height: 30),
          MacrosRow(carbs: carbs, protein: protein, fats: fats),
        ],
      ),
    );
  }
}

class MacrosRow extends StatelessWidget {
  final double? carbs;
  final double? protein;
  final double? fats;

  const MacrosRow({super.key, this.carbs, this.protein, this.fats});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MacroCard(
          title: 'Carbs',
          amountLabel: _macroLabel(carbs),
          accentColor: const Color(0xFF3B82F6),
        ),
        MacroCard(
          title: 'Protein',
          amountLabel: _macroLabel(protein),
          accentColor: const Color(0xFF16A34A),
        ),
        MacroCard(
          title: 'Fats',
          amountLabel: _macroLabel(fats),
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
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              // Navigate to the meals screen
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MealsScreen()));
            },
            icon: const Icon(Icons.restaurant),
            label: const Text('Add Meal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              // Navigate to the workout screen
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const WorkoutScreen()));
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text('Workout'),
          ),
        ),
      ],
    );
  }
}

class WeeklyIntake extends StatelessWidget {
  const WeeklyIntake({super.key});

  @override
  Widget build(BuildContext context) {
    const weeklyValues = [0.18, 0.32, 0.28, 0.52, 0.46, 0.68, 0.61];
    const weekLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Weekly Intake',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('View Report', style: TextStyle(color: Colors.green)),
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
                      children: List.generate(weeklyValues.length, (index) {
                        final isHighlighted = weekLabels[index] == 'Sa';
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                                      height: 180 * weeklyValues[index],
                                      decoration: BoxDecoration(
                                        color: isHighlighted
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFFBFE8C3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  weekLabels[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isHighlighted
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isHighlighted
                                        ? const Color(0xFF4CAF50)
                                        : Colors.black87,
                                  ),
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
          ),
        ],
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: SizedBox(
        height: 82,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.cottage_outlined,
                    color: const Color(0xFF76C98A),
                    onTap: () {},
                  ),
                  const _NavDivider(),
                  _NavItem(
                    icon: Icons.book_outlined,
                    color: const Color(0xFFD9D9D9),
                    onTap: () {},
                  ),
                  const _NavSpacer(),
                  const _NavDivider(),
                  _NavItem(
                    icon: Icons.query_stats_outlined,
                    color: const Color(0xFFD9D9D9),
                    onTap: () {},
                  ),
                  const _NavDivider(),
                  _NavItem(
                    icon: Icons.settings_suggest_outlined,
                    color: const Color(0xFFD9D9D9),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Color(0xFF49B44E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Center(child: Icon(icon, color: color, size: 30)),
      ),
    );
  }
}

class _NavDivider extends StatelessWidget {
  const _NavDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 54, color: const Color(0xFFEAEAEA));
  }
}

class _NavSpacer extends StatelessWidget {
  const _NavSpacer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 70);
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

String _macroLabel(double? grams) {
  final rounded = grams?.round() ?? 0;
  return '0/${rounded > 0 ? rounded : '--'}g';
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
