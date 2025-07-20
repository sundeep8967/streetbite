import 'package:flutter/material.dart';
import '../models/rating_model.dart';
import '../services/rating_service.dart';

class RatingProvider with ChangeNotifier {
  final RatingService _ratingService = RatingService();
  
  List<RatingModel> _vendorRatings = [];
  VendorRatingStats? _vendorStats;
  RatingModel? _currentUserRating;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RatingModel> get vendorRatings => _vendorRatings;
  VendorRatingStats? get vendorStats => _vendorStats;
  RatingModel? get currentUserRating => _currentUserRating;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load vendor ratings and stats
  Future<void> loadVendorRatings(String vendorId) async {
    _setLoading(true);
    _clearError();

    try {
      _vendorRatings = await _ratingService.getVendorRatings(vendorId);
      _vendorStats = await _ratingService.getVendorRatingStats(vendorId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load current user's rating for a vendor
  Future<void> loadCurrentUserRating(String customerId, String vendorId) async {
    try {
      _currentUserRating = await _ratingService.getCustomerRatingForVendor(customerId, vendorId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Add or update rating
  Future<bool> addOrUpdateRating({
    required String vendorId,
    required String customerId,
    required String customerName,
    required double rating,
    String? comment,
    bool isAnonymous = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Create rating ID based on customer and vendor
      String ratingId = '${customerId}_$vendorId';
      
      final ratingModel = RatingModel(
        id: ratingId,
        vendorId: vendorId,
        customerId: customerId,
        customerName: isAnonymous ? 'Anonymous' : customerName,
        rating: rating,
        comment: comment,
        createdAt: _currentUserRating?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isAnonymous: isAnonymous,
      );

      await _ratingService.addOrUpdateRating(ratingModel);
      
      // Update vendor's average rating
      await _ratingService.updateVendorAverageRating(vendorId);
      
      // Update local state
      _currentUserRating = ratingModel;
      
      // Reload ratings to get updated data
      await loadVendorRatings(vendorId);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Delete rating
  Future<bool> deleteRating(String ratingId, String vendorId) async {
    _setLoading(true);
    _clearError();

    try {
      await _ratingService.deleteRating(ratingId);
      
      // Update vendor's average rating
      await _ratingService.updateVendorAverageRating(vendorId);
      
      // Clear current user rating if it was deleted
      if (_currentUserRating?.id == ratingId) {
        _currentUserRating = null;
      }
      
      // Reload ratings to get updated data
      await loadVendorRatings(vendorId);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Stream vendor ratings for real-time updates
  Stream<List<RatingModel>> streamVendorRatings(String vendorId) {
    return _ratingService.streamVendorRatings(vendorId);
  }

  // Clear all data
  void clearRatings() {
    _vendorRatings.clear();
    _vendorStats = null;
    _currentUserRating = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
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

  // Get rating distribution percentage
  double getRatingPercentage(int stars) {
    if (_vendorStats == null || _vendorStats!.totalRatings == 0) return 0.0;
    
    int count = _vendorStats!.ratingDistribution[stars] ?? 0;
    return (count / _vendorStats!.totalRatings) * 100;
  }

  // Check if current user has rated this vendor
  bool hasUserRated(String customerId, String vendorId) {
    return _currentUserRating != null && 
           _currentUserRating!.customerId == customerId && 
           _currentUserRating!.vendorId == vendorId;
  }
}