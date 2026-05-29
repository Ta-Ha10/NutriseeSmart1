import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;

class RecipeService {
  // For mobile development, use your computer's IP address instead of localhost
  // Change this to your computer's IP address when running on device/emulator
  static const String baseUrl =
      'http://10.0.2.2:8000'; // Android emulator localhost
  // static const String baseUrl = 'http://192.168.1.xxx:8000'; // Replace with your computer's IP
  static const Duration timeout = Duration(seconds: 10);

  // Check if server is available
  static Future<bool> isServerAvailable() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Server health check failed: $e');
      return false;
    }
  }

  // Search recipes by meal type and calories
  static Future<List<Map<String, dynamic>>> searchRecipes({
    required String mealType,
    required double targetCalories,
    int topK = 15,
  }) async {
    try {
      // Add random variation to target calories to ensure different results on refresh
      final random = Random();
      final calorieVariation = random.nextInt(41) - 20; // Random value between -20 and +20
      final adjustedTargetCalories = targetCalories + calorieVariation;

      // Ensure adjusted calories stay within reasonable bounds
      final finalTargetCalories = adjustedTargetCalories.clamp(100, 2000);

      print('Making API call to: $baseUrl/search');
      print(
        'Request data: meal_type=$mealType, original_target_calories=$targetCalories, adjusted_target_calories=$finalTargetCalories, top_k=$topK',
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/search'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'meal_type': mealType,
              'target_calories': finalTargetCalories,
              'top_k': topK,
            }),
          )
          .timeout(timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      } else {
        throw Exception(
          'Failed to search recipes: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('API call failed: $e');
      // Re-throw with more context
      throw Exception('Error searching recipes for $mealType: $e');
    }
  }

  // Get meal-specific calorie targets based on user's total daily calories
  static Map<String, double> getMealCalorieTargets(double totalDailyCalories) {
    return {
      'breakfast': totalDailyCalories * 0.225, // 20-25% average
      'lunch': totalDailyCalories * 0.375, // 35-40% average
      'dinner': totalDailyCalories * 0.275, // 25-30% average
      'snacks': totalDailyCalories * 0.125, // 10-15% average
    };
  }
}
