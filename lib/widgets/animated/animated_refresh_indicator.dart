import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// Custom animated refresh indicator with iOS-style pull-to-refresh
class AnimatedRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;

  const AnimatedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
  });

  @override
  State<AnimatedRefreshIndicator> createState() => _AnimatedRefreshIndicatorState();
}

class _AnimatedRefreshIndicatorState extends State<AnimatedRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.iosSpring,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _scaleController.forward();
        _rotationController.repeat();
        _bounceController.forward();
        
        try {
          await widget.onRefresh();
        } finally {
          _rotationController.stop();
          _scaleController.reverse();
          _bounceController.reverse();
        }
      },
      displacement: widget.displacement,
      color: widget.color ?? AppTheme.primaryOrange,
      backgroundColor: widget.backgroundColor ?? Colors.white,
      child: widget.child,
      // Custom refresh indicator builder
      builder: (context, child) {
        return Stack(
          children: [
            child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleAnimation,
                  _rotationAnimation,
                  _bounceAnimation,
                ]),
                builder: (context, child) {
                  if (_scaleAnimation.value == 0.0) {
                    return const SizedBox.shrink();
                  }
                  
                  return Transform.translate(
                    offset: Offset(0, widget.displacement * _bounceAnimation.value),
                    child: Center(
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _buildCustomIndicator(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomIndicator() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: _rotationAnimation.value,
          child: Icon(
            Icons.refresh,
            color: widget.color ?? AppTheme.primaryOrange,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Sliver version of the animated refresh indicator
class SliverAnimatedRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Color? color;

  const SliverAnimatedRefreshIndicator({
    super.key,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
      builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
        return _buildSliverIndicator(
          refreshState,
          pulledExtent,
          refreshTriggerPullDistance,
          refreshIndicatorExtent,
        );
      },
    );
  }

  Widget _buildSliverIndicator(
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    final double percentageComplete = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
    
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 16.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: _buildIndicatorContent(refreshState, percentageComplete),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorContent(RefreshIndicatorMode refreshState, double percentageComplete) {
    switch (refreshState) {
      case RefreshIndicatorMode.drag:
        return Transform.rotate(
          angle: percentageComplete * math.pi * 2,
          child: Icon(
            Icons.arrow_downward,
            color: color ?? AppTheme.primaryOrange,
            size: 20,
          ),
        );
      case RefreshIndicatorMode.armed:
        return Icon(
          Icons.refresh,
          color: color ?? AppTheme.primaryOrange,
          size: 20,
        );
      case RefreshIndicatorMode.refresh:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryOrange,
            ),
          ),
        );
      case RefreshIndicatorMode.done:
        return Icon(
          Icons.check,
          color: AppTheme.iosGreen,
          size: 20,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}