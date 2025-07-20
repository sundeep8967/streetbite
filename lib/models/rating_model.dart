class RatingModel {
  final String id;
  final String vendorId;
  final String customerId;
  final String customerName;
  final double rating; // 1-5 stars
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAnonymous;

  RatingModel({
    required this.id,
    required this.vendorId,
    required this.customerId,
    required this.customerName,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.isAnonymous = false,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      id: map['id'] ?? '',
      vendorId: map['vendorId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isAnonymous: map['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'customerId': customerId,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  RatingModel copyWith({
    String? id,
    String? vendorId,
    String? customerId,
    String? customerName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAnonymous,
  }) {
    return RatingModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}

class VendorRatingStats {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // star -> count
  final List<RatingModel> recentReviews;

  VendorRatingStats({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    required this.recentReviews,
  });

  factory VendorRatingStats.empty() {
    return VendorRatingStats(
      averageRating: 0.0,
      totalRatings: 0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      recentReviews: [],
    );
  }
}