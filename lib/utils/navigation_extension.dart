import 'package:flutter/material.dart';

/// Extension for easier navigation with custom transitions
extension NavigationExtension on NavigatorState {
  /// Push a named route with custom page transition
  Future<T?> pushNamedWithTransition<T>(
    String routeName, {
    Object? arguments,
    PageTransitionType type = PageTransitionType.slideAndFade,
  }) {
    // Note: This uses pushNamed internally, which will use onGenerateRoute
    // The onGenerateRoute in main.dart will apply the transition
    return pushNamed<T>(routeName, arguments: arguments);
  }
}

enum PageTransitionType {
  slide,
  fade,
  slideAndFade,
  scale,
}
