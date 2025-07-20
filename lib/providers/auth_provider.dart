import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      _userProfile = await _authService.getUserProfile();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signInWithPhone(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _setLoading(false);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setLoading(false);
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _setLoading(false);
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _setLoading(false);
        },
      );
    } catch (e) {
      _setLoading(false);
      onError(e.toString());
    }
  }

  Future<bool> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.verifyOTP(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> createUserProfile({
    required String name,
    required String email,
    required UserType userType,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.createUserProfile(
        name: name,
        email: email,
        userType: userType,
        phone: phone,
      );
      await _loadUserProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    _setLoading(false);
  }

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
}