# Feedback & User Preference Implementation Plan

## 📋 CURRENT FRONTEND IMPLEMENTATION

### 1. **What's Implemented (Client-Side)**

#### A. Feedback Collection
- **Location**: `lib/Screens/recipe_feedback.dart`
- **Trigger**: After cooking timer completes (cooking_timer_screen.dart)
- **Data Collected**:
  - ⭐ **Rating**: 1-5 star rating
  - 👅 **Taste Feedback**: Delicious / Good / Average / Bad
  - 🔪 **Difficulty Feedback**: Easy / Just Right / Hard
  - 💬 **Comments**: Optional text feedback

#### B. User Preferences Storage
- **Location**: `lib/services/firestore_service.dart`
- **Database**: Firestore (users collection)

**Data Structure**:
```
users/{uid}/
├── ratings: {recipe_id: rating_value}
├── recipeFeedback: {
│   recipe_id: {
│       recipeId: string,
│       recipeName: string,
│       rating: number (1-5),
│       taste: string,
│       difficulty: string,
│       comment: string (optional),
│       updatedAt: timestamp
│   }
├── likedRecipes: [array of recipe_ids]
├── dislikedRecipes: [array of recipe_ids]
```

#### C. Auto-Generated Preferences
- Recipes rated 4-5 → Added to `likedRecipes`
- Recipes rated 1-2 → Added to `dislikedRecipes`
- Recipes rated 3 → Neutral (removed from both lists)

---

## 🔧 BACKEND IMPLEMENTATION PLAN

### Phase 1: Analytics & Data Processing

#### 1.1 Create Backend Service Layer
**File**: `lib/services/preference_analytics_service.dart`

```dart
class PreferenceAnalyticsService {
  // Process user feedback patterns
  static Future<UserPreferenceProfile> analyzeUserPreferences(String uid) async {
    // Aggregate feedback data
    // Calculate recipe preferences score
    // Identify dietary patterns
    // Generate recommendations
  }
}
```

**What to Do**:
- Read user's feedback history
- Calculate average ratings per recipe category
- Identify taste preferences (spicy, sweet, savory, etc.)
- Track difficulty tolerance
- Find recipe correlations

#### 1.2 Create Recommendation Engine
**File**: `lib/services/recommendation_service.dart`

```dart
class RecommendationService {
  // Generate personalized recipe recommendations
  static Future<List<String>> getRecommendedRecipes(String uid, {int limit = 10}) async {
    // Based on:
    // 1. Liked recipes
    // 2. Rating patterns
    // 3. Similar recipes to high-rated ones
    // 4. User preferences
  }
}
```

**Algorithm**:
1. Find recipes with similar attributes to liked recipes
2. Filter out disliked and previously rated recipes
3. Score based on preference match
4. Return top N recommendations

#### 1.3 Create Models for Analytics
**File**: `lib/utils/models/preference_models.dart`

```dart
class UserPreferenceProfile {
  final String userId;
  final double averageRating;
  final Map<String, int> tastePreferences;
  final Map<String, int> difficultyPreferences;
  final List<String> preferredCategories;
  final List<String> avoidedCategories;
  final DateTime lastUpdated;
}

class RecipeRecommendation {
  final String recipeId;
  final String recipeName;
  final double matchScore;
  final List<String> reasons; // Why this was recommended
}
```

---

### Phase 2: Backend API/Cloud Functions

#### 2.1 Firebase Cloud Functions

**Function 1: Process Feedback**
```
POST /api/preferences/saveFeedback
- Called when user submits feedback
- Stores feedback
- Updates preference profile
- Triggers recommendation refresh
```

**Function 2: Get Recommendations**
```
GET /api/preferences/recommendations?uid={uid}&limit=10
- Returns personalized recipe recommendations
- Cached for performance
```

**Function 3: Analyze Preferences**
```
POST /api/preferences/analyze?uid={uid}
- Generates preference profile
- Identifies patterns
- Updates user preference document
```

**Function 4: Get Preference Summary**
```
GET /api/preferences/summary?uid={uid}
- Returns user's preference profile
- Top liked categories
- Difficulty range
```

---

### Phase 3: Data Model Updates

#### 3.1 Extend Firestore Users Collection

```
users/{uid}/
├── (existing fields)
├── preferences/
│   ├── profile: {
│   │   averageRating: number,
│   │   totalRatings: number,
│   │   tastePreferences: {spicy: n, sweet: n, ...},
│   │   difficultyRange: {min: number, max: number},
│   │   preferredCategories: [array],
│   │   avoidedCategories: [array],
│   │   lastAnalyzedAt: timestamp
│   ├── recommendations: [array of recipe IDs]
│   ├── analyticsCache: {
│   │   generatedAt: timestamp,
│   │   expiresAt: timestamp
```

#### 3.2 Create Analytics Collection

```
analytics/
├── recipeFeedbackStats/{recipeId}/
│   ├── averageRating: number
│   ├── totalRatings: number
│   ├── ratingDistribution: {1: n, 2: n, ...}
│   ├── tasteBreakdown: {delicious: n, good: n, ...}
│   ├── difficultyBreakdown: {easy: n, just_right: n, hard: n}
│   ├── commentSentiment: {positive: n, neutral: n, negative: n}
│   ├── updatedAt: timestamp
│
├── userPreferenceStats/
│   ├── totalUsers: number
│   ├── totalRatings: number
│   ├── averageRating: number
│   ├── updatedAt: timestamp
```

---

### Phase 4: Frontend Integration

#### 4.1 Add Recommendation UI
**File**: `lib/Screens/recommendations_screen.dart`

```dart
class RecommendationsScreen extends StatefulWidget {
  // Displays AI-generated recommendations
  // Shows match score and reason for recommendation
  // Quick access to recipes
}
```

#### 4.2 Update Loading Screen
**File**: `lib/Screens/Signup/loading_screen.dart` (WHERE YOU ARE NOW)

```dart
// After user metrics are calculated:
// 1. Save initial user preferences
// 2. Generate first recommendations
// 3. Update preference profile
// 4. Trigger analytics
```

**Add to _performCalculation()**:
```dart
Future<void> _performCalculation() async {
  widget.userData.calculateMetrics();
  
  // NEW: Initialize user preferences
  await PreferenceAnalyticsService.initializeUserPreferences(user.uid);
  await RecommendationService.generateInitialRecommendations(user.uid);
  
  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;
  
  Navigator.pushReplacementNamed(context, '/success');
}
```

#### 4.3 Update Home Screen
Add a "Recommended for You" section showing personalized recipes

#### 4.4 Add Preference Settings Screen
**File**: `lib/Screens/preference_settings_screen.dart`

```dart
// Allow users to:
// - View their preference profile
// - Set difficulty preference
// - Mark dietary restrictions
// - Adjust recommendation frequency
```

---

## 📊 IMPLEMENTATION CHECKLIST

### Backend Services
- [ ] Create `preference_analytics_service.dart`
- [ ] Create `recommendation_service.dart`
- [ ] Create `preference_models.dart`
- [ ] Implement analytics algorithms
- [ ] Add caching mechanism

### Cloud Functions
- [ ] Deploy `processFeedback` function
- [ ] Deploy `getRecommendations` function
- [ ] Deploy `analyzePreferences` function
- [ ] Deploy `getPreferenceSummary` function

### Firestore
- [ ] Update users collection schema
- [ ] Create analytics collection
- [ ] Add indexes for queries
- [ ] Update security rules

### Frontend UI
- [ ] Create recommendations screen
- [ ] Update loading_screen.dart
- [ ] Add preference settings
- [ ] Update home screen UI

### Testing
- [ ] Unit tests for analytics
- [ ] Integration tests
- [ ] User acceptance testing

---

## 🔄 DATA FLOW DIAGRAM

```
User Provides Feedback (RecipeFeedbackScreen)
        ↓
SaveRecipeFeedback() called (firestore_service.dart)
        ↓
Firestore stored:
- ratings
- recipeFeedback
- likedRecipes/dislikedRecipes
        ↓
Backend Analytics Triggered
        ↓
PreferenceAnalyticsService analyzes patterns
        ↓
RecommendationService generates suggestions
        ↓
Results stored in preferences/profile collection
        ↓
Frontend fetches & displays recommendations
        ↓
User sees personalized recipe suggestions
```

---

## 🎯 PRIORITY ORDER

1. **Immediate (Week 1)**
   - Create backend service layer
   - Implement basic recommendation algorithm
   - Update loading_screen.dart to initialize preferences

2. **Short Term (Week 2-3)**
   - Create recommendations UI
   - Deploy cloud functions
   - Add preference settings screen

3. **Medium Term (Week 4-5)**
   - Add analytics collection
   - Implement advanced algorithms
   - Add user preference dashboard

4. **Long Term (Week 6+)**
   - ML-based recommendations
   - Sentiment analysis on comments
   - Dietary restriction patterns

---

## 💾 CODE SNIPPETS

### Service Implementation Template

```dart
// lib/services/preference_analytics_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PreferenceAnalyticsService {
  static final _firestore = FirebaseFirestore.instance;
  
  /// Initialize user preferences on first signup
  static Future<void> initializeUserPreferences(String uid) async {
    final preferences = {
      'preferences': {
        'profile': {
          'averageRating': 0.0,
          'totalRatings': 0,
          'tastePreferences': {},
          'difficultyRange': {'min': 1, 'max': 5},
          'preferredCategories': [],
          'avoidedCategories': [],
          'lastAnalyzedAt': FieldValue.serverTimestamp(),
        },
        'recommendations': [],
      }
    };
    
    await _firestore
        .collection('users')
        .doc(uid)
        .set(preferences, SetOptions(merge: true));
  }
  
  /// Analyze user feedback and update preference profile
  static Future<void> updatePreferenceProfile(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final data = userDoc.data();
    
    if (data == null) return;
    
    final ratings = (data['ratings'] as Map?)?? {};
    final recipeFeedback = (data['recipeFeedback'] as Map?)?? {};
    
    // Calculate statistics
    double avgRating = 0;
    if (ratings.isNotEmpty) {
      final values = ratings.values.whereType<int>();
      avgRating = values.reduce((a, b) => a + b) / values.length;
    }
    
    // Update profile
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
          'preferences.profile.averageRating': avgRating,
          'preferences.profile.totalRatings': ratings.length,
          'preferences.profile.lastAnalyzedAt': FieldValue.serverTimestamp(),
        });
  }
}
```

---

## 📝 NOTES

- Use Firestore cache for performance
- Implement rate limiting on recommendations API
- Consider pagination for large preference datasets
- Add offline support with local caching
- Implement user privacy controls for analytics
