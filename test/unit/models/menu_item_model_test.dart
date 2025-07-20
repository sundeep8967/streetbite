import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/models/menu_item_model.dart';

void main() {
  group('MenuItemModel Tests', () {
    late MenuItemModel testMenuItem;
    late Map<String, dynamic> testMenuItemMap;

    setUp(() {
      testMenuItem = MenuItemModel(
        id: 'menu_item_id',
        vendorId: 'vendor_id',
        name: 'Margherita Pizza',
        description: 'Classic pizza with tomato, mozzarella, and basil',
        price: 12.99,
        imageUrl: 'https://example.com/pizza.jpg',
        category: 'Main Course',
        isAvailable: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      testMenuItemMap = {
        'id': 'menu_item_id',
        'vendorId': 'vendor_id',
        'name': 'Margherita Pizza',
        'description': 'Classic pizza with tomato, mozzarella, and basil',
        'price': 12.99,
        'imageUrl': 'https://example.com/pizza.jpg',
        'category': 'Main Course',
        'isAvailable': true,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      };
    });

    test('should create MenuItemModel with all properties', () {
      expect(testMenuItem.id, 'menu_item_id');
      expect(testMenuItem.vendorId, 'vendor_id');
      expect(testMenuItem.name, 'Margherita Pizza');
      expect(testMenuItem.description, 'Classic pizza with tomato, mozzarella, and basil');
      expect(testMenuItem.price, 12.99);
      expect(testMenuItem.imageUrl, 'https://example.com/pizza.jpg');
      expect(testMenuItem.category, 'Main Course');
      expect(testMenuItem.isAvailable, true);
      expect(testMenuItem.createdAt, DateTime(2024, 1, 1));
      expect(testMenuItem.updatedAt, DateTime(2024, 1, 2));
    });

    test('should create MenuItemModel with default availability', () {
      final menuItemWithDefaults = MenuItemModel(
        id: 'menu_item_id',
        vendorId: 'vendor_id',
        name: 'Test Item',
        price: 10.0,
        category: 'Test Category',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(menuItemWithDefaults.isAvailable, true);
      expect(menuItemWithDefaults.description, isNull);
      expect(menuItemWithDefaults.imageUrl, isNull);
    });

    test('should convert MenuItemModel to Map correctly', () {
      final result = testMenuItem.toMap();
      expect(result, equals(testMenuItemMap));
    });

    test('should create MenuItemModel from Map correctly', () {
      final result = MenuItemModel.fromMap(testMenuItemMap);
      
      expect(result.id, testMenuItem.id);
      expect(result.vendorId, testMenuItem.vendorId);
      expect(result.name, testMenuItem.name);
      expect(result.description, testMenuItem.description);
      expect(result.price, testMenuItem.price);
      expect(result.imageUrl, testMenuItem.imageUrl);
      expect(result.category, testMenuItem.category);
      expect(result.isAvailable, testMenuItem.isAvailable);
      expect(result.createdAt, testMenuItem.createdAt);
      expect(result.updatedAt, testMenuItem.updatedAt);
    });

    test('should handle missing optional fields in fromMap', () {
      final minimalMap = {
        'id': 'menu_item_id',
        'vendorId': 'vendor_id',
        'name': 'Test Item',
        'price': 10.0,
        'category': 'Test Category',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final result = MenuItemModel.fromMap(minimalMap);
      expect(result.description, isNull);
      expect(result.imageUrl, isNull);
      expect(result.isAvailable, true);
    });

    test('should use copyWith correctly', () {
      final updatedMenuItem = testMenuItem.copyWith(
        name: 'Updated Pizza',
        price: 15.99,
        isAvailable: false,
      );

      expect(updatedMenuItem.name, 'Updated Pizza');
      expect(updatedMenuItem.price, 15.99);
      expect(updatedMenuItem.isAvailable, false);
      // Other properties should remain the same
      expect(updatedMenuItem.id, testMenuItem.id);
      expect(updatedMenuItem.vendorId, testMenuItem.vendorId);
      expect(updatedMenuItem.description, testMenuItem.description);
      expect(updatedMenuItem.category, testMenuItem.category);
    });

    test('should handle copyWith with null values', () {
      final updatedMenuItem = testMenuItem.copyWith(
        description: null,
        imageUrl: null,
      );

      expect(updatedMenuItem.description, isNull);
      expect(updatedMenuItem.imageUrl, isNull);
      // Other properties should remain the same
      expect(updatedMenuItem.name, testMenuItem.name);
      expect(updatedMenuItem.price, testMenuItem.price);
    });

    group('Price validation tests', () {
      test('should handle zero price', () {
        final freeItem = testMenuItem.copyWith(price: 0.0);
        expect(freeItem.price, 0.0);
      });

      test('should handle negative price', () {
        final negativeItem = testMenuItem.copyWith(price: -5.0);
        expect(negativeItem.price, -5.0); // Model doesn't validate, just stores
      });

      test('should handle very large price', () {
        final expensiveItem = testMenuItem.copyWith(price: 999999.99);
        expect(expensiveItem.price, 999999.99);
      });

      test('should handle price with many decimal places', () {
        final preciseItem = testMenuItem.copyWith(price: 12.999999);
        expect(preciseItem.price, 12.999999);
      });
    });

    group('Edge cases', () {
      test('should handle null values in fromMap', () {
        final mapWithNulls = {
          'id': null,
          'vendorId': null,
          'name': null,
          'description': null,
          'price': null,
          'imageUrl': null,
          'category': null,
          'isAvailable': null,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final result = MenuItemModel.fromMap(mapWithNulls);
        expect(result.id, '');
        expect(result.vendorId, '');
        expect(result.name, '');
        expect(result.description, isNull);
        expect(result.price, 0.0);
        expect(result.imageUrl, isNull);
        expect(result.category, '');
        expect(result.isAvailable, true);
      });

      test('should handle invalid price type in fromMap', () {
        final mapWithInvalidPrice = Map<String, dynamic>.from(testMenuItemMap);
        mapWithInvalidPrice['price'] = 'invalid_price';

        expect(
          () => MenuItemModel.fromMap(mapWithInvalidPrice),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle string price in fromMap', () {
        final mapWithStringPrice = Map<String, dynamic>.from(testMenuItemMap);
        mapWithStringPrice['price'] = '12.99';

        final result = MenuItemModel.fromMap(mapWithStringPrice);
        expect(result.price, 12.99);
      });

      test('should handle integer price in fromMap', () {
        final mapWithIntPrice = Map<String, dynamic>.from(testMenuItemMap);
        mapWithIntPrice['price'] = 13;

        final result = MenuItemModel.fromMap(mapWithIntPrice);
        expect(result.price, 13.0);
      });
    });

    group('Business logic tests', () {
      test('should correctly identify available item', () {
        expect(testMenuItem.isAvailable, true);
      });

      test('should correctly identify unavailable item', () {
        final unavailableItem = testMenuItem.copyWith(isAvailable: false);
        expect(unavailableItem.isAvailable, false);
      });

      test('should handle empty name', () {
        final itemWithEmptyName = testMenuItem.copyWith(name: '');
        expect(itemWithEmptyName.name, '');
      });

      test('should handle very long name', () {
        final longName = 'A' * 1000;
        final itemWithLongName = testMenuItem.copyWith(name: longName);
        expect(itemWithLongName.name, longName);
        expect(itemWithLongName.name.length, 1000);
      });

      test('should handle very long description', () {
        final longDescription = 'B' * 5000;
        final itemWithLongDescription = testMenuItem.copyWith(description: longDescription);
        expect(itemWithLongDescription.description, longDescription);
        expect(itemWithLongDescription.description!.length, 5000);
      });

      test('should handle special characters in name and description', () {
        final specialName = 'Café Latté with ñ and émojis 🍕';
        final specialDescription = 'Special chars: @#\$%^&*()_+-=[]{}|;:,.<>?';
        
        final specialItem = testMenuItem.copyWith(
          name: specialName,
          description: specialDescription,
        );
        
        expect(specialItem.name, specialName);
        expect(specialItem.description, specialDescription);
      });
    });

    group('DateTime handling', () {
      test('should handle DateTime serialization and deserialization', () {
        final now = DateTime.now();
        final item = testMenuItem.copyWith(
          createdAt: now,
          updatedAt: now,
        );
        
        final map = item.toMap();
        final reconstructed = MenuItemModel.fromMap(map);
        
        expect(reconstructed.createdAt, now);
        expect(reconstructed.updatedAt, now);
      });

      test('should handle invalid DateTime in fromMap', () {
        final mapWithInvalidDate = Map<String, dynamic>.from(testMenuItemMap);
        mapWithInvalidDate['createdAt'] = 'invalid-date';

        expect(
          () => MenuItemModel.fromMap(mapWithInvalidDate),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}