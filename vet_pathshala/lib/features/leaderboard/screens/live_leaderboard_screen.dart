import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/gamification_models.dart';
import '../../../shared/providers/gamification_provider.dart';
import '../widgets/leaderboard_entry_widget.dart';
import '../widgets/user_rank_widget.dart';

class LiveLeaderboardScreen extends StatefulWidget {
  final UserModel user;

  const LiveLeaderboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<LiveLeaderboardScreen> createState() => _LiveLeaderboardScreenState();
}

class _LiveLeaderboardScreenState extends State<LiveLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;
  String _selectedTimeframe = 'all-time';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaderboard();
      _startRealTimeUpdates();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadLeaderboard() {
    final provider = context.read<GamificationProvider>();
    provider.loadLeaderboard(
      category: _selectedCategory,
      timeframe: _selectedTimeframe,
    );
  }

  void _startRealTimeUpdates() {
    // Update leaderboard every 30 seconds for real-time experience
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadLeaderboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Live Leaderboard',
          style: UnifiedTheme.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: UnifiedTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'Categories'),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                _selectedTimeframe = 'all-time';
                break;
              case 1:
                _selectedTimeframe = 'weekly';
                break;
              case 2:
                _selectedTimeframe = 'monthly';
                break;
              case 3:
                _selectedTimeframe = 'daily';
                break;
            }
            _loadLeaderboard();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // User's current rank
          Consumer<GamificationProvider>(
            builder: (context, provider, child) {
              final userRank = provider.getUserRank(widget.user.id);
              final userEntry = provider.userLeaderboardEntry;
              
              if (userEntry != null || userRank > 0) {
                return UserRankWidget(
                  userRank: userRank,
                  userEntry: userEntry,
                  user: widget.user,
                );
              }
              
              return const SizedBox.shrink();
            },
          ),
          
          // Leaderboard list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(),
                _buildLeaderboardTab(),
                _buildLeaderboardTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return Consumer<GamificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.leaderboard.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadLeaderboard(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.leaderboard.length,
            itemBuilder: (context, index) {
              final entry = provider.leaderboard[index];
              final isCurrentUser = entry.userId == widget.user.id;
              
              return LeaderboardEntryWidget(
                entry: entry,
                position: index + 1,
                isCurrentUser: isCurrentUser,
                onTap: () => _showUserProfile(entry),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    final categories = [
      {'name': 'Anatomy', 'icon': Icons.science, 'color': Colors.blue},
      {'name': 'Physiology', 'icon': Icons.favorite, 'color': Colors.red},
      {'name': 'Pathology', 'icon': Icons.bug_report, 'color': Colors.orange},
      {'name': 'Pharmacology', 'icon': Icons.medication, 'color': Colors.green},
      {'name': 'Surgery', 'icon': Icons.medical_services, 'color': Colors.purple},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (category['color'] as Color).withOpacity(0.1),
              child: Icon(
                category['icon'] as IconData,
                color: category['color'] as Color,
              ),
            ),
            title: Text(
              category['name'] as String,
              style: UnifiedTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('View category rankings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                _selectedCategory = category['name'] as String;
              });
              _loadLeaderboard();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryLeaderboardScreen(
                    category: category['name'] as String,
                    user: widget.user,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Rankings Yet',
              style: UnifiedTheme.headingStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete quizzes and earn points to appear on the leaderboard!',
              style: UnifiedTheme.bodyStyle.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Start Learning'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Leaderboard',
              style: UnifiedTheme.headingStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            
            Text('By Role:', style: UnifiedTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['All', 'Doctors', 'Pharmacists', 'Farmers'].map((role) {
                return FilterChip(
                  label: Text(role),
                  selected: false, // Add state management for filters
                  onSelected: (selected) {
                    // Implement filter logic
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Clear filters
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply filters
                      Navigator.pop(context);
                      _loadLeaderboard();
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserProfile(LeaderboardEntryModel entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // User info
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _getRoleColor(entry.userRole).withOpacity(0.2),
                    child: Text(
                      entry.displayName.isNotEmpty 
                          ? entry.displayName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: _getRoleColor(entry.userRole),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    entry.displayName,
                    style: UnifiedTheme.headingStyle.copyWith(fontSize: 20),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRoleColor(entry.userRole).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getRoleDisplayName(entry.userRole),
                      style: TextStyle(
                        color: _getRoleColor(entry.userRole),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Rank', '#${entry.rank}', Icons.trophy),
                      _buildStatColumn('Points', '${entry.totalPoints}', Icons.star),
                      _buildStatColumn('Badges', '${entry.featuredBadges.length}', Icons.military_tech),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Featured badges
                  if (entry.featuredBadges.isNotEmpty) ...[
                    Text(
                      'Featured Badges',
                      style: UnifiedTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: entry.featuredBadges.map((badgeId) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.military_tech, color: Colors.amber),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: UnifiedTheme.primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: UnifiedTheme.headingStyle.copyWith(
            fontSize: 18,
            color: UnifiedTheme.primaryColor,
          ),
        ),
        Text(label, style: UnifiedTheme.captionStyle),
      ],
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
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'Veterinarian';
      case 'pharmacist':
        return 'Pharmacist';
      case 'farmer':
        return 'Farmer';
      default:
        return role.toUpperCase();
    }
  }
}

class CategoryLeaderboardScreen extends StatelessWidget {
  final String category;
  final UserModel user;

  const CategoryLeaderboardScreen({
    super.key,
    required this.category,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          '$category Rankings',
          style: UnifiedTheme.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: UnifiedTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<GamificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.leaderboard.isEmpty) {
            return const Center(
              child: Text('No rankings available for this category'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.leaderboard.length,
            itemBuilder: (context, index) {
              final entry = provider.leaderboard[index];
              final isCurrentUser = entry.userId == user.id;
              
              return LeaderboardEntryWidget(
                entry: entry,
                position: index + 1,
                isCurrentUser: isCurrentUser,
              );
            },
          );
        },
      ),
    );
  }
}