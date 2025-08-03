import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseDebugHelper {
  static Future<void> testFirestoreConnection() async {
    try {
      if (kDebugMode) {
        print('🔥 Testing Firestore connection...');
      }
      
      // Test basic connection
      final firestore = FirebaseFirestore.instance;
      
      // Simple read test - this should work even without authentication
      await firestore
          .collection('test')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      
      if (kDebugMode) {
        print('✅ Firestore connection successful');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firestore connection failed: $e');
      }
      
      // Try to provide helpful error messages
      if (e.toString().contains('PERMISSION_DENIED')) {
        if (kDebugMode) {
          print('💡 Hint: Check Firestore security rules');
        }
      } else if (e.toString().contains('UNAUTHENTICATED')) {
        if (kDebugMode) {
          print('💡 Hint: User authentication required');
        }
      } else if (e.toString().contains('UNAVAILABLE')) {
        if (kDebugMode) {
          print('💡 Hint: Network connectivity issue');
        }
      }
    }
  }

  static Future<void> testAuthConnection() async {
    try {
      if (kDebugMode) {
        print('🔐 Testing Firebase Auth...');
      }
      
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      
      if (user != null) {
        if (kDebugMode) {
          print('✅ User authenticated: ${user.uid}');
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ No user currently authenticated');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Auth error: $e');
      }
    }
  }

  static Future<void> debugFirebaseIssues() async {
    if (kDebugMode) {
      print('🐛 Starting Firebase Debug Session...');
      await testAuthConnection();
      await testFirestoreConnection();
      print('🏁 Firebase Debug Session Complete');
    }
  }
}