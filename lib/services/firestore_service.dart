import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/user_data.dart';

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
  }

  static String _safePreferenceKey(String recipeId) {
    return recipeId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }

  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
