import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/utils/firebase_availability.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Configure for web - using the web app ID from firebase_options.dart
    clientId: kIsWeb 
        ? '116294954906-d71mjs7mk9jg3a8h0jbgjrui65fcqrd0.apps.googleusercontent.com'
        : null,
    scopes: [
      'email',
      'profile',
      'openid', // Required for ID token
    ],
    hostedDomain: null, // Allow any domain
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    print('🟡 AuthService: Getting user data for UID: ${user?.uid}');
    if (user == null) {
      print('🔴 AuthService: No current user found');
      return null;
    }

    try {
      print('🟡 AuthService: Fetching Firestore document for UID: ${user.uid}');
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        print('✅ AuthService: User document found in Firestore');
        final userData = UserModel.fromFirestore(doc);
        print('✅ AuthService: User data parsed successfully: ${userData.email}');
        return userData;
      } else {
        print('🟡 AuthService: No user document found in Firestore for UID: ${user.uid}');
        return null;
      }
    } catch (e) {
      print('🔴 AuthService: Error getting user data: $e');
      throw Exception('Failed to get user data: $e');
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    print('🟡 AuthService: Starting email sign-up for: $email');
    
    // Check if Firebase is available
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }
    
    try {
      // Add timeout to prevent hanging
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Sign-up request timed out. Please check your internet connection and try again.'),
      );

      print('✅ AuthService: Email sign-up successful, UID: ${credential.user?.uid}');

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document in Firestore
      await _createUserDocument(
        credential.user!,
        name: name,
        role: role,
      );

      print('✅ AuthService: User document created successfully');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('🔴 AuthService: FirebaseAuthException during sign-up: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('🔴 AuthService: Unexpected error during sign-up: $e');
      // Check if Firebase is available
      if (e.toString().contains('MissingPluginException') || 
          e.toString().contains('firebase_auth')) {
        throw Exception('Firebase authentication is not properly configured. Please check your setup.');
      }
      throw Exception('Failed to create account: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    print('🟡 AuthService: Starting email sign-in for: $email');
    
    // Check if Firebase is available
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }
    
    try {
      // Add timeout to prevent hanging
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Sign-in request timed out. Please check your internet connection and try again.'),
      );
      print('✅ AuthService: Email sign-in successful, UID: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('🔴 AuthService: FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('🔴 AuthService: Unexpected error during email sign-in: $e');
      // Check if Firebase is available
      if (e.toString().contains('MissingPluginException') || 
          e.toString().contains('firebase_auth')) {
        throw Exception('Firebase authentication is not properly configured. Please check your setup.');
      }
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle({String? role}) async {
    print('🟡 AuthService: Starting Google sign-in...');
    print('🟡 AuthService: Current scopes: ${_googleSignIn.scopes}');
    print('🟡 AuthService: Client ID: ${_googleSignIn.clientId}');
    print('🟡 AuthService: Is Web: $kIsWeb');
    
    try {
      // Clear any existing session first
      print('🟡 AuthService: Clearing existing Google session...');
      await _googleSignIn.signOut();
      
      GoogleSignInAccount? googleUser;
      
      print('🟡 AuthService: Starting interactive Google sign-in...');
      try {
        // Remove timeout - let user control when to cancel
        googleUser = await _googleSignIn.signIn();
        print('🟡 AuthService: Interactive sign-in completed');
      } catch (e) {
        print('🔴 AuthService: Google sign-in error: $e');
        if (e.toString().contains('popup') || e.toString().contains('blocked')) {
          throw Exception('Popup was blocked. Please allow popups for this site and try again.');
        }
        if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
          throw Exception('Sign-in timed out. Please try again.');
        }
        throw Exception('Google sign-in failed. Please try email sign-in instead.');
      }
      
      if (googleUser == null) {
        print('🔴 AuthService: Google sign-in was cancelled');
        throw Exception('Google sign-in was cancelled');
      }

      print('✅ AuthService: Google sign-in successful for: ${googleUser.email}');
      print('🟡 AuthService: Available data - email: ${googleUser.email}, displayName: ${googleUser.displayName}, id: ${googleUser.id}');

      // Obtain the auth details from the request
      print('🟡 AuthService: Getting Google authentication details...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('🟡 AuthService: Access token available: ${googleAuth.accessToken != null}');
      print('🟡 AuthService: ID token available: ${googleAuth.idToken != null}');
      
      if (googleAuth.idToken == null) {
        print('🔴 AuthService: ID token is null - this is a known issue with google_sign_in on web');
        
        // Try with just access token (this often works for Firebase)
        if (googleAuth.accessToken != null) {
          print('🟡 AuthService: Attempting Firebase auth with access token only...');
          try {
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
            );
            
            final userCredential = await _auth.signInWithCredential(credential).timeout(
              const Duration(seconds: 30),
              onTimeout: () => throw Exception('Firebase authentication timed out'),
            );
            
            print('✅ AuthService: Firebase sign-in successful with access token, UID: ${userCredential.user?.uid}');
            
            // Create user document if new user
            if (userCredential.additionalUserInfo?.isNewUser == true) {
              print('🟡 AuthService: Creating user document for new user...');
              print('🚀 AuthService: Role parameter received = "$role"');
              final displayName = userCredential.user!.displayName ?? 
                                 googleUser.displayName ?? 
                                 googleUser.email?.split('@').first ?? 
                                 'User';
              
              final finalRole = role ?? 'doctor';
              print('🚀 AuthService: Final role being saved = "$finalRole"');
              
              await _createUserDocument(
                userCredential.user!,
                name: displayName,
                role: finalRole,
              );
            } else {
              print('🟡 AuthService: Existing user detected (path 1)');
              // For existing users, check if we need to update their role
              if (role != null) {
                print('🚀 AuthService: Updating existing user role to "$role" (path 1)');
                await _updateUserRole(userCredential.user!.uid, role);
              }
            }
            
            return userCredential;
          } catch (e) {
            print('🔴 AuthService: Firebase auth with access token failed: $e');
            throw Exception('Google Sign-In authentication failed. Please try email sign-in instead.');
          }
        } else {
          throw Exception('No authentication tokens available. Please try email sign-in instead.');
        }
      }

      print('🟡 AuthService: Creating Firebase credential...');
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🟡 AuthService: Signing in to Firebase...');
      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      print('✅ AuthService: Firebase sign-in successful, UID: ${userCredential.user?.uid}');
      print('🟡 AuthService: Firebase user data - email: ${userCredential.user?.email}, displayName: ${userCredential.user?.displayName}');

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        print('🟡 AuthService: New user detected, creating user document...');
        print('🚀 AuthService: Role parameter received (path 2) = "$role"');
        // Create user document for new Google users
        // Use Firebase Auth data, fallback to GoogleSignIn data
        final displayName = userCredential.user!.displayName ?? 
                           googleUser.displayName ?? 
                           googleUser.email?.split('@').first ?? 
                           'User';
        
        final finalRole = role ?? 'doctor';
        print('🚀 AuthService: Final role being saved (path 2) = "$finalRole"');
        
        await _createUserDocument(
          userCredential.user!,
          name: displayName,
          role: finalRole,
        );
        print('✅ AuthService: User document created for new user');
        print('✅ AuthService: User document created');
      } else {
        print('🟡 AuthService: Existing user detected');
        // For existing users, check if we need to update their role
        if (role != null) {
          print('🚀 AuthService: Updating existing user role to "$role"');
          await _updateUserRole(userCredential.user!.uid, role);
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('🔴 AuthService: FirebaseAuthException during Google sign-in: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('🔴 AuthService: Error during Google sign-in: $e');
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Sign in with phone number
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw Exception('Failed to verify phone number: $e');
    }
  }

  // Verify OTP and sign in
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
    String? name,
    String? role,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        // Create user document for new phone users
        await _createUserDocument(
          userCredential.user!,
          name: name ?? 'User',
          role: role ?? 'doctor',
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedUser.id)
          .set(updatedUser.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth user
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    User user, {
    required String name,
    required String role,
  }) async {
    print('🚀 _createUserDocument: Creating user with role = "$role"');
    final userModel = UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: name,
      phoneNumber: user.phoneNumber,
      userRole: role,
      profileCompleted: true, // Mark as complete for Google Sign-In users
      createdTime: DateTime.now(),
    );
    print('🚀 _createUserDocument: UserModel created with userRole = "${userModel.userRole}"');

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
    
    print('✅ AuthService: User document created successfully');
  }

  // Update existing user's role
  Future<void> _updateUserRole(String uid, String role) async {
    try {
      print('🚀 _updateUserRole: Updating user $uid to role "$role"');
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'userRole': role});
      print('✅ _updateUserRole: Role updated successfully in Firestore');
      
      // Trigger a refresh of the user data stream to pick up the new role
      print('🔄 _updateUserRole: Triggering user data refresh...');
      // Force a reload by getting fresh data
      final userData = await getCurrentUserData();
      print('✅ _updateUserRole: User data refreshed');
      print('🚀 _updateUserRole: New role in refreshed data = "${userData?.userRole}"');
      
      // Force auth state change to trigger UI rebuild
      print('🔄 _updateUserRole: Triggering auth state change...');
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // This will trigger the auth state listener
        await currentUser.reload();
        print('✅ _updateUserRole: Auth state refreshed');
      }
    } catch (e) {
      print('🔴 _updateUserRole: Failed to update role: $e');
      // Don't throw error, just log it
    }
  }

  // Mark existing user profile as complete
  Future<void> markProfileComplete(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'profileCompleted': true});
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email address.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email address.';
        break;
      case 'weak-password':
        message = 'Password is too weak.';
        break;
      case 'invalid-email':
        message = 'Email address is invalid.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed.';
        break;
      case 'invalid-verification-code':
        message = 'Invalid verification code.';
        break;
      case 'invalid-verification-id':
        message = 'Invalid verification ID.';
        break;
      default:
        message = e.message ?? 'An unknown error occurred.';
        break;
    }
    return Exception(message);
  }
}