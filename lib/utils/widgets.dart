import 'package:flutter/material.dart';
import 'page_transitions.dart';
import '../l10n/app_locale.dart';

/// Reusable header with animated indicator and back button
class IndicatorHeader extends StatelessWidget {
  final int activeIndex;
  final int totalCount;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const IndicatorHeader({
    super.key,
    required this.activeIndex,
    this.totalCount = 10,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (showBackButton)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: scheme.onSurface,
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
          activeColor: scheme.primary,
          inactiveColor: scheme.outlineVariant,
          dotSize: 10.0,
        ),
        const Spacer(),
        IconButton(
          tooltip: AppLocaleController.isArabic() ? '\u062A\u063A\u064A\u064A\u0631 \u0627\u0644\u0644\u063A\u0629' : 'Change language',
          icon: const Icon(Icons.language),
          color: scheme.onSurface,
          onPressed: () => AppLocaleController.setArabicEnabled(
            !AppLocaleController.isArabic(),
          ),
        ),
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
    super.key,
    required this.onPressed,
    this.label = 'Next',
    this.width = double.infinity,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: scheme.onPrimary,
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
    final scheme = Theme.of(context).colorScheme;

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
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onHelpPressed,
                    child: Icon(
                      Icons.help_outline,
                      size: 16,
                      color: scheme.onSurfaceVariant,
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

