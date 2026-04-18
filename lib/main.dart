import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Screens/Login/login_screen.dart';
import 'Screens/Signup/activity_screen.dart';
import 'Screens/Signup/auth_method_screen.dart';
import 'Screens/Signup/birth_screen.dart';
import 'Screens/Signup/breakfast_time_screen.dart';
import 'Screens/Signup/current_weight_screen.dart' show CurrentWeightScreen;
import 'Screens/Signup/dinner_time_screen.dart';
import 'Screens/Signup/goal_weight_screen.dart';
import 'Screens/Signup/ingredient_search_screen.dart';
import 'Screens/Signup/loading_screen.dart';
import 'Screens/Signup/lunch_time_screen.dart';
import 'Screens/Signup/meal_goal_screen.dart';
import 'Screens/Signup/navigator.dart';
import 'Screens/Signup/obesity_screen.dart';
import 'Screens/Signup/review_screen.dart';
import 'Screens/Signup/success_screen.dart';
import 'Screens/Signup/workout_frequency_screen.dart';
import 'Screens/Splash_Screen.dart';
import 'firebase_options.dart';
import 'main/home_screen.dart';
import 'utils/page_transitions.dart';
import 'utils/user_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriSeseSmart',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: const Color(0xffF2EDE9),
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      // Open SplashScreen first
      home: SplashScreen(), // changed from NameInputScreen to SplashScreen
      onGenerateRoute: (settings) {
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
        '/success': (context) => const SuccessScreen(),
        '/home': (context) => const HomeScreen(),
        '/breakfast_time': (context) => const BreakfastTimeScreen(),
        '/lunch_time': (context) => const LunchTimeScreen(),
        '/dinner_time': (context) => const DinnerTimeScreen(),
        '/workout_frequency': (context) => const WorkoutFrequencyScreen(),
        '/ingredient_search': (context) => const IngredientSearchScreen(),
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
        return const SuccessScreen();
      case '/home':
        return const HomeScreen();
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
