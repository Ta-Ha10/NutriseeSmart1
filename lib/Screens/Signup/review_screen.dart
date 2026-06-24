import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../l10n/app_locale.dart';
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
      backgroundColor: const Color(0xFFFAFBFC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Gap(30),
            Row(
              children: [
                Container(
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
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: const Color(0xff13EC5B),
                    iconSize: 24,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(),
                AnimatedIndicator(
                  activeIndex: 12,
                  count: 13,
                  animationDuration: const Duration(milliseconds: 400),
                  activeColor: const Color(0xff13EC5B),
                  inactiveColor: const Color(0xFFE0E0E0),
                  dotSize: 10.0,
                ),
                const Spacer(),
                Container(
                  width: 48,
                ),
              ],
            ),
            Gap(28),
            const Text(
              "Review Your Profile",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Verify your information to create your personalized nutrition plan",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // Scrollable content - Grid Layout
            Expanded(
              child: ListView(
                children: [
                  _buildSectionHeader("Personal Info"),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                    children: [
                      _buildGridEditableItem(
                        Icons.person_outline,
                        "Name",
                        signupData.name ?? 'Not set',
                        () => _showEditNameDialog(),
                      ),
                      _buildGridEditableItem(
                        Icons.cake,
                        "Birth Date",
                        signupData.birthDay != null
                            ? '${AppLocaleController.formatNumber(signupData.birthDay!)}/${AppLocaleController.formatNumber(signupData.birthMonth!)}/${AppLocaleController.formatNumber(signupData.birthYear!)}'
                            : 'Not set',
                        () => _showEditBirthDateDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  // Body Metrics Section
                  _buildSectionHeader("Body Metrics"),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                    children: [
                      _buildGridEditableItem(
                        Icons.wc,
                        "Gender",
                        signupData.gender?.toUpperCase() ?? 'Not set',
                        () => _showEditGenderDialog(),
                      ),
                      _buildGridEditableItem(
                        Icons.height,
                        "Height",
                        signupData.heightCm != null
                            ? '${AppLocaleController.formatNumber(signupData.heightCm!.round())} cm'
                            : 'Not set',
                        () => _showEditHeightDialog(),
                      ),
                      _buildGridEditableItem(
                        Icons.fitness_center,
                        "Current Weight",
                        signupData.currentWeight != null
                            ? '${AppLocaleController.localizeDigits(signupData.currentWeight!.toStringAsFixed(1))} kg'
                            : 'Not set',
                        () => _showEditCurrentWeightDialog(),
                      ),
                      _buildGridEditableItem(
                        Icons.fitness_center,
                        "Goal Weight",
                        signupData.goalWeight != null
                            ? '${AppLocaleController.localizeDigits(signupData.goalWeight!.toStringAsFixed(1))} kg'
                            : 'Not set',
                        () => _showEditGoalWeightDialog(),
                      ),
                      _buildGridEditableItem(
                        Icons.health_and_safety,
                        "Diabetes",
                        signupData.hasObesity == null
                            ? 'Not set'
                            : (signupData.hasObesity! ? 'Yes' : 'No'),
                        () => _showEditDiabetesDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  // Activity & Goals Section
                  _buildSectionHeader("Activity & Goals"),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                    children: [
                      _buildGridEditableItem(
                        Icons.directions_run,
                        "Activity Level",
                        signupData.activityLabel ?? 'Not set',
                        () => _showEditActivityLevelDialog(),
                      ),
                      _buildGridEditableItem(
                        Icons.restaurant_menu,
                        "Meal Goal",
                        signupData.mealGoalLabel ?? 'Not set',
                        () => _showEditMealGoalDialog(),
                      ),
                      _buildGridEditableItem(
                        Icons.fitness_center,
                        "Workout Days",
                        signupData.workoutDays?.isNotEmpty ?? false
                            ? signupData.workoutDays!.join(', ')
                            : 'Not set',
                        () => _showEditWorkoutDaysDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  // Nutrition Section
                  _buildSectionHeader("Calculated Metrics"),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.95,
                    children: [
                      _buildGridDisplayItem(
                        Icons.calendar_today,
                        "Age",
                        signupData.age > 0
                            ? AppLocaleController.formatNumber(signupData.age)
                            : 'N/A',
                      ),
                      _buildGridDisplayItem(
                        Icons.monitor_weight,
                        "BMI",
                        signupData.bmi != null
                            ? '${AppLocaleController.localizeDigits(signupData.bmi!.toStringAsFixed(1))} (${signupData.bmiCategory})'
                            : 'N/A',
                      ),
                      _buildGridDisplayItem(
                        Icons.restaurant_menu,
                        "Target Calories",
                        signupData.targetCalories != null
                            ? '${AppLocaleController.formatNumber(signupData.targetCalories!.round())} kcal'
                            : 'N/A',
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
            // Confirm button - goes directly to home page
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: NextButton(
                label: 'Confirm & Start',
                onPressed: () async {
                  signupData.calculateMetrics();

                  Navigator.pushReplacementNamed(context, '/auth_method');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xff13EC5B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Grid-based widgets
  Widget _buildGridEditableItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onEdit,
  ) {
    return GestureDetector(
      onTap: onEdit,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF0F0F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xff13EC5B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xff13EC5B), size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xff13EC5B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined, color: Color(0xff13EC5B), size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridDisplayItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF0F0F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xff13EC5B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xff13EC5B), size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Edit Name',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                filled: true,
                fillColor: const Color(0xFFFAFBFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFF0F0F0), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFF0F0F0), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xff13EC5B), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff13EC5B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () {
              setState(() => signupData.name = _nameController.text.trim());
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBirthDateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Edit Birth Date',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
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
                  children: List.generate(
                    31,
                    (i) => Center(
                      child: Text(AppLocaleController.formatNumber(i + 1)),
                    ),
                  ),
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
                  children: List.generate(
                    12,
                    (i) => Center(
                      child: Text(AppLocaleController.formatNumber(i + 1)),
                    ),
                  ),
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
                  children: List.generate(
                    100,
                    (i) => Center(
                      child: Text(
                        AppLocaleController.formatNumber(DateTime.now().year - i),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff13EC5B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditGenderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Select Gender',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Male', style: TextStyle(fontWeight: FontWeight.w600)),
              value: 'male',
              groupValue: signupData.gender,
              activeColor: const Color(0xff13EC5B),
              onChanged: (value) {
                setState(() => signupData.gender = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Female', style: TextStyle(fontWeight: FontWeight.w600)),
              value: 'female',
              groupValue: signupData.gender,
              activeColor: const Color(0xff13EC5B),
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
      text: signupData.heightCm != null
          ? AppLocaleController.localizeDigits(
              signupData.heightCm!.toStringAsFixed(0),
            )
          : '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Edit Height',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter height in cm',
                suffixText: 'cm',
                filled: true,
                fillColor: const Color(0xFFFAFBFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFF0F0F0), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFF0F0F0), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xff13EC5B), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff13EC5B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () {
              final height = double.tryParse(
                AppLocaleController.normalizeDigits(heightController.text),
              );
              if (height != null) {
                setState(() => signupData.heightCm = height);
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCurrentWeightDialog() {
    final weightController = TextEditingController(
      text: signupData.currentWeight != null
          ? AppLocaleController.localizeDigits(
              signupData.currentWeight!.toStringAsFixed(1),
            )
          : '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Edit Current Weight',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter current weight',
                suffixText: 'kg',
                filled: true,
                fillColor: const Color(0xFFFAFBFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFF0F0F0), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFF0F0F0), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xff13EC5B), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff13EC5B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () {
              final weight = double.tryParse(
                AppLocaleController.normalizeDigits(weightController.text),
              );
              if (weight != null) {
                setState(() => signupData.currentWeight = weight);
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditGoalWeightDialog() {
    final weightController = TextEditingController(
      text: signupData.goalWeight != null
          ? AppLocaleController.localizeDigits(
              signupData.goalWeight!.toStringAsFixed(1),
            )
          : '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Edit Goal Weight',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter goal weight',
                suffixText: 'kg',
                filled: true,
                fillColor: const Color(0xFFFAFBFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFF0F0F0), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFF0F0F0), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xff13EC5B), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff13EC5B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () {
              final weight = double.tryParse(
                AppLocaleController.normalizeDigits(weightController.text),
              );
              if (weight != null) {
                setState(() => signupData.goalWeight = weight);
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDiabetesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Do you have Diabetes?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Yes', style: TextStyle(fontWeight: FontWeight.w600)),
              value: true,
              groupValue: signupData.hasObesity,
              activeColor: const Color(0xff13EC5B),
              onChanged: (value) {
                setState(() => signupData.hasObesity = value);
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('No', style: TextStyle(fontWeight: FontWeight.w600)),
              value: false,
              groupValue: signupData.hasObesity,
              activeColor: const Color(0xff13EC5B),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Activity Level',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
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
                  title: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                  value: e.key,
                  groupValue: signupData.activityLevel,
                  activeColor: const Color(0xff13EC5B),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Meal Goal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
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
                  title: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                  value: e.key,
                  groupValue: signupData.mealGoal,
                  activeColor: const Color(0xff13EC5B),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Workout Days',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: days
                .asMap()
                .entries
                .map(
                  (e) => CheckboxListTile(
                    title: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                    value: selectedDays.contains(e.key),
                    activeColor: const Color(0xff13EC5B),
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
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff13EC5B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: () {
                setState(() {
                  signupData.workoutDays =
                      selectedDays.map((i) => days[i]).toList();
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

