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
