import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/unified_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/role_selection_screen.dart';
import 'features/auth/screens/profile_setup_screen.dart';
import 'features/home/screens/unified_home_screen.dart';
import 'features/home/screens/inspired_main_screen.dart';
import 'features/question_bank/screens/question_bank_screen.dart';
import 'features/drug_center/screens/drug_index_screen.dart';
import 'features/coins/providers/coin_provider.dart';
import 'features/coins/screens/coin_store_screen.dart';
import 'features/ebooks/screens/ebooks_screen.dart';
import 'features/gamification/screens/gamification_screen.dart';
import 'features/profile/screens/profile_screen.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (authProvider.state == AuthState.initial) {
          return const SplashScreen();
        }

        // Show authentication screens if not authenticated
        if (authProvider.state == AuthState.unauthenticated) {
          return const RoleSelectionScreen();
        }

        // Show profile setup if profile is not complete
        if (authProvider.isAuthenticated && 
            authProvider.currentUser != null && 
            !authProvider.currentUser!.isProfileComplete) {
          return ProfileSetupSkipScreen(authProvider: authProvider);
        }

        // Show main app if authenticated and profile is complete
        if (authProvider.isAuthenticated) {
          // Initialize coin provider when user is authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<CoinProvider>().initialize(authProvider.currentUser!.id);
          });
          return const InspiredMainScreen(); // Using the new inspired design
        }

        // Fallback to splash screen
        return const SplashScreen();
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _dotsController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    _logoController.forward();
    _dotsController.repeat();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              UnifiedTheme.backgroundColor,
              UnifiedTheme.primaryGreen.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo with Animation
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: UnifiedTheme.primaryGreen.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Animated Loading Dots
              AnimatedBuilder(
                animation: _dotsController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: UnifiedTheme.primaryGreen.withOpacity(
                              ((_dotsController.value + (index * 0.3)) % 1.0).clamp(0.3, 1.0),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Loading Text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Loading your veterinary journey...',
                  style: TextStyle(
                    fontSize: 16,
                    color: UnifiedTheme.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UnifiedHomeScreen(),    // Home
    const EbooksScreen(),            // E-books
    const DrugIndexScreen(),         // Drugs
    const GamificationScreen(),      // Gamification
    const ProfileScreen(),           // Profile
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: UnifiedTheme.cardBackground,
        selectedItemColor: UnifiedTheme.primaryGreen,
        unselectedItemColor: UnifiedTheme.tertiaryText,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'E-books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Drugs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Gamification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  
  const _PlaceholderScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: UnifiedTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens for the bottom navigation
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16),
            Text(
              'Library',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: UnifiedTheme.secondaryText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Question Bank, Notes, and E-books\nComing Soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrugCenterScreen extends StatelessWidget {
  const DrugCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Drug Center',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comprehensive Drug Database',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Access drug information & calculations',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Features
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    _buildFeatureCard(
                      context,
                      'Drug Index',
                      '100% FREE\nComprehensive database',
                      Icons.search,
                      AppColors.success,
                      true,
                    ),
                    _buildFeatureCard(
                      context,
                      'Drug Calculator',
                      '🪙 5 coins\nDosage calculations',
                      Icons.calculate,
                      AppColors.warning,
                      false,
                      coinCost: 5,
                    ),
                    _buildFeatureCard(
                      context,
                      'Interactions',
                      '🪙 3 coins\nDrug interactions',
                      Icons.warning_amber,
                      AppColors.error,
                      false,
                      coinCost: 3,
                    ),
                    _buildFeatureCard(
                      context,
                      'Prescription',
                      '🪙 2 coins\nPrescription helper',
                      Icons.receipt_long,
                      AppColors.info,
                      false,
                      coinCost: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    bool isFree, {
    int? coinCost,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFree 
                  ? '$title - Free feature coming soon!'
                  : '$title - Premium feature ($coinCost coins)',
            ),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFree ? AppColors.success : color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                if (isFree)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'FREE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (coinCost != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$coinCost 🪙',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: UnifiedTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16),
            Text(
              'Battle Arena',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: UnifiedTheme.secondaryText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Challenge friends and compete\nComing Soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: UnifiedTheme.secondaryText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'User profile and settings\nComing Soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick skip screen for profile setup (temporary for testing)
class ProfileSetupSkipScreen extends StatelessWidget {
  final AuthProvider authProvider;
  
  const ProfileSetupSkipScreen({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            const Icon(
              Icons.person_outline,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your profile needs to be completed\nto access the app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: UnifiedTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await authProvider.markProfileComplete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Skip & Continue to Home',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // TODO: Navigate to proper profile setup
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Full profile setup coming soon!'),
                  ),
                );
              },
              child: const Text('Complete Profile Setup'),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}