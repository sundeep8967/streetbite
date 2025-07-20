import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// Success animation widget with checkmark and celebration
class SuccessAnimation extends StatefulWidget {
  final String message;
  final VoidCallback? onComplete;
  final Duration duration;
  final Color? color;

  const SuccessAnimation({
    super.key,
    required this.message,
    this.onComplete,
    this.duration = const Duration(milliseconds: 2000),
    this.color,
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _celebrationController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimation();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.iosSpring,
    ));

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    ));

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimation() async {
    HapticFeedback.mediumImpact();
    
    // Scale in the circle
    await _scaleController.forward();
    
    // Draw the checkmark
    await _checkController.forward();
    
    // Celebration particles
    _celebrationController.forward();
    
    // Complete after duration
    await Future.delayed(widget.duration);
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Circle with Checkmark
          AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimation,
              _checkAnimation,
              _celebrationAnimation,
            ]),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Celebration particles
                  if (_celebrationAnimation.value > 0)
                    ...List.generate(8, (index) {
                      final angle = (index * math.pi * 2) / 8;
                      final distance = 60 * _celebrationAnimation.value;
                      final x = math.cos(angle) * distance;
                      final y = math.sin(angle) * distance;
                      
                      return Transform.translate(
                        offset: Offset(x, y),
                        child: Opacity(
                          opacity: 1 - _celebrationAnimation.value,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: widget.color ?? AppTheme.iosGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  
                  // Success Circle
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.color ?? AppTheme.iosGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.color ?? AppTheme.iosGreen).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: CheckmarkPainter(
                          progress: _checkAnimation.value,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Success Message
          Text(
            widget.message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate()
           .fadeIn(delay: AppAnimations.medium, duration: AppAnimations.medium)
           .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}

/// Custom painter for animated checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final checkPath = Path();
    
    // Define checkmark points
    final startPoint = Offset(center.dx - 12, center.dy);
    final middlePoint = Offset(center.dx - 4, center.dy + 8);
    final endPoint = Offset(center.dx + 12, center.dy - 8);
    
    if (progress <= 0.5) {
      // First half: draw from start to middle
      final t = progress * 2;
      final currentPoint = Offset.lerp(startPoint, middlePoint, t)!;
      checkPath.moveTo(startPoint.dx, startPoint.dy);
      checkPath.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // Second half: draw from middle to end
      final t = (progress - 0.5) * 2;
      final currentPoint = Offset.lerp(middlePoint, endPoint, t)!;
      checkPath.moveTo(startPoint.dx, startPoint.dy);
      checkPath.lineTo(middlePoint.dx, middlePoint.dy);
      checkPath.lineTo(currentPoint.dx, currentPoint.dy);
    }
    
    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Error animation widget
class ErrorAnimation extends StatefulWidget {
  final String message;
  final VoidCallback? onComplete;
  final Duration duration;

  const ErrorAnimation({
    super.key,
    required this.message,
    this.onComplete,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<ErrorAnimation> createState() => _ErrorAnimationState();
}

class _ErrorAnimationState extends State<ErrorAnimation>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _scaleController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimation();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.iosSpring,
    ));
  }

  void _startAnimation() async {
    HapticFeedback.heavyImpact();
    
    await _scaleController.forward();
    await _shakeController.forward();
    
    await Future.delayed(widget.duration);
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_shakeAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  math.sin(_shakeAnimation.value * math.pi * 4) * 10,
                  0,
                ),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.iosRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.iosRed.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            widget.message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate()
           .fadeIn(delay: AppAnimations.medium, duration: AppAnimations.medium)
           .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}