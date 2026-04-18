import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/page_transitions.dart';
import '../../utils/user_data.dart';
import '../../utils/widgets.dart';
import 'current_weight_screen.dart';

class HeightScreen extends StatefulWidget {
  final String? gender;
  const HeightScreen({super.key, this.gender});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  double? _heightCm;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // No default height - user must input
  }

  void _showExplanationDialog(BuildContext context, String questionType) {
    String title = "";
    String explanation = "";

    switch (questionType) {
      case "height":
        title = "Why do we ask about height?";
        explanation =
            "Height is essential for calculating your Body Mass Index (BMI) and Basal Metabolic Rate (BMR). This helps us determine your daily calorie needs and create accurate nutrition and fitness recommendations.";
        break;
      case "obesity_level":
        title = "Why do we ask about obesity level?";
        explanation =
            "Understanding your body composition helps us assess health risks and create appropriate intervention strategies. This information guides our recommendations for safe and effective weight management.";
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            explanation,
            style: const TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Got it",
                style: TextStyle(color: Color(0xff13EC5B)),
              ),
            ),
          ],
        );
      },
    );
  }

  String get _ftIn {
    if (_heightCm == null) return "__'__\"";
    final totalInches = _heightCm! / 2.54;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return "${feet}\'${inches}\"";
  }

  void _onTextChanged(String v) {
    final parsed = int.tryParse(v);
    if (parsed != null) {
      final clamped = parsed.clamp(100, 220).toDouble();
      setState(() => _heightCm = clamped);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_heightCm != null) {
      _textController.value = _textController.value.copyWith(
        text: _heightCm!.toInt().toString(),
      );
    }

    String imagePath = widget.gender == "female"
        ? 'assets/Photoes/female.png'
        : 'assets/Photoes/male.png';

    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Color(0xffF2EDE9),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.black,
                      iconSize: 28,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    AnimatedIndicator(
                      activeIndex: 2,
                      count: 13,
                      animationDuration: const Duration(milliseconds: 400),
                      activeColor: const Color(0xff13EC5B),
                      inactiveColor: const Color(0xFFCCCCCC),
                      dotSize: 10.0,
                    ),
                    const Spacer(),
                    Gap(30),
                  ],
                ),
                Gap(20),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: "What's your ",
                        style: TextStyle(fontSize: 29),
                      ),
                      TextSpan(
                        text: "height",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 29,
                        ),
                      ),
                      const TextSpan(text: "?"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Behind the question
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Behind the question",
                      style: TextStyle(fontSize: 17, color: Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showExplanationDialog(context, "height"),
                      child: Icon(
                        Icons.help_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 90),

                // Main height display with image and scale
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Left: Person image
                      Expanded(
                        child: Image.asset(imagePath, fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 20),
                      // Right: Height display and scale
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Height number
                            Text(
                              _heightCm != null
                                  ? _heightCm!.toInt().toString()
                                  : "___",
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Height scale/ruler
                            Expanded(
                              child: GestureDetector(
                                onVerticalDragUpdate: (details) {
                                  setState(() {
                                    double currentHeight = _heightCm ?? 170.0;
                                    double newHeight =
                                        currentHeight +
                                        (details.delta.dy * 0.5);
                                    newHeight = newHeight.clamp(100, 220);
                                    _heightCm = newHeight;
                                  });
                                },
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final rulerHeight = constraints.maxHeight;
                                    final marks = 25;
                                    const indicatorSize = 35.0;
                                    const borderPadding = 2.0;
                                    final indicatorTop =
                                        ((((_heightCm ?? 170.0) - 100) / 120) *
                                                (rulerHeight -
                                                    indicatorSize -
                                                    borderPadding))
                                            .clamp(
                                              0.0,
                                              rulerHeight -
                                                  indicatorSize -
                                                  borderPadding,
                                            );
                                    return Container(
                                      width: 60,
                                      height: rulerHeight,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          clipBehavior: Clip.hardEdge,
                                          children: [
                                            Positioned.fill(
                                              child: CustomPaint(
                                                painter: _RulerPainter(
                                                  marks: marks,
                                                  primaryColor: Colors.black,
                                                  secondaryColor:
                                                      Colors.grey.shade400,
                                                ),
                                              ),
                                            ),
                                            // Green indicator - Larger circle
                                            Positioned(
                                              top: indicatorTop,
                                              left: 0,
                                              right: 0,
                                              child: Center(
                                                child: Container(
                                                  width: indicatorSize,
                                                  height: indicatorSize,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 130),
                _heightCm != null
                    ? NextButton(
                        onPressed: () {
                          signupData.heightCm = _heightCm;
                          Navigator.push(
                            context,
                            CustomPageTransitions.slideAndFadeTransition(
                              const CurrentWeightScreen(),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: Text(
                            'Set your height to continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final int marks;
  final Color primaryColor;
  final Color secondaryColor;

  _RulerPainter({
    required this.marks,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final primaryPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final segmentHeight = size.height / marks;
    for (var i = 0; i < marks; i++) {
      final y = i * segmentHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        i % 5 == 0 ? primaryPaint : paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) {
    return oldDelegate.marks != marks ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
