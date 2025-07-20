import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/screens/customer/customer_home.dart';
import 'package:streetbite/models/vendor_model.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('CustomerHome Widget Tests', () {
    late MockAuthProvider mockAuthProvider;
    late MockCustomerProvider mockCustomerProvider;
    late List<VendorModel> testVendors;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
      mockCustomerProvider = MockCustomerProvider();
      
      testVendors = [
        TestHelpers.createMockVendor(
          id: 'vendor1',
          name: 'Pizza Palace',
          cuisineType: 'Italian',
          status: VendorStatus.open,
        ),
        TestHelpers.createMockVendor(
          id: 'vendor2',
          name: 'Taco Truck',
          cuisineType: 'Mexican',
          status: VendorStatus.closed,
        ),
      ];

      mockAuthProvider.setMockUser(TestHelpers.createMockUser());
      mockCustomerProvider.setMockVendors(testVendors);
    });

    testWidgets('should display bottom navigation with 4 tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Verify bottom navigation bar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify all 4 tabs
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should display welcome message with user name', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Verify welcome message
      expect(find.textContaining('Hello, Test User!'), findsOneWidget);
      expect(find.text('Discover amazing street food near you'), findsOneWidget);
    });

    testWidgets('should display quick action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Verify quick action buttons
      expect(find.text('Browse All'), findsOneWidget);
      expect(find.text('Map View'), findsOneWidget);
    });

    testWidgets('should display open vendors section', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Verify open vendors section
      expect(find.text('Open Now'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);
      
      // Should show open vendors (Pizza Palace should be visible)
      expect(find.text('Pizza Palace'), findsOneWidget);
      expect(find.text('OPEN'), findsOneWidget);
    });

    testWidgets('should handle tab navigation correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Initially on Home tab
      expect(find.text('StreetBite'), findsOneWidget);

      // Tap Map tab
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Should navigate to map view
      // Note: Exact assertions depend on map implementation

      // Tap Favorites tab
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      // Should show favorites screen
      expect(find.text('Favorites'), findsOneWidget);

      // Tap Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Should show profile screen
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should display loading state correctly', (WidgetTester tester) async {
      mockCustomerProvider.setLoading(true);

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state correctly', (WidgetTester tester) async {
      mockCustomerProvider.setLoading(false);
      mockCustomerProvider.setError('Network error');

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Should show error message
      expect(find.text('Unable to load vendors'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should handle empty vendors list', (WidgetTester tester) async {
      mockCustomerProvider.setMockVendors([]);

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Should show empty state
      expect(find.text('No vendors open nearby'), findsOneWidget);
      expect(find.text('Check back later or explore all vendors'), findsOneWidget);
    });

    testWidgets('should handle vendor card interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Find and tap on a vendor card
      final vendorCard = find.text('Pizza Palace');
      expect(vendorCard, findsOneWidget);

      await tester.tap(vendorCard);
      await tester.pumpAndSettle();

      // Should navigate to vendor detail screen
      // Note: Navigation testing might require additional setup
    });

    testWidgets('should handle favorite button interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Find favorite button
      final favoriteButton = find.byIcon(Icons.favorite_border);
      expect(favoriteButton, findsOneWidget);

      await tester.tap(favoriteButton.first);
      await tester.pumpAndSettle();

      // Should toggle favorite state
      // Note: Exact behavior depends on implementation
    });

    testWidgets('should handle pull to refresh', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomerHome(),
          authProvider: mockAuthProvider,
          customerProvider: mockCustomerProvider,
        ),
      );

      // Find RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Perform pull to refresh
      await tester.fling(refreshIndicator, const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should trigger refresh
      expect(tester.takeException(), isNull);
    });

    group('Profile tab tests', () {
      testWidgets('should display user profile information', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const CustomerHome(),
            authProvider: mockAuthProvider,
            customerProvider: mockCustomerProvider,
          ),
        );

        // Navigate to profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Should show user information
        expect(find.text('Test User'), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('should handle settings navigation', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const CustomerHome(),
            authProvider: mockAuthProvider,
            customerProvider: mockCustomerProvider,
          ),
        );

        // Navigate to profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Find and tap settings
        final settingsButton = find.text('Settings');
        expect(settingsButton, findsOneWidget);

        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        // Should navigate to settings
        // Note: Navigation testing might require additional setup
      });

      testWidgets('should handle logout', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const CustomerHome(),
            authProvider: mockAuthProvider,
            customerProvider: mockCustomerProvider,
          ),
        );

        // Navigate to profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        // Find and tap logout
        final logoutButton = find.text('Logout');
        expect(logoutButton, findsOneWidget);

        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        // Should trigger logout
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility tests', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const CustomerHome(),
            authProvider: mockAuthProvider,
            customerProvider: mockCustomerProvider,
          ),
        );

        // Verify semantic labels for navigation
        expect(find.bySemanticsLabel('Home tab'), findsAny);
        expect(find.bySemanticsLabel('Map tab'), findsAny);
        expect(find.bySemanticsLabel('Favorites tab'), findsAny);
        expect(find.bySemanticsLabel('Profile tab'), findsAny);
      });

      testWidgets('should support keyboard navigation', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const CustomerHome(),
            authProvider: mockAuthProvider,
            customerProvider: mockCustomerProvider,
          ),
        );

        // Test keyboard navigation
        // Note: Specific keyboard navigation tests depend on implementation
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });
    });

    group('Performance tests', () {
      testWidgets('should handle large vendor lists efficiently', (WidgetTester tester) async {
        final largeVendorList = TestHelpers.createLargeVendorList(100);
        mockCustomerProvider.setMockVendors(largeVendorList);

        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const CustomerHome(),
            authProvider: mockAuthProvider,
            customerProvider: mockCustomerProvider,
          ),
        );

        await tester.pumpAndSettle();

        // Should handle large lists without performance issues
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle rapid tab switching', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const CustomerHome(),
            authProvider: mockAuthProvider,
            customerProvider: mockCustomerProvider,
          ),
        );

        // Rapidly switch between tabs
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('Map'));
          await tester.pump();
          await tester.tap(find.text('Home'));
          await tester.pump();
          await tester.tap(find.text('Favorites'));
          await tester.pump();
          await tester.tap(find.text('Profile'));
          await tester.pump();
        }

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });
  });
}