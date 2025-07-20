import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/menu_item_model.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';
import 'animated_card.dart';

/// Animated menu item card with slide and swipe animations
class AnimatedMenuItemCard extends StatefulWidget {
  final MenuItemModel menuItem;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleAvailability;
  final bool enableSwipeActions;
  final EdgeInsetsGeometry? margin;
  final int index;

  const AnimatedMenuItemCard({
    super.key,
    required this.menuItem,
    this.onEdit,
    this.onDelete,
    this.onToggleAvailability,
    this.enableSwipeActions = true,
    this.margin,
    this.index = 0,
  });

  @override
  State<AnimatedMenuItemCard> createState() => _AnimatedMenuItemCardState();
}

class _AnimatedMenuItemCardState extends State<AnimatedMenuItemCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _swipeController;
  late AnimationController _availabilityController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _swipeAnimation;
  late Animation<double> _availabilityAnimation;
  late Animation<Color?> _availabilityColorAnimation;

  bool _isSwipeRevealed = false;
  double _swipeOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntranceAnimation();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _swipeController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    
    _availabilityController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.iosEaseInOut,
    ));

    _swipeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: AppAnimations.easeInOut,
    ));

    _availabilityAnimation = Tween<double>(
      begin: widget.menuItem.isAvailable ? 1.0 : 0.5,
      end: widget.menuItem.isAvailable ? 1.0 : 0.5,
    ).animate(CurvedAnimation(
      parent: _availabilityController,
      curve: AppAnimations.easeInOut,
    ));

    _availabilityColorAnimation = ColorTween(
      begin: widget.menuItem.isAvailable ? Colors.transparent : Colors.grey.withOpacity(0.3),
      end: widget.menuItem.isAvailable ? Colors.transparent : Colors.grey.withOpacity(0.3),
    ).animate(_availabilityController);
  }

  void _startEntranceAnimation() async {
    await Future.delayed(Duration(milliseconds: 50 * widget.index));
    if (mounted) {
      _slideController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedMenuItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.menuItem.isAvailable != widget.menuItem.isAvailable) {
      _updateAvailabilityAnimation();
    }
  }

  void _updateAvailabilityAnimation() {
    _availabilityAnimation = Tween<double>(
      begin: _availabilityAnimation.value,
      end: widget.menuItem.isAvailable ? 1.0 : 0.5,
    ).animate(CurvedAnimation(
      parent: _availabilityController,
      curve: AppAnimations.easeInOut,
    ));

    _availabilityColorAnimation = ColorTween(
      begin: _availabilityColorAnimation.value,
      end: widget.menuItem.isAvailable ? Colors.transparent : Colors.grey.withOpacity(0.3),
    ).animate(_availabilityController);

    _availabilityController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _swipeController.dispose();
    _availabilityController.dispose();
    super.dispose();
  }

  void _handleSwipe(DragUpdateDetails details) {
    if (!widget.enableSwipeActions) return;
    
    setState(() {
      _swipeOffset += details.delta.dx;
      _swipeOffset = _swipeOffset.clamp(-120.0, 0.0);
    });
    
    final progress = (_swipeOffset.abs() / 120.0).clamp(0.0, 1.0);
    _swipeController.value = progress;
  }

  void _handleSwipeEnd(DragEndDetails details) {
    if (!widget.enableSwipeActions) return;
    
    if (_swipeOffset < -60) {
      // Reveal actions
      setState(() {
        _swipeOffset = -120.0;
        _isSwipeRevealed = true;
      });
      _swipeController.forward();
      HapticFeedback.lightImpact();
    } else {
      // Hide actions
      _hideSwipeActions();
    }
  }

  void _hideSwipeActions() {
    setState(() {
      _swipeOffset = 0.0;
      _isSwipeRevealed = false;
    });
    _swipeController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 4),
        child: Stack(
          children: [
            // Swipe Actions Background
            if (widget.enableSwipeActions)
              _buildSwipeActionsBackground(),
            
            // Main Card
            AnimatedBuilder(
              animation: Listenable.merge([
                _availabilityAnimation,
                _availabilityColorAnimation,
              ]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_swipeOffset, 0),
                  child: Opacity(
                    opacity: _availabilityAnimation.value,
                    child: Container(
                      foregroundDecoration: BoxDecoration(
                        color: _availabilityColorAnimation.value,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: GestureDetector(
                        onPanUpdate: _handleSwipe,
                        onPanEnd: _handleSwipeEnd,
                        onTap: _isSwipeRevealed ? _hideSwipeActions : null,
                        child: AnimatedCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Menu Item Image
                              _buildItemImage(),
                              
                              const SizedBox(width: 16),
                              
                              // Menu Item Details
                              Expanded(
                                child: _buildItemDetails(),
                              ),
                              
                              // Availability Badge
                              _buildAvailabilityBadge(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeActionsBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedBuilder(
              animation: _swipeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _swipeAnimation.value,
                  child: Row(
                    children: [
                      // Edit Action
                      _buildSwipeAction(
                        icon: Icons.edit,
                        color: AppTheme.iosBlue,
                        onTap: () {
                          _hideSwipeActions();
                          widget.onEdit?.call();
                        },
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Toggle Availability Action
                      _buildSwipeAction(
                        icon: widget.menuItem.isAvailable 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                        color: AppTheme.iosYellow,
                        onTap: () {
                          _hideSwipeActions();
                          widget.onToggleAvailability?.call();
                        },
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Delete Action
                      _buildSwipeAction(
                        icon: Icons.delete,
                        color: AppTheme.iosRed,
                        onTap: () {
                          _hideSwipeActions();
                          widget.onDelete?.call();
                        },
                      ),
                      
                      const SizedBox(width: 16),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: widget.menuItem.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              child: Image.network(
                widget.menuItem.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.restaurant,
                    color: AppTheme.textTertiary,
                    size: 24,
                  );
                },
              ),
            )
          : Icon(
              Icons.restaurant,
              color: AppTheme.textTertiary,
              size: 24,
            ),
    );
  }

  Widget _buildItemDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.menuItem.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (widget.menuItem.description.isNotEmpty)
          Text(
            widget.menuItem.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '₹${widget.menuItem.price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.menuItem.category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.menuItem.isAvailable 
            ? AppTheme.iosGreen.withOpacity(0.1)
            : AppTheme.iosRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.menuItem.isAvailable ? 'Available' : 'Unavailable',
        style: TextStyle(
          color: widget.menuItem.isAvailable 
              ? AppTheme.iosGreen
              : AppTheme.iosRed,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}