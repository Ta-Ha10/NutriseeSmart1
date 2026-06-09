import 'package:flutter/material.dart';
import '../../utils/page_transitions.dart';
import 'name_input_screen.dart';
import 'birth_screen.dart';
import 'gender_screen.dart';
import 'height_screen.dart';
import 'current_weight_screen.dart';
import 'goal_weight_screen.dart';
import 'obesity_screen.dart';
import 'activity_screen.dart';
import 'meal_goal_screen.dart';
import 'review_screen.dart';

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({super.key});

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Widget> pages = [
    const NameInputScreen(),
    const BirthScreen(),
    const GenderScreen(),
    const HeightScreen(),
    const CurrentWeightScreen(),
    const GoalWeightScreen(),
    const ObesityScreen(),
    const ActivityScreen(),
    const MealGoalScreen(),
    const ReviewScreen(),
  ];

  final List<String> pageNames = [
    'Name',
    'Birth',
    'Gender',
    'Height',
    'Current Weight',
    'Goal Weight',
    'Obesity',
    'Activity',
    'Meal Goal',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < pages.length - 1) {
      // For now, allow navigation - validation will be handled by individual screens
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2EDE9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: Colors.black,
                iconSize: 24,
                onPressed: _goToPreviousPage,
              )
            : const SizedBox(width: 48),
        title: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: AnimatedIndicator(
                activeIndex: _currentPage,
                count: pages.length,
                animationDuration: const Duration(milliseconds: 400),
                activeColor: const Color(0xff13EC5B),
                inactiveColor: const Color(0xFFCCCCCC),
                dotSize: 8.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: pages[index],
          );
        },
      ),
      floatingActionButton: _currentPage < pages.length - 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xff13EC5B),
              onPressed: _goToNextPage,
              child: const Icon(Icons.arrow_forward, color: Colors.black),
            )
          : null,
    );
  }
}