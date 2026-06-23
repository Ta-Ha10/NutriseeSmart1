import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/water_intake_service.dart';
import '../utils/models/daily_water_log.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  static const _cupOptions = <_CupOption>[
    _CupOption(label: 'Small Cup', amountMl: 150, icon: Icons.local_cafe),
    _CupOption(label: 'Medium Cup', amountMl: 250, icon: Icons.local_drink),
    _CupOption(label: 'Large Cup', amountMl: 400, icon: Icons.water_drop),
  ];

  late final Future<Map<String, dynamic>?> _userDataFuture;
  int? _selectedCupIndex;
  int _optimisticConsumedMl = 0;

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

  Future<void> _drinkCup(int index, int goalMl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      _selectedCupIndex = index;
      _optimisticConsumedMl += _cupOptions[index].amountMl;
    });

    await WaterIntakeService.logWaterIntake(
      uid: user.uid,
      amountMl: _cupOptions[index].amountMl,
      targetMl: goalMl,
    );
  }

  Future<void> _resetDay(int goalMl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      _selectedCupIndex = null;
      _optimisticConsumedMl = 0;
    });

    await WaterIntakeService.resetToday(uid: user.uid, targetMl: goalMl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2EDE9),
      appBar: AppBar(
        backgroundColor: const Color(0xffF2EDE9),
        elevation: 0,
        title: const Text(
          'Water Tracker',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
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

              final personalData = _readMap(snapshot.data, 'personalData');
              final currentWeight = _readNum(personalData, 'currentWeight');
              final goalMl = _goalFromWeight(currentWeight);
              final weightLabel = currentWeight != null
                  ? '${currentWeight.toDouble().toStringAsFixed(currentWeight % 1 == 0 ? 0 : 1)} kg'
                  : 'your weight';
              return StreamBuilder<DailyWaterLog>(
                stream: WaterIntakeService.watchTodayLog(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                  targetMl: goalMl,
                ),
                builder: (context, logSnapshot) {
                  final log = logSnapshot.data;
                  final consumedMl = [
                    log?.consumedMl ?? 0,
                    _optimisticConsumedMl,
                  ].reduce((a, b) => a > b ? a : b);
                  final progress = (goalMl == 0 ? 0.0 : consumedMl / goalMl)
                      .clamp(0.0, 1.0);
                  final remainingMl = (goalMl - consumedMl).clamp(0, goalMl);

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Recommended daily intake',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$weightLabel x 35 ml',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: 230,
                                    height: 230,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox.expand(
                                          child: CircularProgressIndicator(
                                            value: progress,
                                            strokeWidth: 18,
                                            backgroundColor: const Color(
                                              0xFFE5E7EB,
                                            ),
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Color(0xFF49B44E)),
                                          ),
                                        ),
                                        Container(
                                          width: 165,
                                          height: 165,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xffF8FAFC),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Current',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '$consumedMl ml',
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'Goal $goalMl ml',
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Remaining $remainingMl ml',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _CupSizeButton(
                                          option: _cupOptions[0],
                                          isSelected: _selectedCupIndex == 0,
                                          onTap: () => _drinkCup(0, goalMl),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _CupSizeButton(
                                          option: _cupOptions[1],
                                          isSelected: _selectedCupIndex == 1,
                                          onTap: () => _drinkCup(1, goalMl),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _CupSizeButton(
                                          option: _cupOptions[2],
                                          isSelected: _selectedCupIndex == 2,
                                          onTap: () => _drinkCup(2, goalMl),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: const [
                                      Expanded(
                                        child: _BenefitTipCard(
                                          icon: Icons.bolt_outlined,
                                          title: 'More energy',
                                          subtitle:
                                              'Helps reduce tiredness and supports daily focus.',
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: _BenefitTipCard(
                                          icon: Icons.favorite_border,
                                          title: 'Better recovery',
                                          subtitle:
                                              'Supports muscles after workouts and activity.',
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: _BenefitTipCard(
                                          icon: Icons.self_improvement_outlined,
                                          title: 'Healthy skin',
                                          subtitle:
                                              'Helps keep skin hydrated and looking fresh.',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(color: Colors.black12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _resetDay(goalMl),
                              child: const Text('Reset Day'),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Tap a cup size to add water to your current intake.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  int _goalFromWeight(num? currentWeight) {
    if (currentWeight == null || currentWeight <= 0) {
      return 2000;
    }
    return (currentWeight * 35).round();
  }
}

class _CupSizeButton extends StatelessWidget {
  final _CupOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _CupSizeButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? const Color(0xFF49B44E) : Colors.white;
    final foregroundColor = isSelected ? Colors.white : const Color(0xFF0F172A);
    final borderColor = isSelected
        ? const Color(0xFF49B44E)
        : const Color(0xFFE5E7EB);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            children: [
              Icon(option.icon, color: foregroundColor, size: 30),
              const SizedBox(height: 10),
              Text(
                option.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${option.amountMl} ml',
                style: TextStyle(
                  color: isSelected ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CupOption {
  final String label;
  final int amountMl;
  final IconData icon;

  const _CupOption({
    required this.label,
    required this.amountMl,
    required this.icon,
  });
}

class _BenefitTipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitTipCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7EAD8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF49B44E), size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
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

num? _readNum(Map<String, dynamic>? source, String key) {
  final value = source?[key];
  return value is num ? value : null;
}
