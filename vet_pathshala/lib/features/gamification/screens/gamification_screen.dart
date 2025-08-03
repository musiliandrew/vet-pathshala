import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../coins/providers/coin_provider.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

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
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Gamification',
                  style: UnifiedTheme.headerSmall,
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UnifiedTheme.spacingXXL),
                  child: Column(
                    children: [
                      // Header with user level
                      Container(
                        padding: const EdgeInsets.all(UnifiedTheme.spacingXL),
                        decoration: UnifiedTheme.featureCardDecoration(UnifiedTheme.primaryGreen),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.emoji_events,
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
                                        'Your Journey',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Level 3 ${user.role.name}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${coinProvider.currentBalance}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Drug Coins',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Progress bar
                            Container(
                              width: double.infinity,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.65, // 65% progress to next level
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '650/1000 XP to Level 4',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Achievements section
                      _buildSection(
                        'Achievements',
                        Icons.military_tech,
                        UnifiedTheme.goldAccent,
                        [
                          _buildAchievementCard('First Steps', 'Complete your first quiz', Icons.quiz, true),
                          _buildAchievementCard('Knowledge Seeker', 'Answer 50 questions correctly', Icons.psychology, true),
                          _buildAchievementCard('Drug Expert', 'Use Drug Calculator 10 times', Icons.medical_services, false),
                          _buildAchievementCard('Streak Master', 'Maintain 7-day streak', Icons.local_fire_department, false),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Leaderboard section
                      _buildSection(
                        'Leaderboard',
                        Icons.leaderboard,
                        UnifiedTheme.primaryGreen,
                        [
                          _buildLeaderboardItem(1, 'Alex Chen', 'Doctor', 2450),
                          _buildLeaderboardItem(2, 'Sarah Johnson', 'Pharmacist', 2180),
                          _buildLeaderboardItem(3, user.name, user.role.name, 1650),
                          _buildLeaderboardItem(4, 'Mike Wilson', 'Farmer', 1420),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Daily challenges
                      _buildSection(
                        'Daily Challenges',
                        Icons.today,
                        UnifiedTheme.primaryGreen,
                        [
                          _buildChallengeCard('Answer 5 Questions', '3/5 completed', 0.6, 10),
                          _buildChallengeCard('Study for 30 minutes', '0/30 minutes', 0.0, 15),
                          _buildChallengeCard('Use Drug Index', '✓ Completed', 1.0, 5),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Coming soon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: UnifiedTheme.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: UnifiedTheme.blueAccent.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.rocket_launch, color: UnifiedTheme.blueAccent),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'More gamification features coming soon: Battle Arena, Team Challenges, and Seasonal Events!',
                                style: TextStyle(
                                  color: UnifiedTheme.blueAccent,
                                  fontWeight: FontWeight.w500,
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

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
    return Column(
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
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: UnifiedTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: UnifiedTheme.borderColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String title, String description, IconData icon, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? UnifiedTheme.primaryGreen.withOpacity(0.1) : UnifiedTheme.tertiaryText.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? UnifiedTheme.primaryGreen.withOpacity(0.3) : UnifiedTheme.tertiaryText.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked ? UnifiedTheme.primaryGreen.withOpacity(0.2) : UnifiedTheme.tertiaryText.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? UnifiedTheme.primaryGreen : UnifiedTheme.tertiaryText,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isUnlocked ? UnifiedTheme.primaryGreen : UnifiedTheme.tertiaryText,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: UnifiedTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle, color: UnifiedTheme.primaryGreen, size: 20),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, String role, int score) {
    Color rankColor;
    IconData? rankIcon;
    
    switch (rank) {
      case 1:
        rankColor = const Color(0xFFFFD700);
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0);
        rankIcon = Icons.emoji_events;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32);
        rankIcon = Icons.emoji_events;
        break;
      default:
        rankColor = UnifiedTheme.secondaryText;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rank <= 3 ? rankColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: rankIcon != null
                  ? Icon(rankIcon, color: rankColor, size: 16)
                  : Text(
                      '$rank',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: UnifiedTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$score pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(String title, String progress, double progressValue, int reward) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UnifiedTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: UnifiedTheme.goldAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$reward coins',
                  style: const TextStyle(
                    fontSize: 10,
                    color: UnifiedTheme.goldAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            progress,
            style: const TextStyle(
              fontSize: 12,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: UnifiedTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(UnifiedTheme.primaryGreen),
          ),
        ],
      ),
    );
  }
}