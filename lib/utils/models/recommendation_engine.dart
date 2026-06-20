class RecommendationEngine {
  final String engineVersion;
  final String algorithmType; // similarity, collaborative, hybrid
  final int cacheHours;
  final int maxRecommendations;
  final double minimumMatchScore;
  final bool enableLogging;
  final Map<String, dynamic> algorithmConfig;

  RecommendationEngine({
    this.engineVersion = '1.0.0',
    this.algorithmType = 'similarity',
    this.cacheHours = 24,
    this.maxRecommendations = 50,
    this.minimumMatchScore = 0.3,
    this.enableLogging = true,
    this.algorithmConfig = const {},
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'engineVersion': engineVersion,
      'algorithmType': algorithmType,
      'cacheHours': cacheHours,
      'maxRecommendations': maxRecommendations,
      'minimumMatchScore': minimumMatchScore,
      'enableLogging': enableLogging,
      'algorithmConfig': algorithmConfig,
    };
  }

  /// Convert from map
  factory RecommendationEngine.fromMap(Map<String, dynamic> map) {
    return RecommendationEngine(
      engineVersion: map['engineVersion'] as String? ?? '1.0.0',
      algorithmType: map['algorithmType'] as String? ?? 'similarity',
      cacheHours: map['cacheHours'] as int? ?? 24,
      maxRecommendations: map['maxRecommendations'] as int? ?? 50,
      minimumMatchScore:
          (map['minimumMatchScore'] as num?)?.toDouble() ?? 0.3,
      enableLogging: map['enableLogging'] as bool? ?? true,
      algorithmConfig: (map['algorithmConfig'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  /// Get algorithm description
  String getAlgorithmDescription() {
    switch (algorithmType) {
      case 'collaborative':
        return 'Collaborative filtering based on user behavior';
      case 'hybrid':
        return 'Hybrid approach combining multiple algorithms';
      case 'similarity':
      default:
        return 'Content-based similarity matching';
    }
  }

  /// Create default engine
  static RecommendationEngine createDefault() {
    return RecommendationEngine(
      engineVersion: '1.0.0',
      algorithmType: 'similarity',
      cacheHours: 24,
      maxRecommendations: 50,
      minimumMatchScore: 0.3,
      enableLogging: true,
      algorithmConfig: {
        'categoryWeight': 0.4,
        'cuisineWeight': 0.3,
        'difficultyWeight': 0.2,
        'ratingWeight': 0.1,
      },
    );
  }

  /// Create hybrid engine (more advanced)
  static RecommendationEngine createHybrid() {
    return RecommendationEngine(
      engineVersion: '2.0.0',
      algorithmType: 'hybrid',
      cacheHours: 12,
      maxRecommendations: 100,
      minimumMatchScore: 0.4,
      enableLogging: true,
      algorithmConfig: {
        'contentWeight': 0.5,
        'collaborativeWeight': 0.5,
        'categoryWeight': 0.35,
        'cuisineWeight': 0.25,
        'difficultyWeight': 0.15,
        'ratingWeight': 0.15,
        'userBehaviorWeight': 0.1,
      },
    );
  }
}
