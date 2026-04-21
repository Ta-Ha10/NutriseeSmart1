import 'package:flutter/material.dart';
import '../../utils/page_transitions.dart';
import '../../utils/user_data.dart';
import '../../utils/widgets.dart';
import 'meal_goal_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int? selectedIndex; // No default selection

  final List<Map<String, String>> options = [
    {
      'title': 'Sedentary',
      'desc':
          'Office workers, people with limited physical activity during the day.',
    },
    {
      'title': 'Lightly Active',
      'desc':
          'Light jogging, walking, yoga, or other low-intensity workouts a few times a week.',
    },
    {
      'title': 'Moderate Active',
      'desc':
          'Running, cycling, swimming, or moderate intensity strength training.',
    },
    {
      'title': 'Active',
      'desc':
          'Intense weight training, running marathons, competitive sports, or professional training sessions.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SignupStepBody(
          activeIndex: 6,
          title: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: "How "),
                TextSpan(
                  text: "active",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: " are you"),
                TextSpan(
                  text: " ?",
                  style: TextStyle(
                    color: Color(0xff13EC5B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          onHelpPressed: () => _showExplanationDialog(context, "activity"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What About you Activity Level",
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
                    return _buildCard(index);
                  },
                ),
              ),
            ],
          ),
          bottomAction: selectedIndex != null
              ? NextButton(
                  onPressed: () {
                    signupData.activityLevel = selectedIndex;
                    Navigator.push(
                      context,
                      CustomPageTransitions.slideAndFadeTransition(
                        const MealGoalScreen(),
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
                      'Select your activity level to continue',
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

  Widget _buildCard(int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              options[index]['title']!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              options[index]['desc']!,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExplanationDialog(BuildContext context, String screenType) {
    String title;
    String explanation;

    switch (screenType) {
      case "activity":
        title = "Why do we ask for your activity level?";
        explanation =
            "Your activity level helps us calculate your daily calorie needs more accurately. This ensures your meal plans provide the right amount of energy for your lifestyle and fitness goals.";
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
