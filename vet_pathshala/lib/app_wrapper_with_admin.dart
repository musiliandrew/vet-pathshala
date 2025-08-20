import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
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
    
    // Listen for URL changes
    html.window.onPopState.listen((event) {
      _checkCurrentRoute();
    });
  }

  void _checkCurrentRoute() {
    final currentUrl = html.window.location.href;
    final currentPath = html.window.location.pathname;
    final currentHash = html.window.location.hash;
    
    setState(() {
      _isAdminRoute = (currentPath?.contains('/admin') ?? false) || 
                     (currentHash?.contains('admin') ?? false) ||
                     (currentUrl?.contains('/admin') ?? false);
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