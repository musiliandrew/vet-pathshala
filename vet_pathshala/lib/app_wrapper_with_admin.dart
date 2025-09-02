import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/admin/providers/admin_auth_provider.dart';
import 'features/admin/screens/admin_login_screen.dart';
import 'features/admin/screens/enhanced_admin_dashboard_screen.dart';
import 'app.dart';

class AppWrapperWithAdminCheck extends StatefulWidget {
  const AppWrapperWithAdminCheck({super.key});

  @override
  State<AppWrapperWithAdminCheck> createState() => _AppWrapperWithAdminCheckState();
}

class _AppWrapperWithAdminCheckState extends State<AppWrapperWithAdminCheck> {
  bool _isAdminRoute = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentRoute();
  }

  void _checkCurrentRoute() {
    // For mobile platforms, admin route checking is not needed since
    // admin functionality is web-only
    setState(() {
      _isAdminRoute = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdminRoute) {
      return Consumer<AdminAuthProvider>(
        builder: (context, adminAuth, child) {
          if (adminAuth.isAdminAuthenticated && adminAuth.isValidAdminSession()) {
            return const EnhancedAdminDashboardScreen();
          }
          
          return const AdminLoginScreen();
        },
      );
    }
    
    return const AppWrapper();
  }
}