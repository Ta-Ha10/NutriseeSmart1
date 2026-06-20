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
