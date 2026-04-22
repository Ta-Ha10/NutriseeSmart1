import 'package:flutter/material.dart';
import '../../utils/auto_dismiss_dialog.dart';
import '../../utils/page_transitions.dart';
import '../../utils/user_data.dart';
import '../../utils/widgets.dart';
import 'workout_frequency_screen.dart';

class MealGoalScreen extends StatefulWidget {
  const MealGoalScreen({super.key});
  @override
  State<MealGoalScreen> createState() => _MealGoalScreenState();
}

class _MealGoalScreenState extends State<MealGoalScreen> {
  int? selectedIndex; // No default selection

  final List<String> options = ['Weekly Plan', 'Daily Plan', 'Single Meal'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SignupStepBody(
          activeIndex: 7,
          title: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: "How often should we\nupdate your "),
                TextSpan(
                  text: "plan",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "?",
                  style: TextStyle(
                    color: Color(0xff13EC5B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          onHelpPressed: () => _showExplanationDialog(context, "meal_goal"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Meal Planning Goal",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: Container(
                        height: 91,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: isSelected
                              ? Border.all(color: Colors.green, width: 3)
                              : Border.all(color: Colors.transparent, width: 3),
                        ),
                        child: Stack(
                          children: [
                            Text(
                              options[index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            if (index == 0)
                              Positioned(
                                right: 20,
                                top: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    "Recommended",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
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
            ],
          ),
          bottomAction: selectedIndex != null
              ? NextButton(
                  onPressed: () {
                    signupData.mealGoal = selectedIndex;
                    Navigator.push(
                      context,
                      CustomPageTransitions.slideAndFadeTransition(
                        const WorkoutFrequencyScreen(),
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
                      'Select a plan frequency to continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
      case "meal_goal":
        title = "Why do we ask for your plan update frequency?";
        explanation =
            "Different people have different needs. Some prefer fresh meal ideas every day, while others are happy with weekly plans. This helps us deliver the right amount of variety and planning that matches your lifestyle.";
        break;
      default:
        title = "Information";
        explanation = "This information helps us personalize your experience.";
    }

    showAutoDismissDialog(
      context,
      title: title,
      message: explanation,
      dismissDuration: const Duration(seconds: 5),
    );
  }
}
