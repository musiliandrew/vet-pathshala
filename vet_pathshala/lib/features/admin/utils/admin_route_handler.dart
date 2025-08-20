import 'package:flutter/material.dart';
import '../guards/admin_route_guard.dart';
import '../screens/enhanced_admin_dashboard_screen.dart';

class AdminRouteHandler {
  // This creates a secure admin route that can be accessed via /admin
  static const String adminRoutePath = '/admin';
  
  // This method handles admin route navigation
  static void handleAdminRoute(BuildContext context, {String? route}) {
    if (route == adminRoutePath) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AdminRouteGuard(
            child: EnhancedAdminDashboardScreen(),
          ),
        ),
      );
    }
  }
  
  // This creates a secret admin URL pattern for additional security
  static bool isValidAdminPath(String path) {
    return path == adminRoutePath || 
           path == '/admin-panel' || 
           path == '/dashboard-admin';
  }
  
  // Admin access logging (for security auditing)
  static void logAdminAccess(String email, bool success) {
    final timestamp = DateTime.now().toIso8601String();
    // Log to console in development, in production this could go to a secure log service
    print('Admin Access: $timestamp - Email: $email - Success: $success');
  }
}