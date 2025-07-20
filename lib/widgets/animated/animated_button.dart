import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// iOS-style animated button with micro interactions
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _loadingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _loadingController = AnimationController(
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

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: AppAnimations.easeInOut,
    ));

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
        _loadingController.reset();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      HapticFeedback.lightImpact();
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.isEnabled && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: isEnabled ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: AppAnimations.medium,
              curve: AppAnimations.easeInOut,
              width: widget.width,
              height: widget.height ?? 48,
              padding: widget.padding ?? 
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isEnabled
                    ? (widget.backgroundColor ?? AppTheme.primaryOrange)
                    : AppTheme.textTertiary,
                borderRadius: widget.borderRadius ?? 
                    BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: isEnabled ? AppTheme.buttonShadow : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.textColor ?? Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.textColor ?? Colors.white,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: widget.textColor ?? Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Outlined version of the animated button
class AnimatedOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;

  const AnimatedOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.borderColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? AppTheme.primaryOrange,
      icon: icon,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
    );
  }
}