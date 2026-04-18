import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _taglineController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _startAnimation();
  }

  // Updated: navigate to login after animations finish.
  Future<void> _startAnimation() async {
    await _logoController.forward();
    await _textController.forward();
    await _taglineController.forward();

    // small pause so user sees full splash
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LOGO + APP NAME & TAGLINE
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// LOGO
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _logoController,
                      curve: Curves.easeOutBack,
                    ),
                    child: const _LogoLoader(height: 90),
                  ),

                  const SizedBox(width: 12),

                  /// APP NAME & TAGLINE
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// APP NAME
                      FadeTransition(
                        opacity: _textController,
                        child: const Text(
                          'NutriSeseSmart',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// TAGLINE
                      FadeTransition(
                        opacity: _taglineController,
                        child: const Text(
                          '\t\t\t\t\t\t\t\t\t\t\tPersonalized for You',
                          textAlign: TextAlign.center,

                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Email TextField
              // Password TextField
              // Login Button
            ],
          ),
        ),
      ),
    );
  }
}

// Updated: load a PNG asset and fall back to an icon if loading fails.
class _LogoLoader extends StatelessWidget {
  final double height;
  final String assetPath;

  const _LogoLoader({
    this.height = 90,
    this.assetPath = 'assets/logo.png',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height,
      child: Image.asset(
        assetPath,
        height: height,
        width: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: height,
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: height / 2,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.restaurant,
                size: height * 0.5,
                color: Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}
