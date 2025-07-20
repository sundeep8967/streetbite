import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// iOS-style animated card with hover and tap effects
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool enableHoverEffect;
  final bool enableTapEffect;
  final double? width;
  final double? height;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.enableHoverEffect = true,
    this.enableTapEffect = true,
    this.width,
    this.height,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _elevationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _elevationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: AppAnimations.scaleNormal,
      end: AppAnimations.scalePressed,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: AppAnimations.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableTapEffect && widget.onTap != null) {
      setState(() => _isPressed = true);
      HapticFeedback.lightImpact();
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableTapEffect) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableTapEffect) {
      setState(() => _isPressed = false);
      _scaleController.reverse();
    }
  }

  void _onHoverEnter(PointerEnterEvent event) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = true);
      _elevationController.forward();
    }
  }

  void _onHoverExit(PointerExitEvent event) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = false);
      _elevationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
      builder: (context, child) {
        final elevationFactor = _elevationAnimation.value;
        final shadowOpacity = 0.1 + (elevationFactor * 0.1);
        final shadowBlur = 10 + (elevationFactor * 10);
        final shadowOffset = Offset(0, 2 + (elevationFactor * 6));

        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: _onHoverEnter,
            onExit: _onHoverExit,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: AppAnimations.medium,
                curve: AppAnimations.easeOut,
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                padding: widget.padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppTheme.surfaceLight,
                  borderRadius: widget.borderRadius ?? 
                      BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: widget.boxShadow ?? [
                    BoxShadow(
                      color: Colors.black.withOpacity(shadowOpacity),
                      blurRadius: shadowBlur,
                      offset: shadowOffset,
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Hero animated card for navigation transitions
class HeroAnimatedCard extends StatelessWidget {
  final String heroTag;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const HeroAnimatedCard({
    super.key,
    required this.heroTag,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: AnimatedCard(
          onTap: onTap,
          margin: margin,
          padding: padding,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          child: child,
        ),
      ),
    );
  }
}