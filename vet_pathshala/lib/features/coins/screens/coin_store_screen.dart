import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/coin_provider.dart';
import '../services/coin_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'coin_history_screen.dart';

class CoinStoreScreen extends StatefulWidget {
  const CoinStoreScreen({super.key});

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();
}

class _CoinStoreScreenState extends State<CoinStoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final coinProvider = context.read<CoinProvider>();
      
      if (authProvider.currentUser != null) {
        coinProvider.initialize(authProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Coin Store',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CoinHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Earn', icon: Icon(Icons.add_circle_outline)),
            Tab(text: 'Buy', icon: Icon(Icons.shopping_cart_outlined)),
            Tab(text: 'Stats', icon: Icon(Icons.analytics_outlined)),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Coin Balance Header
            _buildCoinBalanceHeader(),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEarnTab(),
                  _buildBuyTab(),
                  _buildStatsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinBalanceHeader() {
    return Consumer<CoinProvider>(
      builder: (context, coinProvider, child) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning,
                AppColors.warning.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    '🪙',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Coins',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${coinProvider.currentBalance}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (coinProvider.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEarnTab() {
    return Consumer2<CoinProvider, AuthProvider>(
      builder: (context, coinProvider, authProvider, child) {
        final earningRates = coinProvider.getCoinEarningRates();
        
        return RefreshIndicator(
          onRefresh: () => coinProvider.refresh(authProvider.currentUser?.id ?? ''),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Daily Login Bonus
              _buildEarnCard(
                title: 'Daily Login Bonus',
                description: 'Log in daily to earn coins',
                coins: earningRates[CoinService.earnReasonDailyLogin] ?? 5,
                icon: Icons.calendar_today,
                color: AppColors.success,
                buttonText: coinProvider.hasClaimedDailyBonus ? 'Claimed Today' : 'Claim Now',
                onTap: coinProvider.hasClaimedDailyBonus 
                    ? null 
                    : () => _claimDailyBonus(authProvider.currentUser?.id ?? ''),
              ),

              const SizedBox(height: 16),

              // Quiz Completion
              _buildEarnCard(
                title: 'Complete Quizzes',
                description: 'Earn coins by completing practice quizzes',
                coins: earningRates[CoinService.earnReasonQuizComplete] ?? 10,
                icon: Icons.quiz,
                color: AppColors.primary,
                buttonText: 'Take Quiz',
                onTap: () {
                  // Navigate to quiz screen
                  Navigator.pop(context);
                  // Change to Questions tab
                  // This would need to be implemented in the main app navigation
                },
              ),

              const SizedBox(height: 16),

              // Watch Ads
              _buildEarnCard(
                title: 'Watch Video Ads',
                description: 'Watch short video ads to earn coins',
                coins: 2,
                icon: Icons.play_circle_outline,
                color: AppColors.info,
                buttonText: 'Watch Ad',
                onTap: () => _watchAdForCoins(authProvider.currentUser?.id ?? ''),
              ),

              const SizedBox(height: 16),

              // Referral Program
              _buildEarnCard(
                title: 'Refer Friends',
                description: 'Invite friends and earn when they join',
                coins: earningRates[CoinService.earnReasonReferral] ?? 50,
                icon: Icons.people_outline,
                color: AppColors.secondary,
                buttonText: 'Share App',
                onTap: () => _shareReferralCode(),
              ),

              const SizedBox(height: 16),

              // Achievement Rewards
              _buildEarnCard(
                title: 'Unlock Achievements',
                description: 'Complete milestones to earn bonus coins',
                coins: earningRates[CoinService.earnReasonAchievement] ?? 25,
                icon: Icons.emoji_events,
                color: AppColors.warning,
                buttonText: 'View Achievements',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Achievement system coming soon!'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBuyTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final coinPackages = [
          CoinPackage(id: 'coins_5', coins: 5, price: 0.99, popular: false),
          CoinPackage(id: 'coins_10', coins: 15, price: 1.99, popular: false, bonus: 5),
          CoinPackage(id: 'coins_25', coins: 35, price: 4.99, popular: true, bonus: 10),
          CoinPackage(id: 'coins_50', coins: 75, price: 9.99, popular: false, bonus: 25),
          CoinPackage(id: 'coins_100', coins: 160, price: 19.99, popular: false, bonus: 60),
        ];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Purchase coins to unlock premium features like drug calculators and interaction checkers.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Coin Packages
            ...coinPackages.map((package) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildCoinPackageCard(package),
            )).toList(),
          ],
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return Consumer<CoinProvider>(
      builder: (context, coinProvider, child) {
        final stats = coinProvider.stats;
        
        if (stats == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading statistics...'),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Earned',
                    '${stats.totalEarned}',
                    Icons.trending_up,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Spent',
                    '${stats.totalSpent}',
                    Icons.trending_down,
                    AppColors.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Quiz Rewards',
                    '${stats.quizCoins}',
                    Icons.quiz,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Login Bonuses',
                    '${stats.loginCoins}',
                    Icons.calendar_today,
                    AppColors.info,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Detailed Stats
            _buildDetailedStatsCard(stats),

            const SizedBox(height: 20),

            // Recent Transactions Preview
            _buildRecentTransactionsCard(),
          ],
        );
      },
    );
  }

  Widget _buildEarnCard({
    required String title,
    required String description,
    required int coins,
    required IconData icon,
    required Color color,
    required String buttonText,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '+$coins',
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '🪙',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onTap != null ? color : AppColors.textTertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinPackageCard(CoinPackage package) {
    return Card(
      elevation: package.popular ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: package.popular 
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          '🪙',
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${package.coins} Coins',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (package.bonus != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '+${package.bonus!} Bonus!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${package.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (package.bonus != null)
                            Text(
                              '${package.coins - package.bonus!} + ${package.bonus!} bonus',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _purchaseCoins(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: package.popular ? AppColors.primary : AppColors.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Purchase',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (package.popular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStatsCard(CoinStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Calculator Usage', '${stats.calculatorSpent} coins'),
            _buildStatRow('Total Transactions', '${stats.transactionCount}'),
            _buildStatRow('Earning Efficiency', '${stats.earningEfficiency.toStringAsFixed(1)} coins/transaction'),
            _buildStatRow('Spending Rate', '${(stats.spendingRate * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsCard() {
    return Consumer<CoinProvider>(
      builder: (context, coinProvider, child) {
        final recentTransactions = coinProvider.transactions.take(3).toList();
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CoinHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (recentTransactions.isEmpty)
                  const Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...recentTransactions.map((transaction) => 
                    _buildTransactionRow(transaction)
                  ).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionRow(CoinTransaction transaction) {
    final isEarned = transaction.type == CoinService.transactionTypeEarn;
    final color = isEarned ? AppColors.success : AppColors.error;
    final prefix = isEarned ? '+' : '-';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isEarned ? Icons.add_circle : Icons.remove_circle,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              transaction.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '$prefix${transaction.amount} 🪙',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _claimDailyBonus(String userId) async {
    final coinProvider = context.read<CoinProvider>();
    final success = await coinProvider.claimDailyBonus(userId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily bonus claimed! +5 coins'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily bonus already claimed today'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _watchAdForCoins(String userId) async {
    final coinProvider = context.read<CoinProvider>();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading ad...'),
          ],
        ),
      ),
    );

    // Simulate ad loading and watching
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context); // Close loading dialog

    final success = await coinProvider.watchAdForCoins(userId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad watched! +2 coins earned'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to earn coins from ad'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _shareReferralCode() {
    // In a real app, this would generate a unique referral code and share it
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral system coming soon!'),
      ),
    );
  }

  void _purchaseCoins(CoinPackage package) {
    // In a real app, this would integrate with in-app purchases
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Coins'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Purchase ${package.coins} coins for \$${package.price.toStringAsFixed(2)}?'),
            if (package.bonus != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Includes ${package.bonus!} bonus coins!',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('In-app purchases coming soon!'),
                ),
              );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
}

class CoinPackage {
  final String id;
  final int coins;
  final double price;
  final bool popular;
  final int? bonus;

  CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    this.popular = false,
    this.bonus,
  });
}