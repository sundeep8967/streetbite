import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// iOS-style animated bottom navigation bar
class AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<AnimatedBottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _bounceAnimations;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: AppAnimations.medium,
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: AppAnimations.iosSpring,
      ));
    }).toList();

    _bounceAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();

    _backgroundController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: AppAnimations.easeInOut,
    ));

    // Animate the initially selected item
    _controllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(AnimatedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateToIndex(widget.currentIndex, oldWidget.currentIndex);
    }
  }

  void _animateToIndex(int newIndex, int oldIndex) {
    // Animate out the old item
    _controllers[oldIndex].reverse();
    
    // Animate in the new item
    _controllers[newIndex].forward();
    
    // Background pulse animation
    _backgroundController.forward().then((_) {
      _backgroundController.reverse();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1 + (_backgroundAnimation.value * 0.05)),
                blurRadius: 10 + (_backgroundAnimation.value * 5),
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(widget.items.length, (index) {
                  return _buildNavItem(index);
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];
    final isSelected = index == widget.currentIndex;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimations[index],
        _bounceAnimations[index],
      ]),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap(index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? (widget.selectedItemColor ?? AppTheme.primaryOrange).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: _scaleAnimations[index].value,
                  child: Transform.translate(
                    offset: Offset(0, -2 * _bounceAnimations[index].value),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected
                          ? (widget.selectedItemColor ?? AppTheme.primaryOrange)
                          : (widget.unselectedItemColor ?? AppTheme.textSecondary),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: AppAnimations.fast,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? (widget.selectedItemColor ?? AppTheme.primaryOrange)
                        : (widget.unselectedItemColor ?? AppTheme.textSecondary),
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bottom navigation item model
class AnimatedBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const AnimatedBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}