import 'package:flutter/material.dart';
import '../utils/admin_route_handler.dart';

class AdminAuthProvider extends ChangeNotifier {
  bool _isAdminAuthenticated = false;
  String? _adminSession;

  // Admin credentials (in production, these should be environment variables or secure storage)
  static const String _adminEmail = 'admin@vetpathshala.com';
  static const String _adminPassword = 'VetPathshala@Admin2024!';
  
  bool get isAdminAuthenticated => _isAdminAuthenticated;
  
  Future<bool> authenticateAdmin(String email, String password) async {
    // Simulate authentication delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (email.toLowerCase().trim() == _adminEmail.toLowerCase() && 
        password == _adminPassword) {
      _isAdminAuthenticated = true;
      _adminSession = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Log successful access
      AdminRouteHandler.logAdminAccess(email, true);
      
      notifyListeners();
      return true;
    }
    
    // Log failed access attempt
    AdminRouteHandler.logAdminAccess(email, false);
    
    return false;
  }
  
  void logoutAdmin() {
    _isAdminAuthenticated = false;
    _adminSession = null;
    notifyListeners();
  }
  
  bool isValidAdminSession() {
    if (_adminSession == null || !_isAdminAuthenticated) {
      return false;
    }
    
    // Session expires after 2 hours
    final sessionTime = int.tryParse(_adminSession!) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final twoHoursInMs = 2 * 60 * 60 * 1000;
    
    if (currentTime - sessionTime > twoHoursInMs) {
      logoutAdmin();
      return false;
    }
    
    return true;
  }
}