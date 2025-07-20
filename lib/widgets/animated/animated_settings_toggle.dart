import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// iOS-style animated settings toggle with smooth transitions
class AnimatedSettingsToggle extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enabled;

  const AnimatedSettingsToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.icon,
    this.activeColor,
    this.inactiveColor,
    this.enabled = true,
  });

  @override
  State<AnimatedSettingsToggle> createState() => _AnimatedSettingsToggleState();
}

class _AnimatedSettingsToggleState extends State<AnimatedSettingsToggle>
    with TickerProviderStateMixin {
  late AnimationController _toggleController;
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  
  late Animation<double> _toggleAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _thumbColorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _toggleController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _toggleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _toggleController,
      curve: AppAnimations.iosSpring,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor ?? Colors.grey.shade300,
      end: widget.activeColor ?? AppTheme.iosGreen,
    ).animate(CurvedAnimation(
      parent: _toggleController,
      curve: AppAnimations.easeInOut,
    ));

    _thumbColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.white,
    ).animate(_toggleController);

    // Set initial state
    if (widget.value) {
      _toggleController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedSettingsToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _toggleController.forward();
      } else {
        _toggleController.reverse();
      }
      _startRippleAnimation();
    }
  }

  void _startRippleAnimation() {
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  @override
  void dispose() {
    _toggleController.dispose();
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    
    HapticFeedback.lightImpact();
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _toggleAnimation,
        _scaleAnimation,
        _rippleAnimation,
        _colorAnimation,
        _thumbColorAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  // Icon
                  if (widget.icon != null) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: (_colorAnimation.value ?? Colors.grey).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 18,
                        color: _colorAnimation.value ?? Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: widget.enabled ? AppTheme.textPrimary : AppTheme.textTertiary,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: widget.enabled ? AppTheme.textSecondary : AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Animated Toggle Switch
                  Stack(
                    children: [
                      // Ripple Effect
                      if (_rippleAnimation.value > 0)
                        Container(
                          width: 60,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CustomPaint(
                            painter: RipplePainter(
                              animation: _rippleAnimation,
                              color: _colorAnimation.value ?? Colors.grey,
                            ),
                          ),
                        ),
                      
                      // Toggle Track
                      Container(
                        width: 52,
                        height: 32,
                        decoration: BoxDecoration(
                          color: widget.enabled 
                              ? _colorAnimation.value 
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      
                      // Toggle Thumb
                      AnimatedPositioned(
                        duration: AppAnimations.medium,
                        curve: AppAnimations.iosSpring,
                        left: widget.value ? 22 : 2,
                        top: 2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _thumbColorAnimation.value,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

/// Custom painter for ripple effect
class RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  RipplePainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * animation.value;
    
    final paint = Paint()
      ..color = color.withOpacity(0.3 * (1 - animation.value))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}