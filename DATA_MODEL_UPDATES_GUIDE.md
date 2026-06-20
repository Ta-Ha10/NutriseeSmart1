# Data Model Updates Guide

## 📋 Overview

This guide explains the data models needed for the Feedback & User Preference system. Follow each section to create or update your models.

---

## 1️⃣ USER PREFERENCE MODEL

### Purpose
Represents a user's preference profile with aggregated feedback data.

**File**: `lib/utils/models/user_preference_profile.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPreferenceProfile {
  final String userId;
  final double averageRating;
  final int totalRatings;
  final Map<String, int> tastePreferences;
  final Map<String, int> difficultyPreferences;
  final List<String> preferredCategories;
  final List<String> avoidedCategories;
  final int preferredRecipesCount;
  final int dislikedRecipesCount;
  final DateTime createdAt;
  final DateTime lastAnalyzedAt;

  UserPreferenceProfile({
    required this.userId,
    required this.averageRating,
    required this.totalRatings,
    required this.tastePreferences,
    required this.difficultyPreferences,
    required this.preferredCategories,
    required this.avoidedCategories,
    required this.preferredRecipesCount,
    required this.dislikedRecipesCount,
    required this.createdAt,
    required this.lastAnalyzedAt,
  });

  /// Convert from Firestore map
  factory UserPreferenceProfile.fromMap(
      String userId, Map<String, dynamic> map) {
    return UserPreferenceProfile(
      userId: userId,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['totalRatings'] as int? ?? 0,
      tastePreferences: Map<String, int>.from(
          (map['tastePreferences'] as Map?) ?? {}),
      difficultyPreferences: Map<String, int>.from(
          (map['difficultyPreferences'] as Map?) ?? {}),
      preferredCategories:
          List<String>.from((map['preferredCategories'] as List?) ?? []),
      avoidedCategories:
          List<String>.from((map['avoidedCategories'] as List?) ?? []),
      preferredRecipesCount: map['preferredRecipesCount'] as int? ?? 0,
      dislikedRecipesCount: map['dislikedRecipesCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      lastAnalyzedAt: (map['lastAnalyzedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'tastePreferences': tastePreferences,
      'difficultyPreferences': difficultyPreferences,
      'preferredCategories': preferredCategories,
      'avoidedCategories': avoidedCategories,
      'preferredRecipesCount': preferredRecipesCount,
      'dislikedRecipesCount': dislikedRecipesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastAnalyzedAt': Timestamp.fromDate(lastAnalyzedAt),
    };
  }

  /// Get highest rated taste preference
  String get favoriteTaste {
    if (tastePreferences.isEmpty) return 'Not determined';
    final entry = tastePreferences.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    return entry.key;
  }

  /// Get most challenging difficulty preference
  String get preferredDifficulty {
    if (difficultyPreferences.isEmpty) return 'Not determined';
    final entry = difficultyPreferences.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    return entry.key;
  }

  /// Check if user is an experienced cook
  bool get isExperiencedCook {
    return averageRating >= 4.0 && totalRatings >= 10;
  }

  /// Get preference summary string
  String getSummary() {
    return '''
User ID: $userId
Average Rating: ${averageRating.toStringAsFixed(1)}/5
Total Ratings: $totalRatings
Favorite Taste: $favoriteTaste
Preferred Difficulty: $preferredDifficulty
Liked Recipes: $preferredRecipesCount
Disliked Recipes: $dislikedRecipesCount
''';
  }
}
```

---

## 2️⃣ RECIPE RECOMMENDATION MODEL

### Purpose
Represents a single recipe recommendation with match score and reasoning.

**File**: `lib/utils/models/recipe_recommendation.dart`

```dart
class RecipeRecommendation {
  final String recipeId;
  final String recipeName;
  final double matchScore; // 0.0 to 1.0
  final List<String> reasons; // Why recommended
  final String? imageUrl;
  final String? category;
  final int? estimatedTime;
  final double? difficulty;

  RecipeRecommendation({
    required this.recipeId,
    required this.recipeName,
    required this.matchScore,
    required this.reasons,
    this.imageUrl,
    this.category,
    this.estimatedTime,
    this.difficulty,
  });

  /// Convert from Firestore map
  factory RecipeRecommendation.fromMap(Map<String, dynamic> map) {
    return RecipeRecommendation(
      recipeId: map['recipeId'] as String,
      recipeName: map['recipeName'] as String,
      matchScore: (map['matchScore'] as num?)?.toDouble() ?? 0.0,
      reasons: List<String>.from((map['reasons'] as List?) ?? []),
      imageUrl: map['imageUrl'] as String?,
      category: map['category'] as String?,
      estimatedTime: map['estimatedTime'] as int?,
      difficulty: (map['difficulty'] as num?)?.toDouble(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'recipeName': recipeName,
      'matchScore': matchScore,
      'reasons': reasons,
      'imageUrl': imageUrl,
      'category': category,
      'estimatedTime': estimatedTime,
      'difficulty': difficulty,
    };
  }

  /// Get match quality label
  String getQualityLabel() {
    if (matchScore >= 0.9) return 'Excellent Match';
    if (matchScore >= 0.75) return 'Very Good Match';
    if (matchScore >= 0.6) return 'Good Match';
    if (matchScore >= 0.4) return 'Fair Match';
    return 'Possible Match';
  }

  /// Get match percentage
  int getMatchPercentage() {
    return (matchScore * 100).toInt();
  }
}
```

---

## 3️⃣ RECIPE FEEDBACK MODEL

### Purpose
Represents user feedback for a specific recipe.

**File**: `lib/utils/models/recipe_feedback.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeFeedback {
  final String recipeId;
  final String recipeName;
  final int rating; // 1-5
  final String taste; // Delicious, Good, Average, Bad
  final String difficulty; // Easy, Just Right, Hard
  final String? comment;
  final DateTime updatedAt;
  final String userId;

  RecipeFeedback({
    required this.recipeId,
    required this.recipeName,
    required this.rating,
    required this.taste,
    required this.difficulty,
    this.comment,
    required this.updatedAt,
    required this.userId,
  });

  /// Convert from Firestore map
  factory RecipeFeedback.fromMap(
      String recipeId, String userId, Map<String, dynamic> map) {
    return RecipeFeedback(
      recipeId: recipeId,
      recipeName: map['recipeName'] as String? ?? '',
      rating: map['rating'] as int? ?? 0,
      taste: map['taste'] as String? ?? '',
      difficulty: map['difficulty'] as String? ?? '',
      comment: map['comment'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      userId: userId,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'recipeName': recipeName,
      'rating': rating,
      'taste': taste,
      'difficulty': difficulty,
      'comment': comment,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Check if feedback is positive
  bool get isPositive => rating >= 4;

  /// Check if feedback is negative
  bool get isNegative => rating <= 2;

  /// Check if feedback is neutral
  bool get isNeutral => rating == 3;

  /// Get rating as stars
  String getRatingStars() {
    return '⭐' * rating;
  }

  /// Get feedback summary
  String getSummary() {
    return '$recipeName: $rating/5 - $taste, $difficulty difficulty';
  }
}
```

---

## 4️⃣ RECIPE ANALYTICS MODEL

### Purpose
Represents aggregated analytics for a recipe (used for trending recipes).

**File**: `lib/utils/models/recipe_analytics.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeAnalytics {
  final String recipeId;
  final String recipeName;
  final int totalRatings;
  final double averageRating;
  final Map<int, int> ratingDistribution; // {1: count, 2: count, ...}
  final Map<String, int> tasteBreakdown;
  final Map<String, int> difficultyBreakdown;
  final int positiveFeedbackCount;
  final int negativeFeedbackCount;
  final DateTime updatedAt;

  RecipeAnalytics({
    required this.recipeId,
    required this.recipeName,
    required this.totalRatings,
    required this.averageRating,
    required this.ratingDistribution,
    required this.tasteBreakdown,
    required this.difficultyBreakdown,
    required this.positiveFeedbackCount,
    required this.negativeFeedbackCount,
    required this.updatedAt,
  });

  /// Convert from Firestore map
  factory RecipeAnalytics.fromMap(String recipeId, Map<String, dynamic> map) {
    return RecipeAnalytics(
      recipeId: recipeId,
      recipeName: map['recipeName'] as String? ?? '',
      totalRatings: map['totalRatings'] as int? ?? 0,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingDistribution:
          Map<int, int>.from((map['ratingDistribution'] as Map?) ?? {}),
      tasteBreakdown:
          Map<String, int>.from((map['tasteBreakdown'] as Map?) ?? {}),
      difficultyBreakdown: Map<String, int>.from(
          (map['difficultyBreakdown'] as Map?) ?? {}),
      positiveFeedbackCount: map['positiveFeedbackCount'] as int? ?? 0,
      negativeFeedbackCount: map['negativeFeedbackCount'] as int? ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'recipeName': recipeName,
      'totalRatings': totalRatings,
      'averageRating': averageRating,
      'ratingDistribution': ratingDistribution,
      'tasteBreakdown': tasteBreakdown,
      'difficultyBreakdown': difficultyBreakdown,
      'positiveFeedbackCount': positiveFeedbackCount,
      'negativeFeedbackCount': negativeFeedbackCount,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Get most popular taste preference
  String get mostPopularTaste {
    if (tasteBreakdown.isEmpty) return 'N/A';
    final entry = tasteBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    return entry.key;
  }

  /// Get most reported difficulty
  String get reportedDifficulty {
    if (difficultyBreakdown.isEmpty) return 'N/A';
    final entry = difficultyBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    return entry.key;
  }

  /// Get positive feedback percentage
  double getPositiveFeedbackPercentage() {
    if (totalRatings == 0) return 0;
    return (positiveFeedbackCount / totalRatings) * 100;
  }

  /// Check if recipe is trending
  bool isTrending() {
    return averageRating >= 4.0 && totalRatings >= 10;
  }

  /// Get rating quality
  String getRatingQuality() {
    if (averageRating >= 4.5) return 'Excellent';
    if (averageRating >= 4.0) return 'Very Good';
    if (averageRating >= 3.5) return 'Good';
    if (averageRating >= 3.0) return 'Average';
    return 'Poor';
  }
}
```

---

## 5️⃣ FIRESTORE STRUCTURE

### Updated Users Collection

```
users/{uid}/
├── Basic Info
│   ├── email: string
│   ├── name: string
│   ├── profilePicture: string
│
├── Health Metrics
│   ├── age: number
│   ├── height: number
│   ├── weight: number
│   ├── bmi: number
│   ├── bmr: number
│   ├── tdee: number
│
├── Preferences
│   ├── profile: {
│   │   ├── averageRating: double
│   │   ├── totalRatings: number
│   │   ├── tastePreferences: {
│   │   │   ├── delicious: number
│   │   │   ├── good: number
│   │   │   ├── average: number
│   │   │   ├── bad: number
│   │   ├── difficultyPreferences: {
│   │   │   ├── easy: number
│   │   │   ├── justRight: number
│   │   │   ├── hard: number
│   │   ├── preferredCategories: [string]
│   │   ├── avoidedCategories: [string]
│   │   ├── preferredRecipesCount: number
│   │   ├── dislikedRecipesCount: number
│   │   ├── createdAt: timestamp
│   │   ├── lastAnalyzedAt: timestamp
│   ├── recommendations: [string]
│   ├── recommendationsCacheExpiry: string (ISO8601)
│
├── Recipes
│   ├── ratings: {recipe_id: number}
│   ├── recipeFeedback: {
│   │   recipe_id: {
│   │       ├── recipeId: string
│   │       ├── recipeName: string
│   │       ├── rating: number (1-5)
│   │       ├── taste: string
│   │       ├── difficulty: string
│   │       ├── comment: string (optional)
│   │       ├── updatedAt: timestamp
│   ├── likedRecipes: [string]
│   ├── dislikedRecipes: [string]
```

### Analytics Collection

```
analytics/
├── recipeFeedback/
│   ├── recipes: {
│   │   recipe_id: number (increment count)
│
├── recipes_{recipe_id}/
│   ├── recipeId: string
│   ├── totalRatings: number
│   ├── ratingSum: number
│   ├── averageRating: number
│   ├── ratingDistribution: {1: n, 2: n, ...}
│   ├── tasteBreakdown: {
│   │   ├── delicious: number
│   │   ├── good: number
│   │   ├── average: number
│   │   ├── bad: number
│   ├── difficultyBreakdown: {
│   │   ├── easy: number
│   │   ├── justRight: number
│   │   ├── hard: number
│   ├── lastUpdated: timestamp
```

---

## 6️⃣ CREATE MODELS DIRECTORY

**Directory**: `lib/utils/models/`

Create this directory structure:

```
lib/utils/models/
├── user_preference_profile.dart
├── recipe_recommendation.dart
├── recipe_feedback.dart
├── recipe_analytics.dart
├── index.dart (barrel file)
```

### Barrel File

**File**: `lib/utils/models/index.dart`

```dart
export 'user_preference_profile.dart';
export 'recipe_recommendation.dart';
export 'recipe_feedback.dart';
export 'recipe_analytics.dart';
```

---

## 7️⃣ UPDATE IMPORTS IN SERVICES

### Update `lib/services/preference_analytics_service.dart`

Add at top:
```dart
import '../utils/models/user_preference_profile.dart';
```

### Update `lib/services/recommendation_service.dart`

Add at top:
```dart
import '../utils/models/recipe_recommendation.dart';
```

---

## 8️⃣ USAGE EXAMPLES

### Example 1: Get User Preference Profile

```dart
// Get preference profile from Firestore
final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .get();

if (userDoc.exists) {
  final preferences = userDoc.data()?['preferences'];
  if (preferences != null) {
    final profile = UserPreferenceProfile.fromMap(uid, preferences['profile']);
    print(profile.getSummary());
  }
}
```

### Example 2: Create and Store Recipe Feedback

```dart
final feedback = RecipeFeedback(
  recipeId: 'recipe_123',
  recipeName: 'Pasta Carbonara',
  rating: 5,
  taste: 'Delicious',
  difficulty: 'Just Right',
  comment: 'Amazing recipe! Will make again.',
  updatedAt: DateTime.now(),
  userId: user.uid,
);

// Store in Firestore
await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .collection('feedback')
    .add(feedback.toMap());
```

### Example 3: Get Recipe Analytics

```dart
final analyticsDoc = await FirebaseFirestore.instance
    .collection('analytics')
    .doc('recipes_recipe_123')
    .get();

if (analyticsDoc.exists) {
  final analytics = RecipeAnalytics.fromMap(
    'recipe_123',
    analyticsDoc.data()!,
  );
  
  print('Average Rating: ${analytics.averageRating}');
  print('Most Popular Taste: ${analytics.mostPopularTaste}');
  print('Positive Feedback: ${analytics.getPositiveFeedbackPercentage()}%');
}
```

### Example 4: Display Recommendations

```dart
final recommendations = <RecipeRecommendation>[];
final recIds = await RecommendationService.getRecommendedRecipes(uid);

for (final recId in recIds) {
  final recipeDoc = await FirebaseFirestore.instance
      .collection('recipes')
      .doc(recId)
      .get();
  
  if (recipeDoc.exists) {
    final rec = RecipeRecommendation(
      recipeId: recId,
      recipeName: recipeDoc['name'],
      matchScore: 0.85,
      reasons: ['Based on your liked recipes', 'Similar taste profile'],
      imageUrl: recipeDoc['image'],
      category: recipeDoc['category'],
    );
    recommendations.add(rec);
  }
}
```

---

## ✅ IMPLEMENTATION CHECKLIST

Create these files in order:

- [ ] `lib/utils/models/user_preference_profile.dart`
- [ ] `lib/utils/models/recipe_recommendation.dart`
- [ ] `lib/utils/models/recipe_feedback.dart`
- [ ] `lib/utils/models/recipe_analytics.dart`
- [ ] `lib/utils/models/index.dart`
- [ ] Update imports in services
- [ ] Verify Firestore structure matches schema
- [ ] Test model serialization/deserialization

---

## 📝 NOTES

- All models use `toMap()` for Firestore serialization
- All models use `fromMap()` factory for deserialization
- Timestamps are automatically handled by Firestore
- Models include helper methods for common operations
- Barrel file (`index.dart`) for easy imports across app
