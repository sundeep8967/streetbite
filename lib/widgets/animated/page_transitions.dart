import 'package:flutter/material.dart';
import '../../constants/app_animations.dart';

/// Custom page route with iOS-style transitions
class IOSPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String? routeName;

  IOSPageRoute({
    required this.child,
    this.routeName,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: AppAnimations.slideFromRight,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppAnimations.iosEaseInOut,
              )),
              child: child,
            );
          },
          transitionDuration: AppAnimations.medium,
          reverseTransitionDuration: AppAnimations.medium,
        );
}

/// Fade transition page route
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  FadePageRoute({
    required this.child,
    this.duration = AppAnimations.medium,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppAnimations.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: duration,
        );
}

/// Scale transition page route
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  ScalePageRoute({
    required this.child,
    this.duration = AppAnimations.medium,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppAnimations.iosSpring,
              )),
              child: child,
            );
          },
          transitionDuration: duration,
        );
}

/// Bottom sheet style transition
class BottomSheetPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  BottomSheetPageRoute({
    required this.child,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: AppAnimations.slideFromBottom,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppAnimations.iosEaseInOut,
              )),
              child: child,
            );
          },
          transitionDuration: AppAnimations.medium,
        );
}

/// Navigation helper methods
class NavigationHelper {
  /// Navigate with iOS-style slide transition
  static Future<T?> pushIOS<T>(
    BuildContext context,
    Widget page, {
    String? routeName,
  }) {
    return Navigator.of(context).push<T>(
      IOSPageRoute<T>(
        child: page,
        routeName: routeName,
      ),
    );
  }

  /// Navigate with fade transition
  static Future<T?> pushFade<T>(
    BuildContext context,
    Widget page, {
    Duration duration = AppAnimations.medium,
  }) {
    return Navigator.of(context).push<T>(
      FadePageRoute<T>(
        child: page,
        duration: duration,
      ),
    );
  }

  /// Navigate with scale transition
  static Future<T?> pushScale<T>(
    BuildContext context,
    Widget page, {
    Duration duration = AppAnimations.medium,
  }) {
    return Navigator.of(context).push<T>(
      ScalePageRoute<T>(
        child: page,
        duration: duration,
      ),
    );
  }

  /// Navigate with bottom sheet transition
  static Future<T?> pushBottomSheet<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      BottomSheetPageRoute<T>(child: page),
    );
  }

  /// Replace current route with iOS transition
  static Future<T?> pushReplacementIOS<T, TO>(
    BuildContext context,
    Widget page, {
    TO? result,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      IOSPageRoute<T>(child: page),
      result: result,
    );
  }
}