import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String id;
  final String userId;
  final String name;
  final String cuisineType;
  final VendorStatus status;
  final StallType stallType;
  final GeoPoint location;
  final String? address;
  final List<String> menu;
  final List<String> followers;
  final double rating;
  final int totalRatings;
  final String? imageUrl;
  final Map<String, String>? availabilityHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.cuisineType,
    required this.status,
    required this.stallType,
    required this.location,
    this.address,
    required this.menu,
    required this.followers,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.imageUrl,
    this.availabilityHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      cuisineType: map['cuisineType'] ?? '',
      status: VendorStatus.values.firstWhere(
        (status) => status.toString() == map['status'],
        orElse: () => VendorStatus.closed,
      ),
      stallType: StallType.values.firstWhere(
        (type) => type.toString() == map['stallType'],
        orElse: () => StallType.fixed,
      ),
      location: map['location'] ?? const GeoPoint(0, 0),
      address: map['address'],
      menu: List<String>.from(map['menu'] ?? []),
      followers: List<String>.from(map['followers'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      imageUrl: map['imageUrl'],
      availabilityHours: map['availabilityHours'] != null
          ? Map<String, String>.from(map['availabilityHours'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'cuisineType': cuisineType,
      'status': status.toString(),
      'stallType': stallType.toString(),
      'location': location,
      'address': address,
      'menu': menu,
      'followers': followers,
      'rating': rating,
      'totalRatings': totalRatings,
      'imageUrl': imageUrl,
      'availabilityHours': availabilityHours,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  VendorModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? cuisineType,
    VendorStatus? status,
    StallType? stallType,
    GeoPoint? location,
    String? address,
    List<String>? menu,
    List<String>? followers,
    double? rating,
    int? totalRatings,
    String? imageUrl,
    Map<String, String>? availabilityHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      cuisineType: cuisineType ?? this.cuisineType,
      status: status ?? this.status,
      stallType: stallType ?? this.stallType,
      location: location ?? this.location,
      address: address ?? this.address,
      menu: menu ?? this.menu,
      followers: followers ?? this.followers,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      imageUrl: imageUrl ?? this.imageUrl,
      availabilityHours: availabilityHours ?? this.availabilityHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum VendorStatus { open, closed }
enum StallType { fixed, mobile }