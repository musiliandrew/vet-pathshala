import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../coins/providers/coin_provider.dart';
import '../providers/home_provider.dart';
import '../../question_bank/screens/question_bank_screen.dart';
import '../../drug_center/screens/drug_index_screen.dart';
import '../../coins/screens/coin_store_screen.dart';
import '../../ebooks/screens/ebooks_screen.dart';

class UnifiedHomeScreen extends StatefulWidget {
  const UnifiedHomeScreen({super.key});

  @override
  State<UnifiedHomeScreen> createState() => _UnifiedHomeScreenState();
}

class _UnifiedHomeScreenState extends State<UnifiedHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final authProvider = context.read<AuthProvider>();
    final homeProvider = context.read<HomeProvider>();
    final user = authProvider.currentUser;
    
    if (user != null) {
      homeProvider.loadUserStatistics(user.id);
      homeProvider.loadRecentActivities(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, HomeProvider, CoinProvider>(
      builder: (context, authProvider, homeProvider, coinProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        return Scaffold(
          backgroundColor: UnifiedTheme.backgroundColor,
          body: RefreshIndicator(
            onRefresh: () => homeProvider.refresh(user.id),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header Section
                  _buildHeader(context, user, coinProvider),
                  
                  // Popular Content Cards
                  _buildPopularContent(context, user),
                  
                  // Popular Ebooks Section
                  _buildPopularEbooks(context),
                  
                  // Refer and Earn Section
                  _buildReferEarnSection(context),
                  
                  // Recent Activity
                  _buildRecentActivity(context, homeProvider),
                  
                  // Bottom Spacing
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user, CoinProvider coinProvider) {
    return UnifiedTheme.buildGradientContainer(
      child: SafeArea(
        child: Column(
          children: [
            // Top Header Row
            Row(
              children: [
                // User Info
                Expanded(
                  child: Row(
                    children: [
                      // Avatar with emoji
                      Container(
                        width: 50,
                        height: 50,
                        decoration: UnifiedTheme.avatarDecoration,
                        child: Center(
                          child: Text(
                            user.role.name == 'doctor' ? '👨‍⚕️' : 
                            user.role.name == 'pharmacist' ? '💊' : '👨‍🌾',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: UnifiedTheme.spacingM),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back !',
                            style: UnifiedTheme.headerSmall,
                          ),
                          Text(
                            user.name,
                            style: UnifiedTheme.bodyMedium,
                          ),
                          const SizedBox(height: UnifiedTheme.spacingXS),
                          Text(
                            user.role.name.toUpperCase(),
                            style: UnifiedTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Notification Badge
                GestureDetector(
                  onTap: () => _showNotifications(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: UnifiedTheme.notificationBadge,
                    child: Stack(
                      children: [
                        const Center(
                          child: Text(
                            '🔔',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: UnifiedTheme.notificationDot,
                            child: const Center(
                              child: Text(
                                '1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: UnifiedTheme.spacingXXL),

            // Search Bar
            Container(
              decoration: UnifiedTheme.elevatedCardDecoration,
              child: TextField(
                decoration: UnifiedTheme.searchInputDecoration.copyWith(
                  hintText: 'Search courses, topics...',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(UnifiedTheme.spacingM),
                    width: 28,
                    height: 28,
                    decoration: UnifiedTheme.notificationBadge,
                    child: const Center(
                      child: Text(
                        '🔍',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                onTap: () => _navigateToSearch(context),
              ),
            ),

            const SizedBox(height: UnifiedTheme.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularContent(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingXL),
      child: Column(
        children: [
          // Section Header
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Popular Content',
              style: UnifiedTheme.headerMedium,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingXL),
          // Content Grid - All Features Visible
          Column(
            children: [
              // First Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QuestionBankScreen()),
                      ),
                      child: Container(
                        height: 100,
                        decoration: UnifiedTheme.featureCardDecoration(UnifiedTheme.primaryGreen),
                        child: _buildFeatureCard('❓', 'Question\nBank'),
                      ),
                    ),
                  ),
                  const SizedBox(width: UnifiedTheme.spacingL),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DrugIndexScreen()),
                      ),
                      child: Container(
                        height: 100,
                        decoration: UnifiedTheme.featureCardDecoration(UnifiedTheme.lightGreen),
                        child: _buildFeatureCard('💊', 'Drug\nIndex'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UnifiedTheme.spacingL),
              // Second Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CoinStoreScreen()),
                      ),
                      child: Container(
                        height: 100,
                        decoration: UnifiedTheme.featureCardDecoration(UnifiedTheme.goldAccent),
                        child: _buildFeatureCard('🪙', 'Coin\nStore'),
                      ),
                    ),
                  ),
                  const SizedBox(width: UnifiedTheme.spacingL),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToFullAnalysis(context, user),
                      child: Container(
                        height: 100,
                        decoration: UnifiedTheme.featureCardDecoration(UnifiedTheme.blueAccent),
                        child: _buildFeatureCard('📊', 'Full\nAnalysis'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String emoji, String title) {
    return Stack(
      children: [
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: UnifiedTheme.spacingXS),
              Text(
                title,
                textAlign: TextAlign.center,
                style: UnifiedTheme.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularEbooks(BuildContext context) {
    final sampleEbooks = [
      {
        'title': 'Veterinary Pathology',
        'author': 'Dr. Sarah Johnson',
        'price': '₹299',
        'rating': 4.8,
        'cover': '📖',
      },
      {
        'title': 'Drug Formulations',
        'author': 'Prof. Michael Chen',
        'price': '₹399',
        'rating': 4.6,
        'cover': '💊',
      },
      {
        'title': 'Animal Nutrition',
        'author': 'Dr. Emily Davis',
        'price': '₹199',
        'rating': 4.5,
        'cover': '🌾',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingXL),
      child: Column(
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Ebooks',
                style: UnifiedTheme.headerMedium,
              ),
              GestureDetector(
                onTap: () => _navigateToEbooks(context),
                child: Text(
                  'See all',
                  style: UnifiedTheme.bodyLarge.copyWith(
                    color: UnifiedTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          // Ebooks Horizontal List
          SizedBox(
            height: 175, // Increased height to prevent overflow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sampleEbooks.length,
              itemBuilder: (context, index) {
                final ebook = sampleEbooks[index];
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: UnifiedTheme.spacingL),
                  child: UnifiedTheme.buildCard(
                    padding: const EdgeInsets.all(UnifiedTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Prevent overflow
                      children: [
                        // Ebook Cover
                        Container(
                          width: double.infinity,
                          height: 55, // Slightly reduced height
                          decoration: BoxDecoration(
                            color: UnifiedTheme.lightBorder,
                            borderRadius: BorderRadius.circular(UnifiedTheme.radiusS),
                          ),
                          child: Center(
                            child: Text(
                              ebook['cover'] as String,
                              style: const TextStyle(fontSize: 22), // Slightly smaller
                            ),
                          ),
                        ),
                        const SizedBox(height: UnifiedTheme.spacingS),
                        // Title
                        Flexible(
                          child: Text(
                            ebook['title'] as String,
                            style: UnifiedTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: UnifiedTheme.primaryText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: UnifiedTheme.spacingXS),
                        // Author
                        Text(
                          ebook['author'] as String,
                          style: UnifiedTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: UnifiedTheme.spacingS),
                        // Price and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                ebook['price'] as String,
                                style: UnifiedTheme.bodyMedium.copyWith(
                                  color: UnifiedTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: UnifiedTheme.goldAccent,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${ebook['rating']}',
                                  style: UnifiedTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildReferEarnSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(UnifiedTheme.spacingXL),
      padding: const EdgeInsets.all(UnifiedTheme.spacingXXL),
      decoration: UnifiedTheme.featureCardDecoration(UnifiedTheme.primaryGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Refer and earn',
            style: UnifiedTheme.headerLarge.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          Text(
            'Invite friends and earn rewards for every successful referral!',
            style: UnifiedTheme.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: UnifiedTheme.spacingM, 
                    horizontal: UnifiedTheme.spacingL
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(UnifiedTheme.radiusS),
                  ),
                  child: const Text(
                    'Share Code: VET2024',
                    style: UnifiedTheme.buttonText,
                  ),
                ),
              ),
              const SizedBox(width: UnifiedTheme.spacingM),
              Container(
                padding: const EdgeInsets.all(UnifiedTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(UnifiedTheme.radiusS),
                ),
                child: const Text(
                  '📤',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, HomeProvider homeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent activity',
            style: UnifiedTheme.headerLarge.copyWith(fontSize: 24),
          ),
          const SizedBox(height: UnifiedTheme.spacingXL),
          UnifiedTheme.buildCard(
            padding: const EdgeInsets.all(UnifiedTheme.spacingXL),
            child: homeProvider.isLoadingActivities
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(UnifiedTheme.spacingXL),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(UnifiedTheme.primaryGreen),
                      ),
                    ),
                  )
                : homeProvider.recentActivities.isEmpty
                    ? _buildEmptyActivity()
                    : Column(
                        children: [
                          for (int i = 0; i < homeProvider.recentActivities.length && i < 3; i++) ...{
                            _buildActivityItem(homeProvider.recentActivities[i]),
                            if (i < homeProvider.recentActivities.length - 1 && i < 2)
                              Divider(color: UnifiedTheme.borderColor),
                          },
                          if (homeProvider.recentActivities.length > 3) ...{
                            Divider(color: UnifiedTheme.borderColor),
                            UnifiedTheme.buildSecondaryButton(
                              text: 'View All Activities',
                              onPressed: () => _navigateToAllActivities(context),
                            ),
                          }
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Padding(
      padding: const EdgeInsets.all(UnifiedTheme.spacingXL),
      child: Column(
        children: [
          const Text(
            '📈',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: UnifiedTheme.spacingM),
          Text(
            'No recent activity',
            style: UnifiedTheme.bodyLarge.copyWith(
              color: UnifiedTheme.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingXS),
          Text(
            'Start learning to see your progress here',
            style: UnifiedTheme.bodyMedium.copyWith(
              color: UnifiedTheme.tertiaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final title = activity['title'] as String? ?? 'Unknown activity';
    final timestamp = activity['timestamp'] as DateTime? ?? DateTime.now();
    final iconType = activity['icon'] as String? ?? 'quiz';
    final isPositive = activity['isPositive'] as bool? ?? true;

    // Convert timestamp to relative time
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    String timeText;
    if (difference.inMinutes < 60) {
      timeText = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      timeText = '${difference.inHours}h ago';
    } else {
      timeText = '${difference.inDays}d ago';
    }

    // Choose emoji based on activity type
    String emoji;
    Color color;
    
    switch (iconType) {
      case 'coin':
        emoji = '🪙';
        color = isPositive ? UnifiedTheme.lightGreen : UnifiedTheme.goldAccent;
        break;
      case 'quiz':
        emoji = '❓';
        color = isPositive ? UnifiedTheme.lightGreen : UnifiedTheme.redAccent;
        break;
      default:
        emoji = '📊';
        color = UnifiedTheme.secondaryText;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UnifiedTheme.spacingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(UnifiedTheme.spacingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UnifiedTheme.radiusM),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: UnifiedTheme.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: UnifiedTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: UnifiedTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToSearch(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search feature coming soon!'),
        backgroundColor: UnifiedTheme.primaryGreen,
      ),
    );
  }

  void _navigateToFullAnalysis(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UnifiedTheme.radiusL)),
        title: const Row(
          children: [
            Text('📊', style: TextStyle(fontSize: 24)),
            SizedBox(width: UnifiedTheme.spacingS),
            Text('Full Analysis', style: UnifiedTheme.headerSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get comprehensive insights into your learning journey:',
              style: UnifiedTheme.bodyLarge,
            ),
            const SizedBox(height: UnifiedTheme.spacingL),
            const Text('• 📊 Performance Analytics', style: UnifiedTheme.bodyMedium),
            const Text('• 🎯 Weakness Analysis', style: UnifiedTheme.bodyMedium),
            const Text('• 📈 Learning Trends', style: UnifiedTheme.bodyMedium),
            const Text('• 🏆 Achievement Report', style: UnifiedTheme.bodyMedium),
            const Text('• 📋 Personalized Recommendations', style: UnifiedTheme.bodyMedium),
            const SizedBox(height: UnifiedTheme.spacingL),
            Text(
              '🤖 AI-powered insights coming soon!',
              style: UnifiedTheme.bodyMedium.copyWith(
                color: UnifiedTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: UnifiedTheme.bodyLarge),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You\'ll be notified when Full Analysis is available!'),
                  backgroundColor: UnifiedTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UnifiedTheme.radiusS)),
            ),
            child: const Text('Notify Me', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToEbooks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EbooksScreen()),
    );
  }

  void _navigateToAllActivities(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activity history coming soon!'),
        backgroundColor: UnifiedTheme.primaryGreen,
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UnifiedTheme.radiusL)),
        title: const Row(
          children: [
            Text('🔔', style: TextStyle(fontSize: 24)),
            SizedBox(width: UnifiedTheme.spacingS),
            Text('Notifications', style: UnifiedTheme.headerSmall),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text('🎉', style: TextStyle(fontSize: 24)),
              title: Text('Welcome to Vet-Pathshala!', style: UnifiedTheme.bodyLarge),
              subtitle: Text('Start your learning journey today', style: UnifiedTheme.bodyMedium),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: UnifiedTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}