import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/vendor_model.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';
import 'animated_card.dart';

/// Animated vendor card with hero animation support
class AnimatedVendorCard extends StatefulWidget {
  final VendorModel vendor;
  final VoidCallback? onTap;
  final bool enableHeroAnimation;
  final EdgeInsetsGeometry? margin;

  const AnimatedVendorCard({
    super.key,
    required this.vendor,
    this.onTap,
    this.enableHeroAnimation = true,
    this.margin,
  });

  @override
  State<AnimatedVendorCard> createState() => _AnimatedVendorCardState();
}

class _AnimatedVendorCardState extends State<AnimatedVendorCard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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

    if (!_imageLoaded) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _onImageLoaded() {
    if (mounted && !_imageLoaded) {
      setState(() => _imageLoaded = true);
      _shimmerController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = AnimatedCard(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.zero,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vendor Image with Shimmer Effect
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusMedium),
            ),
            child: Container(
              height: 180,
              width: double.infinity,
              child: Stack(
                children: [
                  // Image
                  if (widget.vendor.imageUrl != null)
                    Image.network(
                      widget.vendor.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          _onImageLoaded();
                          return child;
                        }
                        return _buildShimmerPlaceholder();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        _onImageLoaded();
                        return _buildImagePlaceholder();
                      },
                    )
                  else
                    _buildImagePlaceholder(),
                  
                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildStatusBadge(),
                  ),
                  
                  // Distance Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _buildDistanceBadge(),
                  ),
                ],
              ),
            ),
          ),
          
          // Vendor Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vendor Name and Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.vendor.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildRatingWidget(),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Cuisine Type
                Text(
                  widget.vendor.cuisineType,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Address
                if (widget.vendor.address != null)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.vendor.address!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    // Wrap with Hero animation if enabled
    if (widget.enableHeroAnimation) {
      return Hero(
        tag: 'vendor_${widget.vendor.id}',
        child: Material(
          color: Colors.transparent,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  Widget _buildShimmerPlaceholder() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.backgroundLight,
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 48,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isOpen = widget.vendor.status == VendorStatus.open;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? AppTheme.iosGreen : AppTheme.iosRed,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        isOpen ? 'OPEN' : 'CLOSED',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDistanceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '2.5 km', // TODO: Calculate actual distance
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRatingWidget() {
    final rating = widget.vendor.averageRating;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.iosYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: AppTheme.iosYellow,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}