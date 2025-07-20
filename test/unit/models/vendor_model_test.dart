import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:streetbite/models/vendor_model.dart';

void main() {
  group('VendorModel Tests', () {
    late VendorModel testVendor;
    late Map<String, dynamic> testVendorMap;

    setUp(() {
      testVendor = VendorModel(
        id: 'vendor_id',
        userId: 'user_id',
        name: 'Test Restaurant',
        cuisineType: 'Italian',
        status: VendorStatus.open,
        stallType: StallType.fixed,
        location: const GeoPoint(37.7749, -122.4194),
        address: '123 Main St, San Francisco, CA',
        menu: ['pizza', 'pasta'],
        followers: ['user1', 'user2'],
        rating: 4.5,
        totalRatings: 100,
        imageUrl: 'https://example.com/image.jpg',
        availabilityHours: {'monday': '9:00-18:00'},
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      testVendorMap = {
        'id': 'vendor_id',
        'userId': 'user_id',
        'name': 'Test Restaurant',
        'cuisineType': 'Italian',
        'status': 'VendorStatus.open',
        'stallType': 'StallType.fixed',
        'location': const GeoPoint(37.7749, -122.4194),
        'address': '123 Main St, San Francisco, CA',
        'menu': ['pizza', 'pasta'],
        'followers': ['user1', 'user2'],
        'rating': 4.5,
        'totalRatings': 100,
        'imageUrl': 'https://example.com/image.jpg',
        'availabilityHours': {'monday': '9:00-18:00'},
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      };
    });

    test('should create VendorModel with all properties', () {
      expect(testVendor.id, 'vendor_id');
      expect(testVendor.userId, 'user_id');
      expect(testVendor.name, 'Test Restaurant');
      expect(testVendor.cuisineType, 'Italian');
      expect(testVendor.status, VendorStatus.open);
      expect(testVendor.stallType, StallType.fixed);
      expect(testVendor.location.latitude, 37.7749);
      expect(testVendor.location.longitude, -122.4194);
      expect(testVendor.address, '123 Main St, San Francisco, CA');
      expect(testVendor.menu, ['pizza', 'pasta']);
      expect(testVendor.followers, ['user1', 'user2']);
      expect(testVendor.rating, 4.5);
      expect(testVendor.totalRatings, 100);
      expect(testVendor.imageUrl, 'https://example.com/image.jpg');
      expect(testVendor.availabilityHours, {'monday': '9:00-18:00'});
    });

    test('should create VendorModel with default values', () {
      final minimalVendor = VendorModel(
        id: 'vendor_id',
        userId: 'user_id',
        name: 'Test Restaurant',
        cuisineType: 'Italian',
        status: VendorStatus.open,
        stallType: StallType.fixed,
        location: const GeoPoint(0, 0),
        menu: [],
        followers: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(minimalVendor.rating, 0.0);
      expect(minimalVendor.totalRatings, 0);
      expect(minimalVendor.address, isNull);
      expect(minimalVendor.imageUrl, isNull);
      expect(minimalVendor.availabilityHours, isNull);
    });

    test('should convert VendorModel to Map correctly', () {
      final result = testVendor.toMap();
      expect(result, equals(testVendorMap));
    });

    test('should create VendorModel from Map correctly', () {
      final result = VendorModel.fromMap(testVendorMap);
      
      expect(result.id, testVendor.id);
      expect(result.userId, testVendor.userId);
      expect(result.name, testVendor.name);
      expect(result.cuisineType, testVendor.cuisineType);
      expect(result.status, testVendor.status);
      expect(result.stallType, testVendor.stallType);
      expect(result.location.latitude, testVendor.location.latitude);
      expect(result.location.longitude, testVendor.location.longitude);
      expect(result.address, testVendor.address);
      expect(result.menu, testVendor.menu);
      expect(result.followers, testVendor.followers);
      expect(result.rating, testVendor.rating);
      expect(result.totalRatings, testVendor.totalRatings);
      expect(result.imageUrl, testVendor.imageUrl);
      expect(result.availabilityHours, testVendor.availabilityHours);
    });

    test('should handle missing optional fields in fromMap', () {
      final minimalMap = {
        'id': 'vendor_id',
        'userId': 'user_id',
        'name': 'Test Restaurant',
        'cuisineType': 'Italian',
        'status': 'VendorStatus.open',
        'stallType': 'StallType.fixed',
        'location': const GeoPoint(0, 0),
        'menu': <String>[],
        'followers': <String>[],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final result = VendorModel.fromMap(minimalMap);
      expect(result.rating, 0.0);
      expect(result.totalRatings, 0);
      expect(result.address, isNull);
      expect(result.imageUrl, isNull);
      expect(result.availabilityHours, isNull);
    });

    test('should use copyWith correctly', () {
      final updatedVendor = testVendor.copyWith(
        name: 'Updated Restaurant',
        rating: 5.0,
        status: VendorStatus.closed,
      );

      expect(updatedVendor.name, 'Updated Restaurant');
      expect(updatedVendor.rating, 5.0);
      expect(updatedVendor.status, VendorStatus.closed);
      // Other properties should remain the same
      expect(updatedVendor.id, testVendor.id);
      expect(updatedVendor.cuisineType, testVendor.cuisineType);
      expect(updatedVendor.stallType, testVendor.stallType);
    });

    group('Enum tests', () {
      test('VendorStatus enum should have correct values', () {
        expect(VendorStatus.values.length, 2);
        expect(VendorStatus.values, contains(VendorStatus.open));
        expect(VendorStatus.values, contains(VendorStatus.closed));
      });

      test('StallType enum should have correct values', () {
        expect(StallType.values.length, 2);
        expect(StallType.values, contains(StallType.fixed));
        expect(StallType.values, contains(StallType.mobile));
      });

      test('should default to closed status for invalid enum', () {
        final mapWithInvalidStatus = Map<String, dynamic>.from(testVendorMap);
        mapWithInvalidStatus['status'] = 'InvalidStatus';

        final result = VendorModel.fromMap(mapWithInvalidStatus);
        expect(result.status, VendorStatus.closed);
      });

      test('should default to fixed stall type for invalid enum', () {
        final mapWithInvalidStallType = Map<String, dynamic>.from(testVendorMap);
        mapWithInvalidStallType['stallType'] = 'InvalidStallType';

        final result = VendorModel.fromMap(mapWithInvalidStallType);
        expect(result.stallType, StallType.fixed);
      });
    });

    group('Edge cases', () {
      test('should handle null values in fromMap', () {
        final mapWithNulls = {
          'id': null,
          'userId': null,
          'name': null,
          'cuisineType': null,
          'status': null,
          'stallType': null,
          'location': const GeoPoint(0, 0),
          'menu': null,
          'followers': null,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final result = VendorModel.fromMap(mapWithNulls);
        expect(result.id, '');
        expect(result.userId, '');
        expect(result.name, '');
        expect(result.cuisineType, '');
        expect(result.status, VendorStatus.closed);
        expect(result.stallType, StallType.fixed);
        expect(result.menu, isEmpty);
        expect(result.followers, isEmpty);
      });

      test('should handle invalid rating values', () {
        final mapWithInvalidRating = Map<String, dynamic>.from(testVendorMap);
        mapWithInvalidRating['rating'] = 'invalid';

        expect(
          () => VendorModel.fromMap(mapWithInvalidRating),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle negative rating values', () {
        final mapWithNegativeRating = Map<String, dynamic>.from(testVendorMap);
        mapWithNegativeRating['rating'] = -1.0;

        final result = VendorModel.fromMap(mapWithNegativeRating);
        expect(result.rating, -1.0); // Model doesn't validate, just stores
      });
    });

    group('Business logic tests', () {
      test('should correctly identify open vendor', () {
        expect(testVendor.status, VendorStatus.open);
      });

      test('should correctly identify closed vendor', () {
        final closedVendor = testVendor.copyWith(status: VendorStatus.closed);
        expect(closedVendor.status, VendorStatus.closed);
      });

      test('should correctly identify mobile vendor', () {
        final mobileVendor = testVendor.copyWith(stallType: StallType.mobile);
        expect(mobileVendor.stallType, StallType.mobile);
      });

      test('should handle empty followers list', () {
        final vendorWithoutFollowers = testVendor.copyWith(followers: []);
        expect(vendorWithoutFollowers.followers, isEmpty);
      });

      test('should handle large followers list', () {
        final largeFollowersList = List.generate(1000, (index) => 'user_$index');
        final popularVendor = testVendor.copyWith(followers: largeFollowersList);
        expect(popularVendor.followers.length, 1000);
      });
    });
  });
}