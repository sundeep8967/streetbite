import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// Animated statistics card with counter animation
class AnimatedStatsCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final bool animateOnAppear;
  final Duration delay;

  const AnimatedStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.animateOnAppear = true,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedStatsCard> createState() => _AnimatedStatsCardState();
}

class _AnimatedStatsCardState extends State<AnimatedStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _counterController;
  late AnimationController _iconController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _counterAnimation;
  late Animation<double> _iconAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.animateOnAppear) {
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _counterController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );
    
    _iconController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.iosEaseInOut,
    ));

    _counterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOut,
    ));

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: AppAnimations.iosSpring,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.easeInOut,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(widget.delay);
    if (mounted) {
      _slideController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _iconController.forward();
        _counterController.forward();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _counterController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideAnimation,
        _counterAnimation,
        _iconAnimation,
        _fadeAnimation,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon and Title Row
                  Row(
                    children: [
                      Transform.scale(
                        scale: _iconAnimation.value,
                        child: Transform.rotate(
                          angle: _iconAnimation.value * math.pi * 2,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (widget.color ?? AppTheme.primaryOrange).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color ?? AppTheme.primaryOrange,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Animated Value
                  AnimatedBuilder(
                    animation: _counterAnimation,
                    builder: (context, child) {
                      // Try to parse as number for counter animation
                      final numericValue = double.tryParse(widget.value.replaceAll(RegExp(r'[^0-9.]'), ''));
                      final displayValue = numericValue != null
                          ? (numericValue * _counterAnimation.value).toStringAsFixed(0)
                          : widget.value;
                      
                      return Text(
                        numericValue != null ? displayValue : widget.value,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      );
                    },
                  ),
                  
                  // Subtitle
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Grid of animated stats cards
class AnimatedStatsGrid extends StatelessWidget {
  final List<AnimatedStatsCard> cards;
  final int crossAxisCount;
  final double spacing;

  const AnimatedStatsGrid({
    super.key,
    required this.cards,
    this.crossAxisCount = 2,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.2,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return AnimatedStatsCard(
          title: cards[index].title,
          value: cards[index].value,
          icon: cards[index].icon,
          color: cards[index].color,
          subtitle: cards[index].subtitle,
          delay: Duration(milliseconds: 100 * index),
        );
      },
    );
  }
}