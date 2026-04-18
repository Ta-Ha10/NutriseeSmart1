import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/page_transitions.dart';
import '../../utils/user_data.dart';
import '../../utils/widgets.dart';
import 'activity_screen.dart';

class ObesityScreen extends StatefulWidget {
  const ObesityScreen({super.key});
  @override
  State<ObesityScreen> createState() => _ObesityScreenState();
}

class _ObesityScreenState extends State<ObesityScreen> {
  bool? hasObesity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
          child: Column(
            children: [
              IndicatorHeader(activeIndex: 5, totalCount: 13),
              Gap(20),

              const SizedBox(height: 24),
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
                      text: "Do you have ",
                      style: TextStyle(fontSize: 29),
                    ),
                    TextSpan(
                      text: "Diabetes",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 29,
                      ),
                    ),
                    TextSpan(
                      text: " ?",
                      style: TextStyle(
                        color: Color(0xff13EC5B),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showExplanationDialog(context, "obesity"),
                    child: Icon(
                      Icons.help_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Gap(150), // Image
              Image.asset(
                'assets/Photoes/diabetes.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              // Yes/No buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton("Yes", true),
                  _buildOptionButton("No", false),
                ],
              ),
              const Spacer(),
              hasObesity != null
                  ? NextButton(
                      onPressed: () {
                        signupData.hasObesity = hasObesity;
                        Navigator.push(
                          context,
                          CustomPageTransitions.slideAndFadeTransition(
                            const ActivityScreen(),
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
                          'Select an answer to continue',
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

  Widget _buildOptionButton(String text, bool value) {
    bool isSelected = hasObesity == value;
    return GestureDetector(
      onTap: () => setState(() => hasObesity = value),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[600],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showExplanationDialog(BuildContext context, String screenType) {
    String title;
    String explanation;

    switch (screenType) {
      case "obesity":
        title = "Why do we ask about diabetes?";
        explanation =
            "Diabetes affects how your body processes nutrients and calories. Knowing this helps us provide safe, appropriate meal recommendations and calorie calculations that work with your health needs. Your medical information is kept completely private.";
        break;
      default:
        title = "Information";
        explanation = "This information helps us personalize your experience.";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            explanation,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff13EC5B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
