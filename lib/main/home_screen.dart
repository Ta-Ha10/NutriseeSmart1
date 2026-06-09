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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeHeader(
          name: _readString(personalData, 'name') ?? 'Athlete',
          onMenuTap: onMenuTap,
        ),
        const SizedBox(height: 20),
        NutritionOverview(
          targetCalories:
              _readNum(dietPlan, 'targetCalories')?.toDouble() ??
              _readNum(dietPlan, 'tdee')?.toDouble(),
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

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  static const Color _activeColor = Color(0xFF49B44E);
  static const Color _inactiveColor = Color(0xFFD9D9D9);

  int _selectedIndex = 2;

  final List<_BottomNavItem> _items = const [
    _BottomNavItem(icon: Icons.cottage_outlined, label: 'Home'),
    _BottomNavItem(icon: Icons.book_outlined, label: 'Log'),
    _BottomNavItem(icon: Icons.restaurant_menu_rounded, label: 'Meal'),
    _BottomNavItem(icon: Icons.query_stats_outlined, label: 'Stats'),
    _BottomNavItem(icon: Icons.settings_suggest_outlined, label: 'Settings'),
  ];

  void _selectItem(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: SizedBox(
        height: 112,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = width / _items.length;
            final selectedCenterX = itemWidth * (_selectedIndex + 0.5);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 82,
                  child: CustomPaint(
                    painter: _BottomNavShapePainter(
                      selectedCenterX: selectedCenterX,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned.fill(
                  bottom: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final isSelected = index == _selectedIndex;

                      return _NavItem(
                        icon: item.icon,
                        label: item.label,
                        isSelected: isSelected,
                        color: isSelected ? _activeColor : _inactiveColor,
                        topPadding: isSelected ? 68 : 48,
                        onTap: () => _selectItem(index),
                      );
                    }),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: selectedCenterX - 34,
                  top: 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _selectItem(_selectedIndex),
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: _activeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xffF2EDE9),
                          width: 8,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _items[_selectedIndex].icon,
                        color: Colors.white,
                        size: 31,
                      ),
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
}

class _BottomNavItem {
  final IconData icon;
  final String label;

  const _BottomNavItem({required this.icon, required this.label});
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final double topPadding;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.topPadding,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(top: topPadding, bottom: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isSelected) ...[
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 4),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavShapePainter extends CustomPainter {
  final double selectedCenterX;
  final Color color;

  const _BottomNavShapePainter({
    required this.selectedCenterX,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    canvas.drawShadow(path, const Color(0x26000000), 10, false);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawPath(path, paint);
  }

  Path _buildPath(Size size) {
    const cornerRadius = 20.0;
    const topY = 14.0;
    const notchRadius = 41.0;
    final notchCenter = Offset(selectedCenterX, 36);
    final isNearLeftEdge = selectedCenterX < 108;
    final isNearRightEdge = selectedCenterX > size.width - 108;

    if (isNearLeftEdge || isNearRightEdge) {
      final body = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, topY, size.width, size.height - topY),
            const Radius.circular(cornerRadius),
          ),
        );
      final notch = Path()
        ..addOval(Rect.fromCircle(center: notchCenter, radius: notchRadius));

      return Path.combine(PathOperation.difference, body, notch);
    }

    final body = Path()
      ..moveTo(cornerRadius, topY)
      ..cubicTo(
        size.width * 0.20,
        topY - 12,
        selectedCenterX - 104,
        topY - 12,
        selectedCenterX - 58,
        topY,
      )
      ..cubicTo(
        selectedCenterX - 38,
        topY + 4,
        selectedCenterX - 38,
        topY + 38,
        selectedCenterX,
        topY + 38,
      )
      ..cubicTo(
        selectedCenterX + 38,
        topY + 38,
        selectedCenterX + 38,
        topY + 4,
        selectedCenterX + 58,
        topY,
      )
      ..cubicTo(
        selectedCenterX + 104,
        topY - 12,
        size.width * 0.80,
        topY - 12,
        size.width - cornerRadius,
        topY,
      )
      ..quadraticBezierTo(size.width, topY + 2, size.width, topY + cornerRadius)
      ..lineTo(size.width, size.height - cornerRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - cornerRadius,
        size.height,
      )
      ..lineTo(cornerRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cornerRadius)
      ..lineTo(0, topY + cornerRadius)
      ..quadraticBezierTo(0, topY + 2, cornerRadius, topY)
      ..close();

    final notch = Path()
      ..addOval(Rect.fromCircle(center: notchCenter, radius: notchRadius));

    return Path.combine(PathOperation.difference, body, notch);
  }

  @override
  bool shouldRepaint(covariant _BottomNavShapePainter oldDelegate) {
    return oldDelegate.selectedCenterX != selectedCenterX ||
        oldDelegate.color != color;
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
