import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Screens/Login/login_screen.dart';
import 'Screens/Signup/activity_screen.dart';
import 'Screens/Signup/auth_method_screen.dart';
import 'Screens/Signup/birth_screen.dart';
import 'Screens/Signup/breakfast_time_screen.dart';
import 'Screens/Signup/current_weight_screen.dart' show CurrentWeightScreen;
import 'Screens/Signup/dinner_time_screen.dart';
import 'Screens/Signup/email_verification_screen.dart';
import 'Screens/Signup/goal_weight_screen.dart';
import 'Screens/Signup/ingredient_search_screen.dart';
import 'Screens/Signup/loading_screen.dart';
import 'Screens/Signup/lunch_time_screen.dart';
import 'Screens/Signup/meal_goal_screen.dart';
import 'Screens/Signup/meals_screen.dart';
import 'Screens/Signup/navigator.dart';
import 'Screens/Signup/obesity_screen.dart';
import 'Screens/Signup/review_screen.dart';
import 'Screens/Signup/success_screen.dart';
import 'Screens/Signup/workout_frequency_screen.dart';
import 'Screens/cooking_timer_screen.dart';
import 'Screens/daily_nutrition_summary_screen.dart';
import 'Screens/nutrition_history_screen.dart';
import 'firebase_options.dart';
import 'main/home_screen.dart';
import 'main/setting.dart';
import 'l10n/app_locale.dart';
import 'theme/app_theme.dart';
import 'utils/page_transitions.dart';
import 'utils/user_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppLocaleController.initialize();
  await AppTheme.initialize();
  runApp(const MyApp());
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in, show home screen
          return const HomeScreen();
        } else {
          // User is not signed in, show login screen
          return const LoginScreen();
        }
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            final isArabic = AppLocaleController.isArabic(locale);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppStrings.appTitle(locale: locale),
              locale: locale,
              supportedLocales: AppLocaleController.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                return Directionality(
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                );
              },
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              home: const AuthWrapper(),
              onGenerateRoute: (settings) {
                if (settings.name == '/email_verification') {
                  final email = settings.arguments as String?;
                  if (email != null) {
                    return CustomPageTransitions.slideAndFadeTransition(
                      EmailVerificationScreen(email: email),
                    );
                  }
                }

                if (settings.name == '/cooking_timer') {
                  final args = settings.arguments as Map<String, dynamic>?;
                  if (args != null) {
                    return CustomPageTransitions.slideAndFadeTransition(
                      CookingTimerScreen(
                        recipeName: args['recipeName'] ?? 'Recipe',
                        ingredients: args['ingredients'] ?? [],
                        instructions: args['instructions'] ?? [],
                        prepTime: args['prepTime'] ?? 30,
                        imageUrl: args['imageUrl'],
                        mealType: args['mealType'],
                        recipeId: args['recipeId'],
                      ),
                    );
                  }
                }

                final Widget page = _buildPage(settings.name ?? '');
                if (page != const SizedBox.shrink()) {
                  return CustomPageTransitions.slideAndFadeTransition(page);
                }
                return null;
              },
              routes: {
                '/login': (context) => const LoginScreen(),
                '/navigator': (context) => const NavigatorScreen(),
                '/birth': (context) => const BirthScreen(),
                '/current_weight': (context) => const CurrentWeightScreen(),
                '/goal_weight': (context) => const GoalWeightScreen(),
                '/obesity': (context) => const ObesityScreen(),
                '/activity': (context) => const ActivityScreen(),
                '/meal_goal': (context) => const MealGoalScreen(),
                '/loading': (context) => LoadingScreen(userData: signupData),
                '/review': (context) => const ReviewScreen(),
                '/auth_method': (context) => const AuthMethodScreen(),
                '/success': (context) => SuccessScreen(userData: signupData),
                '/home': (context) => const HomeScreen(),
                '/logs': (context) => const NutritionHistoryScreen(),
                '/meal': (context) => const MealsScreen(),
                '/stats': (context) => const DailyNutritionSummaryScreen(),
                '/settings': (context) => const SettingsScreen(),
                '/breakfast_time': (context) => const BreakfastTimeScreen(),
                '/lunch_time': (context) => const LunchTimeScreen(),
                '/dinner_time': (context) => const DinnerTimeScreen(),
                '/workout_frequency': (context) => const WorkoutFrequencyScreen(),
                '/ingredient_search': (context) => const IngredientSearchScreen(),
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPage(String routeName) {
    switch (routeName) {
      case '/login':
        return const LoginScreen();
      case '/navigator':
        return const NavigatorScreen();
      case '/birth':
        return const BirthScreen();
      case '/current_weight':
        return const CurrentWeightScreen();
      case '/goal_weight':
        return const GoalWeightScreen();
      case '/obesity':
        return const ObesityScreen();
      case '/activity':
        return const ActivityScreen();
      case '/meal_goal':
        return const MealGoalScreen();
      case '/loading':
        return LoadingScreen(userData: signupData);
      case '/review':
        return const ReviewScreen();
      case '/auth_method':
        return const AuthMethodScreen();
      case '/success':
        return SuccessScreen(userData: signupData);
      case '/home':
        return const HomeScreen();
      case '/logs':
        return const NutritionHistoryScreen();
      case '/meal':
        return const MealsScreen();
      case '/stats':
        return const DailyNutritionSummaryScreen();
      case '/settings':
        return const SettingsScreen();
      case '/breakfast_time':
        return const BreakfastTimeScreen();
      case '/lunch_time':
        return const LunchTimeScreen();
      case '/dinner_time':
        return const DinnerTimeScreen();
      case '/workout_frequency':
        return const WorkoutFrequencyScreen();
      case '/ingredient_search':
        return const IngredientSearchScreen();

      default:
        return const SizedBox.shrink();
    }
  }
}
