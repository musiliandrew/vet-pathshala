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
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildEnhancedFeatureCard(
                  'Drug Index',
                  'Complete database of veterinary medicines',
                  Icons.medical_services,
                  UnifiedTheme.primaryGreen,
                  '2,500+ drugs',
                  () => _navigateToDrugIndex(),
                ),
                _buildEnhancedFeatureCard(
                  'Drug Calculator',
                  'Accurate dosage & conversion calculations',
                  Icons.calculate,
                  UnifiedTheme.blueAccent,
                  'Smart calc',
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

  Widget _buildEnhancedFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String badge,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.98)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background gradient accent
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [color.withOpacity(0.08), Colors.transparent],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      color: UnifiedTheme.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      color: UnifiedTheme.secondaryText,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Arrow indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: color,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
            colors: [
              UnifiedTheme.goldAccent.withOpacity(0.05),
              UnifiedTheme.goldAccent.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: UnifiedTheme.goldAccent.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: UnifiedTheme.goldAccent.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Video icon with pulse animation
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.8, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [UnifiedTheme.goldAccent, UnifiedTheme.goldAccent.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: UnifiedTheme.goldAccent.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
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
                  );
                },
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Watch Video',
                          style: TextStyle(
                            color: UnifiedTheme.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: UnifiedTheme.goldAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '+5 Coins',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Watch ads & educational content to earn instant coins',
                      style: TextStyle(
                        color: UnifiedTheme.secondaryText,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: UnifiedTheme.goldAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: UnifiedTheme.goldAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: UnifiedTheme.goldAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '~30 seconds',
                            style: TextStyle(
                              color: UnifiedTheme.goldAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                color: UnifiedTheme.goldAccent,
                size: 16,
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
            colors: [
              UnifiedTheme.primaryGreen.withOpacity(0.05),
              UnifiedTheme.primaryGreen.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: UnifiedTheme.primaryGreen.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Diamond icon with sparkle effect
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [UnifiedTheme.primaryGreen, UnifiedTheme.lightGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: UnifiedTheme.primaryGreen.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
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
                  // Sparkle effect
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: UnifiedTheme.goldAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: UnifiedTheme.goldAccent.withOpacity(0.6),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Coin Store',
                          style: TextStyle(
                            color: UnifiedTheme.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: UnifiedTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Purchase coins to unlock premium drug features',
                      style: TextStyle(
                        color: UnifiedTheme.secondaryText,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₹9 - ₹999',
                            style: TextStyle(
                              color: UnifiedTheme.primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• Instant delivery',
                          style: TextStyle(
                            color: UnifiedTheme.secondaryText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                color: UnifiedTheme.primaryGreen,
                size: 16,
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