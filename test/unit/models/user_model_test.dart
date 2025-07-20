import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    late UserModel testUser;
    late Map<String, dynamic> testUserMap;

    setUp(() {
      testUser = UserModel(
        id: 'test_id',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        userType: UserType.customer,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      testUserMap = {
        'id': 'test_id',
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '+1234567890',
        'userType': 'UserType.customer',
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      };
    });

    test('should create UserModel with all properties', () {
      expect(testUser.id, 'test_id');
      expect(testUser.name, 'John Doe');
      expect(testUser.email, 'john@example.com');
      expect(testUser.phone, '+1234567890');
      expect(testUser.userType, UserType.customer);
      expect(testUser.createdAt, DateTime(2024, 1, 1));
      expect(testUser.updatedAt, DateTime(2024, 1, 2));
    });

    test('should create UserModel without phone', () {
      final userWithoutPhone = UserModel(
        id: 'test_id',
        name: 'Jane Doe',
        email: 'jane@example.com',
        userType: UserType.vendor,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(userWithoutPhone.phone, isNull);
      expect(userWithoutPhone.userType, UserType.vendor);
    });

    test('should convert UserModel to Map correctly', () {
      final result = testUser.toMap();
      expect(result, equals(testUserMap));
    });

    test('should create UserModel from Map correctly', () {
      final result = UserModel.fromMap(testUserMap);
      
      expect(result.id, testUser.id);
      expect(result.name, testUser.name);
      expect(result.email, testUser.email);
      expect(result.phone, testUser.phone);
      expect(result.userType, testUser.userType);
      expect(result.createdAt, testUser.createdAt);
      expect(result.updatedAt, testUser.updatedAt);
    });

    test('should handle missing phone in fromMap', () {
      final mapWithoutPhone = Map<String, dynamic>.from(testUserMap);
      mapWithoutPhone.remove('phone');

      final result = UserModel.fromMap(mapWithoutPhone);
      expect(result.phone, isNull);
    });

    test('should default to customer userType for invalid enum', () {
      final mapWithInvalidUserType = Map<String, dynamic>.from(testUserMap);
      mapWithInvalidUserType['userType'] = 'InvalidType';

      final result = UserModel.fromMap(mapWithInvalidUserType);
      expect(result.userType, UserType.customer);
    });

    test('should handle empty or null values in fromMap', () {
      final emptyMap = {
        'id': '',
        'name': '',
        'email': '',
        'userType': 'UserType.customer',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final result = UserModel.fromMap(emptyMap);
      expect(result.id, '');
      expect(result.name, '');
      expect(result.email, '');
      expect(result.phone, isNull);
    });

    group('UserType enum tests', () {
      test('should have correct enum values', () {
        expect(UserType.values.length, 2);
        expect(UserType.values, contains(UserType.vendor));
        expect(UserType.values, contains(UserType.customer));
      });

      test('should convert enum to string correctly', () {
        expect(UserType.vendor.toString(), 'UserType.vendor');
        expect(UserType.customer.toString(), 'UserType.customer');
      });
    });

    group('Edge cases', () {
      test('should handle DateTime parsing errors gracefully', () {
        final mapWithInvalidDate = Map<String, dynamic>.from(testUserMap);
        mapWithInvalidDate['createdAt'] = 'invalid-date';

        expect(
          () => UserModel.fromMap(mapWithInvalidDate),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle null map values', () {
        final mapWithNulls = {
          'id': null,
          'name': null,
          'email': null,
          'phone': null,
          'userType': null,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final result = UserModel.fromMap(mapWithNulls);
        expect(result.id, '');
        expect(result.name, '');
        expect(result.email, '');
        expect(result.phone, isNull);
        expect(result.userType, UserType.customer);
      });
    });
  });
}