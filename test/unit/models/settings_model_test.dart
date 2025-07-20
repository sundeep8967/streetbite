import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/models/settings_model.dart';

void main() {
  group('SettingsModel Tests', () {
    group('UserSettings Tests', () {
      late UserSettings testUserSettings;
      late Map<String, dynamic> testUserSettingsMap;

      setUp(() {
        testUserSettings = UserSettings(
          userId: 'user_id',
          notificationSettings: NotificationSettings(
            pushNotifications: true,
            emailNotifications: false,
            vendorStatusUpdates: true,
            newFollowerAlerts: false,
            promotionalOffers: true,
          ),
          appPreferences: AppPreferences(
            theme: 'dark',
            language: 'en',
            mapType: 'satellite',
            distanceUnit: 'km',
            autoLocation: true,
          ),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        testUserSettingsMap = {
          'userId': 'user_id',
          'notificationSettings': {
            'pushNotifications': true,
            'emailNotifications': false,
            'vendorStatusUpdates': true,
            'newFollowerAlerts': false,
            'promotionalOffers': true,
          },
          'appPreferences': {
            'theme': 'dark',
            'language': 'en',
            'mapType': 'satellite',
            'distanceUnit': 'km',
            'autoLocation': true,
          },
          'createdAt': '2024-01-01T00:00:00.000',
          'updatedAt': '2024-01-02T00:00:00.000',
        };
      });

      test('should create UserSettings with all properties', () {
        expect(testUserSettings.userId, 'user_id');
        expect(testUserSettings.notificationSettings.pushNotifications, true);
        expect(testUserSettings.appPreferences.theme, 'dark');
        expect(testUserSettings.createdAt, DateTime(2024, 1, 1));
        expect(testUserSettings.updatedAt, DateTime(2024, 1, 2));
      });

      test('should convert UserSettings to Map correctly', () {
        final result = testUserSettings.toMap();
        expect(result, equals(testUserSettingsMap));
      });

      test('should create UserSettings from Map correctly', () {
        final result = UserSettings.fromMap(testUserSettingsMap);
        
        expect(result.userId, testUserSettings.userId);
        expect(result.notificationSettings.pushNotifications, 
               testUserSettings.notificationSettings.pushNotifications);
        expect(result.appPreferences.theme, 
               testUserSettings.appPreferences.theme);
        expect(result.createdAt, testUserSettings.createdAt);
        expect(result.updatedAt, testUserSettings.updatedAt);
      });
    });

    group('NotificationSettings Tests', () {
      late NotificationSettings testNotificationSettings;

      setUp(() {
        testNotificationSettings = NotificationSettings(
          pushNotifications: true,
          emailNotifications: false,
          vendorStatusUpdates: true,
          newFollowerAlerts: false,
          promotionalOffers: true,
        );
      });

      test('should create NotificationSettings with all properties', () {
        expect(testNotificationSettings.pushNotifications, true);
        expect(testNotificationSettings.emailNotifications, false);
        expect(testNotificationSettings.vendorStatusUpdates, true);
        expect(testNotificationSettings.newFollowerAlerts, false);
        expect(testNotificationSettings.promotionalOffers, true);
      });

      test('should create NotificationSettings with default values', () {
        final defaultSettings = NotificationSettings();
        
        expect(defaultSettings.pushNotifications, true);
        expect(defaultSettings.emailNotifications, true);
        expect(defaultSettings.vendorStatusUpdates, true);
        expect(defaultSettings.newFollowerAlerts, true);
        expect(defaultSettings.promotionalOffers, false);
      });

      test('should use copyWith correctly', () {
        final updatedSettings = testNotificationSettings.copyWith(
          pushNotifications: false,
          emailNotifications: true,
        );

        expect(updatedSettings.pushNotifications, false);
        expect(updatedSettings.emailNotifications, true);
        expect(updatedSettings.vendorStatusUpdates, true);
        expect(updatedSettings.newFollowerAlerts, false);
        expect(updatedSettings.promotionalOffers, true);
      });
    });

    group('AppPreferences Tests', () {
      late AppPreferences testAppPreferences;

      setUp(() {
        testAppPreferences = AppPreferences(
          theme: 'dark',
          language: 'en',
          mapType: 'satellite',
          distanceUnit: 'km',
          autoLocation: true,
        );
      });

      test('should create AppPreferences with all properties', () {
        expect(testAppPreferences.theme, 'dark');
        expect(testAppPreferences.language, 'en');
        expect(testAppPreferences.mapType, 'satellite');
        expect(testAppPreferences.distanceUnit, 'km');
        expect(testAppPreferences.autoLocation, true);
      });

      test('should create AppPreferences with default values', () {
        final defaultPreferences = AppPreferences();
        
        expect(defaultPreferences.theme, 'light');
        expect(defaultPreferences.language, 'en');
        expect(defaultPreferences.mapType, 'normal');
        expect(defaultPreferences.distanceUnit, 'km');
        expect(defaultPreferences.autoLocation, true);
      });

      test('should use copyWith correctly', () {
        final updatedPreferences = testAppPreferences.copyWith(
          theme: 'light',
          distanceUnit: 'miles',
        );

        expect(updatedPreferences.theme, 'light');
        expect(updatedPreferences.language, 'en');
        expect(updatedPreferences.mapType, 'satellite');
        expect(updatedPreferences.distanceUnit, 'miles');
        expect(updatedPreferences.autoLocation, true);
      });
    });

    group('VendorAvailabilityHours Tests', () {
      late VendorAvailabilityHours testAvailabilityHours;

      setUp(() {
        testAvailabilityHours = VendorAvailabilityHours(
          vendorId: 'vendor_id',
          weeklyHours: {
            'monday': '9:00-17:00',
            'tuesday': '9:00-17:00',
            'wednesday': '9:00-17:00',
            'thursday': '9:00-17:00',
            'friday': '9:00-17:00',
            'saturday': '10:00-16:00',
            'sunday': 'closed',
          },
          breakPeriods: ['12:00-13:00'],
          specialHours: {
            '2024-12-25': 'closed',
            '2024-01-01': 'closed',
          },
          timezone: 'America/New_York',
          updatedAt: DateTime(2024, 1, 1),
        );
      });

      test('should create VendorAvailabilityHours with all properties', () {
        expect(testAvailabilityHours.vendorId, 'vendor_id');
        expect(testAvailabilityHours.weeklyHours['monday'], '9:00-17:00');
        expect(testAvailabilityHours.weeklyHours['sunday'], 'closed');
        expect(testAvailabilityHours.breakPeriods, ['12:00-13:00']);
        expect(testAvailabilityHours.specialHours['2024-12-25'], 'closed');
        expect(testAvailabilityHours.timezone, 'America/New_York');
        expect(testAvailabilityHours.updatedAt, DateTime(2024, 1, 1));
      });

      test('should create VendorAvailabilityHours with default values', () {
        final defaultHours = VendorAvailabilityHours(
          vendorId: 'vendor_id',
          updatedAt: DateTime.now(),
        );
        
        expect(defaultHours.weeklyHours, isEmpty);
        expect(defaultHours.breakPeriods, isEmpty);
        expect(defaultHours.specialHours, isEmpty);
        expect(defaultHours.timezone, 'UTC');
      });

      test('should use copyWith correctly', () {
        final updatedHours = testAvailabilityHours.copyWith(
          timezone: 'America/Los_Angeles',
          breakPeriods: ['12:00-13:00', '15:00-15:30'],
        );

        expect(updatedHours.vendorId, 'vendor_id');
        expect(updatedHours.timezone, 'America/Los_Angeles');
        expect(updatedHours.breakPeriods, ['12:00-13:00', '15:00-15:30']);
        expect(updatedHours.weeklyHours, testAvailabilityHours.weeklyHours);
      });
    });

    group('Edge cases and validation', () {
      test('should handle null values in UserSettings fromMap', () {
        final mapWithNulls = {
          'userId': null,
          'notificationSettings': null,
          'appPreferences': null,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final result = UserSettings.fromMap(mapWithNulls);
        expect(result.userId, '');
        expect(result.notificationSettings, isA<NotificationSettings>());
        expect(result.appPreferences, isA<AppPreferences>());
      });

      test('should handle invalid theme values', () {
        final preferences = AppPreferences(theme: 'invalid_theme');
        expect(preferences.theme, 'invalid_theme'); // Model doesn't validate
      });

      test('should handle invalid language codes', () {
        final preferences = AppPreferences(language: 'invalid_lang');
        expect(preferences.language, 'invalid_lang'); // Model doesn't validate
      });

      test('should handle empty weekly hours', () {
        final hours = VendorAvailabilityHours(
          vendorId: 'vendor_id',
          weeklyHours: {},
          updatedAt: DateTime.now(),
        );
        expect(hours.weeklyHours, isEmpty);
      });

      test('should handle invalid time format in hours', () {
        final hours = VendorAvailabilityHours(
          vendorId: 'vendor_id',
          weeklyHours: {'monday': 'invalid_time'},
          updatedAt: DateTime.now(),
        );
        expect(hours.weeklyHours['monday'], 'invalid_time');
      });
    });
  });
}