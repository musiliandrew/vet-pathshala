import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/services/enhanced_admin_service.dart';
import '../../../core/theme/unified_theme.dart';
import '../providers/admin_auth_provider.dart';
import 'video_upload_screen.dart';
import 'question_creation_screen.dart';
import 'ebook_upload_screen.dart';
import 'content_search_screen.dart';
import 'data_seeder_screen.dart';
import 'firebase_seeder_screen.dart';

class EnhancedAdminDashboardScreen extends StatefulWidget {
  const EnhancedAdminDashboardScreen({super.key});

  @override
  State<EnhancedAdminDashboardScreen> createState() => _EnhancedAdminDashboardScreenState();
}

class _EnhancedAdminDashboardScreenState extends State<EnhancedAdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late EnhancedAdminService _adminService;
  late TabController _tabController;
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _adminService = EnhancedAdminService();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    try {
      final analytics = await _adminService.getComprehensiveAnalytics();
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Set complete default analytics when Firebase is unavailable
        _analytics = {
          'users': {
            'total': 0, 
            'active': 0, 
            'new': 0,
            'roles': {
              'veterinarian': 0,
              'pharmacist': 0,
              'farmer': 0,
            }
          },
          'content': {
            'questions': 0, 
            'notes': 0, 
            'videos': 0,
            'ebooks': 0
          },
          'engagement': {
            'sessions': 0, 
            'duration': 0,
            'completionRate': 0
          },
          'coins': {'total': 0, 'spent': 0, 'earned': 0},
        };
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin dashboard loaded in offline mode'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      print('⚠️ Analytics unavailable, using default data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: UnifiedTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.video_library), text: 'Videos'),
            Tab(icon: Icon(Icons.quiz), text: 'Questions'),
            Tab(icon: Icon(Icons.book), text: 'E-books'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Fix Loading Issues',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FirebaseSeederScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAnalytics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddContentDialog(),
          ),
          const SizedBox(width: 8),
          // Logout button
          PopupMenuButton<String>(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Menu',
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout'),
                  subtitle: Text('Sign out of admin panel'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildVideosTab(),
                _buildQuestionsTab(),
                _buildEbooksTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (_analytics == null) {
      return const Center(child: Text('No analytics data available'));
    }

    final users = _analytics!['users'] as Map<String, dynamic>;
    final content = _analytics!['content'] as Map<String, dynamic>;
    final engagement = _analytics!['engagement'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Text(
            'Platform Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: UnifiedTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // User Stats
          _buildStatsSection('User Statistics', [
            _buildStatCard(
              'Total Users',
              '${users['total']}',
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Active Users',
              '${users['active']}',
              Icons.people_outline,
              Colors.green,
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Content Stats
          _buildStatsSection('Content Statistics', [
            _buildStatCard(
              'Videos',
              '${content['videos']}',
              Icons.video_library,
              Colors.orange,
            ),
            _buildStatCard(
              'Questions',
              '${content['questions']}',
              Icons.quiz,
              Colors.purple,
            ),
            _buildStatCard(
              'E-books',
              '${content['ebooks']}',
              Icons.book,
              Colors.red,
            ),
            _buildStatCard(
              'Completion Rate',
              '${engagement['completionRate']}%',
              Icons.trending_up,
              Colors.teal,
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActionsSection(),
          
          const SizedBox(height: 24),
          
          // User Role Distribution
          _buildUserRoleChart((users['roles'] as Map<String, dynamic>?)?.cast<String, int>() ?? {}),
        ],
      ),
    );
  }

  Widget _buildStatsSection(String title, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: cards.map((card) => Expanded(child: card)).toList(),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(right: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
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
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FirebaseSeederScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          color: Colors.green.shade600,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fix Loading Issues',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Seed Firebase Data',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: _showAddContentDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: UnifiedTheme.primaryColor,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add Content',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Videos, Questions, E-books',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: _showSearchDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.blue.shade600,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Search Content',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find any content',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserRoleChart(Map<String, int> roleData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Role Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: roleData.entries.map((entry) {
                final total = roleData.values.fold(0, (sum, count) => sum + count);
                final percentage = total > 0 ? (entry.value / total * 100) : 0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key.toLowerCase().replaceFirst(entry.key[0], entry.key[0].toUpperCase()),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            entry.key == 'doctor' ? Colors.blue :
                            entry.key == 'pharmacist' ? Colors.green :
                            Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideosTab() {
    return StreamBuilder(
      stream: _adminService.getVideosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading videos: ${snapshot.error}'),
          );
        }
        
        final videos = snapshot.data ?? [];
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return _buildVideoCard(video);
          },
        );
      },
    );
  }

  Widget _buildQuestionsTab() {
    return StreamBuilder(
      stream: _adminService.getQuestionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading questions: ${snapshot.error}'),
          );
        }
        
        final questions = snapshot.data ?? [];
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return _buildQuestionCard(question);
          },
        );
      },
    );
  }

  Widget _buildEbooksTab() {
    return StreamBuilder(
      stream: _adminService.getEbooksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading ebooks: ${snapshot.error}'),
          );
        }
        
        final ebooks = snapshot.data ?? [];
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ebooks.length,
          itemBuilder: (context, index) {
            final ebook = ebooks[index];
            return _buildEbookCard(ebook);
          },
        );
      },
    );
  }

  Widget _buildStatsSection(String title, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: cards,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2,
          children: [
            _buildActionCard('Add Video', Icons.video_call, () => _showAddVideoDialog()),
            _buildActionCard('Add Question', Icons.quiz, () => _showAddQuestionDialog()),
            _buildActionCard('Upload E-book', Icons.book, () => _showAddEbookDialog()),
            _buildActionCard('Search Content', Icons.search, () => _showSearchDialog()),
            _buildActionCard('Load Sample Data', Icons.upload_file, () => _showDataSeeder()),
            _buildActionCard('Refresh Analytics', Icons.refresh, () => _refreshAnalytics()),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 24, color: UnifiedTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserRoleChart(Map<String, int> roles) {
    // Handle empty or null roles data
    if (roles.isEmpty) {
      roles = {
        'veterinarian': 0,
        'pharmacist': 0,
        'farmer': 0,
      };
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Distribution by Role',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...roles.entries.map((entry) => _buildRoleRow(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleRow(String role, int count) {
    final total = _analytics!['users']['total'] as int;
    final percentage = total > 0 ? (count / total * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              role.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                UnifiedTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count ($percentage%)'),
        ],
      ),
    );
  }

  Widget _buildVideoCard(dynamic video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: video.thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  video.thumbnailUrl!,
                  width: 60,
                  height: 45,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 45,
                    color: Colors.grey[300],
                    child: const Icon(Icons.video_library),
                  ),
                ),
              )
            : Container(
                width: 60,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.video_library),
              ),
        title: Text(
          video.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${video.instructor} • ${video.category}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(video.isActive ? Icons.visibility_off : Icons.visibility),
                  const SizedBox(width: 8),
                  Text(video.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'feature',
              child: Row(
                children: [
                  Icon(video.featured ? Icons.star_border : Icons.star),
                  const SizedBox(width: 8),
                  Text(video.featured ? 'Unfeature' : 'Feature'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleVideoAction(video, value),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(dynamic question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: UnifiedTheme.primaryColor,
          child: const Icon(Icons.quiz, color: Colors.white),
        ),
        title: Text(
          question.question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${question.subject} • ${question.topic} • ${question.difficulty}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(question.isActive ? Icons.visibility_off : Icons.visibility),
                  const SizedBox(width: 8),
                  Text(question.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleQuestionAction(question, value),
        ),
      ),
    );
  }

  Widget _buildEbookCard(dynamic ebook) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ebook.coverImageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  ebook.coverImageUrl!,
                  width: 45,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 45,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book),
                  ),
                ),
              )
            : Container(
                width: 45,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book),
              ),
        title: Text(
          ebook.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${ebook.author} • ${ebook.category}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(ebook.isActive ? Icons.visibility_off : Icons.visibility),
                  const SizedBox(width: 8),
                  Text(ebook.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'feature',
              child: Row(
                children: [
                  Icon(ebook.featured ? Icons.star_border : Icons.star),
                  const SizedBox(width: 8),
                  Text(ebook.featured ? 'Unfeature' : 'Feature'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleEbookAction(ebook, value),
        ),
      ),
    );
  }

  // Action handlers
  void _handleVideoAction(dynamic video, String action) async {
    try {
      switch (action) {
        case 'toggle':
          await _adminService.toggleContentStatus('videos', video.id, !video.isActive);
          break;
        case 'feature':
          await _adminService.featureContent('videos', video.id, !video.featured);
          break;
        case 'edit':
          // TODO: Navigate to edit screen
          break;
        case 'delete':
          await _showDeleteConfirmation(() => _adminService.deleteContent('videos', video.id));
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _handleQuestionAction(dynamic question, String action) async {
    try {
      switch (action) {
        case 'toggle':
          await _adminService.toggleContentStatus('questions', question.id, !question.isActive);
          break;
        case 'edit':
          // TODO: Navigate to edit screen
          break;
        case 'delete':
          await _showDeleteConfirmation(() => _adminService.deleteContent('questions', question.id));
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _handleEbookAction(dynamic ebook, String action) async {
    try {
      switch (action) {
        case 'toggle':
          await _adminService.toggleContentStatus('ebooks', ebook.id, !ebook.isActive);
          break;
        case 'feature':
          await _adminService.featureContent('ebooks', ebook.id, !ebook.featured);
          break;
        case 'edit':
          // TODO: Navigate to edit screen
          break;
        case 'delete':
          await _showDeleteConfirmation(() => _adminService.deleteContent('ebooks', ebook.id));
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(VoidCallback onConfirm) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content'),
        content: const Text('Are you sure you want to delete this content? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      onConfirm();
    }
  }

  // Dialog methods - placeholders for now
  void _showAddContentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Content'),
        content: const Text('Choose content type to add:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddVideoDialog();
            },
            child: const Text('Video'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddQuestionDialog();
            },
            child: const Text('Question'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddEbookDialog();
            },
            child: const Text('E-book'),
          ),
        ],
      ),
    );
  }

  void _showAddVideoDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VideoUploadScreen(),
      ),
    );
  }

  void _showAddQuestionDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QuestionCreationScreen(),
      ),
    );
  }

  void _showAddEbookDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EbookUploadScreen(),
      ),
    );
  }

  void _showSearchDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ContentSearchScreen(),
      ),
    );
  }

  void _showDataSeeder() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DataSeederScreen(),
      ),
    );
  }

  void _refreshAnalytics() {
    setState(() => _isLoading = true);
    _loadAnalytics();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout from the admin panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logout admin
              context.read<AdminAuthProvider>().logoutAdmin();
              
              // Close dialog and navigate to main app
              Navigator.of(context).pop(); // Close dialog
              context.go('/'); // Go to main app
              
              // Show logout message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully logged out from admin panel'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}