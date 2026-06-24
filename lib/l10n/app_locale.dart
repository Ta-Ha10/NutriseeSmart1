import 'package:flutter/material.dart';

import '../utils/app_local_store.dart';

class AppLocaleController {
  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(_initialLocale());

  static const String _localePreferenceKey = 'preferred_locale';
  static const List<String> _arabicDigits = [
    '\u0660',
    '\u0661',
    '\u0662',
    '\u0663',
    '\u0664',
    '\u0665',
    '\u0666',
    '\u0667',
    '\u0668',
    '\u0669',
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static Locale _initialLocale() {
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return _normalize(platformLocale);
  }

  static Locale _normalize(Locale locale) {
    return supportedLocales.any((supported) =>
            supported.languageCode == locale.languageCode)
        ? Locale(locale.languageCode)
        : const Locale('en');
  }

  static bool isArabic([Locale? locale]) {
    final current = locale ?? localeNotifier.value;
    return current.languageCode == 'ar';
  }

  static Future<void> setLocale(Locale locale) async {
    final normalized = _normalize(locale);
    localeNotifier.value = normalized;
    await AppLocalStore.writeString(_localePreferenceKey, normalized.languageCode);
  }

  static Future<void> setArabicEnabled(bool enabled) async {
    await setLocale(enabled ? const Locale('ar') : const Locale('en'));
  }

  static Future<void> initialize() async {
    final savedLocale = await AppLocalStore.readString(_localePreferenceKey);
    if (savedLocale != null && savedLocale.isNotEmpty) {
      localeNotifier.value = _normalize(Locale(savedLocale));
    }
  }

  static String localizeDigits(String input, {Locale? locale}) {
    final activeLocale = locale ?? localeNotifier.value;
    if (!isArabic(activeLocale)) {
      return input;
    }

    return input.replaceAllMapped(RegExp(r'\d'), (match) {
      final digit = int.parse(match.group(0)!);
      return _arabicDigits[digit];
    });
  }

  static String normalizeDigits(String input) {
    return input
        .replaceAll('\u0660', '0')
        .replaceAll('\u0661', '1')
        .replaceAll('\u0662', '2')
        .replaceAll('\u0663', '3')
        .replaceAll('\u0664', '4')
        .replaceAll('\u0665', '5')
        .replaceAll('\u0666', '6')
        .replaceAll('\u0667', '7')
        .replaceAll('\u0668', '8')
        .replaceAll('\u0669', '9')
        .replaceAll('\u06F0', '0')
        .replaceAll('\u06F1', '1')
        .replaceAll('\u06F2', '2')
        .replaceAll('\u06F3', '3')
        .replaceAll('\u06F4', '4')
        .replaceAll('\u06F5', '5')
        .replaceAll('\u06F6', '6')
        .replaceAll('\u06F7', '7')
        .replaceAll('\u06F8', '8')
        .replaceAll('\u06F9', '9');
  }
  static String formatNumber(
    num value, {
    Locale? locale,
    int fractionDigits = 0,
  }) {
    final raw = fractionDigits > 0
        ? value.toStringAsFixed(fractionDigits)
        : value.toString();
    final cleaned = fractionDigits == 0 && value is int
        ? raw
        : raw.replaceFirst(RegExp(r'\.0+$'), '');
    return localizeDigits(cleaned, locale: locale);
  }
}

class AppStrings {
  static bool _ar(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static bool _arLocale(Locale locale) => locale.languageCode == 'ar';

  static String appTitle({BuildContext? context, Locale? locale}) {
    final activeLocale = locale ??
        (context != null
            ? Localizations.localeOf(context)
            : AppLocaleController.localeNotifier.value);
    return _arLocale(activeLocale) ? 'ظ†ظˆطھط±ظٹ ط³ظٹ ط³ظ…ط§ط±طھ' : 'NutriSeeSmart';
  }

  static String settings(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ' : 'Setting';

  static String profileName(BuildContext context) =>
      _ar(context) ? 'ط£ظ„ظٹظƒط³ ط¬ظˆظ†ط³ظˆظ†' : 'Alex Johnson';

  static String preferences(BuildContext context) =>
      _ar(context) ? 'ط§ظ„طھظپط¶ظٹظ„ط§طھ' : 'PREFERENCES';

  static String account(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط­ط³ط§ط¨' : 'ACCOUNT';

  static String language(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظ„ط؛ط© ط§ظ„ط¹ط±ط¨ظٹط©' : 'Arabic Language';

  static String languageSubtitle(BuildContext context) =>
      _ar(context) ? 'RTL' : 'LTR';

  static String darkMode(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظˆط¶ط¹ ط§ظ„ظ„ظٹظ„ظٹ' : 'Dark Mode';

  static String units(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظˆط­ط¯ط§طھ' : 'Units';

  static String metric(BuildContext context) =>
      _ar(context) ? 'ظ…طھط±ظٹ' : 'Metric';

  static String imperial(BuildContext context) =>
      _ar(context) ? 'ط¥ظ…ط¨ط±ظٹط§ظ„ظٹ' : 'Imperial';

  static String editProfile(BuildContext context) =>
      _ar(context) ? 'طھط¹ط¯ظٹظ„ ط§ظ„ظ…ظ„ظپ ط§ظ„ط´ط®طµظٹ' : 'Edit Profile';

  static String notifications(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط¥ط´ط¹ط§ط±ط§طھ' : 'Notifications';

  static String logOut(BuildContext context) =>
      _ar(context) ? 'طھط³ط¬ظٹظ„ ط§ظ„ط®ط±ظˆط¬' : 'Log out';

  static String logoutDialogTitle(BuildContext context) =>
      _ar(context) ? 'طھط³ط¬ظٹظ„ ط§ظ„ط®ط±ظˆط¬' : 'Logout';

  static String logoutDialogBody(BuildContext context) =>
      _ar(context)
          ? 'ظ‡ظ„ طھط±ظٹط¯ طھط³ط¬ظٹظ„ ط§ظ„ط®ط±ظˆط¬ ط¨ط§ظ„ظپط¹ظ„طں'
          : 'Are you sure you want to logout?';

  static String cancel(BuildContext context) =>
      _ar(context) ? 'ط¥ظ„ط؛ط§ط،' : 'Cancel';

  static String confirmLogout(BuildContext context) =>
      _ar(context) ? 'ط®ط±ظˆط¬' : 'Logout';

  static String? bottomNavLabel(BuildContext context, String routeName) {
    switch (routeName) {
      case '/meal':
        return _ar(context) ? 'ط§ظ„ظˆط¬ط¨ط§طھ' : 'Meal';
      case '/logs':
        return _ar(context) ? 'ط§ظ„ط³ط¬ظ„' : 'Log';
      case '/home':
        return _ar(context) ? 'ط§ظ„ط±ط¦ظٹط³ظٹط©' : 'Home';
      case '/stats':
        return _ar(context) ? 'ط§ظ„ط¥ط­طµط§ط¦ظٹط§طھ' : 'Stats';
      case '/settings':
        return _ar(context) ? 'ط§ظ„ط¥ط¹ط¯ط§ط¯ط§طھ' : 'Settings';
      default:
        return null;
    }
  }

  static String homeMorning(BuildContext context) =>
      _ar(context) ? 'طµط¨ط§ط­ ط§ظ„ط®ظٹط±طŒ' : 'Good Morning,';

  static String homeLoadError(BuildContext context) =>
      _ar(context)
          ? 'طھط¹ط°ط± طھط­ظ…ظٹظ„ ط¨ظٹط§ظ†ط§طھ ظ…ظ„ظپظƒ ط§ظ„ط´ط®طµظٹ.'
          : 'Couldn\'t load your profile data.';

  static String homeAthlete(BuildContext context) =>
      _ar(context) ? 'ط±ظٹط§ط¶ظٹ' : 'Athlete';

  static String homeMenu(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظ‚ط§ط¦ظ…ط©' : 'Menu';

  static String today(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظٹظˆظ…' : 'Today';

  static String thisWeek(BuildContext context) =>
      _ar(context) ? 'ظ‡ط°ط§ ط§ظ„ط£ط³ط¨ظˆط¹' : 'This Week';

  static String nutritionSummary(BuildContext context) =>
      _ar(context) ? 'ظ…ظ„ط®طµ ط§ظ„طھط؛ط°ظٹط©' : 'Nutrition Summary';

  static String meals(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظˆط¬ط¨ط§طھ' : 'Meals';

  static String mealTypeLabel(BuildContext context, String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return breakfast(context);
      case 'lunch':
        return lunch(context);
      case 'dinner':
        return dinner(context);
      case 'snacks':
        return snacks(context);
      default:
        return mealType;
    }
  }

  static String breakfast(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط¥ظپط·ط§ط±' : 'Breakfast';

  static String lunch(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط؛ط¯ط§ط،' : 'Lunch';

  static String dinner(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط¹ط´ط§ط،' : 'Dinner';

  static String snacks(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظˆط¬ط¨ط§طھ ط§ظ„ط®ظپظٹظپط©' : 'Snacks';

  static String noMealsLogged(BuildContext context) =>
      _ar(context)
          ? 'ظ„ظ… ظٹطھظ… طھط³ط¬ظٹظ„ ظˆط¬ط¨ط§طھ ط¨ط¹ط¯.'
          : 'No meals logged yet.';

  static String profile(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظ…ظ„ظپ ط§ظ„ط´ط®طµظٹ' : 'Profile';

  static String feedback(BuildContext context) =>
      _ar(context) ? 'ط§ظ„طھظ‚ظٹظٹظ…' : 'Feedback';

  static String favourite(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظ…ظپط¶ظ„ط©' : 'Favourite';

  static String healthy(BuildContext context) =>
      _ar(context) ? 'طµط­ظٹ' : 'Healthy';

  static String loggedMeals(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظˆط¬ط¨ط§طھ ط§ظ„ظ…ط³ط¬ظ„ط©' : 'Logged meals';

  static String nothingAddedYet(BuildContext context) =>
      _ar(context)
          ? 'ظ„ط§ ظٹظˆط¬ط¯ ط´ظٹط، ظ‡ظ†ط§ ط¨ط¹ط¯. ط§ط¶ط؛ط· ط¹ظ„ظ‰ ط¥ط¶ط§ظپط© ط·ط¹ط§ظ… ظ„طھط³ط¬ظٹظ„ ظˆط¬ط¨ط©.'
          : 'Nothing added here yet. Tap Add food + to log a meal.';

  static String pressAddFood(BuildContext context) =>
      _ar(context)
          ? 'ط§ط¶ط؛ط· ط¹ظ„ظ‰ ط¥ط¶ط§ظپط© ط·ط¹ط§ظ… ظ„طھط­ظ…ظٹظ„ ط§ظ„ط§ظ‚طھط±ط§ط­ط§طھ.'
          : 'Press Add food + to load recommendations.';

  static String recipeServerUnavailable(BuildContext context) =>
      _ar(context)
          ? 'ط®ط§ط¯ظ… ط§ظ„ظˆطµظپط§طھ ط؛ظٹط± ظ…طھط§ط­. ط´ط؛ظ‘ظ„ FastAPI ظ„ط±ط¤ظٹط© ط§ظ„ط§ظ‚طھط±ط§ط­ط§طھ.'
          : 'Recipe server is not available. Start the FastAPI server to see recommendations.';

  static String noRecipeRecommendations(BuildContext context) =>
      _ar(context)
          ? 'ظ„ظ… ظٹطھظ… ط§ظ„ط¹ط«ظˆط± ط¹ظ„ظ‰ ط§ظ‚طھط±ط§ط­ط§طھ ظˆطµظپط§طھ ظ„ظ‡ط°ط§ ط§ظ„ظ†ظˆط¹ ظ…ظ† ط§ظ„ظˆط¬ط¨ط§طھ.'
          : 'No recipe recommendations found for this meal type.';

  static String recipesReady(BuildContext context) =>
      _ar(context)
          ? 'ط§ظ„ظˆطµظپط§طھ ط¬ط§ظ‡ط²ط© ظپظٹ طµظپط­ط© ط§ظ„ط¨ط­ط« ط¥ط¶ط§ظپط© ط·ط¹ط§ظ…. ط­ط¯ظ‘ط« ط§ظ„طµظپط­ط© ظ„ظ„ط­طµظˆظ„ ط¹ظ„ظ‰ ظ†طھط§ط¦ط¬ ط¬ط¯ظٹط¯ط©.'
          : 'Recipes are ready in the Add Food search page. Refresh the page to get a new set of search results.';

  static String addFood(BuildContext context) =>
      _ar(context) ? 'ط¥ط¶ط§ظپط© ط·ط¹ط§ظ… +' : 'Add food +';

  static String logDinner(BuildContext context) =>
      _ar(context) ? 'طھط³ط¬ظٹظ„ ط§ظ„ط¹ط´ط§ط،' : 'Log Dinner';

  static String caloriesRemaining(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط³ط¹ط±ط§طھ ط§ظ„ظ…طھط¨ظ‚ظٹط©' : 'CALORIES REMAINING';

  static String waterTrackerButton(BuildContext context) =>
      _ar(context) ? 'ظ…طھطھط¨ط¹ ط§ظ„ظ…ط§ط،' : 'Water Tracker';

  static String refreshRecipes(BuildContext context) =>
      _ar(context) ? 'طھط­ط¯ظٹط« ط§ظ„ظˆطµظپط§طھ' : 'Refresh recipes';

  static String addMealFood(BuildContext context, String mealType) =>
      _ar(context) ? 'ط¥ط¶ط§ظپط© ط·ط¹ط§ظ… $mealType' : 'Add $mealType Food';

  static String recipeAdded(BuildContext context, String recipeName, String mealType) =>
      _ar(context)
          ? 'طھظ…طھ ط¥ط¶ط§ظپط© $recipeName ط¥ظ„ظ‰ $mealType'
          : '$recipeName added to $mealType';

  static String recipeDetails(BuildContext context) =>
      _ar(context) ? 'طھظپط§طµظٹظ„ ط§ظ„ظˆطµظپط©' : 'Recipe Details';

  static String addToMeal(BuildContext context) =>
      _ar(context) ? 'ط¥ط¶ط§ظپط© ط¥ظ„ظ‰ ط§ظ„ظˆط¬ط¨ط©' : 'Add to Meal';

  static String recipeDetailsAddToMeal(BuildContext context) =>
      _ar(context) ? 'ط¥ط¶ط§ظپط© ط¥ظ„ظ‰ ط§ظ„ظˆط¬ط¨ط©' : 'Add to Meal';

  static String waterRecommended(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظƒظ…ظٹط© ط§ظ„ظٹظˆظ…ظٹط© ط§ظ„ظ…ظˆطµظ‰ ط¨ظ‡ط§' : 'Recommended daily intake';

  static String current(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط­ط§ظ„ظٹ' : 'Current';

  static String remaining(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظ…طھط¨ظ‚ظٹ' : 'Remaining';

  static String resetDay(BuildContext context) =>
      _ar(context) ? 'ط¥ط¹ط§ط¯ط© ط¶ط¨ط· ط§ظ„ظٹظˆظ…' : 'Reset Day';

  static String tapCupHint(BuildContext context) =>
      _ar(context)
          ? 'ط§ط¶ط؛ط· ط¹ظ„ظ‰ ط­ط¬ظ… ط§ظ„ظƒظˆط¨ ظ„ط¥ط¶ط§ظپط© ط§ظ„ظ…ط§ط، ط¥ظ„ظ‰ ط§ظ„ط§ط³طھظ‡ظ„ط§ظƒ ط§ظ„ط­ط§ظ„ظٹ.'
          : 'Tap a cup size to add water to your current intake.';

  static String waterTracker(BuildContext context) =>
      _ar(context) ? 'ظ…طھطھط¨ط¹ ط§ظ„ظ…ط§ط،' : 'Water Tracker';

  static String recommendedForYou(BuildContext context) =>
      _ar(context) ? 'ظ…ظ‚طھط±ط­ط§طھ ظ„ظƒ' : 'Recommended for You';

  static String noRecommendations(BuildContext context) =>
      _ar(context)
          ? 'ظ„ط§ طھظˆط¬ط¯ ظ…ظ‚طھط±ط­ط§طھ ط¨ط¹ط¯.\nظ‚ظٹظ‘ظ… ط¨ط¹ط¶ ط§ظ„ظˆطµظپط§طھ ظ„ظ„ط¨ط¯ط،!'
          : 'No recommendations yet.\nRate some recipes to get started!';

  static String nutritionHistory(BuildContext context) =>
      _ar(context) ? 'ط³ط¬ظ„ ط§ظ„طھط؛ط°ظٹط©' : 'Nutrition History';

  static String pleaseSignInMealLogs(BuildContext context) =>
      _ar(context)
          ? 'ظٹط±ط¬ظ‰ طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„ ظ„ط¹ط±ط¶ ط³ط¬ظ„ ط§ظ„ظˆط¬ط¨ط§طھ.'
          : 'Please sign in to view your meal logs.';

  static String mealPleaseSignIn(BuildContext context) =>
      _ar(context)
          ? 'ظٹط±ط¬ظ‰ طھط³ط¬ظٹظ„ ط§ظ„ط¯ط®ظˆظ„ ظ„ط¹ط±ط¶ ط§ظ„ظˆط¬ط¨ط§طھ'
          : 'Please sign in to view meals';

  static String mealProfileMissing(BuildContext context) =>
      _ar(context)
          ? 'ظ„ظ… ظٹطھظ… ط§ظ„ط¹ط«ظˆط± ط¹ظ„ظ‰ ظ…ظ„ظپ ط§ظ„ظ…ط³طھط®ط¯ظ…. ظٹط±ط¬ظ‰ ط¥ظƒظ…ط§ظ„ ط¥ط¹ط¯ط§ط¯ ط§ظ„ظ…ظ„ظپ ط§ظ„ط´ط®طµظٹ.'
          : 'User profile not found. Please complete your profile setup.';

  static String mealProfileUnavailable(BuildContext context) =>
      _ar(context)
          ? 'ط¨ظٹط§ظ†ط§طھ ط§ظ„ظ…ظ„ظپ ط§ظ„ط´ط®طµظٹ ط؛ظٹط± ظ…طھط§ط­ط©. ط­ط§ظˆظ„ ظ…ط±ط© ط£ط®ط±ظ‰ ظ„ط§ط­ظ‚ظ‹ط§.'
          : 'User profile data is unavailable. Please try again later.';

  static String mealLoadingFailed(BuildContext context) =>
      _ar(context)
          ? 'ظپط´ظ„ طھط­ظ…ظٹظ„ ط¨ظٹط§ظ†ط§طھ ط§ظ„ظ…ط³طھط®ط¯ظ…. ظٹط±ط¬ظ‰ ط§ظ„ظ…ط­ط§ظˆظ„ط© ظ…ط±ط© ط£ط®ط±ظ‰.'
          : 'Failed to load user data. Please try again.';

  static String mealServerUnavailable(BuildContext context) =>
      _ar(context)
          ? 'ط®ط§ط¯ظ… ط§ظ„ظˆطµظپط§طھ ط؛ظٹط± ظ…طھط§ط­. ظٹط±ط¬ظ‰ طھط´ط؛ظٹظ„ ط®ط§ط¯ظ… FastAPI.'
          : 'Recipe server is not available. Please start the FastAPI server.';

  static String waterIntake(BuildContext context) =>
      _ar(context) ? 'ط§ط³طھظ‡ظ„ط§ظƒ ط§ظ„ظ…ط§ط،' : 'Water Intake';

  static String last7Days(BuildContext context) =>
      _ar(context) ? 'ط¢ط®ط± 7 ط£ظٹط§ظ…' : 'Last 7 Days';

  static String goalPerDay(BuildContext context, int ml) =>
      _ar(context)
          ? 'ط§ظ„ظ‡ط¯ظپ ${AppLocaleController.formatNumber(ml)} ظ…ظ„ ظپظٹ ط§ظ„ظٹظˆظ…'
          : 'Goal $ml ml per day';

  static String signInToViewWaterHistory(BuildContext context) =>
      _ar(context)
          ? 'ط³ط¬ظ„ ط§ظ„ط¯ط®ظˆظ„ ظ„ط¹ط±ط¶ ط³ط¬ظ„ ط§ظ„ظ…ط§ط،.'
          : 'Sign in to view your water history.';

  static String retry(BuildContext context) =>
      _ar(context) ? 'ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط©' : 'Retry';

  static String noRecommendationsFound(BuildContext context) =>
      _ar(context)
          ? 'ظ„ط§ طھظˆط¬ط¯ طھظˆطµظٹط§طھ ظ„ظ‡ط°ط§ ط§ظ„ظ†ظˆط¹ ظ…ظ† ط§ظ„ظˆط¬ط¨ط§طھ.'
          : 'No recommendations found for this meal type.';

  static String weekdayShortLabel(BuildContext context, int index) {
    final labels = _ar(context)
        ? ['ط£ط­ط¯', 'ط§ط«ظ†', 'ط«ظ„ط«', 'ط£ط±ط¨ط¹', 'ط®ظ…ظٹط³', 'ط¬ظ…ط¹', 'ط³ط¨طھ']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[index % labels.length];
  }

  static String formattedDateLabel(BuildContext context, DateTime date) {
    final monthNames = _ar(context)
        ? [
            'ظٹظ†ط§ظٹط±',
            'ظپط¨ط±ط§ظٹط±',
            'ظ…ط§ط±ط³',
            'ط£ط¨ط±ظٹظ„',
            'ظ…ط§ظٹظˆ',
            'ظٹظˆظ†ظٹظˆ',
            'ظٹظˆظ„ظٹظˆ',
            'ط£ط؛ط³ط·ط³',
            'ط³ط¨طھظ…ط¨ط±',
            'ط£ظƒطھظˆط¨ط±',
            'ظ†ظˆظپظ…ط¨ط±',
            'ط¯ظٹط³ظ…ط¨ط±',
          ]
        : [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
    return '${monthNames[date.month - 1]} ${AppLocaleController.formatNumber(date.day)}';
  }

  static String todayDateLabel(BuildContext context, DateTime date) {
    return '${today(context)}, ${formattedDateLabel(context, date)}';
  }

  static String carbs(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظƒط±ط¨ظˆظ‡ظٹط¯ط±ط§طھ' : 'Carbs';

  static String protein(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط¨ط±ظˆطھظٹظ†' : 'Protein';

  static String fats(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط¯ظ‡ظˆظ†' : 'Fats';

  static String calories(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط³ط¹ط±ط§طھ' : 'Calories';

  static String fat(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ط¯ظ‡ظˆظ†' : 'Fat';

  static String remainingLabel(BuildContext context) =>
      _ar(context) ? 'ط§ظ„ظ…طھط¨ظ‚ظٹ' : 'REMAINING';

  static String goalLabel(BuildContext context, int goalCalories) =>
      _ar(context)
          ? 'ط§ظ„ظ‡ط¯ظپ ${goalCalories > 0 ? AppLocaleController.formatNumber(goalCalories) : '--'}'
          : 'GOAL ${goalCalories > 0 ? goalCalories : '--'}';

  static String unknownRecipe(BuildContext context) =>
      _ar(context) ? 'ظˆطµظپط© ط؛ظٹط± ظ…ط¹ط±ظˆظپط©' : 'Unknown Recipe';

  static String ingredient(BuildContext context) =>
      _ar(context) ? 'ظ…ظƒظˆظ†' : 'Ingredient';

  static String unableToRefreshSearchResults(BuildContext context) =>
      _ar(context)
          ? 'طھط¹ط°ط± طھط­ط¯ظٹط« ظ†طھط§ط¦ط¬ ط§ظ„ط¨ط­ط«. ط§ط³ط­ط¨ ظ„طھط­ط¯ظٹط« ط§ظ„ظ†طھط§ط¦ط¬ ط£ظˆ ط§ط¶ط؛ط· ط²ط± ط§ظ„طھط­ط¯ظٹط« ظ„ظ„ظ…ط­ط§ظˆظ„ط© ظ…ط±ط© ط£ط®ط±ظ‰.'
          : 'Unable to refresh search results. Pull down to refresh or tap the refresh button to retry.';
}

