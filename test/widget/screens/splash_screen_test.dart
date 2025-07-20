import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:streetbite/screens/splash_screen.dart';
import 'package:streetbite/providers/auth_provider.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
    });

    testWidgets('should display app logo and title', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SplashScreen(),
          authProvider: mockAuthProvider,
        ),
      );

      // Verify app title is displayed
      expect(find.text('StreetBite'), findsOneWidget);
      expect(find.text('Discover Street Food Near You'), findsOneWidget);
      
      // Verify app icon is displayed
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('should show loading indicator', (WidgetTester tester) async {
      mockAuthProvider.setLoading(true);

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SplashScreen(),
          authProvider: mockAuthProvider,
        ),
      );

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should navigate to user type selection when not authenticated', 
        (WidgetTester tester) async {
      mockAuthProvider.setLoading(false);
      mockAuthProvider.setMockUser(null);

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SplashScreen(),
          authProvider: mockAuthProvider,
        ),
      );

      await tester.pumpAndSettle();

      // Should navigate away from splash screen
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('should navigate to appropriate dashboard when authenticated', 
        (WidgetTester tester) async {
      final testUser = TestHelpers.createMockUser();
      mockAuthProvider.setLoading(false);
      mockAuthProvider.setMockUser(testUser);

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SplashScreen(),
          authProvider: mockAuthProvider,
        ),
      );

      await tester.pumpAndSettle();

      // Should navigate away from splash screen
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('should handle authentication errors gracefully', 
        (WidgetTester tester) async {
      mockAuthProvider.setLoading(false);
      mockAuthProvider.setError('Authentication failed');

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SplashScreen(),
          authProvider: mockAuthProvider,
        ),
      );

      await tester.pumpAndSettle();

      // Should still show splash screen or navigate to error state
      // Exact behavior depends on implementation
      expect(find.byType(SplashScreen), findsAny);
    });

    testWidgets('should have correct theme and styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SplashScreen(),
          authProvider: mockAuthProvider,
        ),
      );

      // Verify background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);

      // Verify text styling
      final titleText = tester.widget<Text>(find.text('StreetBite'));
      expect(titleText.style?.fontSize, greaterThan(20));
      expect(titleText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should be responsive to different screen sizes', 
        (WidgetTester tester) async {
      // Test with small screen
      await tester.binding.setSurfaceSize(const Size(320, 568));
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SplashScreen(),
          authProvider: mockAuthProvider,
        ),
      );

      expect(find.text('StreetBite'), findsOneWidget);

      // Test with large screen
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SplashScreen(),
          authProvider: mockAuthProvider,
        ),
      );

      expect(find.text('StreetBite'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('should handle rapid state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SplashScreen(),
          authProvider: mockAuthProvider,
        ),
      );

      // Rapidly change states
      mockAuthProvider.setLoading(true);
      await tester.pump();
      
      mockAuthProvider.setLoading(false);
      await tester.pump();
      
      mockAuthProvider.setError('Error');
      await tester.pump();
      
      mockAuthProvider.setError(null);
      await tester.pump();

      // Should handle state changes without crashing
      expect(tester.takeException(), isNull);
    });

    group('Accessibility tests', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const SplashScreen(),
            authProvider: mockAuthProvider,
          ),
        );

        // Verify semantic labels for accessibility
        expect(find.bySemanticsLabel('StreetBite app logo'), findsAny);
        expect(find.bySemanticsLabel('Loading'), findsAny);
      });

      testWidgets('should support screen readers', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const SplashScreen(),
            authProvider: mockAuthProvider,
          ),
        );

        // Verify that important elements are accessible
        final semantics = tester.getSemantics(find.text('StreetBite'));
        expect(semantics.label, isNotNull);
      });
    });

    group('Animation tests', () {
      testWidgets('should animate logo appearance', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const SplashScreen(),
            authProvider: mockAuthProvider,
          ),
        );

        // Test animation if implemented
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 500));
        
        expect(find.byIcon(Icons.restaurant), findsOneWidget);
      });

      testWidgets('should handle animation completion', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: const SplashScreen(),
            authProvider: mockAuthProvider,
          ),
        );

        // Wait for animations to complete
        await tester.pumpAndSettle();
        
        expect(tester.takeException(), isNull);
      });
    });
  });
}