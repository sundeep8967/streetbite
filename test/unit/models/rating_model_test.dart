import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/models/rating_model.dart';

void main() {
  group('RatingModel Tests', () {
    late RatingModel testRating;
    late Map<String, dynamic> testRatingMap;

    setUp(() {
      testRating = RatingModel(
        id: 'rating_id',
        vendorId: 'vendor_id',
        customerId: 'customer_id',
        customerName: 'John Doe',
        rating: 4.5,
        comment: 'Great food and service!',
        createdAt: DateTime(2024, 1, 1),
      );

      testRatingMap = {
        'id': 'rating_id',
        'vendorId': 'vendor_id',
        'customerId': 'customer_id',
        'customerName': 'John Doe',
        'rating': 4.5,
        'comment': 'Great food and service!',
        'createdAt': '2024-01-01T00:00:00.000',
      };
    });

    test('should create RatingModel with all properties', () {
      expect(testRating.id, 'rating_id');
      expect(testRating.vendorId, 'vendor_id');
      expect(testRating.customerId, 'customer_id');
      expect(testRating.customerName, 'John Doe');
      expect(testRating.rating, 4.5);
      expect(testRating.comment, 'Great food and service!');
      expect(testRating.createdAt, DateTime(2024, 1, 1));
    });

    test('should create RatingModel without comment', () {
      final ratingWithoutComment = RatingModel(
        id: 'rating_id',
        vendorId: 'vendor_id',
        customerId: 'customer_id',
        customerName: 'Jane Doe',
        rating: 5.0,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(ratingWithoutComment.comment, isNull);
      expect(ratingWithoutComment.rating, 5.0);
    });

    test('should convert RatingModel to Map correctly', () {
      final result = testRating.toMap();
      expect(result, equals(testRatingMap));
    });

    test('should create RatingModel from Map correctly', () {
      final result = RatingModel.fromMap(testRatingMap);
      
      expect(result.id, testRating.id);
      expect(result.vendorId, testRating.vendorId);
      expect(result.customerId, testRating.customerId);
      expect(result.customerName, testRating.customerName);
      expect(result.rating, testRating.rating);
      expect(result.comment, testRating.comment);
      expect(result.createdAt, testRating.createdAt);
    });

    test('should handle missing comment in fromMap', () {
      final mapWithoutComment = Map<String, dynamic>.from(testRatingMap);
      mapWithoutComment.remove('comment');

      final result = RatingModel.fromMap(mapWithoutComment);
      expect(result.comment, isNull);
    });

    group('Rating validation tests', () {
      test('should handle minimum rating', () {
        final minRating = testRating.copyWith(rating: 1.0);
        expect(minRating.rating, 1.0);
      });

      test('should handle maximum rating', () {
        final maxRating = testRating.copyWith(rating: 5.0);
        expect(maxRating.rating, 5.0);
      });

      test('should handle decimal ratings', () {
        final decimalRating = testRating.copyWith(rating: 3.7);
        expect(decimalRating.rating, 3.7);
      });

      test('should handle zero rating', () {
        final zeroRating = testRating.copyWith(rating: 0.0);
        expect(zeroRating.rating, 0.0);
      });

      test('should handle negative rating', () {
        final negativeRating = testRating.copyWith(rating: -1.0);
        expect(negativeRating.rating, -1.0);
      });

      test('should handle rating above 5', () {
        final highRating = testRating.copyWith(rating: 6.0);
        expect(highRating.rating, 6.0);
      });
    });

    group('Comment validation tests', () {
      test('should handle empty comment', () {
        final emptyComment = testRating.copyWith(comment: '');
        expect(emptyComment.comment, '');
      });

      test('should handle very long comment', () {
        final longComment = 'A' * 1000;
        final longCommentRating = testRating.copyWith(comment: longComment);
        expect(longCommentRating.comment, longComment);
        expect(longCommentRating.comment!.length, 1000);
      });

      test('should handle special characters in comment', () {
        final specialComment = 'Great food! 😋 5/5 stars ⭐⭐⭐⭐⭐';
        final specialRating = testRating.copyWith(comment: specialComment);
        expect(specialRating.comment, specialComment);
      });
    });

    group('Edge cases', () {
      test('should handle null values in fromMap', () {
        final mapWithNulls = {
          'id': null,
          'vendorId': null,
          'customerId': null,
          'customerName': null,
          'rating': null,
          'comment': null,
          'createdAt': DateTime.now().toIso8601String(),
        };

        final result = RatingModel.fromMap(mapWithNulls);
        expect(result.id, '');
        expect(result.vendorId, '');
        expect(result.customerId, '');
        expect(result.customerName, '');
        expect(result.rating, 0.0);
        expect(result.comment, isNull);
      });

      test('should handle invalid rating type in fromMap', () {
        final mapWithInvalidRating = Map<String, dynamic>.from(testRatingMap);
        mapWithInvalidRating['rating'] = 'invalid';

        expect(
          () => RatingModel.fromMap(mapWithInvalidRating),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle DateTime parsing errors', () {
        final mapWithInvalidDate = Map<String, dynamic>.from(testRatingMap);
        mapWithInvalidDate['createdAt'] = 'invalid-date';

        expect(
          () => RatingModel.fromMap(mapWithInvalidDate),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('Business logic tests', () {
      test('should identify high rating', () {
        final highRating = testRating.copyWith(rating: 4.5);
        expect(highRating.rating >= 4.0, true);
      });

      test('should identify low rating', () {
        final lowRating = testRating.copyWith(rating: 2.0);
        expect(lowRating.rating < 3.0, true);
      });

      test('should handle rating with comment', () {
        expect(testRating.comment, isNotNull);
        expect(testRating.comment!.isNotEmpty, true);
      });

      test('should handle rating without comment', () {
        final noCommentRating = testRating.copyWith(comment: null);
        expect(noCommentRating.comment, isNull);
      });
    });
  });
}