import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'page_transitions.dart';

/// Reusable header with animated indicator and back button
class IndicatorHeader extends StatelessWidget {
  final int activeIndex;
  final int totalCount;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const IndicatorHeader({
    Key? key,
    required this.activeIndex,
    this.totalCount = 10,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
            iconSize: 28,
            onPressed: onBackPressed ?? () => Navigator.pop(context),
          )
        else
          const SizedBox(width: 48),
        const Spacer(),
        AnimatedIndicator(
          activeIndex: activeIndex,
          count: totalCount,
          animationDuration: const Duration(milliseconds: 400),
          activeColor: const Color(0xff13EC5B),
          inactiveColor: const Color(0xFFCCCCCC),
          dotSize: 10.0,
        ),
        const Spacer(),
        Gap(30)
      ],
    );
  }
}

/// Standardized Next button
class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final double width;
  final double height;

  const NextButton({
    Key? key,
    required this.onPressed,
    this.label = 'Next',
    this.width = double.infinity,
    this.height = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff13EC5B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
