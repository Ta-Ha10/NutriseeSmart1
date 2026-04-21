import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/page_transitions.dart';
import '../../utils/user_data.dart';
import '../../utils/widgets.dart';
import 'gender_screen.dart';

class BirthScreen extends StatefulWidget {
  const BirthScreen({super.key});

  @override
  State<BirthScreen> createState() => _BirthScreenState();
}

class _BirthScreenState extends State<BirthScreen> {
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    // No default values - user must select
  }

  void _showExplanationDialog(BuildContext context, String questionType) {
    String title = "";
    String explanation = "";

    switch (questionType) {
      case "birth_date":
        title = "Why do we ask about birth date?";
        explanation =
            "Your age helps us understand your life stage and adjust calorie needs, nutrient requirements, and fitness recommendations accordingly for optimal health outcomes.";
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

  String get _displayDate {
    if (_selectedDay == null ||
        _selectedMonth == null ||
        _selectedYear == null) {
      return "Select your birth date";
    }
    return "${_selectedDay.toString().padLeft(2, '0')} "
        "${_monthName(_selectedMonth!)} $_selectedYear";
  }

  String _monthName(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[m - 1];
  }

  bool get _isBirthDateSelected =>
      _selectedDay != null && _selectedMonth != null && _selectedYear != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2EDE9),
      body: SignupStepBody(
        activeIndex: 1,
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            children: [
              const TextSpan(
                text: "When were you ",
                style: TextStyle(fontSize: 25),
              ),
              TextSpan(
                text: "born ?",
                style: TextStyle(
                  color: const Color(0xff13EC5B),
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
        onHelpPressed: () => _showExplanationDialog(context, "birth_date"),
        content: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _displayDate,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Gap(26),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Color(0xffF2EDE9),
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                    // Day Wheel
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: _selectedDay != null
                              ? _selectedDay! - 1
                              : 0,
                        ),
                        itemExtent: 60,
                        onSelectedItemChanged: (int index) {
                          setState(() => _selectedDay = index + 1);
                        },
                        children: List.generate(31, (index) {
                          return Center(
                            child: Text(
                              (index + 1).toString().padLeft(2, '0'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Month Wheel
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: _selectedMonth != null
                              ? _selectedMonth! - 1
                              : 0,
                        ),
                        itemExtent: 60,
                        onSelectedItemChanged: (int index) {
                          setState(() => _selectedMonth = index + 1);
                        },
                        children: List.generate(12, (index) {
                          return Center(
                            child: Text(
                              _monthName(index + 1),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Year Wheel
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: _selectedYear != null
                              ? DateTime.now().year - _selectedYear!
                              : 25,
                        ),
                        itemExtent: 60,
                        onSelectedItemChanged: (int index) {
                          setState(
                            () => _selectedYear = DateTime.now().year - index,
                          );
                        },
                        children: List.generate(100, (index) {
                          return Center(
                            child: Text(
                              (DateTime.now().year - index).toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomAction: _isBirthDateSelected
            ? NextButton(
                onPressed: () {
                  signupData.birthDay = _selectedDay;
                  signupData.birthMonth = _selectedMonth;
                  signupData.birthYear = _selectedYear;
                  Navigator.push(
                    context,
                    CustomPageTransitions.slideAndFadeTransition(
                      const GenderScreen(),
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
                    'Select your birth date to continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
