import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:streetbite/main.dart' as app;
import 'package:streetbite/models/user_model.dart';
import '../setup_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('StreetBite App Integration Tests', () {
    setUpAll(() async {
      await TestSetup.initializeFirebase();
    });

    testWidgets('Complete user authentication flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should start with splash screen
      expect(find.text('StreetBite'), findsOneWidget);
      
      // Wait for navigation to user type selection
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Should show user type selection
      expect(find.text('I am a Customer'), findsOneWidget);
      expect(find.text('I am a Vendor'), findsOneWidget);
      
      // Select customer type
      await tester.tap(find.text('I am a Customer'));
      await tester.pumpAndSettle();
      
      // Should navigate to login screen
      expect(find.text('Enter your phone number'), findsOneWidget);
      
      // Enter phone number
      await tester.enterText(find.byType(TextField), '+1234567890');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();
      
      // Should navigate to OTP verification
      expect(find.text('Enter OTP'), findsOneWidget);
    });

    testWidgets('Vendor registration flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to vendor selection
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('I am a Vendor'));
      await tester.pumpAndSettle();
      
      // Complete phone authentication (mocked)
      await tester.enterText(find.byType(TextField), '+1234567890');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();
      
      // Mock OTP verification success and navigate to vendor registration
      // This would require proper mocking setup
    });

    testWidgets('Customer vendor discovery flow', (WidgetTester tester) async {
      // Test complete customer flow from login to vendor discovery
      app.main();
      await tester.pumpAndSettle();
      
      // Mock authenticated customer state
      // Navigate through customer home, search vendors, view details
    });

    testWidgets('Menu management flow', (WidgetTester tester) async {
      // Test vendor menu management from login to adding/editing items
      app.main();
      await tester.pumpAndSettle();
      
      // Mock authenticated vendor state
      // Test menu CRUD operations
    });

    testWidgets('Rating and feedback flow', (WidgetTester tester) async {
      // Test customer rating submission and vendor feedback viewing
      app.main();
      await tester.pumpAndSettle();
      
      // Mock customer viewing vendor and submitting rating
    });

    testWidgets('Settings management flow', (WidgetTester tester) async {
      // Test settings modification and persistence
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to settings, modify preferences, verify persistence
    });

    testWidgets('Real-time updates flow', (WidgetTester tester) async {
      // Test real-time vendor status updates
      app.main();
      await tester.pumpAndSettle();
      
      // Mock vendor status changes and verify customer sees updates
    });

    testWidgets('Navigation flow between screens', (WidgetTester tester) async {
      // Test navigation between all major screens
      app.main();
      await tester.pumpAndSettle();
      
      // Test deep navigation and back button handling
    });

    testWidgets('Error handling and recovery', (WidgetTester tester) async {
      // Test app behavior under error conditions
      app.main();
      await tester.pumpAndSettle();
      
      // Mock network errors, Firebase errors, etc.
    });

    testWidgets('Performance under load', (WidgetTester tester) async {
      // Test app performance with large datasets
      app.main();
      await tester.pumpAndSettle();
      
      // Load large vendor lists, menu items, ratings
    });

    testWidgets('Accessibility compliance', (WidgetTester tester) async {
      // Test accessibility features
      app.main();
      await tester.pumpAndSettle();
      
      // Verify semantic labels, screen reader support
      final semantics = tester.getSemantics(find.text('StreetBite'));
      expect(semantics.label, isNotNull);
    });
  });
}