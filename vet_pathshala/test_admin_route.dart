import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Simple admin provider for testing
class SimpleAdminProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  
  bool get isAuthenticated => _isAuthenticated;
  
  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }
}

// Simple admin login screen
class SimpleAdminLogin extends StatelessWidget {
  const SimpleAdminLogin({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ADMIN LOGIN - WORKING!')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉 ADMIN ROUTE IS WORKING!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('URL: /admin', style: TextStyle(fontSize: 18)),
            Text('This proves the routing is functional.'),
          ],
        ),
      ),
    );
  }
}

// Simple main screen
class SimpleMain extends StatelessWidget {
  const SimpleMain({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main App')),
      body: const Center(
        child: Text('Main App - Go to /admin to test admin route'),
      ),
    );
  }
}

// Test router configuration
final testRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/admin',
      builder: (context, state) {
        print('✅ ADMIN ROUTE HIT!');
        return const SimpleAdminLogin();
      },
    ),
    GoRoute(
      path: '/',
      builder: (context, state) {
        print('✅ MAIN ROUTE HIT!');
        return const SimpleMain();
      },
    ),
  ],
);

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SimpleAdminProvider(),
      child: MaterialApp.router(
        title: 'Admin Route Test',
        routerConfig: testRouter,
      ),
    ),
  );
}