import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'auth/login_screen.dart';
import 'vendor/vendor_dashboard.dart';
import 'customer/customer_home.dart';
import '../constants/app_animations.dart';
import '../constants/app_theme.dart';
import '../widgets/animated/page_transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _checkAuthState();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: AppAnimations.splash,
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: AppAnimations.iosSpring,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: AppAnimations.easeInOut,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() async {
    _backgroundController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _checkAuthState() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        if (authProvider.isAuthenticated && authProvider.userProfile != null) {
          // Navigate based on user type
          if (authProvider.userProfile!.userType == UserType.vendor) {
            NavigationHelper.pushReplacementIOS(
              context,
              const VendorDashboard(),
            );
          } else {
            NavigationHelper.pushReplacementIOS(
              context,
              const CustomerHome(),
            );
          }
        } else {
          // Navigate to login
          NavigationHelper.pushReplacementIOS(
            context,
            const LoginScreen(),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryOrange,
                  AppTheme.secondaryOrange.withOpacity(0.8 + (_backgroundAnimation.value * 0.2)),
                  AppTheme.accentOrange,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated App Logo
                  AnimatedBuilder(
                    animation: _logoScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotationAnimation.value * 0.1,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2 * _logoScaleAnimation.value),
                                  blurRadius: 20 * _logoScaleAnimation.value,
                                  offset: Offset(0, 10 * _logoScaleAnimation.value),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.restaurant,
                              size: 60,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Animated App Name
                  AnimatedBuilder(
                    animation: _textFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _textFadeAnimation.value)),
                          child: Column(
                            children: [
                              Text(
                                'StreetBite',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Discover Street Food Near You',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Animated Loading Indicator
                  AnimatedBuilder(
                    animation: _textFadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}