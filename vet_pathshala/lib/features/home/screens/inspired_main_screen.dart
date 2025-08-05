import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/inspired_bottom_nav.dart';
import 'stable_inspired_home_screen.dart';
import 'farmer_home_screen.dart';
import '../../ebooks/screens/ebooks_screen.dart';
import '../../drug_center/screens/drug_index_screen.dart';
import '../../gamification/screens/gamification_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../auth/providers/auth_provider.dart';

class InspiredMainScreen extends StatefulWidget {
  const InspiredMainScreen({super.key});

  @override
  State<InspiredMainScreen> createState() => _InspiredMainScreenState();
}

class _InspiredMainScreenState extends State<InspiredMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StableInspiredHomeScreen(),
    const EbooksScreen(),
    const DrugIndexScreen(),
    const GamificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    // Debug: Print user info in InspiredMainScreen
    print('🔧 InspiredMainScreen: Building with user role = "${user?.userRole}"');
    print('🔧 InspiredMainScreen: User name = "${user?.name}"');
    
    // For farmers, show farmer-specific home screen and navigation
    if (user?.userRole == 'farmer') {
      print('✅ InspiredMainScreen: Detected farmer role, building farmer UI');
      
      final farmerScreens = [
        const FarmerHomeScreen(),     // Farmer home instead of StableInspiredHomeScreen
        const EbooksScreen(),
        const DrugIndexScreen(),
        const GamificationScreen(),
        const ProfileScreen(),
      ];
      
      return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: farmerScreens,
        ),
        bottomNavigationBar: _buildFarmerBottomNav(),
      );
    }
    
    print('🟡 InspiredMainScreen: Building standard UI for role: ${user?.userRole}');
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: InspiredBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Farmer-specific bottom navigation
  Widget _buildFarmerBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFF2E7D32).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF2E7D32), // Farm green
        unselectedItemColor: Colors.grey,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Text('🏠', style: TextStyle(fontSize: 20)),
            activeIcon: Text('🏠', style: TextStyle(fontSize: 22)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Text('📖', style: TextStyle(fontSize: 20)),
            activeIcon: Text('📖', style: TextStyle(fontSize: 22)),
            label: 'E-books',
          ),
          BottomNavigationBarItem(
            icon: Text('💊', style: TextStyle(fontSize: 20)),
            activeIcon: Text('💊', style: TextStyle(fontSize: 22)),
            label: 'Drugs',
          ),
          BottomNavigationBarItem(
            icon: Text('📁', style: TextStyle(fontSize: 20)),
            activeIcon: Text('📁', style: TextStyle(fontSize: 22)),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Text('👤', style: TextStyle(fontSize: 20)),
            activeIcon: Text('👤', style: TextStyle(fontSize: 22)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}