class PreferenceSettings {
  final String userId;
  final bool autoRefreshRecommendations;
  final int recommendationRefreshIntervalHours;
  final List<String> excludedCategories;
  final List<String> preferredCategories;
  final int minDifficulty; // 1-3 (Easy, Medium, Hard)
  final int maxDifficulty;
  final int minCookingTime; // in minutes
  final int maxCookingTime;
  final bool hideDislikedRecipes;
  final int minRatingThreshold; // Minimum rating to show recommendations

  PreferenceSettings({
    required this.userId,
    this.autoRefreshRecommendations = true,
    this.recommendationRefreshIntervalHours = 24,
    this.excludedCategories = const [],
    this.preferredCategories = const [],
    this.minDifficulty = 1,
    this.maxDifficulty = 3,
    this.minCookingTime = 0,
    this.maxCookingTime = 120,
    this.hideDislikedRecipes = true,
    this.minRatingThreshold = 3,
  });

  /// Convert from Firestore map
  factory PreferenceSettings.fromMap(String userId, Map<String, dynamic> map) {
    return PreferenceSettings(
      userId: userId,
      autoRefreshRecommendations: map['autoRefreshRecommendations'] as bool? ?? true,
      recommendationRefreshIntervalHours:
          map['recommendationRefreshIntervalHours'] as int? ?? 24,
      excludedCategories:
          List<String>.from((map['excludedCategories'] as List?) ?? []),
      preferredCategories:
          List<String>.from((map['preferredCategories'] as List?) ?? []),
      minDifficulty: map['minDifficulty'] as int? ?? 1,
      maxDifficulty: map['maxDifficulty'] as int? ?? 3,
      minCookingTime: map['minCookingTime'] as int? ?? 0,
      maxCookingTime: map['maxCookingTime'] as int? ?? 120,
      hideDislikedRecipes: map['hideDislikedRecipes'] as bool? ?? true,
      minRatingThreshold: map['minRatingThreshold'] as int? ?? 3,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'autoRefreshRecommendations': autoRefreshRecommendations,
      'recommendationRefreshIntervalHours': recommendationRefreshIntervalHours,
      'excludedCategories': excludedCategories,
      'preferredCategories': preferredCategories,
      'minDifficulty': minDifficulty,
      'maxDifficulty': maxDifficulty,
      'minCookingTime': minCookingTime,
      'maxCookingTime': maxCookingTime,
      'hideDislikedRecipes': hideDislikedRecipes,
      'minRatingThreshold': minRatingThreshold,
    };
  }

  /// Get difficulty label
  String getDifficultyLabel(int level) {
    const labels = ['Easy', 'Medium', 'Hard'];
    if (level < 1 || level > 3) return 'Unknown';
    return labels[level - 1];
  }

  /// Check if category is excluded
  bool isCategoryExcluded(String category) {
    return excludedCategories.contains(category);
  }

  /// Check if category is preferred
  bool isCategoryPreferred(String category) {
    return preferredCategories.contains(category);
  }

  /// Create default settings for new user
  static PreferenceSettings createDefault(String userId) {
    return PreferenceSettings(
      userId: userId,
      autoRefreshRecommendations: true,
      recommendationRefreshIntervalHours: 24,
      excludedCategories: [],
      preferredCategories: [],
      minDifficulty: 1,
      maxDifficulty: 3,
      minCookingTime: 0,
      maxCookingTime: 120,
      hideDislikedRecipes: true,
      minRatingThreshold: 3,
    );
  }
}
