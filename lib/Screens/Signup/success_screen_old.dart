import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../services/firestore_service.dart';
import '../../utils/user_data.dart';
import '../../utils/widgets.dart';

class SuccessScreen extends StatefulWidget {
  final UserData userData;

  const SuccessScreen({super.key, required this.userData});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _isSaving = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _finishSignup();
  }

  Future<void> _finishSignup() async {
    try {
      // Calculate metrics before saving
      widget.userData.calculateMetrics();
      await FirestoreService.saveUserData(widget.userData);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not complete signup: $error';
        _isSaving = false;
      });
      return;
    }

    widget.userData.clearSignupState();
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xff13EC5B)),
              const SizedBox(height: 24),
              Text(
                'Creating your personalized plan...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/auth_method');
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    final userData = widget.userData;
    final goalDate = DateTime.now().add(const Duration(days: 180));
    final monthsAway = goalDate.month;
    final yearAway = goalDate.year;
    final weightDifference = (userData.currentWeight ?? 0) - (userData.goalWeight ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green Header Banner
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xff13EC5B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -80,
                    top: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Congratulations!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: userData.name ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const TextSpan(
                                text: ', we crafted a health plan from your answers',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan Highlights
                  const Text(
                    'Highlights of your personalized plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Weight Progress Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF0F0F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xff13EC5B).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${userData.currentWeight?.toStringAsFixed(0)} kg',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff13EC5B),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${userData.goalWeight?.toStringAsFixed(0)} kg',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 120,
                          child: _buildWeightGraph(userData),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Feb $monthsAway, $yearAway',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Goal Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xff13EC5B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xff13EC5B).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGoalPoint('Lose weight than focus on maintaining your progress'),
                        const SizedBox(height: 12),
                        _buildGoalPoint('Reach your goal weight 70 kg by Feb $monthsAway, $yearAway'),
                        const SizedBox(height: 12),
                        _buildGoalPoint('Create lifelong habits to sustain your success'),
                        const SizedBox(height: 12),
                        _buildGoalPoint('Tailored to your lifestyle'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Nutritional Recommendations
                  const Text(
                    'Your nutritional recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNutrientCircle('🔥', 'Carbs', '${userData.carbGrams?.toStringAsFixed(0) ?? '0'}g'),
                      _buildNutrientCircle('🥚', 'Proteins', '${userData.proteinGrams?.toStringAsFixed(0) ?? '0'}g'),
                      _buildNutrientCircle('🧈', 'Fats', '${userData.fatGrams?.toStringAsFixed(0) ?? '0'}g'),
                      _buildNutrientCircle('📊', 'Calories', '${userData.targetCalories?.toStringAsFixed(0) ?? '0'}'),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Optimized for you
                  const Text(
                    'Optimized for you',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildOptimizedCard(
                          'Health Life',
                          'assets/Photoes/health life.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptimizedCard(
                          'Water Reminder',
                          'assets/Photoes/water reminder.png',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptimizedCard(
                          'Balanced Food',
                          'assets/Photoes/balanced food.png',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF0F0F0),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Get Started Button
                  NextButton(
                    label: 'Get Started',
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightGraph(UserData userData) {
    final currentWeight = userData.currentWeight ?? 0;
    final goalWeight = userData.goalWeight ?? 0;
    final maxWeight = (currentWeight > goalWeight ? currentWeight : goalWeight) + 10;
    final minWeight = (goalWeight < currentWeight ? goalWeight : currentWeight) - 10;

    return CustomPaint(
      painter: WeightGraphPainter(
        currentWeight: currentWeight,
        goalWeight: goalWeight,
        maxWeight: maxWeight,
        minWeight: minWeight,
      ),
      size: const Size(double.infinity, 120),
    );
  }

  Widget _buildGoalPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xff13EC5B),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientCircle(String emoji, String label, String value) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFBFC),
            border: Border.all(
              color: const Color(0xFFF0F0F0),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizedCard(String title, String imagePath) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF0F0F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeightGraphPainter extends CustomPainter {
  final double currentWeight;
  final double goalWeight;
  final double maxWeight;
  final double minWeight;

  WeightGraphPainter({
    required this.currentWeight,
    required this.goalWeight,
    required this.maxWeight,
    required this.minWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff13EC5B)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dottedPaint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final padding = 20.0;
    final graphWidth = size.width - (padding * 2);
    final graphHeight = size.height - (padding * 2);
    final weightRange = maxWeight - minWeight;

    // Draw path for current weight
    final path1 = Path();
    final startX = padding;
    final startY = padding + ((maxWeight - currentWeight) / weightRange) * graphHeight;
    path1.moveTo(startX, startY);
    path1.lineTo(startX + graphWidth * 0.3, startY - 20);
    path1.lineTo(startX + graphWidth * 0.7, startY + 30);
    path1.lineTo(startX + graphWidth, padding + ((maxWeight - goalWeight) / weightRange) * graphHeight);

    canvas.drawPath(path1, paint);

    // Draw dashed line to goal
    _drawDashedLine(
      canvas,
      Offset(startX + graphWidth, padding + ((maxWeight - goalWeight) / weightRange) * graphHeight),
      Offset(startX + graphWidth * 0.2, padding + ((maxWeight - goalWeight) / weightRange) * graphHeight),
      dottedPaint,
    );

    // Draw points
    canvas.drawCircle(Offset(startX, startY), 6, Paint()..color = const Color(0xff13EC5B));
    canvas.drawCircle(
      Offset(startX + graphWidth, padding + ((maxWeight - goalWeight) / weightRange) * graphHeight),
      6,
      Paint()..color = Colors.purple,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dashWidth = 5.0;
    final dashSpace = 5.0;
    final distance = (end - start).distance;
    final steps = (distance / (dashWidth + dashSpace)).ceil();

    for (int i = 0; i < steps; i++) {
      final t = (i * (dashWidth + dashSpace)) / distance;
      if (t > 1) break;

      final startPoint = Offset.lerp(start, end, t)!;
      final endPoint = Offset.lerp(start, end, (t + dashWidth / distance).clamp(0, 1))!;

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
