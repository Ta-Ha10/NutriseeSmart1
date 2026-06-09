import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/ai_chat_service.dart';
import 'recipe_feedback.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String recipeName;
  final List<Map<String, String>> ingredients;
  final Map<String, dynamic>? recipeData;
  final String? mealType;
  final VoidCallback? onAddToMeal;

  const RecipeDetailsScreen({
    super.key,
    required this.recipeName,
    required this.ingredients,
    this.recipeData,
    this.mealType,
    this.onAddToMeal,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late final AIChatService _aiService;
  String _currentLanguage = 'en';
  bool _loadingInstructions = false;
  String? _instructionsError;
  List<String> _aiInstructions = const [];
  List<String> _aiCookware = const [];
  int? _aiPreparationTimeMinutes;
  bool _nutritionExpanded = false;
  int _currentStepIndex = -1;
  Set<int> _completedSteps = {};
  late Timer _recipeTimer;
  int _remainingSeconds = 0;
  bool _timerActive = false;
  bool _recipeEnded = false;

  @override
  void initState() {
    super.initState();
    _aiService = AIChatService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreparationSteps();
    });
  }

  void _startTimer(int minutes) {
    _remainingSeconds = minutes * 60;
    _timerActive = true;
    _recipeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timerActive = false;
          timer.cancel();
          _endRecipe();
        }
      });
    });
  }

  @override
  void dispose() {
    if (_timerActive) {
      _recipeTimer.cancel();
    }
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _loadPreparationSteps() async {
    final ingredients = _recipeIngredients();
    if (ingredients.isEmpty) {
      setState(() {
        _aiInstructions = const [];
        _instructionsError = 'No ingredients found for this recipe';
      });
      return;
    }

    setState(() {
      _loadingInstructions = true;
      _instructionsError = null;
    });

    try {
      final response = await _aiService.getPreparationSteps(
        recipeName: widget.recipeName,
        ingredients: ingredients,
        language: _currentLanguage,
      );
      final parsedResponse = _parseAiRecipeResponse(response);
      if (!mounted) return;
      setState(() {
        _aiInstructions = parsedResponse.instructions;
        _aiCookware = parsedResponse.cookware;
        _aiPreparationTimeMinutes = parsedResponse.preparationTimeMinutes;
      });
    } catch (e) {
      debugPrint('AI recipe instructions failed: $e');
      final fallbackResponse = _fallbackRecipeResponse(ingredients);
      if (!mounted) return;
      setState(() {
        _instructionsError = null;
        _aiInstructions = fallbackResponse.instructions;
        _aiCookware = fallbackResponse.cookware;
        _aiPreparationTimeMinutes = fallbackResponse.preparationTimeMinutes;
      });
    } finally {
      if (mounted) setState(() => _loadingInstructions = false);
    }
  }

  Map<String, String> _validateIngredients() {
    final ingredients = _recipeIngredients();
    final invalidIngredients = <String, String>{};

    for (final ingredient in ingredients) {
      final name = ingredient['name'] ?? 'Unknown';
      final quantity = ingredient['quantity']?.trim() ?? '';

      if (quantity.isEmpty) {
        invalidIngredients[name] = 'No quantity specified';
      } else {
        final quantityNum = double.tryParse(quantity.split(' ').first);
        if (quantityNum == 0 || quantityNum == null) {
          if (!quantity.toLowerCase().contains('taste') &&
              !quantity.toLowerCase().contains('pinch') &&
              !quantity.toLowerCase().contains('dash')) {
            invalidIngredients[name] = 'Quantity is 0 or invalid: $quantity';
          }
        }
      }
    }

    return invalidIngredients;
  }

  void _showAddMealDialog() {
    final invalidIngredients = _validateIngredients();

    if (invalidIngredients.isNotEmpty) {
      _showValidationError(invalidIngredients);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add ${widget.mealType ?? "Meal"}',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF243447),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'How would you like to add this meal?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF243447),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _addToMealNow();
                        },
                        icon: const Icon(Icons.timer, color: Colors.white),
                        label: Text(
                          'Add Now',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF243447),
                          side: const BorderSide(
                            color: Color(0xFF243447),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _addToMealLater();
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          'Add Later',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showValidationError(Map<String, String> invalidIngredients) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Invalid Ingredients',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please fix the following ingredient issues:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                ...invalidIngredients.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF243447),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.value,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF243447),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addToMealLater() {
    if (widget.onAddToMeal != null) {
      widget.onAddToMeal!();
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.recipeName} added to ${widget.mealType}',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF49B44E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addToMealNow() {
    if (widget.onAddToMeal != null) {
      widget.onAddToMeal!();
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/cooking_timer',
      arguments: {
        'recipeName': widget.recipeName,
        'ingredients': _recipeIngredients(),
        'instructions': _aiInstructions,
        'prepTime': _aiPreparationTimeMinutes ?? 30,
        'imageUrl': _getImageUrl(),
        'mealType': widget.mealType,
        'recipeId': _recipeId(),
      },
    );
  }

  void _changeInstructionLanguage(String language) {
    if (_currentLanguage == language || _loadingInstructions) return;
    setState(() => _currentLanguage = language);
    _loadPreparationSteps();
  }

  String? _getImageUrl() {
    final recipe = widget.recipeData;
    if (recipe == null) return null;

    for (final key in [
      'image_url',
      'imageUrl',
      'image',
      'photo',
      'thumbnail',
      'picture',
      'recipe_image',
      'recipeImage',
    ]) {
      final value = recipe[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }

    final images = recipe['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is String && first.trim().isNotEmpty) return first.trim();
      if (first is Map) return _firstUrlFromMap(first);
    }

    if (images is Map) return _firstUrlFromMap(images);
    return null;
  }

  String _recipeId() {
    final recipe = widget.recipeData;
    if (recipe != null) {
      for (final key in [
        'id',
        'recipe_id',
        'recipeId',
        'uri',
        'url',
        'source_url',
        'sourceUrl',
      ]) {
        final value = recipe[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    }

    final normalized = widget.recipeName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return normalized.isEmpty ? 'recipe' : normalized;
  }

  String? _firstUrlFromMap(Map<dynamic, dynamic> data) {
    for (final key in ['url', 'image_url', 'imageUrl', 'source']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  int? _getCookTimeOrNull() {
    if (_aiPreparationTimeMinutes != null) return _aiPreparationTimeMinutes;
    return _getRecipeTimeWithoutAi();
  }

  double? _getCalories() {
    final recipe = widget.recipeData;
    if (recipe == null) return null;
    return _valueFromRecipe([
      'calories',
      'kcal',
      'calories_kcal',
      'energy_kcal',
      'energy',
    ]);
  }

  double? _getRatingOrNull() {
    final rating = widget.recipeData?['rating'] ?? widget.recipeData?['score'];
    return double.tryParse(rating.toString());
  }

  double? _getNutritionValue(List<String> keys) {
    return _valueFromRecipe(keys);
  }

  double? _valueFromRecipe(List<String> keys) {
    final nutrition = widget.recipeData?['nutrition'];

    for (final key in keys.expand((key) => [key, _camelCaseKey(key)])) {
      final value = nutrition is Map ? _lookupIgnoreCase(nutrition, key) : null;
      final parsed = _numberFromValue(value);
      if (parsed != null) return parsed;
    }

    for (final key in keys.expand((key) => [key, _camelCaseKey(key)])) {
      final parsed = _numberFromValue(
        _lookupIgnoreCase(widget.recipeData, key),
      );
      if (parsed != null) return parsed;
    }
    return null;
  }

  dynamic _lookupIgnoreCase(Map<dynamic, dynamic>? data, String key) {
    if (data == null) return null;
    if (data.containsKey(key)) return data[key];

    final normalizedKey = _normalizeKey(key);
    for (final entry in data.entries) {
      if (_normalizeKey(entry.key.toString()) == normalizedKey) {
        return entry.value;
      }
    }
    return null;
  }

  String _normalizeKey(String key) {
    return key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _camelCaseKey(String key) {
    final parts = key.split('_');
    if (parts.length < 2) return key;
    return parts.first +
        parts
            .skip(1)
            .map(
              (part) => part.isEmpty
                  ? ''
                  : '${part[0].toUpperCase()}${part.substring(1)}',
            )
            .join();
  }

  double? _numberFromValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final direct = double.tryParse(value.trim());
      if (direct != null) return direct;

      final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(value);
      if (match != null) return double.tryParse(match.group(0)!);
    }
    return null;
  }

  List<MapEntry<String, String>> _nutritionEntries() {
    final nutrition = widget.recipeData?['nutrition'];
    if (nutrition is! Map || nutrition.isEmpty) return const [];
    return nutrition.entries
        .map(
          (entry) => MapEntry(
            _titleFromKey(entry.key.toString()),
            _formatNutritionValue(entry.key.toString(), entry.value),
          ),
        )
        .toList();
  }

  List<MapEntry<String, String>> _otherNutritionEntries() {
    final nutrition = widget.recipeData?['nutrition'];
    if (nutrition is! Map || nutrition.isEmpty) return const [];

    const visibleKeys = {
      'calories',
      'kcal',
      'calorieskcal',
      'energykcal',
      'energy',
      'proteing',
      'protein',
      'proteins',
      'proteincontent',
      'proteincontentg',
      'carbsg',
      'carbohydratesg',
      'carbohydrateg',
      'carbs',
      'carbohydrates',
      'carbohydrate',
      'carb',
      'carbg',
      'carbohydratecontent',
      'carbohydratecontentg',
      'fatg',
      'fatsg',
      'totalfatg',
      'fat',
      'fats',
      'totalfat',
      'fatcontent',
      'fatcontentg',
      'fiberg',
      'fibersg',
      'fiber',
      'fibers',
      'fibre',
      'fibreg',
      'fibercontent',
      'fibercontentg',
    };

    return nutrition.entries
        .where(
          (entry) => !visibleKeys.contains(_normalizeKey(entry.key.toString())),
        )
        .map(
          (entry) => MapEntry(
            _titleFromKey(entry.key.toString()),
            _formatNutritionValue(entry.key.toString(), entry.value),
          ),
        )
        .toList();
  }

  String _formatNutritionValue(String key, dynamic value) {
    final number = _numberFromValue(value);
    if (number == null) return value.toString();

    final normalizedKey = _normalizeKey(key);
    final suffix =
        normalizedKey.contains('sodium') ||
            normalizedKey.contains('cholesterol')
        ? 'mg'
        : normalizedKey.contains('calorie') || normalizedKey == 'kcal'
        ? 'kcal'
        : 'g';

    return '${_formatNumber(number)} $suffix';
  }

  String _titleFromKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  List<Map<String, String>> _recipeIngredients() {
    if (widget.ingredients.isNotEmpty) return widget.ingredients;

    final rawIngredients = widget.recipeData?['ingredients'];
    if (rawIngredients is! List) return const [];

    return rawIngredients.map<Map<String, String>>((item) {
      if (item is Map) {
        final name =
            item['name'] ??
            item['food'] ??
            item['ingredient'] ??
            item['text'] ??
            'Ingredient';
        final quantity =
            item['measure'] ??
            item['quantity'] ??
            item['amount'] ??
            _formatWeight(item['weight_g'] ?? item['weight']);
        return {
          'name': name.toString(),
          'quantity': quantity?.toString() ?? '',
        };
      }
      return {'name': item.toString(), 'quantity': ''};
    }).toList();
  }

  String? _formatWeight(dynamic value) {
    final weight = double.tryParse(value.toString());
    if (weight == null) return null;
    return '${_formatNumber(weight)} g';
  }

  String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  List<String> _parseInstructionSteps(String response) {
    final cleaned = response
        .replaceAll('*', '')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => line.replaceFirst(RegExp(r'^\d+[\).\-\s]+'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (cleaned.length > 1) return cleaned;

    return response
        .replaceAll('*', '')
        .split(RegExp(r'(?<=\.)\s+(?=[A-Z0-9])'))
        .map((step) => step.replaceFirst(RegExp(r'^\d+[\).\-\s]+'), '').trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }

  _AiRecipeResponse _parseAiRecipeResponse(String response) {
    final preparationMatch = RegExp(
      r'PREPARATION_TIME_MINUTES\s*:\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(response);

    final cookwareMatch = RegExp(
      r'COOKWARE\s*:\s*(.+)',
      caseSensitive: false,
    ).firstMatch(response);

    final instructionsMatch = RegExp(
      r'INSTRUCTIONS\s*:\s*([\s\S]*)',
      caseSensitive: false,
    ).firstMatch(response);

    final cookware = cookwareMatch == null
        ? const <String>[]
        : cookwareMatch
              .group(1)!
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList();

    final instructionText = instructionsMatch?.group(1)?.trim() ?? response;

    return _AiRecipeResponse(
      preparationTimeMinutes: int.tryParse(preparationMatch?.group(1) ?? ''),
      cookware: cookware,
      instructions: _parseInstructionSteps(instructionText),
    );
  }

  _AiRecipeResponse _fallbackRecipeResponse(
    List<Map<String, String>> ingredients,
  ) {
    final namedIngredients = ingredients
        .map((ingredient) {
          final quantity = ingredient['quantity']?.trim() ?? '';
          final name = ingredient['name']?.trim() ?? '';
          return '$quantity $name'.trim();
        })
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();

    final firstIngredients = namedIngredients.take(4).join(', ');
    final instructions = _currentLanguage == 'ar'
        ? [
            'جهز المكونات: $firstIngredients.',
            'سخن المقلاة أو القدر على نار متوسطة وأضف المكونات حسب احتياج الوصفة.',
            'اطه المكونات مع التقليب حتى تنضج وتصبح النكهة متوازنة.',
            'قدم ${widget.recipeName} وهو دافئ.',
          ]
        : [
            'Prepare the ingredients: $firstIngredients.',
            'Heat a pan or pot over medium heat and add the ingredients as needed.',
            'Cook while stirring until the ingredients are tender and the flavors are balanced.',
            'Serve ${widget.recipeName} warm.',
          ];

    return _AiRecipeResponse(
      preparationTimeMinutes: _getRecipeTimeWithoutAi() ?? 30,
      cookware: _getRecipeCookwareWithoutAi().isNotEmpty
          ? _getRecipeCookwareWithoutAi()
          : const ['Cutting board', 'Knife', 'Pan or pot', 'Spatula'],
      instructions: instructions,
    );
  }

  int? _getRecipeTimeWithoutAi() {
    final recipe = widget.recipeData;
    if (recipe == null) return null;
    final time =
        recipe['cookTime'] ??
        recipe['cook_time'] ??
        recipe['totalTime'] ??
        recipe['total_time'] ??
        recipe['prepTime'] ??
        recipe['prep_time'] ??
        recipe['readyInMinutes'] ??
        recipe['ready_in_minutes'];
    return int.tryParse(time.toString());
  }

  List<String> _getRecipeCookwareWithoutAi() {
    final recipe = widget.recipeData;
    final value =
        recipe?['cookware'] ??
        recipe?['equipment'] ??
        recipe?['tools'] ??
        recipe?['utensils'];
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  List<String> _getCookware() {
    if (_aiCookware.isNotEmpty) return _aiCookware;
    return _getRecipeCookwareWithoutAi();
  }

  List<String> _getCookingTipsFromRecipe() {
    final recipe = widget.recipeData;
    final value =
        recipe?['cooking_tips'] ??
        recipe?['cookingTips'] ??
        recipe?['tips'] ??
        recipe?['notes'];
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(RegExp(r'\n+'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String _getTranslatedString(String enText) {
    final translations = <String, Map<String, String>>{
      'Nutrition info': {'ar': 'معلومات التغذية'},
      'View all': {'ar': 'عرض الكل'},
      'Show less': {'ar': 'إظهار أقل'},
      'Diet': {'ar': 'النظام الغذائي'},
      'Health': {'ar': 'الصحة'},
      'Cautions': {'ar': 'تحذيرات'},
      'No nutrition data found': {'ar': 'لم يتم العثور على بيانات التغذية'},
      'Protein': {'ar': 'البروتين'},
      'Carbs': {'ar': 'الكربوهيدرات'},
      'Fats': {'ar': 'الدهون'},
      'Fiber': {'ar': 'الألياف'},
      'Other': {'ar': 'أخرى'},
      'Instructions': {'ar': 'التعليمات'},
      'Ingredients': {'ar': 'المكونات'},
      'Cookware': {'ar': 'أدوات الطهي'},
      'English': {'ar': 'الإنجليزية'},
      'Arabic': {'ar': 'العربية'},
      'Preparation steps': {'ar': 'خطوات التحضير'},
      'Required tools': {'ar': 'الأدوات المطلوبة'},
      'Ingredient': {'ar': 'المكون'},
      'Quantity': {'ar': 'الكمية'},
    };

    if (_currentLanguage == 'ar' && translations.containsKey(enText)) {
      return translations[enText]!['ar'] ?? enText;
    }
    return enText;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    final isArabic = _currentLanguage == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return DefaultTabController(
      length: 3,
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroImage(imageUrl),
                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(26, 26, 26, 40),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(26),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.recipeName,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF243447),
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildStatsRow(),
                            _buildRecipeLabelsSection(),
                            const SizedBox(height: 18),
                            _buildNutritionSection(),
                            const SizedBox(height: 20),
                            _buildTabs(),
                            const SizedBox(height: 28),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.58,
                              child: TabBarView(
                                children: [
                                  _buildInstructionsTab(),
                                  _buildIngredientsTab(),
                                  _buildCookwareTab(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTopControls(),
            ],
          ),
          floatingActionButton:
              widget.onAddToMeal != null && widget.mealType != null
              ? FloatingActionButton.extended(
                  onPressed: _showAddMealDialog,
                  backgroundColor: const Color(0xFF13EC5B),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add to ${widget.mealType}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildHeroImage(String? imageUrl) {
    return SizedBox(
      width: double.infinity,
      height: 332,
      child: imageUrl != null
          ? Hero(
              tag: 'recipe_image_${widget.recipeName}',
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImageFallback(),
              ),
            )
          : _buildImageFallback(),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: const Color(0xFFE7ECE7),
      child: const Icon(Icons.restaurant, size: 82, color: Color(0xFF97A0A8)),
    );
  }

  Widget _buildTopControls() {
    final topPadding = MediaQuery.of(context).padding.top + 10;
    return Positioned(
      top: topPadding,
      left: 14,
      right: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          _buildGlassButton(icon: Icons.favorite_border, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(13),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: const Color(0xFF1F2D3A), size: 26),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final cookTime = _getCookTimeOrNull();
    final calories = _getCalories();
    final rating = _getRatingOrNull();

    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            icon: Icons.schedule,
            value: cookTime == null ? '-- min' : '$cookTime min',
          ),
        ),
        _buildStatDivider(),
        Expanded(
          child: _buildInfoItem(
            icon: Icons.local_fire_department_outlined,
            value: calories == null
                ? '-- kcal'
                : '${_formatNumber(calories)} kcal',
          ),
        ),
        _buildStatDivider(),
        Expanded(
          child: _buildInfoItem(
            icon: Icons.star_border_rounded,
            value: rating == null
                ? '-- rate'
                : '${rating.toStringAsFixed(1)} rate',
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeLabelsSection() {
    final dietLabels = _stringListFromRecipe('diet_labels');
    final healthLabels = _stringListFromRecipe('health_labels');
    final cautions = _stringListFromRecipe('cautions');

    if (dietLabels.isEmpty && healthLabels.isEmpty && cautions.isEmpty) {
      return const SizedBox(height: 18);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dietLabels.isNotEmpty)
            _buildLabelGroup(
              title: _getTranslatedString('Diet'),
              labels: dietLabels,
              color: const Color(0xFF2F8F5B),
              background: const Color(0xFFEAF3EE),
            ),
          if (healthLabels.isNotEmpty)
            _buildLabelGroup(
              title: _getTranslatedString('Health'),
              labels: healthLabels,
              color: const Color(0xFF4866A8),
              background: const Color(0xFFECEFFC),
            ),
          if (cautions.isNotEmpty)
            _buildLabelGroup(
              title: _getTranslatedString('Cautions'),
              labels: cautions,
              color: const Color(0xFFB06428),
              background: const Color(0xFFFFF1E4),
            ),
        ],
      ),
    );
  }

  Widget _buildLabelGroup({
    required String title,
    required List<String> labels,
    required Color color,
    required Color background,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: const Color(0xFF5F6B78),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: labels.map((label) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<String> _stringListFromRecipe(String key) {
    final value = widget.recipeData?[key];
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 28, color: const Color(0xFFE0E3E5));
  }

  Widget _buildInfoItem({required IconData icon, required String value}) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF526170), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: const Color(0xFFA2A7AD),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionSection() {
    final protein = _getNutritionValue([
      'protein_g',
      'protein',
      'proteins',
      'proteinContent',
      'proteinContent_g',
    ]);
    final carbs = _getNutritionValue([
      'carbs_g',
      'carbohydrates_g',
      'carbohydrate_g',
      'carbs',
      'carbohydrates',
      'carbohydrate',
      'carb',
      'carb_g',
      'carbohydrateContent',
      'carbohydrateContent_g',
    ]);
    final fat = _getNutritionValue([
      'fat_g',
      'fats_g',
      'total_fat_g',
      'fat',
      'fats',
      'total_fat',
      'fatContent',
      'fatContent_g',
    ]);
    final fiber = _getNutritionValue([
      'fiber_g',
      'fibers_g',
      'fiber',
      'fibers',
      'fibre',
      'fibre_g',
      'fiberContent',
      'fiberContent_g',
    ]);
    final nutritionValues = [
      protein,
      carbs,
      fat,
      fiber,
    ].whereType<double>().toList();
    final hasNutrition = nutritionValues.isNotEmpty;
    final calories = _getCalories();
    final nutritionEntries = _nutritionEntries();
    final otherEntries = _otherNutritionEntries();
    final canExpand = nutritionEntries.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: _nutritionExpanded ? 420 : 254,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _getTranslatedString('Nutrition info'),
                style: GoogleFonts.inter(
                  color: const Color(0xFF243447),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: canExpand
                    ? () => setState(
                        () => _nutritionExpanded = !_nutritionExpanded,
                      )
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getTranslatedString(
                        _nutritionExpanded ? 'Show less' : 'View all',
                      ),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF243447),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _nutritionExpanded
                          ? Icons.expand_less
                          : Icons.chevron_right,
                      color: Color(0xFF243447),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _nutritionExpanded
                ? _buildAllNutritionList(nutritionEntries)
                : hasNutrition
                ? Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: 142,
                            height: 142,
                            child: _buildMacroPieChart(
                              protein: protein,
                              carbs: carbs,
                              fat: fat,
                              fiber: fiber,
                              calories: calories,
                              otherCount: otherEntries.length,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (protein != null) ...[
                              _buildNutritionRow(
                                _getTranslatedString('Protein'),
                                '${_formatNumber(protein)}g',
                                const Color(0xFF80DCA5),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (carbs != null) ...[
                              _buildNutritionRow(
                                _getTranslatedString('Carbs'),
                                '${_formatNumber(carbs)}g',
                                const Color(0xFF8790F1),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (fat != null) ...[
                              _buildNutritionRow(
                                _getTranslatedString('Fats'),
                                '${_formatNumber(fat)}g',
                                const Color(0xFFFF8F7E),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (fiber != null)
                              _buildNutritionRow(
                                _getTranslatedString('Fiber'),
                                '${_formatNumber(fiber)}g',
                                const Color(0xFFE7EAF0),
                              ),
                            if (otherEntries.isNotEmpty) ...[
                              if (fiber != null) const SizedBox(height: 12),
                              _buildNutritionRow(
                                _getTranslatedString('Other'),
                                '${otherEntries.length} more',
                                const Color(0xFFD8DEE4),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      _getTranslatedString('No nutrition data found'),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF8D949C),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF8D949C),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF8D949C),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroPieChart({
    required double? protein,
    required double? carbs,
    required double? fat,
    required double? fiber,
    required double? calories,
    required int otherCount,
  }) {
    final visibleValues = [protein, carbs, fat, fiber].whereType<double>();
    final visibleTotal = visibleValues.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final otherValue = otherCount == 0
        ? null
        : (visibleTotal == 0 ? otherCount.toDouble() : visibleTotal * 0.08);
    final macros = [
      if (carbs != null) _MacroSlice('Carbs', carbs, const Color(0xFF8790F1)),
      if (fat != null) _MacroSlice('Fats', fat, const Color(0xFFFF8F7E)),
      if (protein != null)
        _MacroSlice('Protein', protein, const Color(0xFF80DCA5)),
      if (fiber != null) _MacroSlice('Fiber', fiber, const Color(0xFFCBD2F8)),
      if (otherValue != null)
        _MacroSlice('Other', otherValue, const Color(0xFFD8DEE4)),
    ];
    final total = macros.fold<double>(0, (sum, item) => sum + item.value);

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 3,
            centerSpaceRadius: 38,
            startDegreeOffset: -90,
            sections: macros.map((macro) {
              final percentage = total == 0 ? 0 : (macro.value / total) * 100;
              return PieChartSectionData(
                color: macro.color,
                value: macro.value,
                title: percentage >= 12 ? '${percentage.round()}%' : '',
                titleStyle: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
                radius: 32,
              );
            }).toList(),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              calories == null ? '--' : _formatNumber(calories),
              style: GoogleFonts.inter(
                color: const Color(0xFF243447),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'kcal',
              style: GoogleFonts.inter(
                color: const Color(0xFF8D949C),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAllNutritionList(List<MapEntry<String, String>> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No nutrition data found',
          style: GoogleFonts.inter(
            color: const Color(0xFF8D949C),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.key,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF5F6B78),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                entry.value,
                style: GoogleFonts.inter(
                  color: const Color(0xFF243447),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE5E8EA)),
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: const Color(0xFF243447),
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF5F6B78),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        tabs: [
          Tab(text: _getTranslatedString('Instructions')),
          Tab(text: _getTranslatedString('Ingredients')),
          Tab(text: _getTranslatedString('Cookware')),
        ],
      ),
    );
  }

  Widget _buildInstructionsTab() {
    return Column(
      children: [
        _buildInstructionsHeader(),
        if (_aiPreparationTimeMinutes != null &&
            _aiPreparationTimeMinutes! > 0) ...[
          const SizedBox(height: 12),
          _buildTimerWidget(),
        ],
        const SizedBox(height: 18),
        Expanded(child: _buildInstructionsContent()),
      ],
    );
  }

  Widget _buildInstructionsHeader() {
    return Row(
      children: [
        Text(
          _getTranslatedString('Instructions'),
          style: GoogleFonts.inter(
            color: const Color(0xFF5F6B78),
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        _buildInstructionLanguageToggle(),
      ],
    );
  }

  Widget _buildInstructionLanguageToggle() {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E8EA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageToggleItem('en', 'ENG'),
          _buildLanguageToggleItem('ar', 'AR'),
        ],
      ),
    );
  }

  Widget _buildLanguageToggleItem(String language, String label) {
    final selected = _currentLanguage == language;
    return InkWell(
      onTap: _loadingInstructions
          ? null
          : () => _changeInstructionLanguage(language),
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 48,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF243447) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? Colors.white : const Color(0xFF5F6B78),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildTimerWidget() {
    final isAllStepsCompleted =
        _completedSteps.length == _aiInstructions.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAllStepsCompleted
            ? const Color(0xFFFFF2D8)
            : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAllStepsCompleted
              ? const Color(0xFFFFD966)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: isAllStepsCompleted
                ? const Color(0xFF8B6914)
                : const Color(0xFFCCCCCC),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preparation Time',
                  style: GoogleFonts.inter(
                    color: isAllStepsCompleted
                        ? const Color(0xFF8B6914)
                        : const Color(0xFFCCCCCC),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (_timerActive)
                  Text(
                    'Time Remaining: ${_formatTime(_remainingSeconds)}',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF243447),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                else
                  Text(
                    isAllStepsCompleted
                        ? '${_aiPreparationTimeMinutes} minutes'
                        : 'Complete all steps to start timer',
                    style: GoogleFonts.inter(
                      color: isAllStepsCompleted
                          ? const Color(0xFF243447)
                          : const Color(0xFFCCCCCC),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
          if (isAllStepsCompleted)
            if (!_timerActive)
              ElevatedButton.icon(
                onPressed: () => _startTimer(_aiPreparationTimeMinutes ?? 30),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Start',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  _recipeTimer.cancel();
                  setState(() => _timerActive = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8F7E),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(Icons.pause, color: Colors.white, size: 18),
                label: Text(
                  'Pause',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildInstructionsContent() {
    if (_loadingInstructions) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF243447)),
            const SizedBox(height: 14),
            Text(
              'Preparing instructions...',
              style: GoogleFonts.inter(
                color: const Color(0xFF8D949C),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_instructionsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _instructionsError!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF8D949C),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadPreparationSteps,
              child: Text(
                'Try again',
                style: GoogleFonts.inter(
                  color: const Color(0xFF243447),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_aiInstructions.isEmpty) {
      return Text(
        'No instructions',
        style: GoogleFonts.inter(color: const Color(0xFF8D949C)),
      );
    }

    final currentIndex = _currentStepIndex == -1 ? 0 : _currentStepIndex;
    final isLastStep = currentIndex == _aiInstructions.length - 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Step Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF76C98A), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF76C98A),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${currentIndex + 1}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Step ${currentIndex + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF243447),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _aiInstructions[currentIndex],
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF5F6B78),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                _buildIngredientChips(maxItems: 4),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: isLastStep
                      ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF76C98A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _endRecipe,
                          icon: const Icon(Icons.check_circle),
                          label: Text(
                            'End Recipe',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF76C98A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () =>
                              _completeStep(currentIndex, isLastStep),
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            'Complete',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Static Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: currentIndex > 0
                        ? const Color(0xFF243447)
                        : Colors.grey[400],
                    side: BorderSide(
                      color: currentIndex > 0
                          ? const Color(0xFF243447)
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: currentIndex > 0 ? _previousStep : null,
                  icon: const Icon(Icons.arrow_back_ios, size: 14),
                  label: Text(
                    'Previous',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentIndex < _aiInstructions.length - 1
                        ? const Color(0xFF76C98A)
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: currentIndex < _aiInstructions.length - 1
                      ? _nextStep
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    'Next',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Step Counter
          Center(
            child: Text(
              'Step ${currentIndex + 1} of ${_aiInstructions.length}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeStep(int index, bool isLast) {
    setState(() {
      _currentStepIndex = index;
      _completedSteps.add(index);
    });

    if (isLast) {
      _endRecipe();
    } else if (index < _aiInstructions.length - 1) {
      // Optionally scroll to next step or show next step
      setState(() {
        _currentStepIndex = index + 1;
      });
    }
  }

  void _nextStep() {
    if (_currentStepIndex < _aiInstructions.length - 1) {
      setState(() => _currentStepIndex++);
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
    }
  }

  void _endRecipe() {
    if (_recipeEnded) return;
    _recipeEnded = true;
    if (_timerActive) {
      _recipeTimer.cancel();
      _timerActive = false;
    }
    _showRecipeCompletionDialog();
  }

  void _showRecipeCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3EE),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF76C98A),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'End Recipe',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF243447),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _remainingSeconds == 0 && !_timerActive
                      ? 'Time is up! You have completed ${widget.recipeName}.'
                      : 'Great job! You have completed ${widget.recipeName}.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => RecipeFeedbackScreen(
                            recipeName: widget.recipeName,
                            recipeId: _recipeId(),
                          ),
                        ),
                        (route) => route.isFirst,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF76C98A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Continue to Feedback',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientChips({int? maxItems}) {
    final recipeIngredients = _recipeIngredients();
    final ingredients = maxItems == null
        ? recipeIngredients
        : recipeIngredients.take(maxItems).toList();

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: ingredients.map((ing) {
        final quantity = ing['quantity'] ?? '';
        final name = ing['name'] ?? '';
        final label = '$quantity $name'.trim();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3EE),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF6C7A78),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIngredientsTab() {
    final ingredients = _recipeIngredients();
    if (ingredients.isEmpty) {
      return Text(
        'No ingredients',
        style: GoogleFonts.inter(color: const Color(0xFF8D949C)),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTranslatedString('Ingredients'),
            style: GoogleFonts.inter(
              color: const Color(0xFF5F6B78),
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          _buildIngredientChips(),
        ],
      ),
    );
  }

  Widget _buildCookwareTab() {
    final cookware = _getCookware();
    final cookingTips = _getCookingTipsFromRecipe();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTranslatedString('Cookware'),
            style: GoogleFonts.inter(
              color: const Color(0xFF5F6B78),
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          if (cookware.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _loadingInstructions
                      ? 'Loading cookware from AI...'
                      : 'No cookware found',
                  style: GoogleFonts.inter(color: const Color(0xFF8D949C)),
                ),
                if (!_loadingInstructions) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _loadPreparationSteps,
                    child: Text(
                      'Try again',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF243447),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            )
          else
            Column(
              children: List.generate(cookware.length, (index) {
                final item = cookware[index];
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    bottom: index == cookware.length - 1 ? 0 : 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3EE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF243447),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6C7A78),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          if (cookingTips.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Tips',
              style: GoogleFonts.inter(
                color: const Color(0xFF5F6B78),
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            ...cookingTips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  tip,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF243447),
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AiRecipeResponse {
  final int? preparationTimeMinutes;
  final List<String> cookware;
  final List<String> instructions;

  const _AiRecipeResponse({
    required this.preparationTimeMinutes,
    required this.cookware,
    required this.instructions,
  });
}

class _MacroSlice {
  final String label;
  final double value;
  final Color color;

  const _MacroSlice(this.label, this.value, this.color);
}
