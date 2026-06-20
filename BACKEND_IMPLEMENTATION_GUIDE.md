# Backend Implementation Guide: Feedback & User Preferences

## 🚀 STEP-BY-STEP IMPLEMENTATION

---

## STEP 1: Create Backend Service Layer

### 1.1 Create Preference Analytics Service

**File**: `lib/services/preference_analytics_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service_base.dart';

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
            difficultyPrefs[difficulty] = (difficultyPrefs[difficulty] ?? 0) + 1;
          }
        }
      });

      // Update preference profile
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
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
  static Future<Map<String, dynamic>?> getPreferenceProfile(
      String uid) async {
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
```

### 1.2 Create Recommendation Service

**File**: `lib/services/recommendation_service.dart`

```dart
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
          .where((e) => (e.value as int?) ?? 0 >= 4)
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
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
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
```

---

## STEP 2: Update Firestore Service

### 2.1 Add Analytics Tracking to `saveRecipeFeedback()`

**File**: `lib/services/firestore_service.dart`

After the existing `saveRecipeFeedback()` function, add:

```dart
// Add this import at the top
import 'preference_analytics_service.dart';
import 'recommendation_service.dart';

// Add this to saveRecipeFeedback() after the set operation:
static Future<void> saveRecipeFeedback({
  required String recipeId,
  required String recipeName,
  required int rating,
  required String taste,
  required String difficulty,
  String? comment,
}) async {
  // ... existing code ...
  
  await _firestore
      .collection('users')
      .doc(user.uid)
      .set(data, SetOptions(merge: true));
  
  // NEW: Update analytics
  await _updateRecipeAnalytics(recipeId, rating, taste, difficulty, comment);
  
  // NEW: Update user preference profile
  await PreferenceAnalyticsService.updatePreferenceProfile(user.uid);
  
  // NEW: Refresh recommendations
  await RecommendationService.refreshRecommendations(user.uid);
}

// NEW: Helper function to update recipe analytics
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
          statsKey: FieldValue.increment(1), // Increment count
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
        'difficultyBreakdown': {difficulty.toLowerCase(): FieldValue.increment(1)},
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
}
```

---

## STEP 3: Update Loading Screen

### 3.1 Initialize Preferences on Signup

**File**: `lib/Screens/Signup/loading_screen.dart`

Replace the `_performCalculation()` method:

```dart
// Add imports at the top
import '../../services/preference_analytics_service.dart';
import '../../services/recommendation_service.dart';

Future<void> _performCalculation() async {
  widget.userData.calculateMetrics();

  // NEW: Initialize user preferences
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await PreferenceAnalyticsService.initializeUserPreferences(user.uid);
      await RecommendationService.getRecommendedRecipes(user.uid);
    }
  } catch (e) {
    print('Error initializing preferences: $e');
  }

  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;

  Navigator.pushReplacementNamed(context, '/success');
}
```

---

## STEP 4: Create Recommendation Screen UI

**File**: `lib/Screens/recommendations_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/recommendation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late Future<List<String>> _recommendationsFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _recommendationsFuture = user != null
        ? RecommendationService.getRecommendedRecipes(user.uid)
        : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2EDE9),
      appBar: AppBar(
        title: Text(
          'Recommended for You',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<String>>(
        future: _recommendationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No recommendations yet.\nRate some recipes to get started!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Recipe ${index + 1}'),
                  subtitle: const Text('Recommended based on your preferences'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to recipe details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## STEP 5: Firestore Security Rules Update

**Update Firebase Console Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
      
      match /preferences/{document=**} {
        allow read, write: if request.auth.uid == uid;
      }
    }
    
    // Analytics collection (read-only for users)
    match /analytics/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Servers can write
    }
    
    // Recipes collection
    match /recipes/{recipeId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }
  }
}
```

---

## STEP 6: Add to pubspec.yaml

Make sure these dependencies exist:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cloud_firestore: ^4.0.0
  firebase_auth: ^4.0.0
  google_fonts: ^6.0.0
  loading_animation_widget: ^1.2.0
```

---

## 📋 VERIFICATION CHECKLIST

After implementing, verify:

- [ ] Preferences initialized when user signs up
- [ ] Feedback updates preference profile
- [ ] Recommendations generated correctly
- [ ] Cache expiry working
- [ ] Analytics data stored in Firestore
- [ ] No errors in console
- [ ] All imports resolved
- [ ] Firestore rules updated

---

## 🧪 TESTING THE IMPLEMENTATION

### Test 1: Verify Initialization
1. Create new user account
2. Check Firestore → users/{uid} → preferences
3. Verify preferences object exists with profile

### Test 2: Verify Feedback Processing
1. Rate a recipe with feedback
2. Check Firestore analytics collection
3. Verify user preference profile updated
4. Check recommendations generated

### Test 3: Verify Recommendations
1. Rate 5+ recipes highly
2. Call `getRecommendedRecipes()`
3. Verify similar recipes returned
4. Check cache is working

### Test 4: Verify Analytics
1. Get user preference profile
2. Verify ratings aggregated correctly
3. Verify taste/difficulty breakdown accurate

---

## 🐛 TROUBLESHOOTING

| Issue | Solution |
|-------|----------|
| Recommendations empty | Ensure user has rated recipes; check Firestore rules |
| Preferences not updating | Check if `updatePreferenceProfile()` called after feedback |
| Cache not working | Verify `recommendationsCacheExpiry` is timestamp |
| Analytics not showing | Ensure `_updateRecipeAnalytics()` is being called |

---

## 📚 NEXT STEPS

1. **Implement Notification System**: Alert users when new recommendations available
2. **Add Preference Settings UI**: Let users manually adjust preferences
3. **Implement ML Recommendations**: Use more sophisticated algorithms
4. **Add Sentiment Analysis**: Analyze feedback comments
5. **Create Dashboard**: Show preference insights to users
