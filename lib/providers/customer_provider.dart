import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/vendor_model.dart';
import '../services/vendor_service.dart';

class CustomerProvider with ChangeNotifier {
  final VendorService _vendorService = VendorService();
  
  List<VendorModel> _nearbyVendors = [];
  List<VendorModel> _favoriteVendors = [];
  List<VendorModel> _filteredVendors = [];
  Position? _currentLocation;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCuisineFilter;
  VendorStatus? _selectedStatusFilter;

  // Getters
  List<VendorModel> get nearbyVendors => _nearbyVendors;
  List<VendorModel> get favoriteVendors => _favoriteVendors;
  List<VendorModel> get filteredVendors => _filteredVendors.isEmpty ? _nearbyVendors : _filteredVendors;
  Position? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCuisineFilter => _selectedCuisineFilter;
  VendorStatus? get selectedStatusFilter => _selectedStatusFilter;

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      _setLoading(true);
      _clearError();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await loadNearbyVendors();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load nearby vendors
  Future<void> loadNearbyVendors() async {
    if (_currentLocation == null) {
      await getCurrentLocation();
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      _nearbyVendors = await _vendorService.getNearbyVendors(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );

      _applyFilters();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Search vendors
  void searchVendors(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Filter by cuisine
  void filterByCuisine(String? cuisine) {
    _selectedCuisineFilter = cuisine;
    _applyFilters();
  }

  // Filter by status
  void filterByStatus(VendorStatus? status) {
    _selectedStatusFilter = status;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCuisineFilter = null;
    _selectedStatusFilter = null;
    _applyFilters();
  }

  // Apply filters
  void _applyFilters() {
    List<VendorModel> filtered = List.from(_nearbyVendors);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((vendor) {
        return vendor.name.toLowerCase().contains(_searchQuery) ||
               vendor.cuisineType.toLowerCase().contains(_searchQuery) ||
               (vendor.address?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Apply cuisine filter
    if (_selectedCuisineFilter != null) {
      filtered = filtered.where((vendor) {
        return vendor.cuisineType == _selectedCuisineFilter;
      }).toList();
    }

    // Apply status filter
    if (_selectedStatusFilter != null) {
      filtered = filtered.where((vendor) {
        return vendor.status == _selectedStatusFilter;
      }).toList();
    }

    _filteredVendors = filtered;
    notifyListeners();
  }

  // Toggle favorite vendor
  Future<bool> toggleFavoriteVendor(String vendorId, String userId) async {
    try {
      final vendor = _nearbyVendors.firstWhere((v) => v.id == vendorId);
      final isCurrentlyFavorite = vendor.followers.contains(userId);

      await _vendorService.toggleFollowVendor(vendorId, userId, !isCurrentlyFavorite);

      // Update local state
      final vendorIndex = _nearbyVendors.indexWhere((v) => v.id == vendorId);
      if (vendorIndex != -1) {
        final updatedFollowers = List<String>.from(vendor.followers);
        if (isCurrentlyFavorite) {
          updatedFollowers.remove(userId);
          _favoriteVendors.removeWhere((v) => v.id == vendorId);
        } else {
          updatedFollowers.add(userId);
          _favoriteVendors.add(vendor);
        }

        _nearbyVendors[vendorIndex] = vendor.copyWith(followers: updatedFollowers);
        _applyFilters();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Load favorite vendors
  void loadFavoriteVendors(String userId) {
    _favoriteVendors = _nearbyVendors.where((vendor) {
      return vendor.followers.contains(userId);
    }).toList();
    notifyListeners();
  }

  // Get vendor by ID
  VendorModel? getVendorById(String vendorId) {
    try {
      return _nearbyVendors.firstWhere((vendor) => vendor.id == vendorId);
    } catch (e) {
      return null;
    }
  }

  // Calculate distance to vendor
  double? getDistanceToVendor(VendorModel vendor) {
    if (_currentLocation == null) return null;

    return Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      vendor.location.latitude,
      vendor.location.longitude,
    ) / 1000; // Convert to kilometers
  }

  // Sort vendors by distance
  void sortVendorsByDistance() {
    if (_currentLocation == null) return;

    _nearbyVendors.sort((a, b) {
      final distanceA = getDistanceToVendor(a) ?? double.infinity;
      final distanceB = getDistanceToVendor(b) ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });

    _applyFilters();
  }

  // Sort vendors by rating
  void sortVendorsByRating() {
    _nearbyVendors.sort((a, b) => b.rating.compareTo(a.rating));
    _applyFilters();
  }

  // Refresh vendors
  Future<void> refreshVendors() async {
    await loadNearbyVendors();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}