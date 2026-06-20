class RecommendationRequest {
  final String userId;
  final int limit;
  final String? preferredCategory;
  final int? minDifficulty;
  final int? maxDifficulty;
  final bool excludeDisliked;
  final bool excludeRated;
  final List<String>? excludeRecipeIds;
  final DateTime requestedAt;

  RecommendationRequest({
    required this.userId,
    this.limit = 10,
    this.preferredCategory,
    this.minDifficulty,
    this.maxDifficulty,
    this.excludeDisliked = true,
    this.excludeRated = true,
    this.excludeRecipeIds,
    required this.requestedAt,
  });

  /// Convert to map for logging/storage
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'limit': limit,
      'preferredCategory': preferredCategory,
      'minDifficulty': minDifficulty,
      'maxDifficulty': maxDifficulty,
      'excludeDisliked': excludeDisliked,
      'excludeRated': excludeRated,
      'excludeRecipeIds': excludeRecipeIds,
      'requestedAt': requestedAt.toIso8601String(),
    };
  }

  /// Create default request
  static RecommendationRequest createDefault(String userId) {
    return RecommendationRequest(
      userId: userId,
      limit: 10,
      excludeDisliked: true,
      excludeRated: true,
      requestedAt: DateTime.now(),
    );
  }

  /// Create request with filters
  static RecommendationRequest withFilters({
    required String userId,
    int limit = 10,
    String? category,
    int? minDifficulty,
    int? maxDifficulty,
  }) {
    return RecommendationRequest(
      userId: userId,
      limit: limit,
      preferredCategory: category,
      minDifficulty: minDifficulty,
      maxDifficulty: maxDifficulty,
      requestedAt: DateTime.now(),
    );
  }
}
