class RecommendationFilter {
  final String filterId;
  final String name;
  final String description;
  final Map<String, dynamic> criteria;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RecommendationFilter({
    required this.filterId,
    required this.name,
    this.description = '',
    required this.criteria,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'filterId': filterId,
      'name': name,
      'description': description,
      'criteria': criteria,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert from map
  factory RecommendationFilter.fromMap(Map<String, dynamic> map) {
    return RecommendationFilter(
      filterId: map['filterId'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      criteria: (map['criteria'] as Map?)?.cast<String, dynamic>() ?? {},
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(map['createdAt'] as String? ?? ''),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Filter for quick meals
  static RecommendationFilter quickMeals() {
    return RecommendationFilter(
      filterId: 'quick_meals',
      name: 'Quick Meals',
      description: 'Recipes that take less than 30 minutes',
      criteria: {'maxCookingTime': 30},
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Filter for healthy options
  static RecommendationFilter healthyOptions() {
    return RecommendationFilter(
      filterId: 'healthy_options',
      name: 'Healthy Options',
      description: 'Low calorie, high protein recipes',
      criteria: {
        'categories': ['Salad', 'Grilled', 'Steamed'],
        'minRating': 4.0,
      },
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Filter for beginner friendly
  static RecommendationFilter beginnerFriendly() {
    return RecommendationFilter(
      filterId: 'beginner_friendly',
      name: 'Beginner Friendly',
      description: 'Easy recipes for beginners',
      criteria: {'difficulty': 'Easy'},
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Filter for advanced cooks
  static RecommendationFilter advancedRecipes() {
    return RecommendationFilter(
      filterId: 'advanced_recipes',
      name: 'Advanced Recipes',
      description: 'Challenge recipes for experienced cooks',
      criteria: {'difficulty': 'Hard'},
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Get all predefined filters
  static List<RecommendationFilter> getPredefinedFilters() {
    return [
      quickMeals(),
      healthyOptions(),
      beginnerFriendly(),
      advancedRecipes(),
    ];
  }
}
