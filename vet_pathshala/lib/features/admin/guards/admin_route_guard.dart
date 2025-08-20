import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
import '../screens/admin_login_screen.dart';
import '../screens/enhanced_admin_dashboard_screen.dart';

class AdminRouteGuard extends StatelessWidget {
  final Widget child;
  
  const AdminRouteGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, adminAuth, _) {
        // Check if admin is authenticated and session is valid
        if (adminAuth.isAdminAuthenticated && adminAuth.isValidAdminSession()) {
          return child;
        }
        
        // If not authenticated, show login screen
        return const AdminLoginScreen();
      },
    );
  }
}

class AdminNavigationGuard {
  static bool canAccessAdmin(BuildContext context) {
    final adminAuth = context.read<AdminAuthProvider>();
    return adminAuth.isAdminAuthenticated && adminAuth.isValidAdminSession();
  }
  
  static void navigateToAdmin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminRouteGuard(
          child: EnhancedAdminDashboardScreen(),
        ),
      ),
    );
  }
}