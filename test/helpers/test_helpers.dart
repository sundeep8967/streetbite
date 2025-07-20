import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:streetbite/providers/auth_provider.dart';
import 'package:streetbite/providers/vendor_provider.dart';
import 'package:streetbite/providers/customer_provider.dart';
import 'package:streetbite/providers/menu_provider.dart';
import 'package:streetbite/providers/rating_provider.dart';
import 'package:streetbite/providers/settings_provider.dart';
import 'package:streetbite/models/user_model.dart';
import 'package:streetbite/models/vendor_model.dart';
import 'package:streetbite/models/menu_item_model.dart';
import 'package:streetbite/models/rating_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Test helper utilities for StreetBite app testing
class TestHelpers {
  /// Creates a test app wrapper with all providers
  static Widget createTestApp({
    required Widget child,
    AuthProvider? authProvider,
    VendorProvider? vendorProvider,
    CustomerProvider? customerProvider,
    MenuProvider? menuProvider,
    RatingProvider? ratingProvider,
    SettingsProvider? settingsProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider ?? MockAuthProvider(),
        ),
        ChangeNotifierProvider<VendorProvider>(
          create: (_) => vendorProvider ?? MockVendorProvider(),
        ),
        ChangeNotifierProvider<CustomerProvider>(
          create: (_) => customerProvider ?? MockCustomerProvider(),
        ),
        ChangeNotifierProvider<MenuProvider>(
          create: (_) => menuProvider ?? MockMenuProvider(),
        ),
        ChangeNotifierProvider<RatingProvider>(
          create: (_) => ratingProvider ?? MockRatingProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => settingsProvider ?? MockSettingsProvider(),
        ),
      ],
      child: MaterialApp(
        home: child,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
    );
  }

  /// Creates a mock user for testing
  static UserModel createMockUser({
    String id = 'test_user_id',
    String name = 'Test User',
    String email = 'test@example.com',
    String? phone = '+1234567890',
    UserType userType = UserType.customer,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      userType: userType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a mock vendor for testing
  static VendorModel createMockVendor({
    String id = 'test_vendor_id',
    String userId = 'test_user_id',
    String name = 'Test Vendor',
    String cuisineType = 'Italian',
    VendorStatus status = VendorStatus.open,
    StallType stallType = StallType.fixed,
    double latitude = 37.7749,
    double longitude = -122.4194,
    String? address = '123 Test Street',
    double rating = 4.5,
    int totalRatings = 10,
  }) {
    return VendorModel(
      id: id,
      userId: userId,
      name: name,
      cuisineType: cuisineType,
      status: status,
      stallType: stallType,
      location: GeoPoint(latitude, longitude),
      address: address,
      menu: [],
      followers: [],
      rating: rating,
      totalRatings: totalRatings,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a mock menu item for testing
  static MenuItemModel createMockMenuItem({
    String id = 'test_menu_item_id',
    String vendorId = 'test_vendor_id',
    String name = 'Test Pizza',
    String? description = 'Delicious test pizza',
    double price = 12.99,
    String category = 'Main Course',
    bool isAvailable = true,
  }) {
    return MenuItemModel(
      id: id,
      vendorId: vendorId,
      name: name,
      description: description,
      price: price,
      category: category,
      isAvailable: isAvailable,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates a mock rating for testing
  static RatingModel createMockRating({
    String id = 'test_rating_id',
    String vendorId = 'test_vendor_id',
    String customerId = 'test_customer_id',
    String customerName = 'Test Customer',
    double rating = 4.0,
    String? comment = 'Great food!',
    bool isAnonymous = false,
  }) {
    return RatingModel(
      id: id,
      vendorId: vendorId,
      customerId: customerId,
      customerName: customerName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isAnonymous: isAnonymous,
    );
  }

  /// Pumps and settles a widget with a timeout
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Finds a widget by text with case-insensitive matching
  static Finder findTextIgnoreCase(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data?.toLowerCase().contains(text.toLowerCase()) == true,
    );
  }

  /// Finds a widget by key with type safety
  static Finder findByKeyAndType<T extends Widget>(String key) {
    return find.byWidgetPredicate(
      (widget) => widget.key == Key(key) && widget is T,
    );
  }

  /// Verifies that a snackbar with specific text is shown
  static void expectSnackBar(WidgetTester tester, String text) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(text), findsOneWidget);
  }

  /// Verifies that a loading indicator is shown
  static void expectLoadingIndicator() {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Verifies that an error message is shown
  static void expectErrorMessage(String message) {
    expect(find.text(message), findsOneWidget);
  }

  /// Simulates a network delay
  static Future<void> simulateNetworkDelay([Duration? delay]) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 500));
  }

  /// Creates test data for performance testing
  static List<VendorModel> createLargeVendorList(int count) {
    return List.generate(count, (index) => createMockVendor(
      id: 'vendor_$index',
      name: 'Vendor $index',
      cuisineType: ['Italian', 'Chinese', 'Mexican', 'Indian'][index % 4],
      rating: 3.0 + (index % 3),
    ));
  }

  /// Creates test data for menu items
  static List<MenuItemModel> createLargeMenuItemList(int count, String vendorId) {
    return List.generate(count, (index) => createMockMenuItem(
      id: 'menu_item_$index',
      vendorId: vendorId,
      name: 'Menu Item $index',
      price: 10.0 + (index % 20),
      category: ['Appetizers', 'Main Course', 'Desserts', 'Beverages'][index % 4],
    ));
  }
}

/// Mock providers for testing
class MockAuthProvider extends AuthProvider {
  UserModel? _mockUser;
  bool _isLoading = false;
  String? _error;

  @override
  UserModel? get userProfile => _mockUser;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  void setMockUser(UserModel? user) {
    _mockUser = user;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

class MockVendorProvider extends VendorProvider {
  VendorModel? _mockVendor;
  bool _isLoading = false;
  String? _error;

  @override
  VendorModel? get currentVendor => _mockVendor;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  void setMockVendor(VendorModel? vendor) {
    _mockVendor = vendor;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

class MockCustomerProvider extends CustomerProvider {
  List<VendorModel> _mockVendors = [];
  bool _isLoading = false;
  String? _error;

  @override
  List<VendorModel> get nearbyVendors => _mockVendors;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  void setMockVendors(List<VendorModel> vendors) {
    _mockVendors = vendors;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

class MockMenuProvider extends MenuProvider {
  List<MenuItemModel> _mockMenuItems = [];
  bool _isLoading = false;
  String? _error;

  @override
  List<MenuItemModel> get menuItems => _mockMenuItems;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  void setMockMenuItems(List<MenuItemModel> items) {
    _mockMenuItems = items;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

class MockRatingProvider extends RatingProvider {
  List<RatingModel> _mockRatings = [];
  bool _isLoading = false;
  String? _error;

  @override
  List<RatingModel> get vendorRatings => _mockRatings;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  void setMockRatings(List<RatingModel> ratings) {
    _mockRatings = ratings;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}

class MockSettingsProvider extends SettingsProvider {
  bool _isLoading = false;
  String? _error;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}