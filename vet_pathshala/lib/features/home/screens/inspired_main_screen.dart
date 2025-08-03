import 'package:flutter/material.dart';
import '../widgets/inspired_bottom_nav.dart';
import 'stable_inspired_home_screen.dart';
import '../../ebooks/screens/ebooks_screen.dart';
import '../../drug_center/screens/drug_index_screen.dart';
import '../../gamification/screens/gamification_screen.dart';
import '../../profile/screens/profile_screen.dart';

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
}