class AppConstants {
  // App Info
  static const String appName = 'StreetBite';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String vendorsCollection = 'vendors';
  static const String menuItemsCollection = 'menu_items';
  static const String ratingsCollection = 'ratings';
  static const String notificationsCollection = 'notifications';
  
  // Shared Preferences Keys
  static const String userTypeKey = 'user_type';
  static const String isFirstTimeKey = 'is_first_time';
  static const String notificationEnabledKey = 'notification_enabled';
  
  // Map Settings
  static const double defaultZoom = 15.0;
  static const double vendorSearchRadius = 5.0; // km
  
  // Cuisine Types
  static const List<String> cuisineTypes = [
    'Indian',
    'Chinese',
    'Italian',
    'Mexican',
    'Thai',
    'American',
    'Mediterranean',
    'Japanese',
    'Korean',
    'Vietnamese',
    'Other'
  ];
  
  // Menu Categories
  static const List<String> menuCategories = [
    'Appetizers',
    'Main Course',
    'Desserts',
    'Beverages',
    'Snacks',
    'Specials'
  ];
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String unknownError = 'Something went wrong. Please try again.';
  static const String locationPermissionDenied = 'Location permission is required to find nearby vendors.';
  
  // Success Messages
  static const String profileUpdated = 'Profile updated successfully!';
  static const String vendorRegistered = 'Vendor registered successfully!';
  static const String statusUpdated = 'Status updated successfully!';
}