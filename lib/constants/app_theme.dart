import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// iOS-style theme configuration for the app
class AppTheme {
  // Color constants
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color secondaryOrange = Color(0xFFFF8C42);
  static const Color accentOrange = Color(0xFFFFA726);
  
  // iOS-style colors
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosGreen = Color(0xFF34C759);
  static const Color iosRed = Color(0xFFFF3B30);
  static const Color iosYellow = Color(0xFFFFCC00);
  static const Color iosPurple = Color(0xFFAF52DE);
  
  // Neutral colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1C1C1E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2C2C2E);
  
  // Text colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6C6C70);
  static const Color textTertiary = Color(0xFF8E8E93);
  
  // Shadow and elevation
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        brightness: Brightness.light,
        primary: primaryOrange,
        secondary: secondaryOrange,
        surface: surfaceLight,
        background: backgroundLight,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        color: surfaceLight,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          side: const BorderSide(color: primaryOrange),
          foregroundColor: primaryOrange,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceLight,
        selectedItemColor: primaryOrange,
        unselectedItemColor: textSecondary,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textTertiary,
        ),
      ),
    );
  }
  
  /// Dark theme configuration
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryOrange,
        brightness: Brightness.dark,
        primary: primaryOrange,
        secondary: secondaryOrange,
        surface: surfaceDark,
        background: backgroundDark,
      ),
    );
  }
}

/// iOS-style Cupertino theme
class CupertinoAppTheme {
  static const CupertinoThemeData lightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: AppTheme.primaryOrange,
    scaffoldBackgroundColor: AppTheme.backgroundLight,
    barBackgroundColor: AppTheme.surfaceLight,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppTheme.textPrimary,
      textStyle: TextStyle(
        fontSize: 16,
        color: AppTheme.textPrimary,
      ),
    ),
  );
  
  static const CupertinoThemeData darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppTheme.primaryOrange,
    scaffoldBackgroundColor: AppTheme.backgroundDark,
    barBackgroundColor: AppTheme.surfaceDark,
  );
}