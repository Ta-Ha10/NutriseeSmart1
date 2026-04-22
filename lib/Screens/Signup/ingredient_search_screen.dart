import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../../utils/auto_dismiss_dialog.dart';
import '../../utils/page_transitions.dart';
import '../../utils/widgets.dart';
import 'review_screen.dart';

class IngredientSearchScreen extends StatefulWidget {
  const IngredientSearchScreen({super.key});

  @override
  State<IngredientSearchScreen> createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  List<String> allIngredients = [];
  List<String> displayedIngredients = [];
  List<String> filteredIngredients = [];
  Set<String> selectedIngredients = {};
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadIngredients();
  }

  void _showExplanationDialog(BuildContext context, String questionType) {
    String title = "";
    String explanation = "";

    switch (questionType) {
      case "allergies":
        title = "Why do we ask about allergies?";
        explanation = "Understanding your allergies helps us create safe and personalized meal plans. We'll avoid ingredients that could cause allergic reactions and suggest suitable alternatives to ensure your meals are both nutritious and safe.";
        break;
      case "meal_goals":
        title = "Why do we ask about meal goals?";
        explanation = "Your meal goals help us understand your dietary preferences and objectives. This allows us to create meal plans that align with your lifestyle and help you achieve your nutrition targets.";
        break;
      case "activity_level":
        title = "Why do we ask about activity level?";
        explanation = "Your activity level determines your daily calorie needs and exercise recommendations. This helps us create balanced meal plans that support your fitness goals and energy requirements.";
        break;
    }

    showAutoDismissDialog(
      context,
      title: title,
      message: explanation,
      dismissDuration: const Duration(seconds: 5),
    );
  }

  Future<void> loadIngredients() async {
    try {
      String content = await rootBundle.loadString('assets/unique_ingredients.txt');
      allIngredients = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
      // Clean up ingredients (remove leading/trailing whitespace and special chars)
      allIngredients = allIngredients.map((ing) => ing.trim().replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '')).toList();
      // Remove duplicates
      allIngredients = allIngredients.toSet().toList();
      // Shuffle and take random subset
      allIngredients.shuffle();
      displayedIngredients = allIngredients.take(50).toList(); // Display 50 random ingredients
      filteredIngredients = List.from(displayedIngredients);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading ingredients: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterIngredients(String query) {
    if (query.isEmpty) {
      filteredIngredients = List.from(displayedIngredients);
    } else {
      filteredIngredients = displayedIngredients
          .where((ingredient) => ingredient.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  void toggleIngredientSelection(String ingredient) {
    setState(() {
      if (selectedIngredients.contains(ingredient)) {
        selectedIngredients.remove(ingredient);
      } else {
        selectedIngredients.add(ingredient);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2EDE9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
          child: Column(
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
                    activeIndex: 12,
                    count: 14,
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
              // Header
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: "Select Your "),
                    TextSpan(
                      text: "Allergies",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showExplanationDialog(context, "allergies"),
                    child: Icon(
                      Icons.help_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: filterIngredients,
                  decoration: const InputDecoration(
                    hintText: 'Search allergies...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Ingredients grid
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: filteredIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = filteredIngredients[index];
                          final isSelected = selectedIngredients.contains(ingredient);
                          return GestureDetector(
                            onTap: () => toggleIngredientSelection(ingredient),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green[50] : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.green : Colors.grey[200]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  ingredient,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.green : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              // Next button
              NextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CustomPageTransitions.slideAndFadeTransition(
                      const ReviewScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Selected allergies display
              if (selectedIngredients.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Allergies (${selectedIngredients.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: selectedIngredients.map((ingredient) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.green[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ingredient,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => toggleIngredientSelection(ingredient),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
          ]
          )
        ),
      ),
    );
  }
}
