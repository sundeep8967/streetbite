import 'package:flutter/material.dart';

/// Animation constants and configurations for the app
class AppAnimations {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 1500);
  
  // Curve constants
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve spring = Curves.elasticInOut;
  
  // iOS-style curves
  static const Curve iosEaseInOut = Curves.easeInOut;
  static const Curve iosSpring = Curves.elasticOut;
  
  // Animation offsets
  static const Offset slideFromRight = Offset(1.0, 0.0);
  static const Offset slideFromLeft = Offset(-1.0, 0.0);
  static const Offset slideFromBottom = Offset(0.0, 1.0);
  static const Offset slideFromTop = Offset(0.0, -1.0);
  
  // Scale values
  static const double scaleMin = 0.0;
  static const double scaleNormal = 1.0;
  static const double scalePressed = 0.95;
  static const double scaleExpanded = 1.05;
}

/// Animation helper methods
class AnimationHelpers {
  /// Creates a slide transition from the specified direction
  static SlideTransition slideTransition({
    required Animation<double> animation,
    required Widget child,
    Offset begin = AppAnimations.slideFromRight,
    Offset end = Offset.zero,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimations.iosEaseInOut,
      )),
      child: child,
    );
  }
  
  /// Creates a fade transition
  static FadeTransition fadeTransition({
    required Animation<double> animation,
    required Widget child,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimations.easeInOut,
      )),
      child: child,
    );
  }
  
  /// Creates a scale transition
  static ScaleTransition scaleTransition({
    required Animation<double> animation,
    required Widget child,
    double begin = AppAnimations.scaleMin,
    double end = AppAnimations.scaleNormal,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimations.iosSpring,
      )),
      child: child,
    );
  }
}