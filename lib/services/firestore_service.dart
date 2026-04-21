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

    await _firestore.collection('users').doc(user.uid).update({
      'likedRecipes': FieldValue.arrayUnion([recipeId]),
    });
  }

  static Future<void> removeLikedRecipe(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'likedRecipes': FieldValue.arrayRemove([recipeId]),
    });
  }

  static Future<void> addDislikedRecipe(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'dislikedRecipes': FieldValue.arrayUnion([recipeId]),
    });
  }

  static Future<void> removeDislikedRecipe(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'dislikedRecipes': FieldValue.arrayRemove([recipeId]),
    });
  }

  static Future<void> setRecipeRating(String recipeId, int rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'ratings.$recipeId': rating,
    });
  }

  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}
