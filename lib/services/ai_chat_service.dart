import 'package:google_generative_ai/google_generative_ai.dart';

class AIChatService {
  static const String apiKey = 'AIzaSyBJM_uaiAhaS0ozn4e0C-BsBEyvKaObFZw';
  late final GenerativeModel _model;

  AIChatService() {
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  Future<String> getPreparationSteps({
    required String recipeName,
    required List<Map<String, String>> ingredients,
    required String language,
  }) async {
    try {
      final ingredientsList = _formatIngredients(ingredients);
      final languageInstruction = language == 'ar' ? 'in Arabic' : 'in English';

      final prompt =
          '''
Write clear cooking instructions for this recipe $languageInstruction.

Recipe: $recipeName

Ingredients:
$ingredientsList

Return exactly this format:
PREPARATION_TIME_MINUTES: estimated number only
COOKWARE: comma-separated cookware names
INSTRUCTIONS:
1. First step
2. Second step

Rules:
- Use only the recipe name and ingredients provided above.
- Mention ingredient names and quantities naturally when they are used.
- Keep cookware practical and specific.
- Do not use markdown bullets, tables, headings, or extra commentary outside the exact format.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response received';
    } catch (e) {
      throw Exception('Failed to get preparation steps: $e');
    }
  }

  Future<String> chatAboutRecipe({
    required String recipeName,
    required List<Map<String, String>> ingredients,
    required String userMessage,
    required String language,
  }) async {
    try {
      final ingredientsList = _formatIngredients(ingredients);
      final languageInstruction = language == 'ar'
          ? 'Respond in Arabic'
          : 'Respond in English';

      final prompt =
          '''
$languageInstruction.

You are a helpful cooking assistant. The user is interested in this recipe:

Recipe: $recipeName

Ingredients:
$ingredientsList

User's question: $userMessage

Please provide a helpful response.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response received';
    } catch (e) {
      throw Exception('Failed to chat: $e');
    }
  }

  Future<String> getNutritionalInfo({
    required String recipeName,
    required List<Map<String, String>> ingredients,
    required String language,
  }) async {
    try {
      final ingredientsList = _formatIngredients(ingredients);
      final languageInstruction = language == 'ar' ? 'in Arabic' : 'in English';

      final prompt =
          '''
Please provide nutritional information for this recipe $languageInstruction:

Recipe: $recipeName

Ingredients:
$ingredientsList

Include calories, protein, carbs, fats, fiber, and any other important nutrients.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response received';
    } catch (e) {
      throw Exception('Failed to get nutritional info: $e');
    }
  }

  Future<String> getCookingTips({
    required String recipeName,
    required List<Map<String, String>> ingredients,
    required String language,
  }) async {
    try {
      final ingredientsList = _formatIngredients(ingredients);
      final languageInstruction = language == 'ar' ? 'in Arabic' : 'in English';

      final prompt =
          '''
Please provide helpful cooking tips for this recipe $languageInstruction:

Recipe: $recipeName

Ingredients:
$ingredientsList

Include tips about:
- Best techniques for preparation
- Common mistakes to avoid
- How to store leftovers
- Possible substitutions for ingredients
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response received';
    } catch (e) {
      throw Exception('Failed to get cooking tips: $e');
    }
  }

  String _formatIngredients(List<Map<String, String>> ingredients) {
    return ingredients
        .map((ing) {
          final quantity = ing['quantity']?.trim() ?? '';
          final name = ing['name']?.trim() ?? '';
          return '- $quantity $name'.trim();
        })
        .join('\n');
  }
}
