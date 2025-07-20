import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constants/app_animations.dart';
import '../../constants/app_theme.dart';
import '../../models/vendor_model.dart';

/// Animated Google Maps widget with smooth transitions
class AnimatedMapWidget extends StatefulWidget {
  final List<VendorModel> vendors;
  final LatLng? initialPosition;
  final Function(VendorModel)? onVendorTap;
  final double zoom;
  final bool showUserLocation;

  const AnimatedMapWidget({
    super.key,
    required this.vendors,
    this.initialPosition,
    this.onVendorTap,
    this.zoom = 14.0,
    this.showUserLocation = true,
  });

  @override
  State<AnimatedMapWidget> createState() => _AnimatedMapWidgetState();
}

class _AnimatedMapWidgetState extends State<AnimatedMapWidget>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _markerController;
  late Animation<double> _markerAnimation;
  Set<Marker> _markers = {};
  VendorModel? _selectedVendor;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _createMarkers();
  }

  void _initializeAnimations() {
    _markerController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _markerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _markerController,
      curve: AppAnimations.iosSpring,
    ));

    _markerController.forward();
  }

  void _createMarkers() {
    _markers = widget.vendors.map((vendor) {
      return Marker(
        markerId: MarkerId(vendor.id),
        position: LatLng(
          vendor.location.latitude,
          vendor.location.longitude,
        ),
        infoWindow: InfoWindow(
          title: vendor.name,
          snippet: vendor.cuisineType,
          onTap: () => _onMarkerTap(vendor),
        ),
        icon: _getMarkerIcon(vendor),
        onTap: () => _onMarkerTap(vendor),
      );
    }).toSet();
  }

  BitmapDescriptor _getMarkerIcon(VendorModel vendor) {
    // Use different colors based on vendor status
    return vendor.status == VendorStatus.open
        ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }

  void _onMarkerTap(VendorModel vendor) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedVendor = vendor;
    });
    
    // Animate camera to vendor location
    _animateToVendor(vendor);
    
    // Trigger callback
    widget.onVendorTap?.call(vendor);
  }

  Future<void> _animateToVendor(VendorModel vendor) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              vendor.location.latitude,
              vendor.location.longitude,
            ),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _markerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Map
        AnimatedBuilder(
          animation: _markerAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _markerAnimation.value,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: widget.initialPosition ?? 
                      const LatLng(28.6139, 77.2090), // Default to Delhi
                  zoom: widget.zoom,
                ),
                markers: _markers,
                myLocationEnabled: widget.showUserLocation,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                onTap: (position) {
                  setState(() {
                    _selectedVendor = null;
                  });
                },
              ),
            );
          },
        ),

        // Custom Controls
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapButton(
                icon: Icons.my_location,
                onTap: _centerOnUserLocation,
              ),
              const SizedBox(height: 8),
              _buildMapButton(
                icon: Icons.zoom_in,
                onTap: _zoomIn,
              ),
              const SizedBox(height: 8),
              _buildMapButton(
                icon: Icons.zoom_out,
                onTap: _zoomOut,
              ),
            ],
          ),
        ),

        // Vendor Info Card
        if (_selectedVendor != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildVendorInfoCard(_selectedVendor!),
          ),
      ],
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(24),
          child: Icon(
            icon,
            color: AppTheme.textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildVendorInfoCard(VendorModel vendor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onVendorTap?.call(vendor);
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Vendor Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: vendor.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          child: Image.network(
                            vendor.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.restaurant,
                                color: AppTheme.textTertiary,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.restaurant,
                          color: AppTheme.textTertiary,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Vendor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vendor.cuisineType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppTheme.iosYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vendor.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: vendor.status == VendorStatus.open
                                  ? AppTheme.iosGreen
                                  : AppTheme.iosRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              vendor.status == VendorStatus.open ? 'OPEN' : 'CLOSED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _centerOnUserLocation() async {
    // TODO: Implement user location centering
    HapticFeedback.lightImpact();
  }

  void _zoomIn() async {
    if (_mapController != null) {
      HapticFeedback.lightImpact();
      await _mapController!.animateCamera(CameraUpdate.zoomIn());
    }
  }

  void _zoomOut() async {
    if (_mapController != null) {
      HapticFeedback.lightImpact();
      await _mapController!.animateCamera(CameraUpdate.zoomOut());
    }
  }
}