import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';
import '../constants/app_constants.dart';

class VendorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create vendor profile
  Future<void> createVendorProfile(VendorModel vendor) async {
    await _firestore
        .collection(AppConstants.vendorsCollection)
        .doc(vendor.id)
        .set(vendor.toMap());
  }

  // Get vendor by user ID
  Future<VendorModel?> getVendorByUserId(String userId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(AppConstants.vendorsCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return VendorModel.fromMap(
            query.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching vendor profile: $e');
    }
  }

  // Update vendor status
  Future<void> updateVendorStatus(String vendorId, VendorStatus status) async {
    await _firestore
        .collection(AppConstants.vendorsCollection)
        .doc(vendorId)
        .update({
      'status': status.toString(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Get nearby vendors
  Future<List<VendorModel>> getNearbyVendors({
    required double latitude,
    required double longitude,
    double radiusKm = AppConstants.vendorSearchRadius,
  }) async {
    try {
      // Note: For production, consider using GeoFlutterFire for better geo queries
      QuerySnapshot query = await _firestore
          .collection(AppConstants.vendorsCollection)
          .get();

      List<VendorModel> vendors = [];
      for (var doc in query.docs) {
        VendorModel vendor = VendorModel.fromMap(doc.data() as Map<String, dynamic>);
        
        // Simple distance calculation (for demo purposes)
        double distance = _calculateDistance(
          latitude,
          longitude,
          vendor.location.latitude,
          vendor.location.longitude,
        );

        if (distance <= radiusKm) {
          vendors.add(vendor);
        }
      }

      return vendors;
    } catch (e) {
      throw Exception('Error fetching nearby vendors: $e');
    }
  }

  // Get open vendors
  Stream<List<VendorModel>> getOpenVendors() {
    return _firestore
        .collection(AppConstants.vendorsCollection)
        .where('status', isEqualTo: VendorStatus.open.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorModel.fromMap(doc.data()))
            .toList());
  }

  // Follow/Unfollow vendor
  Future<void> toggleFollowVendor(String vendorId, String userId, bool follow) async {
    DocumentReference vendorRef = _firestore
        .collection(AppConstants.vendorsCollection)
        .doc(vendorId);

    if (follow) {
      await vendorRef.update({
        'followers': FieldValue.arrayUnion([userId]),
      });
    } else {
      await vendorRef.update({
        'followers': FieldValue.arrayRemove([userId]),
      });
    }
  }

  // Update vendor location (for mobile vendors)
  Future<void> updateVendorLocation(String vendorId, GeoPoint location) async {
    await _firestore
        .collection(AppConstants.vendorsCollection)
        .doc(vendorId)
        .update({
      'location': location,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Simple distance calculation using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}