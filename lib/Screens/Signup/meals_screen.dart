import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/components.dart';
import '../../utils/user_data.dart';
import '../../services/daily_nutrition_service.dart';
import '../../services/recipe_service.dart';
import '../recipe_details_screen.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  UserData? userData;
  bool isLoading = true;
  String? errorMessage;
  Map<String, List<Map<String, dynamic>>> mealRecipes = {};
  Map<String, List<Map<String, dynamic>>> loggedMeals = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snacks': [],
  };
  Map<String, double> mealCalorieTargets = {};
  Map<String, bool> mealRecipesRequested = {
    'breakfast': false,
    'lunch': false,
    'dinner': false,
    'snacks': false,
  };
  bool isServerAvailable = false;
  int selectedDayIndex = DateTime.now().weekday - 1;
  int selectedWeekIndex = 0;
  bool showWeekSelector = false;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndRecipes();
    // Set selectedWeekIndex to current week
    final weekMondays = _getWeekMondays();
    for (int i = 0; i < weekMondays.length; i++) {
      if (_isCurrentWeek(weekMondays[i])) {
        selectedWeekIndex = i;
        break;
      }
    }
    // Set selectedDayIndex to today
    final today = DateTime.now();
    final weekDays = _weekDays();
    for (int i = 0; i < weekDays.length; i++) {
      if (weekDays[i].year == today.year &&
          weekDays[i].month == today.month &&
          weekDays[i].day == today.day) {
        selectedDayIndex = i;
        break;
      }
    }
  }

  Future<void> _loadUserDataAndRecipes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Please sign in to view meals';
          isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        setState(() {
          errorMessage =
              'User profile not found. Please complete your profile setup.';
          isLoading = false;
        });
        return;
      }

      final data = doc.data();
      if (data == null) {
        setState(() {
          errorMessage =
              'User profile data is unavailable. Please try again later.';
          isLoading = false;
        });
        return;
      }

      final dietPlan = (data['dietPlan'] as Map<String, dynamic>?) ?? {};

      userData = UserData()
        ..name = data['name'] as String?
        ..targetCalories = dietPlan['targetCalories']?.toDouble()
        ..proteinGrams = dietPlan['proteinGrams']?.toDouble()
        ..carbGrams = dietPlan['carbGrams']?.toDouble()
        ..fatGrams = dietPlan['fatGrams']?.toDouble()
        ..tdee = dietPlan['tdee']?.toDouble()
        ..likedRecipes = _stringList(data['likedRecipes'])
        ..dislikedRecipes = _stringList(data['dislikedRecipes']);

      // Use stored daily calories, or fallback to TDEE/profile calculation.
      userData?.targetCalories ??= userData?.tdee;
      if (userData?.targetCalories == null) {
        userData?.calculateMetrics();
      }

      // Calculate meal-specific calorie targets
      final safeTargetCalories =
          userData?.targetCalories ?? userData?.tdee ?? 0;
      mealCalorieTargets = RecipeService.getMealCalorieTargets(
        safeTargetCalories,
      );
      await _loadTodayLoggedMeals(user.uid);

      // Check server availability first
      await _checkServerAvailability();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        errorMessage = 'Failed to load user data. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkServerAvailability() async {
    try {
      isServerAvailable = await RecipeService.isServerAvailable();
      debugPrint('Server availability check: $isServerAvailable');
    } catch (e) {
      debugPrint('Server availability check failed: $e');
      isServerAvailable = false;
    }
  }

  Future<void> _loadTodayLoggedMeals(String uid) async {
    final log = await DailyNutritionService.getLog(
      uid: uid,
      targetCalories: userData?.targetCalories ?? userData?.tdee ?? 0,
      targetCarbs: userData?.carbGrams ?? 0,
      targetProtein: userData?.proteinGrams ?? 0,
      targetFat: userData?.fatGrams ?? 0,
    );

    final nextLoggedMeals = {
      'breakfast': <Map<String, dynamic>>[],
      'lunch': <Map<String, dynamic>>[],
      'dinner': <Map<String, dynamic>>[],
      'snacks': <Map<String, dynamic>>[],
    };

    for (final meal in log.meals) {
      nextLoggedMeals.putIfAbsent(
        meal.mealType,
        () => <Map<String, dynamic>>[],
      );
      nextLoggedMeals[meal.mealType]!.add({
        'recipe_id': meal.recipeId,
        'recipe_name': meal.recipeName,
        'image_url': meal.imageUrl,
        'nutrition': {
          'calories': meal.calories,
          'carbs': meal.carbs,
          'protein': meal.protein,
          'fat': meal.fat,
        },
      });
    }

    loggedMeals = nextLoggedMeals;
  }

  Future<void> _logSelectedMeal(
    String mealType,
    Map<String, dynamic> recipe,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await DailyNutritionService.logMeal(
      uid: user.uid,
      mealType: mealType,
      recipe: recipe,
      targetCalories: userData?.targetCalories ?? userData?.tdee ?? 0,
      targetCarbs: userData?.carbGrams ?? 0,
      targetProtein: userData?.proteinGrams ?? 0,
      targetFat: userData?.fatGrams ?? 0,
    );
  }

  String _formatDateLabel(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[date.month - 1]} ${date.day}';
  }

  List<DateTime> _weekDays() {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  List<DateTime> _getWeekMondays() {
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;

    // Find the first day of the month
    final firstDay = DateTime(currentYear, currentMonth, 1);

    // Find the Monday of the week containing the first day
    final firstMonday = firstDay.subtract(Duration(days: firstDay.weekday - 1));

    final weeks = <DateTime>[];
    var currentMonday = firstMonday;

    // Generate weeks until we've covered the entire month
    while (currentMonday.month <= currentMonth) {
      final sunday = currentMonday.add(const Duration(days: 6));
      // Include week if it has any days in the current month
      if (currentMonday.month == currentMonth || sunday.month == currentMonth) {
        weeks.add(currentMonday);
      }
      currentMonday = currentMonday.add(const Duration(days: 7));
      // Break if we've gone past the month
      if (currentMonday.month > currentMonth) break;
    }

    return weeks;
  }

  bool _isCurrentWeek(DateTime monday) {
    final today = DateTime.now();
    final currentMonday = today.subtract(Duration(days: today.weekday - 1));
    return monday.year == currentMonday.year &&
        monday.month == currentMonday.month &&
        monday.day == currentMonday.day;
  }

  Widget _buildWeekDaySelector() {
    final weekDays = _weekDays();
    final weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = weekDays[index];
          final isSelected = index == selectedDayIndex;
          final isToday =
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return GestureDetector(
            onTap: () => setState(() => selectedDayIndex = index),
            child: Container(
              width: 55,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.green
                    : (isToday ? Colors.orange.shade50 : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isSelected
                      ? Colors.green
                      : (isToday
                            ? Colors.orange.shade300
                            : Colors.grey.shade200),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdayLabels[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isToday ? Colors.orange : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : (isToday
                                ? Colors.orange.shade100
                                : Colors.grey.shade100),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.green
                              : (isToday ? Colors.orange : Colors.black87),
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
    );
  }

  String _formatWeekDateRange(DateTime monday, DateTime sunday) {
    return '${monday.day}-${sunday.day}';
  }

  Widget _buildWeekSelector() {
    final weekMondays = _getWeekMondays();

    // Calculate dynamic height based on number of weeks
    // 2 weeks per row = 1 row (60px), 4 weeks = 2 rows (60px each = 120px), etc.
    final numRows = (weekMondays.length + 1) ~/ 2;
    final dynamicHeight =
        (numRows * 65).toDouble() + ((numRows - 1) * 10).toDouble();

    return SizedBox(
      height: dynamicHeight,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: weekMondays.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.8,
        ),
        itemBuilder: (context, index) {
          final monday = weekMondays[index];
          final sunday = monday.add(const Duration(days: 6));
          final isSelected = index == selectedWeekIndex;
          final isCurrentWeek = _isCurrentWeek(monday);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedWeekIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.green
                    : (isCurrentWeek ? Colors.green.shade50 : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.green
                      : (isCurrentWeek
                            ? Colors.green.shade200
                            : Colors.grey.shade300),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'W${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isCurrentWeek ? Colors.green : Colors.black87),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatWeekDateRange(monday, sunday),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white70
                          : (isCurrentWeek
                                ? Colors.green.shade600
                                : Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadRecipesForMeal(String mealType) async {
    try {
      final targetCalories = mealCalorieTargets[mealType] ?? 500;
      final recipes = await RecipeService.searchRecipes(
        mealType: mealType,
        targetCalories: targetCalories,
        topK: 15,
        likedRecipes: userData?.likedRecipes ?? const [],
        dislikedRecipes: userData?.dislikedRecipes ?? const [],
      ).timeout(const Duration(seconds: 10));
      setState(() {
        mealRecipes[mealType] = recipes;
      });
    } catch (e) {
      debugPrint('Error loading recipes for $mealType: $e');
      setState(() {
        mealRecipes[mealType] = [];
      });
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    await _loadUserDataAndRecipes();

    setState(() {
      mealRecipesRequested.updateAll((key, value) => false);
      mealRecipes.clear();
      isLoading = false;
    });
  }

  Future<void> _handleMealLog(String mealType) async {
    if (!mounted) return;
    if (!isServerAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recipe server is not available. Please start the FastAPI server.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      mealRecipesRequested[mealType] = true;
      isLoading = true;
      errorMessage = null;
    });

    await _loadRecipesForMeal(mealType);

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final recipes = mealRecipes[mealType] ?? [];
    if (recipes.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No recommendations found for this meal type.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeSelectionPage(
          mealType: mealType,
          targetCalories: mealCalorieTargets[mealType] ?? 500,
          recipes: recipes,
          likedRecipes: userData?.likedRecipes ?? const [],
          dislikedRecipes: userData?.dislikedRecipes ?? const [],
          onMealSelected: (selectedRecipe) async {
            await _logSelectedMeal(mealType, selectedRecipe);
            setState(() {
              final current = loggedMeals[mealType] ?? [];
              loggedMeals[mealType] = List.from(current)..add(selectedRecipe);
            });
          },
        ),
      ),
    );
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .where((item) => item != null && item.toString().trim().isNotEmpty)
        .map((item) => item.toString().trim())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F4EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today, ${_formatDateLabel(DateTime.now())}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshPage,
                        tooltip: 'Refresh recipes',
                      ),
                      const Icon(Icons.settings),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  // 4 Weeks Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '4 Weeks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          showWeekSelector
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            showWeekSelector = !showWeekSelector;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  // Week Selector (Animated)
                  if (showWeekSelector) ...[
                    const SizedBox(height: 8),
                    _buildWeekSelector(),
                  ],
                  const SizedBox(height: 16),
                  // This Week Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildWeekDaySelector(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshPage,
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : errorMessage != null
                      ? _buildErrorView()
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              CaloriesSummaryCard(
                                userData: userData,
                                loggedMeals: loggedMeals,
                              ),
                              const SizedBox(height: 20),
                              MealsList(
                                mealRecipes: mealRecipes,
                                loggedMeals: loggedMeals,
                                mealCalorieTargets: mealCalorieTargets,
                                isServerAvailable: isServerAvailable,
                                mealRecipesRequested: mealRecipesRequested,
                                onLogPressed: _handleMealLog,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadUserDataAndRecipes,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class DateHeader extends StatelessWidget {
  const DateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text('Today, Oct 24', style: TextStyle(fontWeight: FontWeight.bold)),
        Icon(Icons.settings),
      ],
    );
  }
}

class CaloriesSummaryCard extends StatelessWidget {
  final UserData? userData;
  final Map<String, List<Map<String, dynamic>>> loggedMeals;

  const CaloriesSummaryCard({
    super.key,
    this.userData,
    required this.loggedMeals,
  });

  double _nutritionValueFromRecipe(
    Map<String, dynamic> recipe,
    List<String> keys,
  ) {
    final nutrition = recipe['nutrition'] as Map<String, dynamic>?;
    for (final key in keys) {
      final value = nutrition?[key] ?? recipe[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  int _totalConsumed(String key, [List<String> altKeys = const []]) {
    final keys = [key, ...altKeys];
    return loggedMeals.values.fold<int>(0, (totalCalories, meals) {
      return totalCalories +
          meals.fold<int>(0, (mealSum, meal) {
            return mealSum + _nutritionValueFromRecipe(meal, keys).round();
          });
    });
  }

  int _caloriesConsumed() {
    return loggedMeals.values.fold<int>(0, (totalCalories, meals) {
      return totalCalories +
          meals.fold<int>(0, (mealSum, meal) {
            return mealSum +
                _nutritionValueFromRecipe(meal, [
                  'calories',
                  'kcal',
                  'energy',
                ]).round();
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    final targetCalories = userData?.targetCalories ?? userData?.tdee ?? 0;
    final caloriesConsumed = _caloriesConsumed();
    final remainingCalories = (targetCalories - caloriesConsumed)
        .clamp(0, double.infinity)
        .toInt();

    final carbsConsumed = _totalConsumed('carbs', ['carbohydrates']);
    final carbsTarget = userData?.carbGrams?.toInt() ?? 0;
    final proteinConsumed = _totalConsumed('protein');
    final proteinTarget = userData?.proteinGrams?.toInt() ?? 0;
    final fatConsumed = _totalConsumed('fat', ['fats', 'fat_grams']);
    final fatTarget = userData?.fatGrams?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'CALORIES REMAINING',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            remainingCalories.toString(),
            style: const TextStyle(
              fontSize: 32,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          MacroProgress(
            label: 'Carbs',
            value: '$carbsConsumed / ${carbsTarget}g',
            progress: carbsTarget > 0 ? carbsConsumed / carbsTarget : 0,
          ),
          MacroProgress(
            label: 'Protein',
            value: '$proteinConsumed / ${proteinTarget}g',
            progress: proteinTarget > 0 ? proteinConsumed / proteinTarget : 0,
          ),
          MacroProgress(
            label: 'Fat',
            value: '$fatConsumed / ${fatTarget}g',
            progress: fatTarget > 0 ? fatConsumed / fatTarget : 0,
          ),
        ],
      ),
    );
  }
}

class MealsList extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> mealRecipes;
  final Map<String, List<Map<String, dynamic>>> loggedMeals;
  final Map<String, double> mealCalorieTargets;
  final Map<String, bool> mealRecipesRequested;
  final Future<void> Function(String) onLogPressed;
  final bool isServerAvailable;

  const MealsList({
    super.key,
    required this.mealRecipes,
    required this.loggedMeals,
    required this.mealCalorieTargets,
    required this.mealRecipesRequested,
    required this.onLogPressed,
    required this.isServerAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MealSection(
          title: 'Breakfast',
          targetCalories: mealCalorieTargets['breakfast'] ?? 0,
          recipes: mealRecipes['breakfast'] ?? [],
          loggedRecipes: loggedMeals['breakfast'] ?? [],
          isRequested: mealRecipesRequested['breakfast'] ?? false,
          isServerAvailable: isServerAvailable,
          onLogPressed: onLogPressed,
        ),
        MealSection(
          title: 'Lunch',
          targetCalories: mealCalorieTargets['lunch'] ?? 0,
          recipes: mealRecipes['lunch'] ?? [],
          loggedRecipes: loggedMeals['lunch'] ?? [],
          isRequested: mealRecipesRequested['lunch'] ?? false,
          isServerAvailable: isServerAvailable,
          onLogPressed: onLogPressed,
        ),
        MealSection(
          title: 'Dinner',
          targetCalories: mealCalorieTargets['dinner'] ?? 0,
          recipes: mealRecipes['dinner'] ?? [],
          loggedRecipes: loggedMeals['dinner'] ?? [],
          isRequested: mealRecipesRequested['dinner'] ?? false,
          isServerAvailable: isServerAvailable,
          onLogPressed: onLogPressed,
        ),
        MealSection(
          title: 'Snacks',
          targetCalories: mealCalorieTargets['snacks'] ?? 0,
          recipes: mealRecipes['snacks'] ?? [],
          loggedRecipes: loggedMeals['snacks'] ?? [],
          isRequested: mealRecipesRequested['snacks'] ?? false,
          isServerAvailable: isServerAvailable,
          onLogPressed: onLogPressed,
        ),
      ],
    );
  }
}

class MealSection extends StatelessWidget {
  final String title;
  final double targetCalories;
  final List<Map<String, dynamic>> recipes;
  final List<Map<String, dynamic>> loggedRecipes;
  final bool isRequested;
  final bool isServerAvailable;
  final Future<void> Function(String) onLogPressed;

  const MealSection({
    super.key,
    required this.title,
    required this.targetCalories,
    required this.recipes,
    required this.loggedRecipes,
    required this.isRequested,
    required this.isServerAvailable,
    required this.onLogPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total calories from recipes (this would be actual consumed calories)
    final consumedCalories = loggedRecipes.isNotEmpty
        ? loggedRecipes
              .map((r) => r['nutrition']?['calories'] ?? 0)
              .reduce((a, b) => a + b)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${consumedCalories.toInt()} / ${targetCalories.toInt()} kcal',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        // Show logged meals first, then recipe recommendations or a prompt.
        if (loggedRecipes.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Logged meals',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...loggedRecipes.map((meal) {
            final imageUrl = MealSection._imageUrl(meal);
            return FoodItem(
              name: meal['recipe_name'] ?? meal['name'] ?? 'Logged Meal',
              kcal: (meal['nutrition']?['calories'] ?? 0).toInt().toString(),
              imagePath: imageUrl,
              isNetworkImage: MealSection._isNetworkImage(imageUrl),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailsScreen(
                      recipeName:
                          (meal['recipe_name'] ?? meal['name'] ?? 'Recipe')
                              .toString(),
                      ingredients: MealSection._ingredients(meal),
                      recipeData: meal,
                      mealType: title.toLowerCase(),
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 12),
        ] else ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Nothing added here yet. Tap Add food + to log a meal.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (!isRequested) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isServerAvailable ? Icons.play_arrow : Icons.info_outline,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isServerAvailable
                        ? 'Press Add food + to load recommendations.'
                        : 'Recipe server is not available. Start the FastAPI server to see recommendations.',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ] else if (recipes.isEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No recipe recommendations found for this meal type.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ] else if (isRequested && recipes.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Recipes are ready in the Add Food search page. Refresh the page to get a new set of search results.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
        ],
        AddFoodButton(
          label: title == 'Dinner' ? 'Log Dinner' : 'Add food +',
          onTap: () => onLogPressed(title.toLowerCase()),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  static String? _imageUrl(Map<String, dynamic> recipe) {
    return recipe['image_url'] as String? ??
        recipe['image'] as String? ??
        recipe['photo'] as String?;
  }

  static bool _isNetworkImage(String? imagePath) {
    return imagePath != null &&
        (imagePath.startsWith('http://') || imagePath.startsWith('https://'));
  }

  static List<Map<String, String>> _ingredients(Map<String, dynamic> recipe) {
    final rawIngredients = recipe['ingredients'] as List?;
    if (rawIngredients == null) return const [];

    return rawIngredients.whereType<Map>().map((ing) {
      final weight = double.tryParse(
        (ing['weight_g'] ?? ing['weight'] ?? '').toString(),
      );
      return {
        'name':
            (ing['name'] ?? ing['food'] ?? ing['ingredient'] ?? 'Ingredient')
                .toString(),
        'quantity':
            (ing['measure'] ??
                    ing['quantity'] ??
                    ing['amount'] ??
                    (weight == null ? '' : '${_formatNumber(weight)} g'))
                .toString(),
      };
    }).toList();
  }

  static String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  static String? _imageUrl(Map<String, dynamic> recipe) {
    return recipe['image_url'] as String? ??
        recipe['image'] as String? ??
        recipe['photo'] as String?;
  }

  static List<String> _extractDietLabels(Map<String, dynamic> recipe) {
    final labels = <String>{};
    final rawLabels =
        recipe['diet_labels'] ?? recipe['dietLabels'] ?? recipe['tags'];

    if (rawLabels is String) {
      labels.addAll(
        rawLabels
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty),
      );
    } else if (rawLabels is Iterable) {
      labels.addAll(
        rawLabels
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty),
      );
    }

    for (final key in [
      'meal_type',
      'mealType',
      'category',
      'cuisine',
      'type',
    ]) {
      final value = recipe[key];
      if (value is String && value.isNotEmpty) {
        labels.add(value);
      }
    }

    return labels.toList();
  }

  static List<MapEntry<String, String>> _flattenRecipeData(
    Map<String, dynamic> recipe,
  ) {
    final entries = <MapEntry<String, String>>[];

    recipe.forEach((key, value) {
      if (key == 'image' ||
          key == 'image_url' ||
          key == 'photo' ||
          key == 'diet_labels' ||
          key == 'dietLabels' ||
          key == 'tags' ||
          key == 'recipe_name' ||
          key == 'name' ||
          key == 'nutrition' ||
          key == 'description') {
        return;
      }

      entries.add(MapEntry(key, _formatValue(value)));
    });

    return entries;
  }

  static String _formatValue(dynamic value) {
    if (value == null) return '—';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    if (value is Iterable) return value.join(', ');
    if (value is Map) {
      return value.entries
          .map((entry) => '${entry.key}: ${_formatValue(entry.value)}')
          .join(', ');
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl(recipe);
    final recipeName =
        recipe['recipe_name'] ?? recipe['name'] ?? 'Recipe Details';
    final calories = (recipe['nutrition']?['calories'] ?? 0).toInt();
    final labels = _extractDietLabels(recipe);
    final description = recipe['description'] as String?;
    final nutrition = recipe['nutrition'] as Map<String, dynamic>?;
    final extraData = _flattenRecipeData(recipe);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffF6F4EF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null) ...[
                Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipeName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$calories kcal',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (labels.isNotEmpty)
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: labels
                            .map(
                              (label) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ...(description != null && description.isNotEmpty
                        ? [
                            const SizedBox(height: 20),
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                          ]
                        : []),
                  ],
                ),
              ),
              ...(nutrition != null && nutrition.isNotEmpty
                  ? [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.restaurant_menu,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Nutrition Facts',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...nutrition.entries.map(
                              (entry) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _formatValue(entry.value),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  : []),
              ...(extraData.isNotEmpty
                  ? [
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Additional Details',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...extraData.map(
                              (entry) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${entry.key}:',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  : []),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeSelectionPage extends StatefulWidget {
  final String mealType;
  final double targetCalories;
  final int topK;
  final List<Map<String, dynamic>> recipes;
  final List<String> likedRecipes;
  final List<String> dislikedRecipes;
  final void Function(Map<String, dynamic>) onMealSelected;

  const RecipeSelectionPage({
    super.key,
    required this.mealType,
    required this.targetCalories,
    required this.recipes,
    this.likedRecipes = const [],
    this.dislikedRecipes = const [],
    required this.onMealSelected,
    this.topK = 15,
  });

  @override
  State<RecipeSelectionPage> createState() => _RecipeSelectionPageState();
}

class _RecipeSelectionPageState extends State<RecipeSelectionPage> {
  late List<Map<String, dynamic>> recipes;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    recipes = widget.recipes;
  }

  Future<void> _refreshRecipes() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final newRecipes = await RecipeService.searchRecipes(
        mealType: widget.mealType,
        targetCalories: widget.targetCalories,
        topK: widget.topK,
        likedRecipes: widget.likedRecipes,
        dislikedRecipes: widget.dislikedRecipes,
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      setState(() {
        recipes = newRecipes;
      });
    } catch (e) {
      debugPrint('Error refreshing recipes: $e');
      if (!mounted) return;
      setState(() {
        errorMessage =
            'Unable to refresh search results. Pull down to refresh or tap the refresh button to retry.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  static List<String> _extractDietLabels(Map<String, dynamic> recipe) {
    final labels = <String>{};
    final rawLabels =
        recipe['diet_labels'] ?? recipe['dietLabels'] ?? recipe['tags'];

    if (rawLabels is String) {
      labels.addAll(
        rawLabels
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty),
      );
    } else if (rawLabels is Iterable) {
      labels.addAll(
        rawLabels
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty),
      );
    }

    for (final key in [
      'meal_type',
      'mealType',
      'category',
      'cuisine',
      'type',
    ]) {
      final value = recipe[key];
      if (value is String && value.isNotEmpty) {
        labels.add(value);
      }
    }

    return labels.toList();
  }

  static String? _imageUrl(Map<String, dynamic> recipe) {
    return recipe['image_url'] as String? ??
        recipe['image'] as String? ??
        recipe['photo'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Add ${widget.mealType} Food'),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshRecipes,
            tooltip: 'Get different recipes',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffF6F4EF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _refreshRecipes,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: recipes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    final imageUrl = _imageUrl(recipe);
                    final labels = _extractDietLabels(recipe);
                    final recipeName =
                        recipe['recipe_name'] ??
                        recipe['name'] ??
                        'Unknown Recipe';
                    final calories = (recipe['nutrition']?['calories'] ?? 0)
                        .toInt();

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          // Extract ingredients from recipe
                          final List<Map<String, String>> ingredients = [];
                          final ingredientList = recipe['ingredients'] as List?;
                          if (ingredientList != null) {
                            for (var ing in ingredientList) {
                              if (ing is Map<String, dynamic>) {
                                final weight = double.tryParse(
                                  (ing['weight_g'] ?? ing['weight'] ?? '')
                                      .toString(),
                                );
                                ingredients.add({
                                  'name':
                                      (ing['name'] ??
                                              ing['food'] ??
                                              ing['ingredient'] ??
                                              'Ingredient')
                                          .toString(),
                                  'quantity':
                                      (ing['measure'] ??
                                              ing['quantity'] ??
                                              ing['amount'] ??
                                              (weight == null
                                                  ? ''
                                                  : '${weight.round()} g'))
                                          .toString(),
                                });
                              }
                            }
                          }

                          // Navigate to RecipeDetailsScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailsScreen(
                                recipeName: recipeName,
                                ingredients: ingredients,
                                recipeData: recipe,
                                mealType: widget.mealType,
                                onAddToMeal: () {
                                  widget.onMealSelected(recipe);
                                  Navigator.pop(context);
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$recipeName added to ${widget.mealType}',
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'recipe_image_$recipeName',
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.grey.shade200,
                                    image: imageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: imageUrl == null
                                      ? const Icon(
                                          Icons.restaurant,
                                          color: Colors.grey,
                                          size: 32,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipeName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.local_fire_department,
                                          color: Colors.orange,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$calories kcal',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: labels.isNotEmpty
                                          ? labels
                                                .map(
                                                  (label) => Chip(
                                                    label: Text(
                                                      label,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.green.shade100,
                                                    labelStyle: const TextStyle(
                                                      color: Colors.green,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                )
                                                .toList()
                                          : [
                                              Chip(
                                                label: const Text(
                                                  'Healthy',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    Colors.green.shade100,
                                                labelStyle: const TextStyle(
                                                  color: Colors.green,
                                                ),
                                                padding: EdgeInsets.zero,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
