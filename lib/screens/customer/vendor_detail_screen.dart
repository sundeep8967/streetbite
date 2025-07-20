import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/vendor_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import 'vendor_ratings_screen.dart';
import 'add_rating_screen.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';
import '../../widgets/animated/animated_button.dart';
import '../../widgets/animated/animated_card.dart';
import '../../widgets/animated/page_transitions.dart';

class VendorDetailScreen extends StatefulWidget {
  final VendorModel vendor;

  const VendorDetailScreen({
    super.key,
    required this.vendor,
  });

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _isFollowing = false;
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.easeInOut,
    ));

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
      
      // Fade app bar based on scroll
      final fadeValue = (_scrollOffset / 200).clamp(0.0, 1.0);
      _fadeController.animateTo(fadeValue);
    });

    // Start entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _checkFollowStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _isFollowing = widget.vendor.followers.contains(authProvider.user!.uid);
    }
  }

  Future<void> _toggleFollow() async {
    HapticFeedback.lightImpact();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final success = await customerProvider.toggleFavoriteVendor(
      widget.vendor.id,
      authProvider.user!.uid,
    );

    if (success) {
      setState(() {
        _isFollowing = !_isFollowing;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFollowing ? 'Following vendor!' : 'Unfollowed vendor'),
          backgroundColor: _isFollowing ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _openDirections() async {
    final lat = widget.vendor.location.latitude;
    final lng = widget.vendor.location.longitude;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open directions')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final distance = customerProvider.getDistanceToVendor(widget.vendor);
    final parallaxOffset = _scrollOffset * 0.5;

    return Scaffold(
      body: Stack(
        children: [
          // Main Content with Parallax
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Image with Parallax
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Parallax Image
                      Transform.translate(
                        offset: Offset(0, -parallaxOffset),
                        child: Container(
                          height: 350,
                          width: double.infinity,
                          child: widget.vendor.imageUrl != null
                              ? Image.network(
                                  widget.vendor.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholderImage();
                                  },
                                )
                              : _buildPlaceholderImage(),
                        ),
                      ),
                      
                      // Gradient Overlay
                      Container(
                        height: 350,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _toggleFollow,
                      icon: Icon(
                        _isFollowing ? Icons.favorite : Icons.favorite_border,
                        color: _isFollowing ? AppTheme.iosRed : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Name and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.vendor.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.vendor.status == VendorStatus.open
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.vendor.status == VendorStatus.open ? 'OPEN' : 'CLOSED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Cuisine and Stall Type
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.vendor.cuisineType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.store, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.vendor.stallType.name.toUpperCase()} Stall',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.star,
                        label: 'Rating',
                        value: widget.vendor.rating > 0 
                            ? widget.vendor.rating.toStringAsFixed(1)
                            : 'New',
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        icon: Icons.people,
                        label: 'Followers',
                        value: widget.vendor.followers.length.toString(),
                        color: Colors.blue,
                      ),
                      if (distance != null) ...[
                        const SizedBox(width: 24),
                        _buildStatItem(
                          icon: Icons.location_on,
                          label: 'Distance',
                          value: '${distance.toStringAsFixed(1)} km',
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openDirections,
                          icon: const Icon(Icons.directions),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Menu coming soon!')),
                            );
                          },
                          icon: const Icon(Icons.restaurant_menu),
                          label: const Text('View Menu'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Rating and Review Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VendorRatingsScreen(vendor: widget.vendor),
                              ),
                            );
                          },
                          icon: const Icon(Icons.star_outline),
                          label: const Text('View Reviews'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            if (authProvider.user != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddRatingScreen(vendor: widget.vendor),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please log in to rate this vendor')),
                              );
                            }
                          },
                          icon: const Icon(Icons.rate_review),
                          label: const Text('Rate Vendor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Address Section
                  if (widget.vendor.address != null) ...[
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.vendor.address!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Map Section
                  Text(
                    'Map',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            widget.vendor.location.latitude,
                            widget.vendor.location.longitude,
                          ),
                          zoom: 16.0,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(widget.vendor.id),
                            position: LatLng(
                              widget.vendor.location.latitude,
                              widget.vendor.location.longitude,
                            ),
                            infoWindow: InfoWindow(title: widget.vendor.name),
                          ),
                        },
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Availability Hours (if available)
                  if (widget.vendor.availabilityHours != null) ...[
                    Text(
                      'Opening Hours',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.vendor.availabilityHours!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              entry.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}