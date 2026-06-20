class RecommendationStats {
  final String userId;
  final int totalRecommendationsGenerated;
  final int recommendationsClicked;
  final int recommendationsCookedFrom;
  final double averageClickThroughRate; // 0-1
  final double averageConversionRate; // 0-1
  final Map<String, int> categoryRecommendationCounts;
  final int daysActive;
  final DateTime createdAt;
  final DateTime lastUpdated;

  RecommendationStats({
    required this.userId,
    this.totalRecommendationsGenerated = 0,
    this.recommendationsClicked = 0,
    this.recommendationsCookedFrom = 0,
    this.averageClickThroughRate = 0.0,
    this.averageConversionRate = 0.0,
    this.categoryRecommendationCounts = const {},
    this.daysActive = 0,
    required this.createdAt,
    required this.lastUpdated,
  });

  /// Convert from Firestore map
  factory RecommendationStats.fromMap(String userId, Map<String, dynamic> map) {
    return RecommendationStats(
      userId: userId,
      totalRecommendationsGenerated:
          map['totalRecommendationsGenerated'] as int? ?? 0,
      recommendationsClicked: map['recommendationsClicked'] as int? ?? 0,
      recommendationsCookedFrom:
          map['recommendationsCookedFrom'] as int? ?? 0,
      averageClickThroughRate:
          (map['averageClickThroughRate'] as num?)?.toDouble() ?? 0.0,
      averageConversionRate:
          (map['averageConversionRate'] as num?)?.toDouble() ?? 0.0,
      categoryRecommendationCounts: Map<String, int>.from(
          (map['categoryRecommendationCounts'] as Map?) ?? {}),
      daysActive: map['daysActive'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String? ?? ''),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String? ?? ''),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalRecommendationsGenerated': totalRecommendationsGenerated,
      'recommendationsClicked': recommendationsClicked,
      'recommendationsCookedFrom': recommendationsCookedFrom,
      'averageClickThroughRate': averageClickThroughRate,
      'averageConversionRate': averageConversionRate,
      'categoryRecommendationCounts': categoryRecommendationCounts,
      'daysActive': daysActive,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Calculate click-through rate
  double calculateClickThroughRate() {
    if (totalRecommendationsGenerated == 0) return 0.0;
    return recommendationsClicked / totalRecommendationsGenerated;
  }

  /// Calculate conversion rate
  double calculateConversionRate() {
    if (recommendationsClicked == 0) return 0.0;
    return recommendationsCookedFrom / recommendationsClicked;
  }

  /// Get most recommended category
  String getMostRecommendedCategory() {
    if (categoryRecommendationCounts.isEmpty) return 'N/A';
    final entry = categoryRecommendationCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    return entry.key;
  }

  /// Get engagement level
  String getEngagementLevel() {
    final ctr = calculateClickThroughRate();
    if (ctr >= 0.7) return 'Very High';
    if (ctr >= 0.5) return 'High';
    if (ctr >= 0.3) return 'Medium';
    if (ctr >= 0.1) return 'Low';
    return 'Very Low';
  }

  /// Get success rate (conversion)
  String getSuccessRate() {
    final cr = calculateConversionRate();
    if (cr >= 0.8) return 'Excellent';
    if (cr >= 0.6) return 'Very Good';
    if (cr >= 0.4) return 'Good';
    if (cr >= 0.2) return 'Fair';
    return 'Poor';
  }

  /// Create default stats
  static RecommendationStats createDefault(String userId) {
    final now = DateTime.now();
    return RecommendationStats(
      userId: userId,
      totalRecommendationsGenerated: 0,
      recommendationsClicked: 0,
      recommendationsCookedFrom: 0,
      averageClickThroughRate: 0.0,
      averageConversionRate: 0.0,
      categoryRecommendationCounts: {},
      daysActive: 0,
      createdAt: now,
      lastUpdated: now,
    );
  }
}
