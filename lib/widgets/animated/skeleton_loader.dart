import 'package:flutter/material.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';

/// Skeleton loading animation widget
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor ?? Colors.grey.shade300,
                widget.highlightColor ?? Colors.grey.shade100,
                widget.baseColor ?? Colors.grey.shade300,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton card for loading states
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 120,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          // Image placeholder
          SkeletonLoader(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          
          const SizedBox(width: 16),
          
          // Content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 150,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 100,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton list for loading multiple items
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double? itemHeight;
  final EdgeInsetsGeometry? padding;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return SkeletonCard(height: itemHeight);
      },
    );
  }
}

/// Skeleton grid for loading grid items
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 12),
                SkeletonLoader(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 80,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}