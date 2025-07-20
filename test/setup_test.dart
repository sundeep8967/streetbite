import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Test setup utilities for StreetBite app
class TestSetup {
  static bool _initialized = false;

  /// Initialize Firebase for testing
  static Future<void> initializeFirebase() async {
    if (_initialized) return;
    
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase with fake instance for testing
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: 'test-project-id',
        ),
      );
    } catch (e) {
      // Firebase already initialized
    }
    
    _initialized = true;
  }

  /// Create a fake Firestore instance for testing
  static FakeFirebaseFirestore createFakeFirestore() {
    return FakeFirebaseFirestore();
  }

  /// Reset test state
  static void reset() {
    _initialized = false;
  }
}