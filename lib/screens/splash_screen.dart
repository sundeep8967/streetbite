import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'auth/login_screen.dart';
import 'vendor/vendor_dashboard.dart';
import 'customer/customer_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        if (authProvider.isAuthenticated && authProvider.userProfile != null) {
          // Navigate based on user type
          if (authProvider.userProfile!.userType == UserType.vendor) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const VendorDashboard()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CustomerHome()),
            );
          }
        } else {
          // Navigate to login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant,
                size: 60,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 30),
            
            // App Name
            Text(
              'StreetBite',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            
            // Tagline
            Text(
              'Discover Street Food Near You',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 50),
            
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}