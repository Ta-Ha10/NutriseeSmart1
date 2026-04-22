import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../utils/auto_dismiss_dialog.dart';
import '../../utils/page_transitions.dart';
import '../../utils/widgets.dart';
import '../../widgets/wheel_time_picker.dart';
import '../../utils/user_data.dart';
import 'ingredient_search_screen.dart';

class DinnerTimeScreen extends StatefulWidget {
  const DinnerTimeScreen({super.key});
  @override
  State<DinnerTimeScreen> createState() => _DinnerTimeScreenState();
}

class _DinnerTimeScreenState extends State<DinnerTimeScreen> {
  TimeOfDay selectedTime = TimeOfDay(hour: 20, minute: 00);

  void _showExplanationDialog(BuildContext context, String questionType) {
    String title = "";
    String explanation = "";

    switch (questionType) {
      case "dinner_time":
        title = "Why do we ask about dinner time?";
        explanation = "Knowing your dinner time helps us create meal plans that align with your daily routine. This ensures your meals are scheduled appropriately and helps maintain consistent eating patterns for better health outcomes.";
        break;
      case "breakfast_time":
        title = "Why do we ask about breakfast time?";
        explanation = "Your breakfast time helps us structure your daily meal plan around your schedule. This ensures you start your day with proper nutrition and maintain energy levels throughout the morning.";
        break;
      case "lunch_time":
        title = "Why do we ask about lunch time?";
        explanation = "Understanding your lunch schedule allows us to plan balanced meals that fit your workday or daily routine, ensuring you get the right nutrients at the right time.";
        break;
      // Add more cases for other screens
    }

    showAutoDismissDialog(
      context,
      title: title,
      message: explanation,
      dismissDuration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.black,
                    iconSize: 28,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  AnimatedIndicator(
                    activeIndex: 11,
                    count: 14,
                    animationDuration: const Duration(milliseconds: 400),
                    activeColor: const Color(0xff13EC5B),
                    inactiveColor: const Color(0xFFCCCCCC),
                    dotSize: 10.0,
                  ),
                  const Spacer(),
                  Gap(40)
                ],
              ),
              Gap(20),
              // Header with styled text
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: "When do you have\nyour "),
                      TextSpan(
                        text: "dinner",
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
              ),
              const SizedBox(height: 16),
              // Behind the question
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Behind the question",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showExplanationDialog(context, "dinner_time"),
                    child: Icon(
                      Icons.help_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Time picker container
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.dinner_dining,
                        size: 48,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        selectedTime.format(context),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),
                      WheelTimePicker(
                        initialTime: selectedTime,
                        onTimeChanged: (TimeOfDay newTime) {
                          setState(() {
                            selectedTime = newTime;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Skip button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CustomPageTransitions.slideAndFadeTransition(
                        IngredientSearchScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Skip this meal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              NextButton(
                height: 56,
                label: 'Continue',
                onPressed: () {
                  // Save dinner time
                  signupData.mealTimes ??= {};
                  signupData.mealTimes!['dinner'] = selectedTime;
                  
                  Navigator.push(
                    context,
                    CustomPageTransitions.slideAndFadeTransition(
                      IngredientSearchScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 17),
            ],
          ),
        ),
      ),
    );
  }
}
