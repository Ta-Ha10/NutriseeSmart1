class RecipePreference {
  final String recipeId;
  final String userId;
  final bool isFavorite;
  final bool isDisliked;
  final int? lastRating;
  final DateTime? lastRatedAt;
  final int timesCooked;
  final bool wantToCook;

  RecipePreference({
    required this.recipeId,
    required this.userId,
    this.isFavorite = false,
    this.isDisliked = false,
    this.lastRating,
    this.lastRatedAt,
    this.timesCooked = 0,
    this.wantToCook = false,
  });

  /// Convert from Firestore map
  factory RecipePreference.fromMap(
      String recipeId, String userId, Map<String, dynamic> map) {
    return RecipePreference(
      recipeId: recipeId,
      userId: userId,
      isFavorite: map['isFavorite'] as bool? ?? false,
      isDisliked: map['isDisliked'] as bool? ?? false,
      lastRating: map['lastRating'] as int?,
      lastRatedAt: map['lastRatedAt'] != null
          ? DateTime.parse(map['lastRatedAt'] as String)
          : null,
      timesCooked: map['timesCooked'] as int? ?? 0,
      wantToCook: map['wantToCook'] as bool? ?? false,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'isFavorite': isFavorite,
      'isDisliked': isDisliked,
      'lastRating': lastRating,
      'lastRatedAt': lastRatedAt?.toIso8601String(),
      'timesCooked': timesCooked,
      'wantToCook': wantToCook,
    };
  }

  /// Create a copy with updated fields
  RecipePreference copyWith({
    bool? isFavorite,
    bool? isDisliked,
    int? lastRating,
    DateTime? lastRatedAt,
    int? timesCooked,
    bool? wantToCook,
  }) {
    return RecipePreference(
      recipeId: recipeId,
      userId: userId,
      isFavorite: isFavorite ?? this.isFavorite,
      isDisliked: isDisliked ?? this.isDisliked,
      lastRating: lastRating ?? this.lastRating,
      lastRatedAt: lastRatedAt ?? this.lastRatedAt,
      timesCooked: timesCooked ?? this.timesCooked,
      wantToCook: wantToCook ?? this.wantToCook,
    );
  }

  /// Check if user is familiar with this recipe
  bool get isFamiliar {
    return timesCooked > 0;
  }

  /// Get days since last rated
  int? getDaysSinceLastRated() {
    if (lastRatedAt == null) return null;
    return DateTime.now().difference(lastRatedAt!).inDays;
  }

  /// Get status label
  String getStatusLabel() {
    if (isFavorite) return 'Favorite';
    if (isDisliked) return 'Disliked';
    if (wantToCook) return 'Want to Cook';
    if (isFamiliar) return 'Cooked ${timesCooked}x';
    return 'New Recipe';
  }
}
