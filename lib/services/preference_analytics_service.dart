import 'package:cloud_firestore/cloud_firestore.dart';

class PreferenceAnalyticsService {
  static final _firestore = FirebaseFirestore.instance;

  /// Initialize preference profile when user signs up
  static Future<void> initializeUserPreferences(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'preferences': {
          'profile': {
            'averageRating': 0.0,
            'totalRatings': 0,
            'tastePreferences': {
              'delicious': 0,
              'good': 0,
              'average': 0,
              'bad': 0,
            },
            'difficultyPreferences': {
              'easy': 0,
              'justRight': 0,
              'hard': 0,
            },
            'preferredCategories': [],
            'avoidedCategories': [],
            'createdAt': FieldValue.serverTimestamp(),
            'lastAnalyzedAt': FieldValue.serverTimestamp(),
          },
          'recommendations': [],
          'recommendationsCacheExpiry': DateTime.now(),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error initializing preferences: $e');
      rethrow;
    }
  }

  /// Analyze user feedback and update preference profile
  static Future<void> updatePreferenceProfile(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      if (userData == null) return;

      final ratings = (userData['ratings'] as Map?) ?? {};
      final recipeFeedback = (userData['recipeFeedback'] as Map?) ?? {};
      final likedRecipes = (userData['likedRecipes'] as List?) ?? [];
      final dislikedRecipes = (userData['dislikedRecipes'] as List?) ?? [];

      // Calculate statistics
      double avgRating = 0;
      int totalRatings = ratings.length;

      if (ratings.isNotEmpty) {
        final values = ratings.values.whereType<int>().toList();
        avgRating = values.reduce((a, b) => a + b) / values.length;
      }

      // Aggregate taste preferences
      Map<String, int> tastePrefs = {
        'delicious': 0,
        'good': 0,
        'average': 0,
        'bad': 0,
      };

      Map<String, int> difficultyPrefs = {
        'easy': 0,
        'justRight': 0,
        'hard': 0,
      };

      recipeFeedback.forEach((key, feedback) {
        if (feedback is Map) {
          final taste = (feedback['taste'] as String?)?.toLowerCase() ?? '';
          final difficulty =
              (feedback['difficulty'] as String?)?.toLowerCase() ?? '';

          if (tastePrefs.containsKey(taste)) {
            tastePrefs[taste] = (tastePrefs[taste] ?? 0) + 1;
          }
          if (difficultyPrefs.containsKey(difficulty)) {
            difficultyPrefs[difficulty] =
                (difficultyPrefs[difficulty] ?? 0) + 1;
          }
        }
      });

      // Update preference profile
      await _firestore.collection('users').doc(uid).update({
        'preferences.profile': {
          'averageRating': avgRating,
          'totalRatings': totalRatings,
          'tastePreferences': tastePrefs,
          'difficultyPreferences': difficultyPrefs,
          'preferredRecipesCount': likedRecipes.length,
          'dislikedRecipesCount': dislikedRecipes.length,
          'lastAnalyzedAt': FieldValue.serverTimestamp(),
        }
      });
    } catch (e) {
      print('Error updating preference profile: $e');
      rethrow;
    }
  }

  /// Get comprehensive preference profile
  static Future<Map<String, dynamic>?> getPreferenceProfile(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      if (userData == null) return null;

      return userData['preferences'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting preference profile: $e');
      return null;
    }
  }

  /// Get user's favorite recipe categories
  static Future<List<String>> getFavoriteCategories(String uid,
      {int limit = 5}) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      if (userData == null) return [];

      final likedRecipes = (userData['likedRecipes'] as List?) ?? [];

      // Count categories from liked recipes
      Map<String, int> categoryCount = {};

      for (String recipeId in likedRecipes) {
        // Fetch recipe to get category
        try {
          final recipeDoc =
              await _firestore.collection('recipes').doc(recipeId).get();
          final recipeData = recipeDoc.data();
          if (recipeData != null) {
            final category =
                recipeData['category'] as String? ?? 'Uncategorized';
            categoryCount[category] = (categoryCount[category] ?? 0) + 1;
          }
        } catch (e) {
          continue;
        }
      }

      // Sort by frequency
      final sorted = categoryCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(limit).map((e) => e.key).toList();
    } catch (e) {
      print('Error getting favorite categories: $e');
      return [];
    }
  }
}
