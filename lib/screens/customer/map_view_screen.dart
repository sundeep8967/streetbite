import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/customer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/vendor_model.dart';
import 'vendor_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  VendorModel? _selectedVendor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVendorsAndMarkers();
    });
  }

  void _loadVendorsAndMarkers() {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    
    if (customerProvider.currentLocation == null) {
      customerProvider.getCurrentLocation().then((_) {
        _updateMarkers();
      });
    } else {
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final vendors = customerProvider.nearbyVendors;

    setState(() {
      _markers = vendors.map((vendor) {
        return Marker(
          markerId: MarkerId(vendor.id),
          position: LatLng(
            vendor.location.latitude,
            vendor.location.longitude,
          ),
          infoWindow: InfoWindow(
            title: vendor.name,
            snippet: '${vendor.cuisineType} • ${vendor.status.name.toUpperCase()}',
          ),
          icon: vendor.status == VendorStatus.open
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () {
            setState(() {
              _selectedVendor = vendor;
            });
          },
        );
      }).toSet();

      // Add user location marker if available
      if (customerProvider.currentLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(
              customerProvider.currentLocation!.latitude,
              customerProvider.currentLocation!.longitude,
            ),
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    if (customerProvider.currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            customerProvider.currentLocation!.latitude,
            customerProvider.currentLocation!.longitude,
          ),
        ),
      );
    }
  }

  void _showVendorDetails(VendorModel vendor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VendorDetailScreen(vendor: vendor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
              if (customerProvider.currentLocation != null && _mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        customerProvider.currentLocation!.latitude,
                        customerProvider.currentLocation!.longitude,
                      ),
                      zoom: 15.0,
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
              customerProvider.refreshVendors().then((_) {
                _updateMarkers();
              });
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          if (customerProvider.isLoading && customerProvider.currentLocation == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            );
          }

          if (customerProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${customerProvider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadVendorsAndMarkers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: customerProvider.currentLocation != null
                      ? LatLng(
                          customerProvider.currentLocation!.latitude,
                          customerProvider.currentLocation!.longitude,
                        )
                      : const LatLng(28.6139, 77.2090), // Default to Delhi
                  zoom: 15.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                onTap: (_) {
                  setState(() {
                    _selectedVendor = null;
                  });
                },
              ),

              // Legend
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Open', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Closed', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Selected Vendor Bottom Sheet
              if (_selectedVendor != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedVendor!.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedVendor!.cuisineType,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _selectedVendor!.status == VendorStatus.open
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _selectedVendor!.status == VendorStatus.open ? 'OPEN' : 'CLOSED',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _selectedVendor!.rating > 0 
                                  ? _selectedVendor!.rating.toStringAsFixed(1)
                                  : 'New',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.people, color: Colors.blue, size: 16),
                            const SizedBox(width: 4),
                            Text('${_selectedVendor!.followers.length} followers'),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () => _showVendorDetails(_selectedVendor!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('View Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}