import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';
import '../constants/app_constants.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Settings Operations
  Future<void> saveUserSettings(UserSettings settings) async {
    await _firestore
        .collection('user_settings')
        .doc(settings.userId)
        .set(settings.toMap());
  }

  Future<UserSettings?> getUserSettings(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('user_settings')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserSettings.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user settings: $e');
    }
  }

  Future<void> updateNotificationSettings(String userId, NotificationSettings notifications) async {
    await _firestore
        .collection('user_settings')
        .doc(userId)
        .update({
      'notifications': notifications.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateAppPreferences(String userId, AppPreferences preferences) async {
    await _firestore
        .collection('user_settings')
        .doc(userId)
        .update({
      'preferences': preferences.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Vendor Availability Hours Operations
  Future<void> saveVendorAvailabilityHours(VendorAvailabilityHours hours) async {
    await _firestore
        .collection('vendor_availability')
        .doc(hours.vendorId)
        .set(hours.toMap());
  }

  Future<VendorAvailabilityHours?> getVendorAvailabilityHours(String vendorId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('vendor_availability')
          .doc(vendorId)
          .get();

      if (doc.exists) {
        return VendorAvailabilityHours.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching vendor availability hours: $e');
    }
  }

  Future<void> updateDaySchedule(String vendorId, String day, DaySchedule schedule) async {
    await _firestore
        .collection('vendor_availability')
        .doc(vendorId)
        .update({
      'schedule.$day': schedule.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Local Preferences (using SharedPreferences for app-level settings)
  Future<void> saveLocalPreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  Future<T?> getLocalPreference<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }

  Future<void> removeLocalPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clearAllLocalPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Theme Management
  Future<void> saveThemePreference(String theme) async {
    await saveLocalPreference('app_theme', theme);
  }

  Future<String> getThemePreference() async {
    return await getLocalPreference<String>('app_theme') ?? 'system';
  }

  // Language Management
  Future<void> saveLanguagePreference(String language) async {
    await saveLocalPreference('app_language', language);
  }

  Future<String> getLanguagePreference() async {
    return await getLocalPreference<String>('app_language') ?? 'en';
  }

  // Notification Token Management
  Future<void> saveFCMToken(String userId, String token) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'fcmToken': token,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFCMToken(String userId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'fcmToken': FieldValue.delete(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Privacy Settings
  Future<void> deleteUserData(String userId) async {
    final batch = _firestore.batch();

    // Delete user settings
    batch.delete(_firestore.collection('user_settings').doc(userId));
    
    // Delete user document
    batch.delete(_firestore.collection(AppConstants.usersCollection).doc(userId));
    
    // Delete vendor data if exists
    batch.delete(_firestore.collection(AppConstants.vendorsCollection).doc(userId));
    
    // Delete vendor availability
    batch.delete(_firestore.collection('vendor_availability').doc(userId));

    await batch.commit();
  }

  // Export user data (GDPR compliance)
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    Map<String, dynamic> userData = {};

    try {
      // Get user profile
      DocumentSnapshot userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      if (userDoc.exists) {
        userData['profile'] = userDoc.data();
      }

      // Get user settings
      DocumentSnapshot settingsDoc = await _firestore
          .collection('user_settings')
          .doc(userId)
          .get();
      if (settingsDoc.exists) {
        userData['settings'] = settingsDoc.data();
      }

      // Get vendor data if exists
      DocumentSnapshot vendorDoc = await _firestore
          .collection(AppConstants.vendorsCollection)
          .doc(userId)
          .get();
      if (vendorDoc.exists) {
        userData['vendor'] = vendorDoc.data();
      }

      // Get ratings given by user
      QuerySnapshot ratingsQuery = await _firestore
          .collection(AppConstants.ratingsCollection)
          .where('customerId', isEqualTo: userId)
          .get();
      userData['ratings'] = ratingsQuery.docs.map((doc) => doc.data()).toList();

      return userData;
    } catch (e) {
      throw Exception('Error exporting user data: $e');
    }
  }
}