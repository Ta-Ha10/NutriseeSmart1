import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/page_transitions.dart';
import '../../utils/user_data.dart';
import '../../utils/widgets.dart';
import 'height_screen.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? _selected; // "male" or "female"

  void _select(String value) => setState(() => _selected = value);

  void _showExplanationDialog(BuildContext context, String questionType) {
    String title = "";
    String explanation = "";

    switch (questionType) {
      case "gender":
        title = "Why do we ask about gender?";
        explanation =
            "Gender helps us calculate your Basal Metabolic Rate (BMR) more accurately. This allows us to create personalized fitness and nutrition plans that are tailored to your body's specific metabolic needs.";
        break;
      case "birth_date":
        title = "Why do we ask about birth date?";
        explanation =
            "Your age helps us understand your life stage and adjust calorie needs, nutrient requirements, and fitness recommendations accordingly for optimal health outcomes.";
        break;
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
    return Scaffold(
      backgroundColor: Color(0xffF2EDE9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                    activeIndex: 1,
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
              Gap(60),
              // Heading and hint
              Column(
                children: [
                  RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        const TextSpan(
                          text: "What’s your ",
                          style: TextStyle(fontSize: 25),
                        ),
                        TextSpan(
                          text: "Gender ?",
                          style: TextStyle(
                            color: const Color(0xff13EC5B),
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Behind the question
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Behind the question",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showExplanationDialog(context, "gender"),
                        child: Icon(
                          Icons.help_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 90),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _select("male"),
                        child: _GenderImageCard(
                          imagePath: "assets/Photoes/male.png",
                          label: "Male",
                          selected: _selected == "male",
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _select("female"),
                        child: _GenderImageCard(
                          imagePath: "assets/Photoes/female.png",
                          label: "Female",
                          selected: _selected == "female",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(150),
              _selected == null
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Select a gender to continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : NextButton(
                      onPressed: () {
                        signupData.gender = _selected;
                        Navigator.push(
                          context,
                          CustomPageTransitions.slideAndFadeTransition(
                            HeightScreen(gender: _selected),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderImageCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool selected;

  const _GenderImageCard({
    required this.imagePath,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: selected ? 1.0 : 0.7,
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image fills remaining vertical space within the card
            Expanded(child: Image.asset(imagePath, fit: BoxFit.contain)),
            const SizedBox(height: 12),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.green : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
