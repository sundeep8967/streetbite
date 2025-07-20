import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';
import '../services/vendor_service.dart';

class VendorProvider with ChangeNotifier {
  final VendorService _vendorService = VendorService();
  
  VendorModel? _currentVendor;
  List<VendorModel> _nearbyVendors = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  VendorModel? get currentVendor => _currentVendor;
  List<VendorModel> get nearbyVendors => _nearbyVendors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Create vendor profile
  Future<bool> createVendorProfile({
    required String userId,
    required String name,
    required String cuisineType,
    required StallType stallType,
    required GeoPoint location,
    String? address,
    String? imageUrl,
    Map<String, String>? availabilityHours,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final vendor = VendorModel(
        id: userId, // Using userId as vendor ID for simplicity
        userId: userId,
        name: name,
        cuisineType: cuisineType,
        status: VendorStatus.closed,
        stallType: stallType,
        location: location,
        address: address,
        menu: [],
        followers: [],
        imageUrl: imageUrl,
        availabilityHours: availabilityHours,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _vendorService.createVendorProfile(vendor);
      _currentVendor = vendor;
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Load vendor profile by user ID
  Future<void> loadVendorProfile(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentVendor = await _vendorService.getVendorByUserId(userId);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  // Update vendor status
  Future<bool> updateVendorStatus(VendorStatus status) async {
    if (_currentVendor == null) return false;

    _setLoading(true);
    _clearError();

    try {
      await _vendorService.updateVendorStatus(_currentVendor!.id, status);
      _currentVendor = _currentVendor!.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Load nearby vendors for customers
  Future<void> loadNearbyVendors(double latitude, double longitude) async {
    _setLoading(true);
    _clearError();

    try {
      _nearbyVendors = await _vendorService.getNearbyVendors(
        latitude: latitude,
        longitude: longitude,
      );
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
    }
  }

  // Update vendor location (for mobile vendors)
  Future<bool> updateVendorLocation(GeoPoint location) async {
    if (_currentVendor == null) return false;

    try {
      await _vendorService.updateVendorLocation(_currentVendor!.id, location);
      _currentVendor = _currentVendor!.copyWith(
        location: location,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Follow/Unfollow vendor
  Future<bool> toggleFollowVendor(String vendorId, String userId) async {
    try {
      // Find the vendor in nearby vendors list
      final vendorIndex = _nearbyVendors.indexWhere((v) => v.id == vendorId);
      if (vendorIndex == -1) return false;

      final vendor = _nearbyVendors[vendorIndex];
      final isFollowing = vendor.followers.contains(userId);

      await _vendorService.toggleFollowVendor(vendorId, userId, !isFollowing);

      // Update local state
      final updatedFollowers = List<String>.from(vendor.followers);
      if (isFollowing) {
        updatedFollowers.remove(userId);
      } else {
        updatedFollowers.add(userId);
      }

      _nearbyVendors[vendorIndex] = vendor.copyWith(followers: updatedFollowers);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
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

  void clearVendor() {
    _currentVendor = null;
    notifyListeners();
  }
}