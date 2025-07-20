import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// Animated status toggle switch with iOS-style animations
class AnimatedStatusToggle extends StatefulWidget {
  final bool isOpen;
  final Function(bool) onToggle;
  final String openText;
  final String closedText;
  final Color? activeColor;
  final Color? inactiveColor;

  const AnimatedStatusToggle({
    super.key,
    required this.isOpen,
    required this.onToggle,
    this.openText = 'OPEN',
    this.closedText = 'CLOSED',
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<AnimatedStatusToggle> createState() => _AnimatedStatusToggleState();
}

class _AnimatedStatusToggleState extends State<AnimatedStatusToggle>
    with TickerProviderStateMixin {
  late AnimationController _toggleController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  
  late Animation<double> _toggleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

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
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _toggleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _toggleController,
      curve: AppAnimations.iosSpring,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor ?? AppTheme.iosRed,
      end: widget.activeColor ?? AppTheme.iosGreen,
    ).animate(CurvedAnimation(
      parent: _toggleController,
      curve: AppAnimations.easeInOut,
    ));

    // Set initial state
    if (widget.isOpen) {
      _toggleController.value = 1.0;
      _startPulseAnimation();
    }
  }

  void _startPulseAnimation() {
    if (widget.isOpen) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void didUpdateWidget(AnimatedStatusToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOpen != widget.isOpen) {
      if (widget.isOpen) {
        _toggleController.forward();
        _startPulseAnimation();
      } else {
        _toggleController.reverse();
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _toggleController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onToggle(!widget.isOpen);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _toggleAnimation,
        _pulseAnimation,
        _scaleAnimation,
        _colorAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: 160,
              height: 60,
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: (_colorAnimation.value ?? Colors.grey).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background glow effect
                  if (widget.isOpen)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Toggle indicator
                  AnimatedPositioned(
                    duration: AppAnimations.medium,
                    curve: AppAnimations.iosSpring,
                    left: widget.isOpen ? 100 : 4,
                    top: 4,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isOpen ? Icons.store : Icons.store_mall_directory_outlined,
                        color: _colorAnimation.value,
                        size: 24,
                      ),
                    ),
                  ),
                  
                  // Text labels
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedOpacity(
                            duration: AppAnimations.fast,
                            opacity: widget.isOpen ? 0.0 : 1.0,
                            child: Center(
                              child: Text(
                                widget.closedText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AnimatedOpacity(
                            duration: AppAnimations.fast,
                            opacity: widget.isOpen ? 1.0 : 0.0,
                            child: Center(
                              child: Text(
                                widget.openText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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