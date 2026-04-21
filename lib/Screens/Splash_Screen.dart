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
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _logoScaleAnimation = Tween<double>(
      begin: 0.78,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoRotationAnimation = Tween<double>(
      begin: -0.08,
      end: 0,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _startAnimation();
  }

  // Updated: navigate to login after animations finish.
  Future<void> _startAnimation() async {
    await _logoController.forward();

    // small pause so user sees full splash
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
   Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F7F1), Color(0xFFF2EFE8)],
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _logoController,
              child: SlideTransition(
                position: _logoSlideAnimation,
                child: Hero(
                  tag: 'app-logo',
                  child: AnimatedBuilder(
                    animation: _logoController,
                    child: const _LogoLoader(height: 350),
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _logoRotationAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: child,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Updated: load a PNG asset and fall back to an icon if loading fails.
class _LogoLoader extends StatelessWidget {
  final double height;

  const _LogoLoader({
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height,
      child: Image.asset(
        'assets/S_logo.png',
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
