import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/user_data.dart';
import 'preference_analytics_service.dart';
import 'recommendation_service.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> saveUserData(UserData data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found when saving user data.');
    }

    if (!data.hasProfileData) {
      return;
    }

    data.calculateMetrics();

    final docData = data.toFirestoreMap();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(docData, SetOptions(merge: true));
  }

  static Future<void> addLikedRecipe(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'likedRecipes': FieldValue.arrayUnion([recipeId]),
      'dislikedRecipes': FieldValue.arrayRemove([recipeId]),
    }, SetOptions(merge: true));
  }

  static Future<void> removeLikedRecipe(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'likedRecipes': FieldValue.arrayRemove([recipeId]),
    }, SetOptions(merge: true));
  }

  static Future<void> addDislikedRecipe(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'likedRecipes': FieldValue.arrayRemove([recipeId]),
      'dislikedRecipes': FieldValue.arrayUnion([recipeId]),
    }, SetOptions(merge: true));
  }

  static Future<void> removeDislikedRecipe(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'dislikedRecipes': FieldValue.arrayRemove([recipeId]),
    }, SetOptions(merge: true));
  }

  static Future<void> setRecipeRating(String recipeId, int rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'ratings': {_safePreferenceKey(recipeId): rating},
    }, SetOptions(merge: true));
  }

  static Future<void> saveRecipeFeedback({
    required String recipeId,
    required String recipeName,
    required int rating,
    required String taste,
    required String difficulty,
    String? comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final trimmedComment = comment?.trim();
    final feedbackKey = _safePreferenceKey(recipeId);
    final data = <String, dynamic>{
      'ratings': {feedbackKey: rating},
      'recipeFeedback': {
        feedbackKey: {
          'recipeId': recipeId,
          'recipeName': recipeName,
          'rating': rating,
          'taste': taste,
          'difficulty': difficulty,
          'comment': trimmedComment?.isEmpty ?? true ? null : trimmedComment,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
    };

    if (rating >= 4) {
      data['likedRecipes'] = FieldValue.arrayUnion([recipeId]);
      data['dislikedRecipes'] = FieldValue.arrayRemove([recipeId]);
    } else if (rating <= 2) {
      data['likedRecipes'] = FieldValue.arrayRemove([recipeId]);
      data['dislikedRecipes'] = FieldValue.arrayUnion([recipeId]);
    } else {
      data['likedRecipes'] = FieldValue.arrayRemove([recipeId]);
      data['dislikedRecipes'] = FieldValue.arrayRemove([recipeId]);
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));

    // Update analytics
    await _updateRecipeAnalytics(recipeId, rating, taste, difficulty, comment);

    // Update user preference profile
    await PreferenceAnalyticsService.updatePreferenceProfile(user.uid);

    // Refresh recommendations
    await RecommendationService.refreshRecommendations(user.uid);
  }

  static Future<void> _updateRecipeAnalytics(
    String recipeId,
    int rating,
    String taste,
    String difficulty,
    String? comment,
  ) async {
    final statsKey = _safePreferenceKey(recipeId);

    await _firestore
        .collection('analytics')
        .doc('recipeFeedback')
        .set({
          'recipes': {
            statsKey: FieldValue.increment(1),
          }
        }, SetOptions(merge: true));

    // Update detailed stats
    await _firestore
        .collection('analytics')
        .doc('recipes_$statsKey')
        .set({
          'recipeId': recipeId,
          'totalRatings': FieldValue.increment(1),
          'ratingSum': FieldValue.increment(rating),
          'tasteBreakdown': {taste.toLowerCase(): FieldValue.increment(1)},
          'difficultyBreakdown': {
            difficulty.toLowerCase(): FieldValue.increment(1)
          },
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  static String _safePreferenceKey(String recipeId) {
    return recipeId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }

  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Search for a user by their Telegram chat ID
  /// Returns user data if found, null otherwise
  /// 
  /// This method is used by N8N workflows to look up users by their Telegram ID
  /// and perform actions like syncing meal logs
  static Future<Map<String, dynamic>?> searchUserByTelegramId(
    String telegramChatId,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('personalData.telegramChatId', isEqualTo: telegramChatId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return query.docs.first.data();
    } catch (e) {
      throw Exception('Failed to search user by Telegram ID: $e');
    }
  }
}
