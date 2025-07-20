import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/models/vendor_model.dart';
import 'package:streetbite/models/menu_item_model.dart';
import 'package:streetbite/models/rating_model.dart';
import 'package:streetbite/providers/vendor_provider.dart';
import 'package:streetbite/providers/menu_provider.dart';
import 'package:streetbite/providers/rating_provider.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Performance Tests', () {
    group('Large Dataset Handling', () {
      test('should handle 1000 vendors efficiently', () async {
        final stopwatch = Stopwatch()..start();
        
        // Create large vendor list
        final vendors = List.generate(1000, (index) => 
          TestHelpers.createMockVendor(
            id: 'vendor_$index',
            name: 'Vendor $index',
          )
        );
        
        stopwatch.stop();
        
        // Should complete within reasonable time (< 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(vendors.length, 1000);
      });

      test('should handle 5000 menu items efficiently', () async {
        final stopwatch = Stopwatch()..start();
        
        // Create large menu item list
        final menuItems = TestHelpers.createLargeMenuItemList(5000, 'vendor_1');
        
        stopwatch.stop();
        
        // Should complete within reasonable time (< 200ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        expect(menuItems.length, 5000);
      });

      test('should handle 10000 ratings efficiently', () async {
        final stopwatch = Stopwatch()..start();
        
        // Create large ratings list
        final ratings = List.generate(10000, (index) => 
          TestHelpers.createMockRating(
            id: 'rating_$index',
            vendorId: 'vendor_${index % 100}', // Distribute across 100 vendors
            rating: 1.0 + (index % 5), // Ratings 1-5
          )
        );
        
        stopwatch.stop();
        
        // Should complete within reasonable time (< 300ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(300));
        expect(ratings.length, 10000);
      });
    });

    group('Provider Performance', () {
      test('VendorProvider should filter large lists efficiently', () async {
        final vendorProvider = VendorProvider();
        final stopwatch = Stopwatch();
        
        // Create large vendor list with different cuisine types
        final vendors = List.generate(1000, (index) => 
          TestHelpers.createMockVendor(
            id: 'vendor_$index',
            name: 'Vendor $index',
            cuisineType: ['Italian', 'Chinese', 'Mexican', 'Indian'][index % 4],
          )
        );
        
        // Simulate loading vendors
        vendorProvider.setVendors(vendors);
        
        stopwatch.start();
        vendorProvider.filterVendors('Italian');
        stopwatch.stop();
        
        // Filtering should be fast (< 50ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
        expect(vendorProvider.filteredVendors.length, 250); // 1/4 of vendors
      });

      test('MenuProvider should filter large menu efficiently', () async {
        final menuProvider = MenuProvider();
        final stopwatch = Stopwatch();
        
        // Create large menu with different categories
        final menuItems = List.generate(2000, (index) => 
          TestHelpers.createMockMenuItem(
            id: 'item_$index',
            name: 'Item $index',
            category: ['Appetizers', 'Main Course', 'Desserts', 'Beverages'][index % 4],
          )
        );
        
        // Simulate loading menu items
        menuProvider.setMenuItems(menuItems);
        
        stopwatch.start();
        menuProvider.filterByCategory('Main Course');
        stopwatch.stop();
        
        // Filtering should be fast (< 30ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(30));
        expect(menuProvider.filteredMenuItems.length, 500); // 1/4 of items
      });
    });

    group('Memory Usage Tests', () {
      test('should not leak memory with repeated operations', () async {
        final vendorProvider = VendorProvider();
        
        // Perform repeated operations that could cause memory leaks
        for (int i = 0; i < 100; i++) {
          final vendors = List.generate(100, (index) => 
            TestHelpers.createMockVendor(id: 'vendor_${i}_$index')
          );
          
          vendorProvider.setVendors(vendors);
          vendorProvider.filterVendors('Italian');
          vendorProvider.clearVendors();
        }
        
        // Test should complete without memory issues
        expect(vendorProvider.vendors, isEmpty);
      });

      test('should handle rapid state changes efficiently', () async {
        final menuProvider = MenuProvider();
        final stopwatch = Stopwatch()..start();
        
        // Rapid state changes
        for (int i = 0; i < 1000; i++) {
          menuProvider.filterByCategory(['All', 'Appetizers', 'Main Course', 'Desserts'][i % 4]);
        }
        
        stopwatch.stop();
        
        // Should handle rapid changes efficiently (< 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Serialization Performance', () {
      test('should serialize large vendor list efficiently', () async {
        final vendors = List.generate(1000, (index) => 
          TestHelpers.createMockVendor(id: 'vendor_$index')
        );
        
        final stopwatch = Stopwatch()..start();
        
        // Serialize all vendors
        final serialized = vendors.map((v) => v.toMap()).toList();
        
        stopwatch.stop();
        
        // Serialization should be fast (< 200ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        expect(serialized.length, 1000);
      });

      test('should deserialize large vendor list efficiently', () async {
        final vendorMaps = List.generate(1000, (index) => {
          'id': 'vendor_$index',
          'userId': 'user_$index',
          'name': 'Vendor $index',
          'cuisineType': 'Italian',
          'status': 'VendorStatus.open',
          'stallType': 'StallType.fixed',
          'location': {'latitude': 37.7749, 'longitude': -122.4194},
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
        
        final stopwatch = Stopwatch()..start();
        
        // Deserialize all vendors
        final vendors = vendorMaps.map((m) => VendorModel.fromMap(m)).toList();
        
        stopwatch.stop();
        
        // Deserialization should be fast (< 300ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(300));
        expect(vendors.length, 1000);
      });
    });

    group('Search Performance', () {
      test('should search through large vendor list efficiently', () async {
        final vendors = List.generate(5000, (index) => 
          TestHelpers.createMockVendor(
            id: 'vendor_$index',
            name: 'Restaurant ${index % 100}', // Create some duplicates for realistic search
            cuisineType: ['Italian', 'Chinese', 'Mexican', 'Indian', 'Thai'][index % 5],
          )
        );
        
        final stopwatch = Stopwatch()..start();
        
        // Search by name
        final searchResults = vendors.where((v) => 
          v.name.toLowerCase().contains('restaurant 5')
        ).toList();
        
        stopwatch.stop();
        
        // Search should be fast (< 50ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
        expect(searchResults.isNotEmpty, true);
      });

      test('should filter and search simultaneously efficiently', () async {
        final vendors = List.generate(2000, (index) => 
          TestHelpers.createMockVendor(
            id: 'vendor_$index',
            name: 'Restaurant $index',
            cuisineType: ['Italian', 'Chinese'][index % 2],
          )
        );
        
        final stopwatch = Stopwatch()..start();
        
        // Combined filter and search
        final results = vendors.where((v) => 
          v.cuisineType == 'Italian' && 
          v.name.toLowerCase().contains('restaurant')
        ).toList();
        
        stopwatch.stop();
        
        // Combined operation should be fast (< 30ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(30));
        expect(results.length, 1000); // Half should be Italian
      });
    });

    group('UI Performance', () {
      testWidgets('should render large lists efficiently', (WidgetTester tester) async {
        final vendors = List.generate(100, (index) => 
          TestHelpers.createMockVendor(id: 'vendor_$index')
        );
        
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: vendors.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(vendors[index].name),
                  subtitle: Text(vendors[index].cuisineType),
                ),
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        stopwatch.stop();
        
        // UI rendering should be fast (< 500ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        expect(find.byType(ListTile), findsWidgets);
      });

      testWidgets('should handle rapid scrolling efficiently', (WidgetTester tester) async {
        final vendors = List.generate(1000, (index) => 
          TestHelpers.createMockVendor(id: 'vendor_$index')
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: vendors.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(vendors[index].name),
                ),
              ),
            ),
          ),
        );
        
        final stopwatch = Stopwatch()..start();
        
        // Simulate rapid scrolling
        await tester.fling(find.byType(ListView), const Offset(0, -1000), 5000);
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // Scrolling should be smooth (< 200ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });
    });
  });
}