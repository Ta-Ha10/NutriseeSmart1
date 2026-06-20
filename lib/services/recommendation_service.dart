import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationService {
  static final _firestore = FirebaseFirestore.instance;
  static const CACHE_DURATION = Duration(hours: 24);

  /// Generate personalized recipe recommendations
  static Future<List<String>> getRecommendedRecipes(String uid,
      {int limit = 10}) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      if (userData == null) return [];

      // Check cache first
      final preferences = userData['preferences'] as Map?;
      if (preferences != null) {
        final cachedRecs = preferences['recommendations'] as List?;
        final cacheExpiry = preferences['recommendationsCacheExpiry'];

        if (cachedRecs != null &&
            cacheExpiry != null &&
            DateTime.parse(cacheExpiry.toString()).isAfter(DateTime.now())) {
          return cachedRecs.cast<String>().take(limit).toList();
        }
      }

      // Generate recommendations
      final likedRecipes = (userData['likedRecipes'] as List?) ?? [];
      final dislikedRecipes = (userData['dislikedRecipes'] as List?) ?? [];
      final ratings = (userData['ratings'] as Map?) ?? {};

      // Get high-rated recipes
      final highRatedRecipes = ratings.entries
          .where((e) => ((e.value as int?) ?? 0) >= 4)
          .map((e) => e.key)
          .toList();

      // Find similar recipes
      final recommendedIds = <String>{};

      for (String recipeId in highRatedRecipes.take(5)) {
        try {
          final recipeDoc =
              await _firestore.collection('recipes').doc(recipeId).get();
          final recipeData = recipeDoc.data();

          if (recipeData != null) {
            final category = recipeData['category'] as String? ?? '';
            final cuisine = recipeData['cuisine'] as String? ?? '';

            // Find similar recipes
            final similarRecipes = await _firestore
                .collection('recipes')
                .where('category', isEqualTo: category)
                .limit(20)
                .get();

            for (var doc in similarRecipes.docs) {
              final docId = doc.id;
              if (!likedRecipes.contains(docId) &&
                  !dislikedRecipes.contains(docId) &&
                  !ratings.containsKey(docId) &&
                  docId != recipeId) {
                recommendedIds.add(docId);
              }
            }
          }
        } catch (e) {
          continue;
        }
      }

      final recommendationList = recommendedIds.take(limit).toList();

      // Cache recommendations
      await _firestore.collection('users').doc(uid).update({
        'preferences.recommendations': recommendationList,
        'preferences.recommendationsCacheExpiry':
            DateTime.now().add(CACHE_DURATION).toIso8601String(),
      });

      return recommendationList;
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  /// Get recipes similar to a specific recipe
  static Future<List<String>> getSimilarRecipes(String recipeId,
      {int limit = 5}) async {
    try {
      final recipeDoc =
          await _firestore.collection('recipes').doc(recipeId).get();
      final recipeData = recipeDoc.data();

      if (recipeData == null) return [];

      final category = recipeData['category'] as String? ?? '';
      final cuisine = recipeData['cuisine'] as String? ?? '';

      // Query similar recipes
      final querySnapshot = await _firestore
          .collection('recipes')
          .where('category', isEqualTo: category)
          .limit(limit + 1)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.id)
          .where((id) => id != recipeId)
          .take(limit)
          .toList();
    } catch (e) {
      print('Error getting similar recipes: $e');
      return [];
    }
  }

  /// Get trending recipes based on ratings
  static Future<List<String>> getTrendingRecipes({int limit = 10}) async {
    try {
      final analyticsDoc =
          await _firestore.collection('analytics').doc('recipeFeedback').get();
      final data = analyticsDoc.data();

      if (data == null) return [];

      final stats = data['recipes'] as Map? ?? {};
      final sorted = stats.entries.toList()
        ..sort((a, b) => (b.value['averageRating'] as num?)?.compareTo(
                a.value['averageRating'] as num? ?? 0) ??
            0);

      return sorted.take(limit).map((e) => e.key as String).toList();
    } catch (e) {
      print('Error getting trending recipes: $e');
      return [];
    }
  }

  /// Refresh all recommendations (call after feedback)
  static Future<void> refreshRecommendations(String uid) async {
    try {
      await getRecommendedRecipes(uid);
    } catch (e) {
      print('Error refreshing recommendations: $e');
    }
  }
}
