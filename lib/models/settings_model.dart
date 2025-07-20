class UserSettings {
  final String userId;
  final NotificationSettings notifications;
  final AppPreferences preferences;
  final DateTime updatedAt;

  UserSettings({
    required this.userId,
    required this.notifications,
    required this.preferences,
    required this.updatedAt,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      userId: map['userId'] ?? '',
      notifications: NotificationSettings.fromMap(map['notifications'] ?? {}),
      preferences: AppPreferences.fromMap(map['preferences'] ?? {}),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'notifications': notifications.toMap(),
      'preferences': preferences.toMap(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserSettings copyWith({
    String? userId,
    NotificationSettings? notifications,
    AppPreferences? preferences,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserSettings.defaultSettings(String userId) {
    return UserSettings(
      userId: userId,
      notifications: NotificationSettings.defaultSettings(),
      preferences: AppPreferences.defaultPreferences(),
      updatedAt: DateTime.now(),
    );
  }
}

class NotificationSettings {
  final bool pushNotifications;
  final bool vendorStatusUpdates;
  final bool newFollowers;
  final bool menuUpdates;
  final bool ratingsAndReviews;
  final bool promotions;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String quietHoursStart; // "22:00"
  final String quietHoursEnd; // "08:00"

  NotificationSettings({
    required this.pushNotifications,
    required this.vendorStatusUpdates,
    required this.newFollowers,
    required this.menuUpdates,
    required this.ratingsAndReviews,
    required this.promotions,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      pushNotifications: map['pushNotifications'] ?? true,
      vendorStatusUpdates: map['vendorStatusUpdates'] ?? true,
      newFollowers: map['newFollowers'] ?? true,
      menuUpdates: map['menuUpdates'] ?? true,
      ratingsAndReviews: map['ratingsAndReviews'] ?? true,
      promotions: map['promotions'] ?? false,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      quietHoursStart: map['quietHoursStart'] ?? '22:00',
      quietHoursEnd: map['quietHoursEnd'] ?? '08:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications,
      'vendorStatusUpdates': vendorStatusUpdates,
      'newFollowers': newFollowers,
      'menuUpdates': menuUpdates,
      'ratingsAndReviews': ratingsAndReviews,
      'promotions': promotions,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? vendorStatusUpdates,
    bool? newFollowers,
    bool? menuUpdates,
    bool? ratingsAndReviews,
    bool? promotions,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      vendorStatusUpdates: vendorStatusUpdates ?? this.vendorStatusUpdates,
      newFollowers: newFollowers ?? this.newFollowers,
      menuUpdates: menuUpdates ?? this.menuUpdates,
      ratingsAndReviews: ratingsAndReviews ?? this.ratingsAndReviews,
      promotions: promotions ?? this.promotions,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  factory NotificationSettings.defaultSettings() {
    return NotificationSettings(
      pushNotifications: true,
      vendorStatusUpdates: true,
      newFollowers: true,
      menuUpdates: true,
      ratingsAndReviews: true,
      promotions: false,
      soundEnabled: true,
      vibrationEnabled: true,
      quietHoursStart: '22:00',
      quietHoursEnd: '08:00',
    );
  }
}

class AppPreferences {
  final String theme; // 'light', 'dark', 'system'
  final String language; // 'en', 'es', etc.
  final double searchRadius; // in kilometers
  final String distanceUnit; // 'km', 'miles'
  final bool showOnlineVendorsOnly;
  final String defaultMapType; // 'normal', 'satellite', 'hybrid'
  final bool autoLocationUpdate;
  final bool saveSearchHistory;

  AppPreferences({
    required this.theme,
    required this.language,
    required this.searchRadius,
    required this.distanceUnit,
    required this.showOnlineVendorsOnly,
    required this.defaultMapType,
    required this.autoLocationUpdate,
    required this.saveSearchHistory,
  });

  factory AppPreferences.fromMap(Map<String, dynamic> map) {
    return AppPreferences(
      theme: map['theme'] ?? 'system',
      language: map['language'] ?? 'en',
      searchRadius: (map['searchRadius'] ?? 5.0).toDouble(),
      distanceUnit: map['distanceUnit'] ?? 'km',
      showOnlineVendorsOnly: map['showOnlineVendorsOnly'] ?? false,
      defaultMapType: map['defaultMapType'] ?? 'normal',
      autoLocationUpdate: map['autoLocationUpdate'] ?? true,
      saveSearchHistory: map['saveSearchHistory'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'language': language,
      'searchRadius': searchRadius,
      'distanceUnit': distanceUnit,
      'showOnlineVendorsOnly': showOnlineVendorsOnly,
      'defaultMapType': defaultMapType,
      'autoLocationUpdate': autoLocationUpdate,
      'saveSearchHistory': saveSearchHistory,
    };
  }

  AppPreferences copyWith({
    String? theme,
    String? language,
    double? searchRadius,
    String? distanceUnit,
    bool? showOnlineVendorsOnly,
    String? defaultMapType,
    bool? autoLocationUpdate,
    bool? saveSearchHistory,
  }) {
    return AppPreferences(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      searchRadius: searchRadius ?? this.searchRadius,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      showOnlineVendorsOnly: showOnlineVendorsOnly ?? this.showOnlineVendorsOnly,
      defaultMapType: defaultMapType ?? this.defaultMapType,
      autoLocationUpdate: autoLocationUpdate ?? this.autoLocationUpdate,
      saveSearchHistory: saveSearchHistory ?? this.saveSearchHistory,
    );
  }

  factory AppPreferences.defaultPreferences() {
    return AppPreferences(
      theme: 'system',
      language: 'en',
      searchRadius: 5.0,
      distanceUnit: 'km',
      showOnlineVendorsOnly: false,
      defaultMapType: 'normal',
      autoLocationUpdate: true,
      saveSearchHistory: true,
    );
  }
}

class VendorAvailabilityHours {
  final String vendorId;
  final Map<String, DaySchedule> schedule;
  final DateTime updatedAt;

  VendorAvailabilityHours({
    required this.vendorId,
    required this.schedule,
    required this.updatedAt,
  });

  factory VendorAvailabilityHours.fromMap(Map<String, dynamic> map) {
    Map<String, DaySchedule> schedule = {};
    if (map['schedule'] != null) {
      (map['schedule'] as Map<String, dynamic>).forEach((key, value) {
        schedule[key] = DaySchedule.fromMap(value);
      });
    }

    return VendorAvailabilityHours(
      vendorId: map['vendorId'] ?? '',
      schedule: schedule,
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> scheduleMap = {};
    schedule.forEach((key, value) {
      scheduleMap[key] = value.toMap();
    });

    return {
      'vendorId': vendorId,
      'schedule': scheduleMap,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VendorAvailabilityHours.defaultSchedule(String vendorId) {
    return VendorAvailabilityHours(
      vendorId: vendorId,
      schedule: {
        'monday': DaySchedule.defaultDay(),
        'tuesday': DaySchedule.defaultDay(),
        'wednesday': DaySchedule.defaultDay(),
        'thursday': DaySchedule.defaultDay(),
        'friday': DaySchedule.defaultDay(),
        'saturday': DaySchedule.defaultDay(),
        'sunday': DaySchedule.defaultDay(),
      },
      updatedAt: DateTime.now(),
    );
  }
}

class DaySchedule {
  final bool isOpen;
  final String openTime; // "09:00"
  final String closeTime; // "18:00"
  final List<BreakPeriod> breaks;

  DaySchedule({
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.breaks,
  });

  factory DaySchedule.fromMap(Map<String, dynamic> map) {
    List<BreakPeriod> breaks = [];
    if (map['breaks'] != null) {
      breaks = (map['breaks'] as List)
          .map((breakMap) => BreakPeriod.fromMap(breakMap))
          .toList();
    }

    return DaySchedule(
      isOpen: map['isOpen'] ?? true,
      openTime: map['openTime'] ?? '09:00',
      closeTime: map['closeTime'] ?? '18:00',
      breaks: breaks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
      'breaks': breaks.map((b) => b.toMap()).toList(),
    };
  }

  factory DaySchedule.defaultDay() {
    return DaySchedule(
      isOpen: true,
      openTime: '09:00',
      closeTime: '18:00',
      breaks: [],
    );
  }

  factory DaySchedule.closedDay() {
    return DaySchedule(
      isOpen: false,
      openTime: '09:00',
      closeTime: '18:00',
      breaks: [],
    );
  }
}

class BreakPeriod {
  final String startTime; // "12:00"
  final String endTime; // "13:00"
  final String? description; // "Lunch break"

  BreakPeriod({
    required this.startTime,
    required this.endTime,
    this.description,
  });

  factory BreakPeriod.fromMap(Map<String, dynamic> map) {
    return BreakPeriod(
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
    };
  }
}