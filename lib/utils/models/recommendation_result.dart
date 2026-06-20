class RecommendationResult {
  final String userId;
  final List<String> recommendedRecipeIds;
  final List<String> reasons; // Why these recommendations
  final double averageMatchScore;
  final int processingTimeMs;
  final bool isCached;
  final DateTime generatedAt;
  final DateTime expiresAt;

  RecommendationResult({
    required this.userId,
    required this.recommendedRecipeIds,
    this.reasons = const [],
    this.averageMatchScore = 0.0,
    this.processingTimeMs = 0,
    this.isCached = false,
    required this.generatedAt,
    required this.expiresAt,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recommendedRecipeIds': recommendedRecipeIds,
      'reasons': reasons,
      'averageMatchScore': averageMatchScore,
      'processingTimeMs': processingTimeMs,
      'isCached': isCached,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Check if result is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Get time remaining before expiry
  Duration? getTimeUntilExpiry() {
    if (isExpired) return null;
    return expiresAt.difference(DateTime.now());
  }

  /// Get number of recommendations
  int get count => recommendedRecipeIds.length;

  /// Check if has recommendations
  bool get hasRecommendations => recommendedRecipeIds.isNotEmpty;

  /// Get quality label
  String getQualityLabel() {
    if (averageMatchScore >= 0.9) return 'Excellent';
    if (averageMatchScore >= 0.75) return 'Very Good';
    if (averageMatchScore >= 0.6) return 'Good';
    if (averageMatchScore >= 0.4) return 'Fair';
    return 'Poor';
  }

  /// Create empty result
  static RecommendationResult empty(String userId) {
    return RecommendationResult(
      userId: userId,
      recommendedRecipeIds: [],
      generatedAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: 24)),
    );
  }
}
