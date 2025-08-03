import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../coins/providers/coin_provider.dart';
import '../../coins/screens/coin_store_screen.dart';
import '../providers/home_provider.dart';
import '../../question_bank/screens/question_bank_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Consumer2<AuthProvider, HomeProvider>(
      builder: (context, authProvider, homeProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => homeProvider.refresh(user.id),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, user),
                    const SizedBox(height: 32),

                    // Stats Cards
                    _buildStatsCards(context, user, homeProvider),
                    const SizedBox(height: 32),

                    // Quick Actions
                    _buildQuickActions(context, user),
                    const SizedBox(height: 32),

                    // Recent Activity
                    _buildRecentActivity(context, homeProvider),
                    const SizedBox(height: 32),

                    // Profile Completion
                    if (!user.isProfileComplete) _buildProfileCompletion(context, user),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return Row(
      children: [
        // Profile Avatar
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.getRoleGradient(user.role.name),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.getRoleColor(user.role.name).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.role.name.capitalize(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.getRoleColor(user.role.name),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Settings Button
        IconButton(
          onPressed: () => _showSettingsMenu(context),
          icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsCards(BuildContext context, UserModel user, HomeProvider homeProvider) {
    final stats = homeProvider.userStats;
    
    return Column(
      children: [
        // Drug Coins Card (Prominent)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.getRoleColor(user.role.name),
                AppColors.getRoleColor(user.role.name).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.getRoleColor(user.role.name).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Drug Coins',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Consumer<CoinProvider>(
                      builder: (context, coinProvider, child) {
                        return Text(
                          '${coinProvider.currentBalance} coins',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _navigateToEarnCoins(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.getRoleColor(user.role.name),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Earn More',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Other Stats - Real Data
        if (homeProvider.isLoadingStats)
          Container(
            height: 100,
            child: const Center(child: CircularProgressIndicator()),
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Questions\nAnswered',
                  '${stats?.questionsAnswered ?? 0}',
                  Icons.quiz_outlined,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Accuracy\nRate',
                  '${stats?.accuracy != null ? (stats!.accuracy * 100).toInt() : 0}%',
                  Icons.track_changes_outlined,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Current\nStreak',
                  '${stats?.streak ?? 0} days',
                  Icons.local_fire_department_outlined,
                  AppColors.warning,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              context,
              'Drug Index',
              '100% FREE\nComprehensive drug database',
              Icons.medical_services_outlined,
              AppColors.success,
              () => _navigateToDrugIndex(context),
              isFree: true,
            ),
            _buildActionCard(
              context,
              'Drug Calculator',
              '🪙 5 coins\nDosage & interaction checker',
              Icons.calculate_outlined,
              AppColors.getRoleColor(user.role.name),
              () => _navigateToDrugCalculator(context),
              coinCost: 5,
            ),
            _buildActionCard(
              context,
              'Question Bank',
              'Practice questions\nand improve skills',
              Icons.quiz_outlined,
              AppColors.primary,
              () => _navigateToQuestionBank(context),
            ),
            _buildActionCard(
              context,
              'Battle Mode',
              'Challenge friends\nand compete',
              Icons.sports_esports_outlined,
              AppColors.warning,
              () => _navigateToBattle(context),
            ),
            _buildActionCard(
              context,
              'Short Notes',
              'Quick revision\nand study notes',
              Icons.note_outlined,
              AppColors.info,
              () => _navigateToNotes(context),
            ),
            _buildActionCard(
              context,
              'Watch Ads',
              'Earn coins by\nwatching ads',
              Icons.play_circle_outline,
              AppColors.warning,
              () => _navigateToWatchAds(context),
              isEarnCoins: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isFree = false,
    int? coinCost,
    bool isEarnCoins = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFree 
                ? AppColors.success
                : coinCost != null 
                    ? AppColors.warning.withOpacity(0.5)
                    : AppColors.border,
            width: isFree || coinCost != null ? 2 : 1,
          ),
          boxShadow: isFree || isEarnCoins
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    if (isEarnCoins)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '+COINS',
                          style: TextStyle(
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, HomeProvider homeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: homeProvider.isLoadingActivities
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : homeProvider.recentActivities.isEmpty
                  ? _buildEmptyActivity(context)
                  : Column(
                      children: [
                        for (int i = 0; i < homeProvider.recentActivities.length; i++) ...[
                          _buildActivityItemFromData(
                            context,
                            homeProvider.recentActivities[i],
                          ),
                          if (i < homeProvider.recentActivities.length - 1)
                            const Divider(color: AppColors.border),
                        ],
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyActivity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            'No recent activity',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start learning to see your activity here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItemFromData(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    final title = activity['title'] as String? ?? 'Unknown activity';
    final description = activity['description'] as String? ?? '';
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

    // Choose icon and color based on activity type
    IconData icon;
    Color color;
    
    switch (iconType) {
      case 'coin':
        icon = Icons.monetization_on_outlined;
        color = isPositive ? AppColors.success : AppColors.warning;
        break;
      case 'quiz':
        icon = Icons.quiz_outlined;
        color = isPositive ? AppColors.success : AppColors.error;
        break;
      case 'battle':
        icon = Icons.emoji_events_outlined;
        color = isPositive ? AppColors.warning : AppColors.textSecondary;
        break;
      case 'note':
        icon = Icons.note_outlined;
        color = AppColors.info;
        break;
      default:
        icon = Icons.history;
        color = AppColors.textSecondary;
    }

    return _buildActivityItem(context, title, timeText, icon, color);
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletion(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.getRoleGradient(user.role.name),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Get personalized content and recommendations',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _navigateToProfileSetup(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.getRoleColor(user.role.name),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Complete',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _navigateToProfile(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSettings(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                _signOut(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDrugIndex(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DrugIndexScreen(),
      ),
    );
  }

  void _navigateToDrugCalculator(BuildContext context) {
    // TODO: Check coin balance and navigate to drug calculator
    final coinProvider = context.read<CoinProvider>();
    if (coinProvider.currentBalance >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🪙 Drug Calculator - Opening premium feature...'),
          backgroundColor: AppColors.warning,
        ),
      );
    } else {
      _showInsufficientCoinsDialog(context, 5);
    }
  }

  void _navigateToEarnCoins(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CoinStoreScreen(),
      ),
    );
  }

  void _navigateToWatchAds(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CoinStoreScreen(),
      ),
    );
  }

  void _navigateToQuestionBank(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuestionBankScreen(),
      ),
    );
  }

  void _navigateToBattle(BuildContext context) {
    // TODO: Navigate to battle mode
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Battle Mode - Coming Soon!')),
    );
  }

  void _navigateToNotes(BuildContext context) {
    // TODO: Navigate to notes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Short Notes - Coming Soon!')),
    );
  }

  void _navigateToProfileSetup(BuildContext context) {
    // TODO: Navigate to profile setup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Setup - Available in auth flow')),
    );
  }

  void _navigateToProfile(BuildContext context) {
    // TODO: Navigate to profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile - Coming Soon!')),
    );
  }

  void _navigateToSettings(BuildContext context) {
    // TODO: Navigate to settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings - Coming Soon!')),
    );
  }

  void _showInsufficientCoinsDialog(BuildContext context, int requiredCoins) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.monetization_on, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text('Insufficient Coins'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You need $requiredCoins coins to access this feature.'),
            const SizedBox(height: 16),
            const Text('Earn coins by:'),
            const SizedBox(height: 8),
            const Text('• Watching ads (2-5 coins)'),
            const Text('• Completing daily tasks'),
            const Text('• Winning battles'),
            const Text('• Or purchase coin packages'),
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
              _navigateToEarnCoins(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text(
              'Earn Coins',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            child: const Text(AppStrings.signOut),
          ),
        ],
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}