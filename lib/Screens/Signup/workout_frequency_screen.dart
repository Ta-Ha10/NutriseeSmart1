import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../utils/page_transitions.dart';
import '../../utils/widgets.dart';
import '../../utils/user_data.dart';
import 'breakfast_time_screen.dart';

class WorkoutFrequencyScreen extends StatefulWidget {
  const WorkoutFrequencyScreen({super.key});
  @override
  State<WorkoutFrequencyScreen> createState() => _WorkoutFrequencyScreenState();
}

class _WorkoutFrequencyScreenState extends State<WorkoutFrequencyScreen> {
  final List<String> days = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final Set<int> selectedDays = {};

  Widget _dayButton(int index) {
    bool isSelected = selectedDays.contains(index);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedDays.remove(index);
          } else {
            selectedDays.add(index);
          }
        });
      },
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300] ?? Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            days[index],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    activeIndex: 8,
                    count: 13,
                    animationDuration: const Duration(milliseconds: 400),
                    activeColor: const Color(0xff13EC5B),
                    inactiveColor: const Color(0xFFCCCCCC),
                    dotSize: 10.0,
                  ),
                  const Spacer(),
                  Gap(30)
                ],
              ),
              Gap(20),
              // Header with styled text
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: "When do you "),
                    TextSpan(
                      text: "workout",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: "?"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                "Select the days you usually work out\nto keep your fitness routine on track.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              // Days selection rows
              Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 450),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _dayButton(0)),
                          const SizedBox(width: 12),
                          Expanded(child: _dayButton(1)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _dayButton(2)),
                          const SizedBox(width: 12),
                          Expanded(child: _dayButton(3)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _dayButton(4)),
                          const SizedBox(width: 12),
                          Expanded(child: _dayButton(5)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _dayButton(6)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Selected days display
              if (selectedDays.isNotEmpty)
                Center(
                  child: Text(
                    '${selectedDays.length} day${selectedDays.length > 1 ? 's' : ''} selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Spacer(),
              // Next button
              selectedDays.isNotEmpty
                  ? NextButton(
                      height: 56,
                      label: 'Continue to Meals',
                      onPressed: () {
                        // Save workout days
                        signupData.workoutDays = selectedDays.map((index) => days[index]).toList();
                        
                        Navigator.push(
                          context,
                          CustomPageTransitions.slideAndFadeTransition(
                            BreakfastTimeScreen(),
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
                          'Select at least one workout day to continue',
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
