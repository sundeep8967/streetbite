import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  UserSettings? _userSettings;
  VendorAvailabilityHours? _vendorHours;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserSettings? get userSettings => _userSettings;
  VendorAvailabilityHours? get vendorHours => _vendorHours;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user settings
  Future<void> loadUserSettings(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _userSettings = await _settingsService.getUserSettings(userId);
      _userSettings ??= UserSettings.defaultSettings(userId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Save user settings
  Future<bool> saveUserSettings(UserSettings settings) async {
    _setLoading(true);
    _clearError();

    try {
      await _settingsService.saveUserSettings(settings);
      _userSettings = settings;
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Update notification settings
  Future<bool> updateNotificationSettings(String userId, NotificationSettings notifications) async {
    _setLoading(true);
    _clearError();

    try {
      await _settingsService.updateNotificationSettings(userId, notifications);
      if (_userSettings != null) {
        _userSettings = _userSettings!.copyWith(
          notifications: notifications,
          updatedAt: DateTime.now(),
        );
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Update app preferences
  Future<bool> updateAppPreferences(String userId, AppPreferences preferences) async {
    _setLoading(true);
    _clearError();

    try {
      await _settingsService.updateAppPreferences(userId, preferences);
      if (_userSettings != null) {
        _userSettings = _userSettings!.copyWith(
          preferences: preferences,
          updatedAt: DateTime.now(),
        );
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Load vendor availability hours
  Future<void> loadVendorAvailabilityHours(String vendorId) async {
    _setLoading(true);
    _clearError();

    try {
      _vendorHours = await _settingsService.getVendorAvailabilityHours(vendorId);
      _vendorHours ??= VendorAvailabilityHours.defaultSchedule(vendorId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Save vendor availability hours
  Future<bool> saveVendorAvailabilityHours(VendorAvailabilityHours hours) async {
    _setLoading(true);
    _clearError();

    try {
      await _settingsService.saveVendorAvailabilityHours(hours);
      _vendorHours = hours;
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Update specific day schedule
  Future<bool> updateDaySchedule(String vendorId, String day, DaySchedule schedule) async {
    try {
      await _settingsService.updateDaySchedule(vendorId, day, schedule);
      
      if (_vendorHours != null) {
        Map<String, DaySchedule> updatedSchedule = Map.from(_vendorHours!.schedule);
        updatedSchedule[day] = schedule;
        
        _vendorHours = VendorAvailabilityHours(
          vendorId: vendorId,
          schedule: updatedSchedule,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Theme management
  Future<void> updateTheme(String theme) async {
    try {
      await _settingsService.saveThemePreference(theme);
      if (_userSettings != null) {
        final updatedPreferences = _userSettings!.preferences.copyWith(theme: theme);
        _userSettings = _userSettings!.copyWith(preferences: updatedPreferences);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Language management
  Future<void> updateLanguage(String language) async {
    try {
      await _settingsService.saveLanguagePreference(language);
      if (_userSettings != null) {
        final updatedPreferences = _userSettings!.preferences.copyWith(language: language);
        _userSettings = _userSettings!.copyWith(preferences: updatedPreferences);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Privacy and data management
  Future<bool> deleteUserData(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _settingsService.deleteUserData(userId);
      _userSettings = null;
      _vendorHours = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>?> exportUserData(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final data = await _settingsService.exportUserData(userId);
      _setLoading(false);
      return data;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return null;
    }
  }

  // Local preferences
  Future<void> saveLocalPreference(String key, dynamic value) async {
    await _settingsService.saveLocalPreference(key, value);
  }

  Future<T?> getLocalPreference<T>(String key) async {
    return await _settingsService.getLocalPreference<T>(key);
  }

  // Quick settings updates
  Future<void> toggleNotification(String userId, String notificationType, bool value) async {
    if (_userSettings == null) return;

    NotificationSettings updatedNotifications;
    
    switch (notificationType) {
      case 'pushNotifications':
        updatedNotifications = _userSettings!.notifications.copyWith(pushNotifications: value);
        break;
      case 'vendorStatusUpdates':
        updatedNotifications = _userSettings!.notifications.copyWith(vendorStatusUpdates: value);
        break;
      case 'newFollowers':
        updatedNotifications = _userSettings!.notifications.copyWith(newFollowers: value);
        break;
      case 'menuUpdates':
        updatedNotifications = _userSettings!.notifications.copyWith(menuUpdates: value);
        break;
      case 'ratingsAndReviews':
        updatedNotifications = _userSettings!.notifications.copyWith(ratingsAndReviews: value);
        break;
      case 'promotions':
        updatedNotifications = _userSettings!.notifications.copyWith(promotions: value);
        break;
      case 'soundEnabled':
        updatedNotifications = _userSettings!.notifications.copyWith(soundEnabled: value);
        break;
      case 'vibrationEnabled':
        updatedNotifications = _userSettings!.notifications.copyWith(vibrationEnabled: value);
        break;
      default:
        return;
    }

    await updateNotificationSettings(userId, updatedNotifications);
  }

  // Clear all data
  void clearSettings() {
    _userSettings = null;
    _vendorHours = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get current theme
  String getCurrentTheme() {
    return _userSettings?.preferences.theme ?? 'system';
  }

  // Get current language
  String getCurrentLanguage() {
    return _userSettings?.preferences.language ?? 'en';
  }

  // Check if notifications are enabled
  bool areNotificationsEnabled() {
    return _userSettings?.notifications.pushNotifications ?? true;
  }

  // Get search radius
  double getSearchRadius() {
    return _userSettings?.preferences.searchRadius ?? 5.0;
  }

  // Check if vendor is open now
  bool isVendorOpenNow(String vendorId) {
    if (_vendorHours == null) return false;

    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final daySchedule = _vendorHours!.schedule[dayName];

    if (daySchedule == null || !daySchedule.isOpen) return false;

    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return _isTimeInRange(currentTime, daySchedule.openTime, daySchedule.closeTime);
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }

  bool _isTimeInRange(String currentTime, String openTime, String closeTime) {
    final current = _timeToMinutes(currentTime);
    final open = _timeToMinutes(openTime);
    final close = _timeToMinutes(closeTime);

    if (close > open) {
      // Same day (e.g., 9:00 - 18:00)
      return current >= open && current <= close;
    } else {
      // Crosses midnight (e.g., 22:00 - 06:00)
      return current >= open || current <= close;
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}