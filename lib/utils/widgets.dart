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

class SignupStepBody extends StatelessWidget {
  final int activeIndex;
  final int totalCount;
  final Widget title;
  final Widget content;
  final Widget bottomAction;
  final VoidCallback? onBackPressed;
  final VoidCallback? onHelpPressed;
  final String helperText;
  final bool centerTitle;

  const SignupStepBody({
    super.key,
    required this.activeIndex,
    required this.title,
    required this.content,
    required this.bottomAction,
    this.totalCount = 13,
    this.onBackPressed,
    this.onHelpPressed,
    this.helperText = 'Behind the question',
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 16),
        child: Column(
          children: [
            IndicatorHeader(
              activeIndex: activeIndex,
              totalCount: totalCount,
              onBackPressed: onBackPressed,
            ),
            const SizedBox(height: 26),
            Align(
              alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
              child: title,
            ),
            const SizedBox(height: 14),
            if (onHelpPressed != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    helperText,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onHelpPressed,
                    child: Icon(
                      Icons.help_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            if (onHelpPressed != null) const SizedBox(height: 26),
            Expanded(child: content),
            const SizedBox(height: 18),
            bottomAction,
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
