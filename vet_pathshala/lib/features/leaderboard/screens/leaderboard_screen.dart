import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/gamification_models.dart';
import '../../../shared/providers/gamification_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  final UserModel user;

  const LeaderboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = 'all-time';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaderboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLeaderboard() {
    final provider = context.read<GamificationProvider>();
    provider.loadLeaderboard(
      timeframe: _selectedTimeframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E3FF), // Matching the HTML gradient background
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8E3FF), Color(0xFFF0EBFF)],
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xFF6B46C1),
                          size: 20,
                        ),
                      ),
                    ),
                    
                    // Title
                    const Expanded(
                      child: Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Spacer for balance
                    const SizedBox(width: 50),
                  ],
                ),
              ),

              // Change State Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loadLeaderboard,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Refresh Rankings',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B46C1),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B46C1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'All Time'),
                      Tab(text: 'Monthly'),
                      Tab(text: 'Weekly'),
                    ],
                    onTap: (index) {
                      switch (index) {
                        case 0:
                          _selectedTimeframe = 'all-time';
                          break;
                        case 1:
                          _selectedTimeframe = 'monthly';
                          break;
                        case 2:
                          _selectedTimeframe = 'weekly';
                          break;
                      }
                      _loadLeaderboard();
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Content
              Expanded(
                child: Consumer<GamificationProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.leaderboard.isEmpty) {
                      return _buildEmptyState();
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Podium
                          if (provider.leaderboard.length >= 3)
                            _buildPodium(provider.leaderboard),
                          
                          const SizedBox(height: 30),
                          
                          // Leaderboard List
                          _buildLeaderboardList(provider.leaderboard),
                          
                          // Current User Highlight (if not in top rankings)
                          if (provider.userLeaderboardEntry != null)
                            _buildCurrentUserHighlight(provider.userLeaderboardEntry!),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntryModel> leaderboard) {
    final top3 = leaderboard.take(3).toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place
          if (top3.length > 1) _buildPodiumItem(top3[1], 2, false),
          // First place
          if (top3.isNotEmpty) _buildPodiumItem(top3[0], 1, true),
          // Third place
          if (top3.length > 2) _buildPodiumItem(top3[2], 3, false),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(LeaderboardEntryModel entry, int rank, bool isFirst) {
    final colors = [
      const Color(0xFF6B46C1), // First
      const Color(0xFF8B5CF6), // Second
      const Color(0xFFA78BFA), // Third
    ];
    
    return Column(
      children: [
        // Avatar
        Container(
          width: isFirst ? 100 : 80,
          height: isFirst ? 100 : 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              CircleAvatar(
                radius: isFirst ? 50 : 40,
                backgroundColor: colors[rank - 1].withOpacity(0.2),
                child: Text(
                  entry.displayName.isNotEmpty 
                      ? entry.displayName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: colors[rank - 1],
                    fontWeight: FontWeight.bold,
                    fontSize: isFirst ? 36 : 28,
                  ),
                ),
              ),
              
              // Rank badge
              Positioned(
                bottom: -5,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors[rank - 1],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Name
        SizedBox(
          width: 80,
          child: Text(
            entry.displayName.length > 10 
                ? '${entry.displayName.substring(0, 10)}...'
                : entry.displayName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(height: 5),
        
        // Score
        Text(
          '${entry.totalPoints}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntryModel> leaderboard) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: leaderboard.asMap().entries.map((entry) {
          final index = entry.key;
          final leaderboardEntry = entry.value;
          final isCurrentUser = leaderboardEntry.userId == widget.user.id;
          
          return _buildLeaderboardItem(
            leaderboardEntry, 
            index + 1, 
            isCurrentUser,
            isLastItem: index == leaderboard.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLeaderboardItem(
    LeaderboardEntryModel entry, 
    int position, 
    bool isCurrentUser,
    {bool isLastItem = false}
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: isLastItem ? null : Border(
          bottom: BorderSide(color: const Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Rank circle
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Color(0xFF6B46C1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 15),
          
          // Avatar
          CircleAvatar(
            radius: 22.5,
            backgroundColor: _getRoleColor(entry.userRole).withOpacity(0.2),
            child: Text(
              entry.displayName.isNotEmpty 
                  ? entry.displayName[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                color: _getRoleColor(entry.userRole),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          
          const SizedBox(width: 15),
          
          // User info
          Expanded(
            child: Text(
              entry.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
                fontSize: 16,
              ),
            ),
          ),
          
          // Score
          Text(
            '${entry.totalPoints}',
            style: const TextStyle(
              color: Color(0xFF10B981),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserHighlight(LeaderboardEntryModel userEntry) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF6B46C1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Rank circle
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${userEntry.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 15),
            
            // Avatar
            CircleAvatar(
              radius: 22.5,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                userEntry.displayName.isNotEmpty 
                    ? userEntry.displayName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            
            const SizedBox(width: 15),
            
            // User info
            const Expanded(
              child: Text(
                'You',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            
            // Score
            Text(
              '${userEntry.totalPoints}',
              style: const TextStyle(
                color: Color(0xFFA7F3D0),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 24),
            Text(
              'No Rankings Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Complete quizzes and earn points to appear on the leaderboard!',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return Colors.blue;
      case 'pharmacist':
        return Colors.green;
      case 'farmer':
        return Colors.orange;
      default:
        return const Color(0xFF6B46C1);
    }
  }
}