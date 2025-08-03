import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../coins/providers/coin_provider.dart';
import '../../../features/coins/screens/coin_store_screen.dart';
import 'drug_index_screen.dart';
import 'enhanced_drug_calculator_screen.dart';

class EnhancedDrugCenterScreen extends StatefulWidget {
  const EnhancedDrugCenterScreen({super.key});

  @override
  State<EnhancedDrugCenterScreen> createState() => _EnhancedDrugCenterScreenState();
}

class _EnhancedDrugCenterScreenState extends State<EnhancedDrugCenterScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Please sign in to access drug center')),
          );
        }

        return Scaffold(
          backgroundColor: UnifiedTheme.backgroundColor,
          body: SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Header with drug character
                        _buildHeader(context, user),
                        
                        // Content
                        Expanded(
                          child: _buildContent(context, user),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return UnifiedTheme.buildGradientContainer(
      child: Column(
        children: [
          // Top navigation bar with back button
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Coins Display
              Consumer<CoinProvider>(
                builder: (context, coinProvider, child) {
                  return GestureDetector(
                    onTap: _navigateToCoinStore,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: UnifiedTheme.goldAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: UnifiedTheme.goldAccent.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '\$',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Drug Coins: ${user.coins}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: UnifiedTheme.spacingXXL),
          
          // Drug character with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 3),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -8 * (0.5 - (value * 2 - 1).abs())),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Title and subtitle
          Text(
            'Drug Center',
            style: UnifiedTheme.headerLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              'Veterinary medicine resources',
              style: UnifiedTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Features Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: UnifiedTheme.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: UnifiedTheme.blueAccent.withOpacity(0.3)),
            ),
            child: Text(
              'Features',
              style: UnifiedTheme.headerMedium.copyWith(
                color: UnifiedTheme.blueAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Feature Cards Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: UnifiedTheme.spacingM,
              mainAxisSpacing: UnifiedTheme.spacingM,
              childAspectRatio: 1.0,
              children: [
                _buildFeatureCard(
                  'Drug Index',
                  'All medicines listed',
                  Icons.medical_services,
                  UnifiedTheme.primaryGreen,
                  () => _navigateToDrugIndex(),
                ),
                _buildFeatureCard(
                  'Drug Calculator',
                  'Dose & conversion tool',
                  Icons.calculate,
                  UnifiedTheme.blueAccent,
                  () => _navigateToDrugCalculator(),
                ),
              ],
            ),
          ),
          
          // Earn Coins Section
          const SizedBox(height: UnifiedTheme.spacingL),
          Text(
            'Earn Drug Coins',
            style: UnifiedTheme.headerMedium.copyWith(
              color: UnifiedTheme.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingM),
          
          _buildEarnCoinsCard(),
          
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Coin Store Section
          Text(
            'Coin Store',
            style: UnifiedTheme.headerMedium.copyWith(
              color: UnifiedTheme.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingM),
          
          _buildCoinStoreCard(),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
          border: Border.all(color: UnifiedTheme.borderColor),
          boxShadow: UnifiedTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(UnifiedTheme.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: UnifiedTheme.spacingM),
              Text(
                title,
                style: UnifiedTheme.headerSmall.copyWith(
                  color: UnifiedTheme.primaryText,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UnifiedTheme.spacingS),
              Text(
                description,
                style: UnifiedTheme.bodySmall.copyWith(
                  color: UnifiedTheme.secondaryText,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarnCoinsCard() {
    return GestureDetector(
      onTap: _watchVideoToEarnCoins,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
          border: Border.all(color: UnifiedTheme.borderColor),
          boxShadow: UnifiedTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(UnifiedTheme.spacingL),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [UnifiedTheme.goldAccent, UnifiedTheme.goldAccent.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: UnifiedTheme.goldAccent.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: UnifiedTheme.spacingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Watch Video to Earn Coins',
                      style: UnifiedTheme.headerSmall.copyWith(
                        color: UnifiedTheme.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: UnifiedTheme.spacingS),
                    Text(
                      'Watch & earn instant coins to unlock features',
                      style: UnifiedTheme.bodyMedium.copyWith(
                        color: UnifiedTheme.secondaryText,
                        height: 1.4,
                      ),
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

  Widget _buildCoinStoreCard() {
    return GestureDetector(
      onTap: _navigateToCoinStore,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
          border: Border.all(color: UnifiedTheme.borderColor),
          boxShadow: UnifiedTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(UnifiedTheme.spacingL),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [UnifiedTheme.primaryGreen, UnifiedTheme.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: UnifiedTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.diamond,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: UnifiedTheme.spacingL),
              Text(
                'Buy Coins',
                style: UnifiedTheme.headerSmall.copyWith(
                  color: UnifiedTheme.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDrugIndex() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DrugIndexScreen(),
      ),
    );
  }

  void _navigateToDrugCalculator() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EnhancedDrugCalculatorScreen(),
      ),
    );
  }

  void _navigateToCoinStore() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CoinStoreScreen(),
      ),
    );
  }

  void _watchVideoToEarnCoins() {
    // Simulate watching video to earn coins
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting video to earn coins...'),
        backgroundColor: UnifiedTheme.goldAccent,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Simulate earning coins after delay
    Future.delayed(const Duration(seconds: 2), () async {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        // Award 5 coins for watching video
        final updatedUser = authProvider.currentUser!.copyWith(
          coins: authProvider.currentUser!.coins + 5,
        );
        
        final success = await authProvider.updateUserProfile(updatedUser);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You earned 5 coins! 🎉'),
              backgroundColor: UnifiedTheme.primaryGreen,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to award coins. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }
}