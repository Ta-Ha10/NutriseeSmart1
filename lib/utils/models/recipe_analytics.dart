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
