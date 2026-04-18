import 'package:animated_weight_picker/animated_weight_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/page_transitions.dart';
import '../../utils/user_data.dart';
import '../../utils/widgets.dart';
import 'obesity_screen.dart';

class GoalWeightScreen extends StatefulWidget {
  const GoalWeightScreen({super.key});
  @override
  State<GoalWeightScreen> createState() => _GoalWeightScreenState();
}

class _GoalWeightScreenState extends State<GoalWeightScreen> {
  double? _currentWeight;
  final double min = 50;
  final double max = 220;
  String selectedValue = '';

  void _showExplanationDialog(BuildContext context, String questionType) {
    String title = "";
    String explanation = "";

    switch (questionType) {
      case "goal_weight":
        title = "Why do we ask about goal weight?";
        explanation =
            "Your target weight helps us create realistic nutrition and fitness plans. This allows us to set appropriate calorie goals and track your progress toward your desired outcome.";
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffF2EDE9),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
          child: Column(
            children: [
              IndicatorHeader(activeIndex: 4, totalCount: 13),

              Gap(20),
              // Header with styled text
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: "What's your ",
                      style: TextStyle(fontSize: 29),
                    ),
                    TextSpan(
                      text: "Goal\nWeight",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 29,
                      ),
                    ),
                    TextSpan(
                      text: " ?",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 29,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Behind the question
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Behind the question",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showExplanationDialog(context, "goal_weight"),
                    child: Icon(
                      Icons.help_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Weight display
              // Ruler/Scale visualization
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.35,
                        maxWidth: screenWidth * 0.9,
                      ),
                      child: AnimatedWeightPicker(
                        min: 50,
                        max: 220,
                        onChange: (newValue) {
                          setState(() {
                            selectedValue = newValue;
                            _currentWeight = double.tryParse(newValue);
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Spacer(),
              _currentWeight != null
                  ? NextButton(
                      onPressed: () {
                        signupData.goalWeight = _currentWeight;
                        Navigator.push(
                          context,
                          CustomPageTransitions.slideAndFadeTransition(
                            const ObesityScreen(),
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
                          'Select your goal weight to continue',
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
    );
  }
}
