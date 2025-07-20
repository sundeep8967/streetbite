import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';
import '../constants/app_constants.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update a rating
  Future<void> addOrUpdateRating(RatingModel rating) async {
    await _firestore
        .collection(AppConstants.ratingsCollection)
        .doc(rating.id)
        .set(rating.toMap());
  }

  // Get all ratings for a vendor
  Future<List<RatingModel>> getVendorRatings(String vendorId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(AppConstants.ratingsCollection)
          .where('vendorId', isEqualTo: vendorId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => RatingModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching vendor ratings: $e');
    }
  }

  // Get rating by customer for a specific vendor
  Future<RatingModel?> getCustomerRatingForVendor(String customerId, String vendorId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(AppConstants.ratingsCollection)
          .where('customerId', isEqualTo: customerId)
          .where('vendorId', isEqualTo: vendorId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return RatingModel.fromMap(query.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching customer rating: $e');
    }
  }

  // Delete a rating
  Future<void> deleteRating(String ratingId) async {
    await _firestore
        .collection(AppConstants.ratingsCollection)
        .doc(ratingId)
        .delete();
  }

  // Get vendor rating statistics
  Future<VendorRatingStats> getVendorRatingStats(String vendorId) async {
    try {
      final ratings = await getVendorRatings(vendorId);
      
      if (ratings.isEmpty) {
        return VendorRatingStats.empty();
      }

      // Calculate average rating
      double totalRating = ratings.fold(0.0, (sum, rating) => sum + rating.rating);
      double averageRating = totalRating / ratings.length;

      // Calculate rating distribution
      Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (var rating in ratings) {
        int starRating = rating.rating.round();
        distribution[starRating] = (distribution[starRating] ?? 0) + 1;
      }

      // Get recent reviews (with comments)
      List<RatingModel> recentReviews = ratings
          .where((rating) => rating.comment != null && rating.comment!.isNotEmpty)
          .take(10)
          .toList();

      return VendorRatingStats(
        averageRating: averageRating,
        totalRatings: ratings.length,
        ratingDistribution: distribution,
        recentReviews: recentReviews,
      );
    } catch (e) {
      throw Exception('Error calculating vendor rating stats: $e');
    }
  }

  // Stream vendor ratings for real-time updates
  Stream<List<RatingModel>> streamVendorRatings(String vendorId) {
    return _firestore
        .collection(AppConstants.ratingsCollection)
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RatingModel.fromMap(doc.data()))
            .toList());
  }

  // Update vendor's average rating in vendor document
  Future<void> updateVendorAverageRating(String vendorId) async {
    try {
      final stats = await getVendorRatingStats(vendorId);
      
      await _firestore
          .collection(AppConstants.vendorsCollection)
          .doc(vendorId)
          .update({
        'rating': stats.averageRating,
        'totalRatings': stats.totalRatings,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error updating vendor average rating: $e');
    }
  }
}