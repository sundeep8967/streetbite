import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/menu_provider.dart';
import './providers/rating_provider.dart';
import './providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const StreetBiteApp());
}

class StreetBiteApp extends StatelessWidget {
  const StreetBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'StreetBite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        // iOS-style page transitions
        onGenerateRoute: (settings) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) {
              switch (settings.name) {
                default:
                  return const SplashScreen();
              }
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
    );
  }
}

