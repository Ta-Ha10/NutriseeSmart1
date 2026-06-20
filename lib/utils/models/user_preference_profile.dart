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
