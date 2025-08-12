import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../providers/gamification_provider.dart';
import '../models/gamification_model.dart';
import '../../auth/providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'all_time';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    final gamificationProvider = context.read<GamificationProvider>();
    await gamificationProvider.loadLeaderboard(period: _selectedPeriod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: UnifiedTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: UnifiedTheme.primaryGreen,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'All Time'),
                Tab(text: 'This Week'),
                Tab(text: 'This Month'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              onTap: (index) {
                setState(() {
                  switch (index) {
                    case 0:
                      _selectedPeriod = 'all_time';
                      break;
                    case 1:
                      _selectedPeriod = 'week';
                      break;
                    case 2:
                      _selectedPeriod = 'month';
                      break;
                  }
                });
                _loadLeaderboard();
              },
            ),
          ),
        ),
      ),
      body: Consumer<GamificationProvider>(
        builder: (context, gamificationProvider, child) {
          if (gamificationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final leaderboard = gamificationProvider.leaderboard;
          final currentUser = context.read<AuthProvider>().currentUser;
          final userRank = currentUser != null 
              ? gamificationProvider.getUserRank(currentUser.id)
              : null;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildLeaderboardView(leaderboard, userRank, currentUser?.id),
              _buildLeaderboardView(leaderboard, userRank, currentUser?.id),
              _buildLeaderboardView(leaderboard, userRank, currentUser?.id),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardView(
    List<LeaderboardEntry> leaderboard,
    int? userRank,
    String? currentUserId,
  ) {
    if (leaderboard.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No leaderboard data yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start learning to see your ranking!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: Column(
        children: [
          // User's current position (if not in top 10)
          if (userRank != null && userRank > 10)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      '#$userRank',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Position',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'Keep learning to climb higher!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.trending_up,
                    color: Colors.blue.shade600,
                  ),
                ],
              ),
            ),

          // Top performers
          if (leaderboard.isNotEmpty) _buildTopThree(leaderboard),

          // Full leaderboard
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                final isCurrentUser = entry.userId == currentUserId;
                
                return _buildLeaderboardItem(entry, isCurrentUser);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree(List<LeaderboardEntry> leaderboard) {
    final topThree = leaderboard.take(3).toList();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UnifiedTheme.primaryGreen.withOpacity(0.1),
            UnifiedTheme.goldAccent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 2nd place
          if (topThree.length > 1)
            _buildPodiumPosition(topThree[1], 2, Colors.grey.shade400, 60),
          
          // 1st place
          if (topThree.isNotEmpty)
            _buildPodiumPosition(topThree[0], 1, UnifiedTheme.goldAccent, 80),
          
          // 3rd place
          if (topThree.length > 2)
            _buildPodiumPosition(topThree[2], 3, Colors.brown.shade400, 50),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(LeaderboardEntry entry, int position, Color color, double height) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: entry.profileImageUrl != null
                  ? NetworkImage(entry.profileImageUrl!)
                  : null,
              backgroundColor: color.withOpacity(0.2),
              child: entry.profileImageUrl == null
                  ? Text(
                      entry.displayName.isNotEmpty 
                          ? entry.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  position.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry.totalPoints} pts',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: height,
          width: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser 
            ? Border.all(color: Colors.blue.shade200, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(entry.rank).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(entry.rank),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Profile picture
          CircleAvatar(
            radius: 20,
            backgroundImage: entry.profileImageUrl != null
                ? NetworkImage(entry.profileImageUrl!)
                : null,
            backgroundColor: UnifiedTheme.primaryGreen.withOpacity(0.2),
            child: entry.profileImageUrl == null
                ? Text(
                    entry.displayName.isNotEmpty 
                        ? entry.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: UnifiedTheme.primaryGreen,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isCurrentUser ? Colors.blue.shade700 : null,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'You',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _getUserRoleDisplay(entry.userRole),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.questionsAnswered} questions',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(entry.accuracy * 100).toInt()}% accuracy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalPoints}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'points',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return UnifiedTheme.goldAccent;
    if (rank == 2) return Colors.grey.shade500;
    if (rank == 3) return Colors.brown.shade400;
    if (rank <= 10) return UnifiedTheme.primaryGreen;
    return Colors.grey.shade400;
  }

  String _getUserRoleDisplay(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'Veterinarian';
      case 'pharmacist':
        return 'Pharmacist';
      case 'farmer':
        return 'Farmer';
      default:
        return 'Student';
    }
  }
}