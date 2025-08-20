import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/video_models.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/video_lecture_service.dart';
import 'video_lecture_screen.dart';

class VideoLecturesListScreen extends StatefulWidget {
  final UserModel user;
  final VideoCategory? initialCategory;

  const VideoLecturesListScreen({
    super.key,
    required this.user,
    this.initialCategory,
  });

  @override
  State<VideoLecturesListScreen> createState() => _VideoLecturesListScreenState();
}

class _VideoLecturesListScreenState extends State<VideoLecturesListScreen>
    with SingleTickerProviderStateMixin {
  
  final VideoLectureService _videoService = VideoLectureService();
  late TabController _tabController;
  
  List<VideoLectureModel> _videos = [];
  List<VideoLectureModel> _featuredVideos = [];
  bool _isLoading = false;
  String _searchQuery = '';
  VideoCategory? _selectedCategory;
  VideoAccessLevel? _selectedAccessLevel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedCategory = widget.initialCategory;
    _loadVideos();
    _loadFeaturedVideos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final videos = await _videoService.getVideos(
        category: _selectedCategory,
        accessLevel: _selectedAccessLevel,
        targetRole: widget.user.role,
      );

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading videos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFeaturedVideos() async {
    try {
      final featuredVideos = await _videoService.getFeaturedVideos(
        widget.user.role,
        limit: 10,
      );

      setState(() {
        _featuredVideos = featuredVideos;
      });
    } catch (e) {
      print('Error loading featured videos: $e');
    }
  }

  Future<void> _searchVideos(String query) async {
    if (query.isEmpty) {
      _loadVideos();
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final searchResults = await _videoService.searchVideos(
        query: query,
        targetRole: widget.user.role,
        category: _selectedCategory,
      );

      setState(() {
        _videos = searchResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterByCategory(VideoCategory? category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = '';
    });
    _loadVideos();
  }

  void _filterByAccessLevel(VideoAccessLevel? accessLevel) {
    setState(() {
      _selectedAccessLevel = accessLevel;
    });
    _loadVideos();
  }

  void _openVideo(VideoLectureModel video) async {
    // Check if user has access to this video
    final hasAccess = await _videoService.hasAccessToVideo(widget.user.id, video.id);
    
    if (!hasAccess && video.accessLevel != VideoAccessLevel.free) {
      _showPremiumDialog(video);
      return;
    }

    // Get user progress
    final userProgress = await _videoService.getUserProgress(widget.user.id, video.id);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoLectureScreen(
            video: video,
            user: widget.user,
            userProgress: userProgress,
          ),
        ),
      );
    }
  }

  void _showPremiumDialog(VideoLectureModel video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock,
              size: 48,
              color: Colors.amber.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'This video requires ${video.coinCost} coins to unlock.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              video.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
              // Navigate to coin purchase screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
            ),
            child: Text('Get ${video.coinCost} Coins'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Video Lectures'),
        backgroundColor: UnifiedTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All Videos'),
            Tab(text: 'Featured'),
            Tab(text: 'Continue'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filters
          _buildSearchAndFilters(),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllVideosTab(),
                _buildFeaturedVideosTab(),
                _buildContinueWatchingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search videos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                        _loadVideos();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: UnifiedTheme.primaryColor),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                _loadVideos();
              }
            },
            onSubmitted: _searchVideos,
          ),
          
          const SizedBox(height: 12),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Category filter
                _buildFilterChip(
                  'All Categories',
                  _selectedCategory == null,
                  () => _filterByCategory(null),
                ),
                
                const SizedBox(width: 8),
                
                ...VideoCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      category.name.replaceAll('_', ' ').toUpperCase(),
                      _selectedCategory == category,
                      () => _filterByCategory(category),
                    ),
                  );
                }),
                
                const SizedBox(width: 16),
                
                // Access level filter
                _buildFilterChip(
                  'Free Only',
                  _selectedAccessLevel == VideoAccessLevel.free,
                  () => _filterByAccessLevel(
                    _selectedAccessLevel == VideoAccessLevel.free 
                        ? null 
                        : VideoAccessLevel.free,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? UnifiedTheme.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? UnifiedTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildAllVideosTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_videos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.video_library_outlined,
        title: _searchQuery.isNotEmpty ? 'No videos found' : 'No videos available',
        subtitle: _searchQuery.isNotEmpty 
            ? 'Try adjusting your search terms or filters'
            : 'Check back later for new content',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVideos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return _buildVideoCard(video);
        },
      ),
    );
  }

  Widget _buildFeaturedVideosTab() {
    if (_featuredVideos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.star_outline,
        title: 'No featured videos',
        subtitle: 'Featured content will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _featuredVideos.length,
      itemBuilder: (context, index) {
        final video = _featuredVideos[index];
        return _buildFeaturedVideoCard(video);
      },
    );
  }

  Widget _buildContinueWatchingTab() {
    // This would load user's in-progress videos
    return _buildEmptyState(
      icon: Icons.play_circle_outline,
      title: 'Continue watching',
      subtitle: 'Videos you started will appear here',
    );
  }

  Widget _buildVideoCard(VideoLectureModel video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openVideo(video),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade300,
                          Colors.purple.shade300,
                          Colors.indigo.shade300,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle,
                          size: 64,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          video.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Quality badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video.qualityUrls.keys.isNotEmpty 
                          ? video.qualityUrls.keys.first.displayName
                          : 'SD',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Access level badge
                if (video.accessLevel != VideoAccessLevel.free)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: video.accessLevel == VideoAccessLevel.premium
                            ? Colors.amber.shade600
                            : Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            video.accessLevel == VideoAccessLevel.premium 
                                ? 'Premium' 
                                : '${video.coinCost} Coins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Video info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Instructor and stats
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: UnifiedTheme.primaryColor,
                        child: Text(
                          video.instructor.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Expanded(
                        child: Text(
                          video.instructor,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Rating
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            video.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Views
                      Row(
                        children: [
                          Icon(Icons.visibility, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 2),
                          Text(
                            '${video.viewCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description preview
                  if (video.description.isNotEmpty)
                    Text(
                      video.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Tags
                  if (video.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: video.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedVideoCard(VideoLectureModel video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade200, width: 2),
      ),
      child: InkWell(
        onTap: () => _openVideo(video),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Featured badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'FEATURED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Regular video card content (reuse the same structure)
            _buildVideoCardContent(video),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCardContent(VideoLectureModel video) {
    // This is a simplified version of the video card content
    // In a real implementation, you'd extract this into a separate method
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.purple.shade300],
                ),
              ),
              child: const Icon(
                Icons.play_circle,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Video info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  video.instructor,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Text(
                      video.formattedDuration,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      video.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}