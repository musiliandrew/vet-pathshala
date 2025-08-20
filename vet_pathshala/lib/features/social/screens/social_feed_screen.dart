import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/social_provider.dart';
import '../widgets/activity_card_widget.dart';
import '../widgets/create_post_widget.dart';
import 'study_groups_screen.dart';
import 'user_search_screen.dart';
import 'user_profile_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  final UserModel user;

  const SocialFeedScreen({
    super.key,
    required this.user,
  });

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final provider = context.read<SocialProvider>();
    provider.loadFeedActivities(widget.user.id, refresh: true);
    provider.loadUserSocialProfile(widget.user.id);
    provider.loadUserStudyGroups(widget.user.id);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore) {
      _loadMoreActivities();
    }
  }

  void _loadMoreActivities() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final provider = context.read<SocialProvider>();
      await provider.loadFeedActivities(widget.user.id);
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Social Feed',
          style: UnifiedTheme.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: UnifiedTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserSearchScreen(user: widget.user),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudyGroupsScreen(user: widget.user),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(user: widget.user),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialData();
        },
        child: Consumer<SocialProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.feedActivities.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.feedActivities.isEmpty) {
              return _buildEmptyState();
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Quick actions header
                SliverToBoxAdapter(
                  child: _buildQuickActions(),
                ),
                
                // Activities feed
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < provider.feedActivities.length) {
                        final activity = provider.feedActivities[index];
                        return ActivityCardWidget(
                          activity: activity,
                          currentUser: widget.user,
                        );
                      } else if (_isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    childCount: provider.feedActivities.length + 
                        (_isLoadingMore ? 1 : 0),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: UnifiedTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: UnifiedTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.group_add,
                  label: 'Join Groups',
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudyGroupsScreen(user: widget.user),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.person_add,
                  label: 'Find Users',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSearchScreen(user: widget.user),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.share,
                  label: 'Share Progress',
                  color: Colors.orange,
                  onTap: _showShareProgressDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Welcome to Vet-Pathshala Social!',
              style: UnifiedTheme.headingStyle.copyWith(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Connect with fellow veterinary professionals, join study groups, and share your learning journey.',
              style: UnifiedTheme.bodyStyle.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudyGroupsScreen(user: widget.user),
                      ),
                    ),
                    icon: const Icon(Icons.group),
                    label: const Text('Explore Study Groups'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UnifiedTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserSearchScreen(user: widget.user),
                      ),
                    ),
                    icon: const Icon(Icons.search),
                    label: const Text('Find People to Follow'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostWidget(
        user: widget.user,
        onPostCreated: () {
          _loadInitialData();
        },
      ),
    );
  }

  void _showShareProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Your Progress'),
        content: const Text(
          'Complete quizzes, earn achievements, and maintain study streaks to automatically share your progress with your followers!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}