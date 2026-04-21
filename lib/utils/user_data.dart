import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String? name;
  int? birthDay;
  int? birthMonth;
  int? birthYear;
  String? gender;
  double? heightCm;
  double? currentWeight;
  double? goalWeight;
  bool? hasObesity;
  int? activityLevel; // 0: Sedentary, 1: Lightly Active, 2: Moderate, 3: Active, 4: Very Active
  int? mealGoal; // 0: Weekly Plan, 1: Daily Plan, 2: Single Meal
  String? email; // Email from authentication, null if not entered
  String? password; // Password for email/password signup
  
  // Google Sign-In fields
  String? googleIdToken;
  String? googleAccessToken;
  bool isGoogleSignIn = false;

  // Additional signup fields
  List<String>? workoutDays; // e.g., ['Monday', 'Wednesday', 'Friday']
  Map<String, TimeOfDay>? mealTimes; // e.g., {'breakfast': TimeOfDay(hour: 8, minute: 0), ...}

  // Recipe preferences
  List<String>? likedRecipes; // array of recipe IDs
  List<String>? dislikedRecipes; // array of recipe IDs
  Map<String, int>? recipeRatings; // recipeId -> rating (1-5)

  // Calculated values
  double? bmi;
  String? bmiCategory;
  double? bmr;
  double? tdee;
  double? targetCalories;
  double? proteinGrams;
  double? fatGrams;
  double? carbGrams;

  int get age {
    if (birthYear == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthYear!;
    if (now.month < (birthMonth ?? 1) ||
        (now.month == (birthMonth ?? 1) && now.day < (birthDay ?? 1))) {
      age--;
    }
    return age;
  }

  void calculateMetrics() {
    if (currentWeight == null || heightCm == null || gender == null || activityLevel == null) {
      return;
    }

    // BMI Calculation
    double heightM = heightCm! / 100;
    bmi = currentWeight! / (heightM * heightM);

    // BMI Category
    if (bmi! < 18.5) {
      bmiCategory = 'Underweight';
    } else if (bmi! < 25) {
      bmiCategory = 'Normal';
    } else if (bmi! < 30) {
      bmiCategory = 'Overweight';
    } else {
      bmiCategory = 'Obese';
    }

    // BMR Calculation (Mifflin-St Jeor)
    if (gender == 'male') {
      bmr = 10 * currentWeight! + 6.25 * heightCm! - 5 * age + 5;
    } else {
      bmr = 10 * currentWeight! + 6.25 * heightCm! - 5 * age - 161;
    }

    // Activity Factors
    const activityFactors = [1.2, 1.375, 1.55, 1.725, 1.9];
    double activityFactor = activityFactors[activityLevel!];

    // TDEE
    tdee = bmr! * activityFactor;

    // Target Calories based on goal
    if (goalWeight != null) {
      if (goalWeight! < currentWeight!) {
        // Weight loss
        targetCalories = tdee! - 400; // Moderate deficit
      } else if (goalWeight! > currentWeight!) {
        // Weight gain
        targetCalories = tdee! + 400; // Moderate surplus
      } else {
        // Maintain
        targetCalories = tdee;
      }
    } else {
      targetCalories = tdee;
    }

    // Macronutrients
    // Protein: 1.8-2.0 g/kg for training (using 1.9 as average)
    proteinGrams = 1.9 * currentWeight!;

    // Fat: 0.8-1.0 g/kg (using 0.9 as average)
    fatGrams = 0.9 * currentWeight!;

    // Carbs: remaining calories / 4
    double proteinCalories = proteinGrams! * 4;
    double fatCalories = fatGrams! * 9;
    double remainingCalories = targetCalories! - proteinCalories - fatCalories;
    carbGrams = remainingCalories / 4;

    // Ensure minimum values
    if (carbGrams! < 0) carbGrams = 50;
  }

  String? get activityLabel {
    const labels = [
      'Sedentary',
      'Lightly Active',
      'Moderate',
      'Active',
      'Very Active',
    ];
    if (activityLevel == null || activityLevel! < 0 || activityLevel! >= labels.length) {
      return null;
    }
    return labels[activityLevel!];
  }

  String? get mealGoalLabel {
    const labels = ['Weekly Plan', 'Daily Plan', 'Single Meal'];
    if (mealGoal == null || mealGoal! < 0 || mealGoal! >= labels.length) {
      return null;
    }
    return labels[mealGoal!];
  }

  bool get hasProfileData {
    return name != null ||
        birthDay != null ||
        birthMonth != null ||
        birthYear != null ||
        gender != null ||
        heightCm != null ||
        currentWeight != null ||
        goalWeight != null ||
        hasObesity != null ||
        activityLevel != null ||
        mealGoal != null ||
        email != null ||
        (workoutDays?.isNotEmpty ?? false) ||
        (mealTimes?.isNotEmpty ?? false);
  }

  Map<String, dynamic> toFirestoreMap() {
    calculateMetrics();

    final personalData = {
      'name': name,
      'birthDay': birthDay,
      'birthMonth': birthMonth,
      'birthYear': birthYear,
      if (birthYear != null) 'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'currentWeight': currentWeight,
      'goalWeight': goalWeight,
      'hasObesity': hasObesity,
      'activityLevel': activityLevel,
      'mealGoal': mealGoal,
      'workoutDays': workoutDays,
      'mealTimes': mealTimes?.map((key, value) => MapEntry(key, {'hour': value.hour, 'minute': value.minute})),
    };

    // Only include email if it's not null
    if (email != null) {
      personalData['email'] = email;
    }

    return _removeNullValues({
      'personalData': personalData,
      'dietPlan': {
        'bmi': bmi,
        'bmiCategory': bmiCategory,
        'bmr': bmr,
        'tdee': tdee,
        'targetCalories': targetCalories,
        'proteinGrams': proteinGrams,
        'fatGrams': fatGrams,
        'carbGrams': carbGrams,
      },
      'likedRecipes': likedRecipes ?? [],
      'dislikedRecipes': dislikedRecipes ?? [],
      'ratings': recipeRatings ?? {},
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Map<String, dynamic> _removeNullValues(Map<String, dynamic> input) {
    final cleaned = <String, dynamic>{};

    input.forEach((key, value) {
      final sanitizedValue = _sanitizeValue(value);
      if (sanitizedValue != null) {
        cleaned[key] = sanitizedValue;
      }
    });

    return cleaned;
  }

  dynamic _sanitizeValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map<String, dynamic>) {
      final cleanedMap = _removeNullValues(value);
      return cleanedMap.isEmpty ? null : cleanedMap;
    }

    if (value is List) {
      return value.where((item) => item != null).toList();
    }

    return value;
  }

  void clearSignupState() {
    name = null;
    birthDay = null;
    birthMonth = null;
    birthYear = null;
    gender = null;
    heightCm = null;
    currentWeight = null;
    goalWeight = null;
    hasObesity = null;
    activityLevel = null;
    mealGoal = null;
    email = null;
    password = null;
    googleIdToken = null;
    googleAccessToken = null;
    isGoogleSignIn = false;
    workoutDays = null;
    mealTimes = null;
    bmi = null;
    bmiCategory = null;
    bmr = null;
    tdee = null;
    targetCalories = null;
    proteinGrams = null;
    fatGrams = null;
    carbGrams = null;
  }
}

final signupData = UserData();
