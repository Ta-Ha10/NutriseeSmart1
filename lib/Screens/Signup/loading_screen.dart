import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../services/firestore_service.dart';
import '../../utils/user_data.dart';
import 'success_screen.dart';

class LoadingScreen extends StatefulWidget {
  final UserData userData;

  const LoadingScreen({super.key, required this.userData});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController1;
  late AnimationController _animationController2;
  late AnimationController _animationController3;
  late Animation<Offset> _offsetAnimation1;
  late Animation<Offset> _offsetAnimation2;
  late Animation<Offset> _offsetAnimation3;

  @override
  void initState() {
    super.initState();

    // Animation 1 - BMI (bottom to top)
    _animationController1 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _offsetAnimation1 =
        Tween<Offset>(
          begin: const Offset(-0.3, 1.5),
          end: const Offset(-0.3, -1.5),
        ).animate(
          CurvedAnimation(
            parent: _animationController1,
            curve: Curves.easeInOut,
          ),
        );

    // Animation 2 - BMR (bottom to top)
    _animationController2 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _offsetAnimation2 =
        Tween<Offset>(
          begin: const Offset(0.2, 1.5),
          end: const Offset(0.2, -1.5),
        ).animate(
          CurvedAnimation(
            parent: _animationController2,
            curve: Curves.easeInOut,
          ),
        );

    // Animation 3 - TDEE (bottom to top)
    _animationController3 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _offsetAnimation3 =
        Tween<Offset>(
          begin: const Offset(0.7, 1.5),
          end: const Offset(0.7, -1.5),
        ).animate(
          CurvedAnimation(
            parent: _animationController3,
            curve: Curves.easeInOut,
          ),
        );

    _performCalculationAndSave();
  }

  @override
  void dispose() {
    _animationController1.dispose();
    _animationController2.dispose();
    _animationController3.dispose();
    super.dispose();
  }

  Future<void> _performCalculationAndSave() async {
    widget.userData.calculateMetrics();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirestoreService.saveUserData(widget.userData);
      } catch (error) {
        // Logging or error handling can be added here if needed.
      }
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Center(
                  child: LoadingAnimationWidget.threeRotatingDots(
                    color: Colors.green,
                    size: 200,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Let's do some Calculation...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
