# Nutrisee Smart - Meal Integration

## Overview
The app now integrates with a FastAPI recipe recommendation server to provide personalized meal suggestions based on user data.

## Features
- **Dynamic Calorie Distribution**: Meals are distributed based on daily calorie needs:
  - Breakfast: 20-25% of total daily calories
  - Lunch: 35-40% of total daily calories
  - Dinner: 25-30% of total daily calories
  - Snacks: 10-15% of total daily calories

- **Personalized Recommendations**: Recipes are fetched from the API based on:
  - User's target calories for each meal type
  - Meal type filtering
  - Nutritional information

## Setup

### 1. Start the FastAPI Server
```bash
# Navigate to your FastAPI project directory
cd /path/to/fastapi/project

# Install dependencies
pip install -r requirements.txt

# Start the server
python app.py
# or
uvicorn app:app --reload --port 8000
```

### 2. Update API URL for Your Network
**For Android Emulator:**
- The app uses `http://10.0.2.2:8000` (Android emulator's localhost)
- This should work if your FastAPI server is running on `localhost:8000` on your development machine

**For Physical Android Device:**
- Replace `10.0.2.2` with your computer's IP address in `lib/services/recipe_service.dart`:
```dart
static const String baseUrl = 'http://192.168.1.xxx:8000'; // Replace xxx with your IP
```

**For iOS Simulator:**
- Use `http://localhost:8000` (iOS simulator can access host machine directly)

### 3. Required Data Files
Ensure these files exist in your FastAPI project directory:
- `recommendation_metadata.pkl`
- `recipe_similarity_index.pkl`
- `final_recipes_cleaned.csv`
- `recipe_identifiers.csv`

## API Integration

### Request Format
```json
{
  "meal_type": "breakfast",
  "target_calories": 500,
  "top_k": 10
}
```

### Response Format
```json
{
  "search_criteria": {
    "meal_type": "breakfast",
    "target_calories": 500,
    "calorie_tolerance": null
  },
  "results": [
    {
      "recipe_id": 123,
      "recipe_name": "Oatmeal with Berries",
      "source": "some_source",
      "url": "https://example.com/recipe",
      "image_url": "https://example.com/image.jpg",
      "total_weight_g": 250.0,
      "nutrition": {
        "calories": 450,
        "protein_g": 15,
        "carbs_g": 70,
        "fat_g": 8,
        "fiber_g": 8,
        "sugar_g": 25,
        "sodium_mg": 150,
        "cholesterol_mg": 0
      },
      "cuisine_type": "American",
      "meal_type": "Breakfast",
      "diet_labels": ["Vegetarian"],
      "health_labels": ["Low Sugar"],
      "cautions": [],
      "ingredients": [
        {
          "name": "Oats",
          "weight_g": 50
        }
      ]
    }
  ],
  "count": 1
}
```

## User Data Integration
The app automatically:
1. Loads user data from Firestore
2. Calculates meal-specific calorie targets
3. Fetches personalized recipe recommendations
4. Displays dynamic nutrition summaries

## Testing
Run the test script to verify API connectivity:
```bash
dart run test_api.dart
```

This will test both the health endpoint and search functionality, showing you exactly what's working and what isn't.

## Error Handling & Offline Mode

### When API Server is Unavailable
The app gracefully handles server unavailability:
- **Shows helpful messages** instead of blank screens
- **Provides retry options** with refresh button and pull-to-refresh
- **Displays calorie targets** even without recipes
- **Shows snackbar notifications** when trying to add food without server

### Troubleshooting Common Issues

#### Empty White Screen
**Problem**: App shows blank/white screen on meals page
**Solutions**:
1. **Check user authentication**: Ensure user is signed in
2. **Verify user profile**: Make sure user completed signup with calorie targets
3. **Start API server**: Ensure FastAPI server is running on port 8000
4. **Check network**: Verify device can reach localhost/127.0.0.1
5. **Use refresh button**: Tap the refresh icon in top-right to retry

#### "Recipe server is not available" Message
**Problem**: SnackBar shows server unavailable message
**Solution**: Start your FastAPI server with `python app.py`

#### No Recipe Recommendations
**Problem**: Meals show info message instead of recipes
**Solutions**:
1. Start the FastAPI server
2. Check that all required data files exist
3. Verify API endpoint `/search` is working
4. Use the refresh button to retry loading

## App Features

### Refresh Options
- **Refresh Button**: Top-right refresh icon reloads recipes
- **Pull-to-Refresh**: Swipe down on meals list to refresh
- **Retry Button**: Appears when errors occur

### Offline Behavior
- **Calorie targets always shown**: Based on user profile data
- **Graceful degradation**: App works without recipes
- **Clear messaging**: Users know why recipes aren't loading
- **Easy recovery**: Simple retry options available