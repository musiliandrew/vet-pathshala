import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../../../shared/models/user_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  
  // Phone auth specific
  String? _verificationId;
  bool _isPhoneAuthInProgress = false;
  
  // Getters
  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  String? get verificationId => _verificationId;
  bool get isPhoneAuthInProgress => _isPhoneAuthInProgress;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    try {
      _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        try {
          _currentUser = await _authService.getCurrentUserData();
          if (_currentUser != null) {
            _setState(AuthState.authenticated);
          } else {
            // User is authenticated with Firebase but has no Firestore document
            // This can happen with Google/Phone sign-in or incomplete registration
            print('User authenticated but no Firestore document found. Creating minimal user profile...');
            await _createMinimalUserProfile(user);
            _currentUser = await _authService.getCurrentUserData();
            _setState(AuthState.authenticated);
          }
        } catch (e) {
          print('🔴 AuthProvider: Error loading user data: $e');
          print('🔴 AuthProvider: User UID: ${user.uid}');
          print('🔴 AuthProvider: User email: ${user.email}');
          print('🔴 AuthProvider: User displayName: ${user.displayName}');
          
          // If we can't load user data but user is authenticated, create minimal profile
          if (e.toString().contains('Failed to get user data')) {
            print('🟡 AuthProvider: Attempting to create minimal user profile...');
            try {
              await _createMinimalUserProfile(user);
              print('✅ AuthProvider: Minimal profile created successfully');
              _currentUser = await _authService.getCurrentUserData();
              print('✅ AuthProvider: User data loaded after profile creation');
              _setState(AuthState.authenticated);
            } catch (createError) {
              print('🔴 AuthProvider: Failed to create minimal profile: $createError');
              _setError('Unable to set up your account. Please try signing in again.');
            }
          } else {
            print('🔴 AuthProvider: Unexpected error type: $e');
            _setError('Network error. Please check your connection and try again.');
          }
        }
      } else {
        _currentUser = null;
        _setState(AuthState.unauthenticated);
      }
    });
    } catch (e) {
      print('🔴 AuthProvider: Failed to initialize auth: $e');
      // Fallback to unauthenticated state if Firebase is not available
      _setState(AuthState.unauthenticated);
    }
  }

  Future<void> _createMinimalUserProfile(User user) async {
    // Create a minimal user profile if one doesn't exist
    final userModel = UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      phoneNumber: user.phoneNumber,
      userRole: 'doctor', // Default role
      profileCompleted: false,
      createdTime: DateTime.now(),
    );

    await _authService.updateUserProfile(userModel);
  }

  // Sign up with email
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _setState(AuthState.loading);
    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      return true;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    }
  }

  // Sign in with email
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    print('🟡 AuthProvider: Starting email sign-in for: $email');
    _setState(AuthState.loading);
    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      print('✅ AuthProvider: Email sign-in successful');
      return true;
    } catch (e) {
      print('🔴 AuthProvider: Email sign-in failed: $e');
      _setError(_parseAuthError(e.toString()));
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle({String? role}) async {
    print('🟡 AuthProvider: Starting Google sign-in with role: $role');
    _setState(AuthState.loading);
    try {
      await _authService.signInWithGoogle(role: role);
      print('✅ AuthProvider: Google sign-in successful');
      return true;
    } catch (e) {
      print('🔴 AuthProvider: Google sign-in failed: $e');
      _setError(_parseAuthError(e.toString()));
      return false;
    }
  }

  // Start phone authentication
  Future<bool> signInWithPhone(String phoneNumber) async {
    _setState(AuthState.loading);
    _isPhoneAuthInProgress = true;
    notifyListeners();
    
    try {
      await _authService.signInWithPhone(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            _isPhoneAuthInProgress = false;
            notifyListeners();
          } catch (e) {
            _setError('Auto-verification failed: $e');
            _isPhoneAuthInProgress = false;
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError('Phone verification failed: ${e.message}');
          _isPhoneAuthInProgress = false;
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setState(AuthState.unauthenticated); // Not loading anymore, waiting for OTP
          _isPhoneAuthInProgress = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          _isPhoneAuthInProgress = false;
          notifyListeners();
        },
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      _isPhoneAuthInProgress = false;
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP({
    required String smsCode,
    String? name,
    String? role,
  }) async {
    if (_verificationId == null) {
      _setError('No verification ID available');
      return false;
    }

    _setState(AuthState.loading);
    try {
      await _authService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
        name: name,
        role: role,
      );
      _verificationId = null;
      return true;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setState(AuthState.loading);
    try {
      await _authService.sendPasswordResetEmail(email);
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    _setState(AuthState.loading);
    try {
      await _authService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    }
  }

  // Complete profile setup
  Future<bool> completeProfile({
    String? specialization,
    int? experienceYears,
  }) async {
    if (_currentUser == null) {
      _setError('No user found');
      return false;
    }

    _setState(AuthState.loading);
    try {
      final updatedUser = _currentUser!.copyWith(
        specialization: specialization,
        experienceYears: experienceYears,
        profileCompleted: true,
      );
      
      await _authService.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError(_parseAuthError(e.toString()));
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setState(AuthState.loading);
    try {
      await _authService.signOut();
      _currentUser = null;
      _verificationId = null;
      _isPhoneAuthInProgress = false;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear verification ID (for phone auth)
  void clearVerificationId() {
    _verificationId = null;
    _isPhoneAuthInProgress = false;
    notifyListeners();
  }

  // Mark current user profile as complete
  Future<bool> markProfileComplete() async {
    if (_currentUser == null) return false;
    
    try {
      await _authService.markProfileComplete(_currentUser!.id);
      _currentUser = _currentUser!.copyWith(profileCompleted: true);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  String _parseAuthError(String error) {
    print('🔴 AuthProvider: Parsing error: $error');
    // Remove 'Exception: ' prefix if present
    final cleanError = error.startsWith('Exception: ') 
        ? error.substring(11) 
        : error;
    
    // Firebase Auth error codes
    if (cleanError.contains('user-not-found')) {
      return 'No account found with this email address. Please check your email or sign up.';
    } else if (cleanError.contains('wrong-password') || cleanError.contains('invalid-credential')) {
      return 'Incorrect password. Please check your password and try again.';
    } else if (cleanError.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (cleanError.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    } else if (cleanError.contains('too-many-requests')) {
      return 'Too many failed attempts. Please wait a few minutes before trying again.';
    } else if (cleanError.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (cleanError.contains('email-already-in-use')) {
      return 'An account with this email already exists. Please sign in instead.';
    } else if (cleanError.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (cleanError.contains('requires-recent-login')) {
      return 'Please sign out and sign in again to perform this action.';
    } else if (cleanError.contains('auth credential is incorrect, malformed or has expired')) {
      return 'Authentication error. Please try signing in again.';
    } else if (cleanError.contains('popup-closed-by-user')) {
      return 'Sign-in was cancelled. Please try again.';
    } else if (cleanError.contains('popup-blocked')) {
      return 'Popup was blocked. Please allow popups for this site and try again.';
    } else if (cleanError.contains('cancelled')) {
      return 'Sign-in was cancelled.';
    } else if (cleanError.contains('credential')) {
      return 'Authentication failed. Please try signing in again.';
    } else {
      // Log the full error for debugging
      print('🔴 AuthProvider: Unknown error - Full error: $error');
      print('🔴 AuthProvider: Clean error: $cleanError');
      
      // Check for common connection issues
      if (cleanError.toLowerCase().contains('timeout') || 
          cleanError.toLowerCase().contains('connection') ||
          cleanError.toLowerCase().contains('network')) {
        return 'Connection timeout. Please check your internet connection and try again.';
      }
      
      if (cleanError.toLowerCase().contains('firebase') ||
          cleanError.toLowerCase().contains('auth') ||
          cleanError.toLowerCase().contains('credential')) {
        return 'Authentication service error. Please check your internet connection and try again.';
      }
      
      // Return a user-friendly version of unknown errors with more context
      return 'Unexpected error: ${cleanError.length > 100 ? cleanError.substring(0, 100) + '...' : cleanError}';
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _state = AuthState.error;
    _errorMessage = error;
    _isPhoneAuthInProgress = false;
    notifyListeners();
  }
}