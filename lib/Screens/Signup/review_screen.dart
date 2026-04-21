import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gap/gap.dart';
import '../../utils/page_transitions.dart';
import '../../utils/widgets.dart';
import '../../utils/user_data.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: signupData.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    signupData.calculateMetrics();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Gap(30),
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
                  activeIndex: 12,
                  count: 13,
                  animationDuration: const Duration(milliseconds: 400),
                  activeColor: const Color(0xff13EC5B),
                  inactiveColor: const Color(0xFFCCCCCC),
                  dotSize: 10.0,
                ),
                const Spacer(),
              ],
            ),
            Gap(20),
            const Text(
              "REVIEW PROFILE",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Please review your details below to ensure your\npersonalized plan is accurate.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            // Scrollable content
            Expanded(
              child: ListView(
                children: [
                  _buildSectionHeader("Personal Info"),
                  const SizedBox(height: 16),
                  _buildEditableItem(
                    Icons.person_outline,
                    "Name",
                    signupData.name ?? 'Not set',
                    () => _showEditNameDialog(),
                  ),
                  const SizedBox(height: 16),
                  _buildEditableItem(
                    Icons.cake,
                    "Birth Date",
                    signupData.birthDay != null
                        ? '${signupData.birthDay.toString().padLeft(2, '0')}/${signupData.birthMonth.toString().padLeft(2, '0')}/${signupData.birthYear}'
                        : 'Not set',
                    () => _showEditBirthDateDialog(),
                  ),

                  const SizedBox(height: 32),
                  // Body Metrics Section
                  _buildSectionHeader("Body Metrics"),
                  const SizedBox(height: 16),
                  _buildEditableItem(
                    Icons.wc,
                    "Gender",
                    signupData.gender?.toUpperCase() ?? 'Not set',
                    () => _showEditGenderDialog(),
                  ),
                  const SizedBox(height: 16),
                  _buildEditableItem(
                    Icons.height,
                    "Height",
                    signupData.heightCm != null
                        ? '${signupData.heightCm!.toStringAsFixed(0)} cm'
                        : 'Not set',
                    () => _showEditHeightDialog(),
                  ),
                  const SizedBox(height: 16),
                  _buildEditableItem(
                    Icons.fitness_center,
                    "Current Weight",
                    signupData.currentWeight != null
                        ? '${signupData.currentWeight!.toStringAsFixed(1)} kg'
                        : 'Not set',
                    () => _showEditCurrentWeightDialog(),
                  ),
                  const SizedBox(height: 16),
                  _buildEditableItem(
                    Icons.fitness_center,
                    "Goal Weight",
                    signupData.goalWeight != null
                        ? '${signupData.goalWeight!.toStringAsFixed(1)} kg'
                        : 'Not set',
                    () => _showEditGoalWeightDialog(),
                  ),
                  const SizedBox(height: 16),
                  _buildEditableItem(
                    Icons.health_and_safety,
                    "Diabetes",
                    signupData.hasObesity == null
                        ? 'Not set'
                        : (signupData.hasObesity! ? 'Yes' : 'No'),
                    () => _showEditDiabetesDialog(),
                  ),

                  const SizedBox(height: 32),
                  // Activity & Goals Section
                  _buildSectionHeader("Activity & Goals"),
                  const SizedBox(height: 16),
                  _buildEditableItem(
                    Icons.directions_run,
                    "Activity Level",
                    signupData.activityLabel ?? 'Not set',
                    () => _showEditActivityLevelDialog(),
                  ),
                  const SizedBox(height: 16),
                  _buildEditableItem(
                    Icons.restaurant_menu,
                    "Meal Goal",
                    signupData.mealGoalLabel ?? 'Not set',
                    () => _showEditMealGoalDialog(),
                  ),
                  const SizedBox(height: 16),
                  _buildEditableItem(
                    Icons.fitness_center,
                    "Workout Days",
                    signupData.workoutDays?.isNotEmpty ?? false
                        ? signupData.workoutDays!.join(', ')
                        : 'Not set',
                    () => _showEditWorkoutDaysDialog(),
                  ),

                  const SizedBox(height: 32),
                  // Nutrition Section
                  _buildSectionHeader("Calculated Metrics"),
                  const SizedBox(height: 16),
                  _buildDisplayItem(
                    Icons.calendar_today,
                    "Age",
                    signupData.age > 0 ? signupData.age.toString() : 'N/A',
                  ),
                  const SizedBox(height: 16),
                  _buildDisplayItem(
                    Icons.monitor_weight,
                    "BMI",
                    signupData.bmi != null
                        ? '${signupData.bmi!.toStringAsFixed(1)} (${signupData.bmiCategory})'
                        : 'N/A',
                  ),
                  const SizedBox(height: 16),
                  _buildDisplayItem(
                    Icons.restaurant_menu,
                    "Target Calories",
                    signupData.targetCalories != null
                        ? '${signupData.targetCalories!.toStringAsFixed(0)} kcal'
                        : 'N/A',
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
            // Confirm button - goes directly to home page
            NextButton(
              label: 'Confirm & Start',
              onPressed: () async {
                // Perform final calculations
                signupData.calculateMetrics();
                
                // Handle Google Sign-In authentication if needed
                if (signupData.isGoogleSignIn && 
                    signupData.googleIdToken != null && 
                    signupData.googleAccessToken != null) {
                  try {
                    final credential = GoogleAuthProvider.credential(
                      accessToken: signupData.googleAccessToken!,
                      idToken: signupData.googleIdToken!,
                    );
                    await FirebaseAuth.instance.signInWithCredential(credential);
                  } catch (error) {
                    // Handle authentication error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Authentication failed: $error')),
                    );
                    return;
                  }
                }
                
                // Navigate directly to home page
                Navigator.pushReplacementNamed(context, '/auth_method');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildEditableItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onEdit,
  ) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Edit Dialogs
  void _showEditNameDialog() {
    _nameController.text = signupData.name ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => signupData.name = _nameController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditBirthDateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Birth Date'),
        content: SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: (signupData.birthDay ?? 1) - 1,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    signupData.birthDay = index + 1;
                  },
                  children: List.generate(31, (i) => Center(child: Text('${i + 1}'))),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: (signupData.birthMonth ?? 1) - 1,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    signupData.birthMonth = index + 1;
                  },
                  children: List.generate(12, (i) => Center(child: Text('${i + 1}'))),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: DateTime.now().year - (signupData.birthYear ?? DateTime.now().year),
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    signupData.birthYear = DateTime.now().year - index;
                  },
                  children: List.generate(100, (i) => Center(child: Text('${DateTime.now().year - i}'))),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditGenderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Male'),
              value: 'male',
              groupValue: signupData.gender,
              onChanged: (value) {
                setState(() => signupData.gender = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Female'),
              value: 'female',
              groupValue: signupData.gender,
              onChanged: (value) {
                setState(() => signupData.gender = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditHeightDialog() {
    final heightController = TextEditingController(
      text: signupData.heightCm?.toStringAsFixed(0) ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Height (cm)'),
        content: TextField(
          controller: heightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter height in cm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final height = double.tryParse(heightController.text);
              if (height != null) {
                setState(() => signupData.heightCm = height);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditCurrentWeightDialog() {
    final weightController = TextEditingController(
      text: signupData.currentWeight?.toStringAsFixed(1) ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Current Weight (kg)'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter current weight'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null) {
                setState(() => signupData.currentWeight = weight);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalWeightDialog() {
    final weightController = TextEditingController(
      text: signupData.goalWeight?.toStringAsFixed(1) ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Goal Weight (kg)'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter goal weight'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null) {
                setState(() => signupData.goalWeight = weight);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditDiabetesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Do you have Diabetes?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Yes'),
              value: true,
              groupValue: signupData.hasObesity,
              onChanged: (value) {
                setState(() => signupData.hasObesity = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('No'),
              value: false,
              groupValue: signupData.hasObesity,
              onChanged: (value) {
                setState(() => signupData.hasObesity = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditActivityLevelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Activity Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Sedentary',
            'Lightly Active',
            'Moderate',
            'Active',
            'Very Active',
          ]
              .asMap()
              .entries
              .map(
                (e) => RadioListTile(
                  title: Text(e.value),
                  value: e.key,
                  groupValue: signupData.activityLevel,
                  onChanged: (value) {
                    setState(() => signupData.activityLevel = value);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showEditMealGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Meal Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Weekly Plan',
            'Daily Plan',
            'Single Meal',
          ]
              .asMap()
              .entries
              .map(
                (e) => RadioListTile(
                  title: Text(e.value),
                  value: e.key,
                  groupValue: signupData.mealGoal,
                  onChanged: (value) {
                    setState(() => signupData.mealGoal = value);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showEditWorkoutDaysDialog() {
    final days = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final selectedDays = <int>{};
    
    if (signupData.workoutDays != null) {
      for (int i = 0; i < days.length; i++) {
        if (signupData.workoutDays!.contains(days[i])) {
          selectedDays.add(i);
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Edit Workout Days'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: days
                .asMap()
                .entries
                .map(
                  (e) => CheckboxListTile(
                    title: Text(e.value),
                    value: selectedDays.contains(e.key),
                    onChanged: (value) {
                      setStateDialog(() {
                        if (value ?? false) {
                          selectedDays.add(e.key);
                        } else {
                          selectedDays.remove(e.key);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  signupData.workoutDays =
                      selectedDays.map((i) => days[i]).toList();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

