import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../coins/providers/coin_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        return Consumer<CoinProvider>(
          builder: (context, coinProvider, child) {
            return Scaffold(
              backgroundColor: UnifiedTheme.backgroundColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header with profile info
                      UnifiedTheme.buildGradientContainer(
                        padding: const EdgeInsets.all(UnifiedTheme.spacingXXL),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: UnifiedTheme.spacingXL),
                            // Profile avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: UnifiedTheme.avatarDecoration.copyWith(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: Center(
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'V',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.role.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Drug Coins',
                                '${coinProvider.currentBalance}',
                                Icons.monetization_on,
                                UnifiedTheme.goldAccent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Level',
                                '3',
                                Icons.emoji_events,
                                UnifiedTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Menu items
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildMenuSection('Account', [
                              _buildMenuItem(
                                'Edit Profile',
                                'Update your personal information',
                                Icons.edit_outlined,
                                () => _showComingSoon(context, 'Edit Profile'),
                              ),
                              _buildMenuItem(
                                'Preferences',
                                'App settings and preferences',
                                Icons.settings_outlined,
                                () => _showComingSoon(context, 'Preferences'),
                              ),
                              _buildMenuItem(
                                'Notifications',
                                'Manage notification settings',
                                Icons.notifications_outlined,
                                () => _showComingSoon(context, 'Notifications'),
                              ),
                            ]),

                            const SizedBox(height: 24),

                            _buildMenuSection('Learning', [
                              _buildMenuItem(
                                'Progress Report',
                                'View your learning analytics',
                                Icons.analytics_outlined,
                                () => _showComingSoon(context, 'Progress Report'),
                              ),
                              _buildMenuItem(
                                'Achievements',
                                'View badges and milestones',
                                Icons.military_tech_outlined,
                                () => _showComingSoon(context, 'Achievements'),
                              ),
                              _buildMenuItem(
                                'Study Streak',
                                'Track your daily learning',
                                Icons.local_fire_department_outlined,
                                () => _showComingSoon(context, 'Study Streak'),
                              ),
                            ]),

                            const SizedBox(height: 24),

                            _buildMenuSection('Support', [
                              _buildMenuItem(
                                'Help Center',
                                'Get help and support',
                                Icons.help_outline,
                                () => _showComingSoon(context, 'Help Center'),
                              ),
                              _buildMenuItem(
                                'Feedback',
                                'Share your thoughts with us',
                                Icons.feedback_outlined,
                                () => _showComingSoon(context, 'Feedback'),
                              ),
                              _buildMenuItem(
                                'About',
                                'App version and information',
                                Icons.info_outline,
                                () => _showAboutDialog(context),
                              ),
                            ]),

                            const SizedBox(height: 24),

                            // Sign out button
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 24),
                              child: OutlinedButton(
                                onPressed: () => _showSignOutDialog(context, authProvider),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: UnifiedTheme.redAccent,
                                  side: const BorderSide(color: UnifiedTheme.redAccent),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.logout_outlined),
                                    SizedBox(width: 8),
                                    Text(
                                      'Sign Out',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UnifiedTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: UnifiedTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: UnifiedTheme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: UnifiedTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: UnifiedTheme.borderColor),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: UnifiedTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: UnifiedTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: UnifiedTheme.tertiaryText,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: UnifiedTheme.blueAccent,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: UnifiedTheme.primaryGreen),
            SizedBox(width: 8),
            Text('About Vet-Pathshala'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Educational platform for Veterinary professionals'),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Interactive Q&A'),
            Text('• Drug Index & Calculator'),
            Text('• E-books Library'),
            Text('• Gamification System'),
            Text('• Progress Tracking'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: UnifiedTheme.redAccent),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}