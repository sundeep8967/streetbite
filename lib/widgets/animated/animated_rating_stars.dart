import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// Animated star rating widget with haptic feedback
class AnimatedRatingStars extends StatefulWidget {
  final double rating;
  final Function(double)? onRatingChanged;
  final int starCount;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool allowHalfRating;
  final bool isInteractive;
  final MainAxisAlignment alignment;

  const AnimatedRatingStars({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.starCount = 5,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = true,
    this.isInteractive = true,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  State<AnimatedRatingStars> createState() => _AnimatedRatingStarsState();
}

class _AnimatedRatingStarsState extends State<AnimatedRatingStars>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  
  double _currentRating = 0;
  int _hoveredStar = -1;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _initializeAnimations();
    _startInitialAnimation();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.starCount,
      (index) => AnimationController(
        duration: AppAnimations.medium,
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: AppAnimations.iosSpring,
      ));
    }).toList();

    _rotationAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  void _startInitialAnimation() async {
    for (int i = 0; i < widget.starCount; i++) {
      await Future.delayed(Duration(milliseconds: 100 * i));
      if (mounted) {
        _controllers[i].forward();
      }
    }
    
    // Start shimmer for filled stars
    if (_currentRating > 0) {
      _shimmerController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedRatingStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      _updateRating(widget.rating);
    }
  }

  void _updateRating(double newRating) {
    setState(() {
      _currentRating = newRating;
    });
    
    // Animate stars based on new rating
    for (int i = 0; i < widget.starCount; i++) {
      if (i < newRating) {
        _controllers[i].forward();
      } else {
        _controllers[i].reverse();
      }
    }
    
    // Control shimmer
    if (newRating > 0) {
      _shimmerController.repeat(reverse: true);
    } else {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleStarTap(int starIndex) {
    if (!widget.isInteractive) return;
    
    HapticFeedback.lightImpact();
    
    double newRating;
    if (widget.allowHalfRating) {
      // Toggle between half and full rating
      if (_currentRating == starIndex + 0.5) {
        newRating = starIndex + 1.0;
      } else if (_currentRating == starIndex + 1.0) {
        newRating = starIndex.toDouble();
      } else {
        newRating = starIndex + 1.0;
      }
    } else {
      newRating = starIndex + 1.0;
    }
    
    newRating = newRating.clamp(0.0, widget.starCount.toDouble());
    
    _updateRating(newRating);
    widget.onRatingChanged?.call(newRating);
    
    // Bounce animation for tapped star
    _controllers[starIndex].reverse().then((_) {
      _controllers[starIndex].forward();
    });
  }

  void _handleStarHover(int starIndex) {
    if (!widget.isInteractive) return;
    
    setState(() {
      _hoveredStar = starIndex;
    });
  }

  void _handleHoverExit() {
    setState(() {
      _hoveredStar = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.alignment,
      children: List.generate(widget.starCount, (index) {
        return _buildAnimatedStar(index);
      }),
    );
  }

  Widget _buildAnimatedStar(int index) {
    final isActive = index < _currentRating;
    final isHalfActive = widget.allowHalfRating && 
                        index < _currentRating && 
                        index >= _currentRating - 1 && 
                        _currentRating % 1 != 0;
    final isHovered = _hoveredStar == index;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimations[index],
        _rotationAnimations[index],
        _shimmerAnimation,
      ]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _handleStarHover(index),
          onExit: (_) => _handleHoverExit(),
          child: GestureDetector(
            onTap: () => _handleStarTap(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Transform.scale(
                scale: _scaleAnimations[index].value * (isHovered ? 1.2 : 1.0),
                child: Transform.rotate(
                  angle: _rotationAnimations[index].value * math.pi * 2,
                  child: Stack(
                    children: [
                      // Background star
                      Icon(
                        Icons.star,
                        size: widget.size,
                        color: widget.inactiveColor ?? Colors.grey.shade300,
                      ),
                      
                      // Foreground star with shimmer
                      if (isActive || isHalfActive)
                        ShaderMask(
                          shaderCallback: (bounds) {
                            if (isActive && _shimmerAnimation.value > 0) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: [
                                  (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                                  _shimmerAnimation.value.clamp(0.0, 1.0),
                                  (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                                ],
                              ).createShader(bounds);
                            }
                            return const LinearGradient(
                              colors: [Colors.transparent, Colors.transparent],
                            ).createShader(bounds);
                          },
                          child: ClipPath(
                            clipper: isHalfActive 
                                ? HalfStarClipper() 
                                : null,
                            child: Icon(
                              Icons.star,
                              size: widget.size,
                              color: widget.activeColor ?? AppTheme.iosYellow,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom clipper for half stars
class HalfStarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width / 2, size.height));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Compact rating display widget
class CompactRatingDisplay extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;
  final Color? color;

  const CompactRatingDisplay({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: size,
          color: color ?? AppTheme.iosYellow,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.8,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.7,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}