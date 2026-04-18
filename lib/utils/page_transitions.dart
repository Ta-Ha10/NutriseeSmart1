import 'package:flutter/material.dart';

/// Custom page transition animations
class CustomPageTransitions {
  /// Slide transition - slides in from right to left
  static PageRouteBuilder slideTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Fade transition - fades in the new page
  static PageRouteBuilder fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOutQuad),
        );
        return FadeTransition(opacity: fadeAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Combined slide and fade transition
  static PageRouteBuilder slideAndFadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var slideAnimation = animation.drive(tween);

        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOutQuad),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Scale transition with rotation - bouncy effect
  static PageRouteBuilder scaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.elasticOut),
        );

        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOutQuad),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Enhanced smooth indicator with animation
class AnimatedIndicator extends StatelessWidget {
  final int activeIndex;
  final int count;
  final Duration animationDuration;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;

  const AnimatedIndicator({
    Key? key,
    required this.activeIndex,
    required this.count,
    this.animationDuration = const Duration(milliseconds: 400),
    this.activeColor = const Color(0xff13EC5B),
    this.inactiveColor = const Color(0xFFCCCCCC),
    this.dotSize = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeInOutQuad,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: dotSize,
          width: isActive ? dotSize * 2.5 : dotSize,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}

/// Enhanced progress indicator with smooth animation
class AnimatedProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Duration animationDuration;
  final Color activeColor;
  final Color inactiveColor;
  final double barHeight;
  final double barWidth;
  final double spacing;

  const AnimatedProgressBar({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.animationDuration = const Duration(milliseconds: 500),
    this.activeColor = Colors.green,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.barHeight = 3,
    this.barWidth = 12,
    this.spacing = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          bool isFilled = index < currentStep;
          return Row(
            children: [
              AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeInOutQuad,
                height: barHeight,
                width: barWidth,
                decoration: BoxDecoration(
                  color: isFilled ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(barHeight / 2),
                ),
              ),
              if (index < totalSteps - 1) SizedBox(width: spacing),
            ],
          );
        }),
      ),
    );
  }
}
