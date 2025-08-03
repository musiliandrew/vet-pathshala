import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'lecture_watch_screen.dart';

class LectureListScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> topic;
  final Map<String, dynamic>? subtopic;
  final String userRole;

  const LectureListScreen({
    super.key,
    required this.subject,
    required this.topic,
    this.subtopic,
    required this.userRole,
  });

  @override
  State<LectureListScreen> createState() => _LectureListScreenState();
}

class _LectureListScreenState extends State<LectureListScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _showWatched = false;
  bool _showBookmarked = false;

  // Sample lectures data - in real app this would come from Firebase
  final List<Map<String, dynamic>> lectures = [
    {
      'id': 1,
      'title': 'Introduction to Veterinary Anatomy',
      'description': 'Basic concepts and overview of animal anatomy fundamentals',
      'instructor': 'Dr. Sarah Johnson',
      'duration': '15:30',
      'watchedDuration': '0:00',
      'isWatched': false,
      'isBookmarked': true,
      'views': 1245,
      'likes': 89,
      'difficulty': 'Beginner',
      'uploadDate': '2 days ago',
      'thumbnailUrl': '',
    },
    {
      'id': 2,
      'title': 'Cell Structure and Function',
      'description': 'Detailed exploration of cellular components in animal tissues',
      'instructor': 'Prof. Michael Chen',
      'duration': '22:45',
      'watchedDuration': '15:20',
      'isWatched': false,
      'isBookmarked': false,
      'views': 987,
      'likes': 67,
      'difficulty': 'Intermediate',
      'uploadDate': '5 days ago',
      'thumbnailUrl': '',
    },
    {
      'id': 3,
      'title': 'Tissue Organization Patterns',
      'description': 'How cells organize into functional tissue types',
      'instructor': 'Dr. Emily Rodriguez',
      'duration': '18:12',
      'watchedDuration': '18:12',
      'isWatched': true,
      'isBookmarked': false,
      'views': 2156,
      'likes': 145,
      'difficulty': 'Intermediate',
      'uploadDate': '1 week ago',
      'thumbnailUrl': '',
    },
    {
      'id': 4,
      'title': 'Advanced Organ Development',
      'description': 'Complex developmental processes in organ formation',
      'instructor': 'Dr. Robert Kim',
      'duration': '28:30',
      'watchedDuration': '0:00',
      'isWatched': false,
      'isBookmarked': true,
      'views': 756,
      'likes': 52,
      'difficulty': 'Advanced',
      'uploadDate': '3 days ago',
      'thumbnailUrl': '',
    },
    {
      'id': 5,
      'title': 'Clinical Case Studies',
      'description': 'Real-world applications of anatomical knowledge',
      'instructor': 'Dr. Lisa Thompson',
      'duration': '35:45',
      'watchedDuration': '12:30',
      'isWatched': false,
      'isBookmarked': false,
      'views': 1834,
      'likes': 123,
      'difficulty': 'Expert',
      'uploadDate': '4 days ago',
      'thumbnailUrl': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _animationController,
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Breadcrumb
              _buildBreadcrumb(context),
              
              // Search and Filters
              _buildSearchSection(context),
              
              // Lectures List
              Expanded(
                child: _buildLecturesList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      color: Colors.white,
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: UnifiedTheme.primaryGreen, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: UnifiedTheme.primaryGreen,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: UnifiedTheme.spacingM),
          
          // Title
          Expanded(
            child: Text(
              widget.subtopic?['title'] ?? widget.topic['title'],
              style: UnifiedTheme.headerLarge.copyWith(
                color: UnifiedTheme.primaryText,
                fontSize: 20,
              ),
            ),
          ),
          
          // Translate Button
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'TE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    String breadcrumb = 'Video Lectures / ${widget.subject['title']} / ${widget.topic['title']}';
    if (widget.subtopic != null) {
      breadcrumb += ' / ${widget.subtopic!['title']}';
    }
    
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      color: Colors.white,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          breadcrumb,
          style: UnifiedTheme.bodyLarge.copyWith(
            color: UnifiedTheme.primaryText,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      color: Colors.white,
      child: Column(
        children: [
          // Search Input
          Container(
            decoration: BoxDecoration(
              color: UnifiedTheme.lightBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: UnifiedTheme.borderColor, width: 2),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search lectures',
                hintStyle: UnifiedTheme.bodyMedium.copyWith(
                  color: UnifiedTheme.tertiaryText,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(UnifiedTheme.spacingM),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: UnifiedTheme.primaryText,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: UnifiedTheme.spacingL,
                  vertical: UnifiedTheme.spacingM,
                ),
              ),
              style: UnifiedTheme.bodyLarge.copyWith(
                color: UnifiedTheme.primaryText,
              ),
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Filter Section
          Row(
            children: [
              // Filter Checkboxes
              Expanded(
                child: Row(
                  children: [
                    _buildFilterCheckbox('Watched', _showWatched, (value) {
                      setState(() {
                        _showWatched = value;
                      });
                    }),
                    const SizedBox(width: UnifiedTheme.spacingXL),
                    _buildFilterCheckbox('Bookmarked', _showBookmarked, (value) {
                      setState(() {
                        _showBookmarked = value;
                      });
                    }),
                  ],
                ),
              ),
              
              // Filter Button
              Container(
                padding: const EdgeInsets.all(UnifiedTheme.spacingM),
                decoration: BoxDecoration(
                  color: UnifiedTheme.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Results Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${lectures.length} Lectures Found',
                style: UnifiedTheme.headerSmall.copyWith(color: UnifiedTheme.primaryText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UnifiedTheme.spacingL,
                  vertical: UnifiedTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: UnifiedTheme.lightBorder,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Progress: 20%',
                  style: UnifiedTheme.bodyMedium.copyWith(
                    color: UnifiedTheme.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCheckbox(String label, bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? UnifiedTheme.primaryGreen : Colors.transparent,
              border: Border.all(color: UnifiedTheme.primaryGreen, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: UnifiedTheme.spacingS),
          Text(
            label,
            style: UnifiedTheme.bodyMedium.copyWith(
              color: UnifiedTheme.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLecturesList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL),
      child: ListView.builder(
        itemCount: lectures.length,
        itemBuilder: (context, index) {
          final lecture = lectures[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
            child: _buildLectureCard(context, lecture),
          );
        },
      ),
    );
  }

  Widget _buildLectureCard(BuildContext context, Map<String, dynamic> lecture) {
    final watchProgress = _calculateWatchProgress(lecture['watchedDuration'], lecture['duration']);
    
    return GestureDetector(
      onTap: () => _navigateToLecture(context, lecture),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
          border: Border.all(color: UnifiedTheme.borderColor),
          boxShadow: UnifiedTheme.cardShadow,
        ),
        child: Column(
          children: [
            // Lecture Header with thumbnail
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: UnifiedTheme.lightBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(UnifiedTheme.radiusL)),
                gradient: LinearGradient(
                  colors: [UnifiedTheme.primaryGreen.withOpacity(0.1), UnifiedTheme.blueAccent.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Video thumbnail placeholder
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 48,
                      color: UnifiedTheme.primaryGreen,
                    ),
                  ),
                  
                  // Duration badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lecture['duration'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  // Watch progress indicator
                  if (watchProgress > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(UnifiedTheme.radiusL)),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: watchProgress,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: UnifiedTheme.primaryGreen,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(UnifiedTheme.radiusL)),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Lecture Content
            Padding(
              padding: const EdgeInsets.all(UnifiedTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lecture['title'],
                          style: UnifiedTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: UnifiedTheme.primaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: UnifiedTheme.spacingS),
                      
                      if (lecture['isWatched'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UnifiedTheme.spacingS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: UnifiedTheme.lightGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: UnifiedTheme.lightGreen,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Watched',
                                style: UnifiedTheme.bodySmall.copyWith(
                                  color: UnifiedTheme.lightGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(width: UnifiedTheme.spacingS),
                      GestureDetector(
                        onTap: () => _toggleBookmark(lecture['id']),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            lecture['isBookmarked'] ? Icons.bookmark : Icons.bookmark_border,
                            color: lecture['isBookmarked'] ? UnifiedTheme.goldAccent : UnifiedTheme.tertiaryText,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UnifiedTheme.spacingS),
                  
                  // Description
                  Text(
                    lecture['description'],
                    style: UnifiedTheme.bodyMedium.copyWith(
                      color: UnifiedTheme.secondaryText,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: UnifiedTheme.spacingM),
                  
                  // Instructor and stats
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: UnifiedTheme.tertiaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lecture['instructor'],
                        style: UnifiedTheme.bodySmall.copyWith(
                          color: UnifiedTheme.tertiaryText,
                        ),
                      ),
                      const SizedBox(width: UnifiedTheme.spacingM),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(lecture['difficulty']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lecture['difficulty'],
                          style: UnifiedTheme.bodySmall.copyWith(
                            color: _getDifficultyColor(lecture['difficulty']),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      
                      Text(
                        lecture['uploadDate'],
                        style: UnifiedTheme.bodySmall.copyWith(
                          color: UnifiedTheme.tertiaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UnifiedTheme.spacingM,
                vertical: UnifiedTheme.spacingM,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: UnifiedTheme.borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton('Like', lecture['likes']),
                  _buildActionButton('View', lecture['views']),
                  _buildActionButton('Notes', 0),
                  _buildActionButton('Share', 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, int count) {
    return GestureDetector(
      onTap: () => _handleAction(label),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: UnifiedTheme.bodySmall.copyWith(
              color: UnifiedTheme.tertiaryText,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count > 999 ? '${(count / 1000).toStringAsFixed(1)}k' : count.toString(),
            style: UnifiedTheme.bodySmall.copyWith(
              color: UnifiedTheme.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return UnifiedTheme.lightGreen;
      case 'intermediate':
        return UnifiedTheme.goldAccent;
      case 'advanced':
        return Colors.orange;
      case 'expert':
        return Colors.red;
      default:
        return UnifiedTheme.tertiaryText;
    }
  }

  double _calculateWatchProgress(String watched, String total) {
    final watchedParts = watched.split(':');
    final totalParts = total.split(':');
    
    final watchedSeconds = int.parse(watchedParts[0]) * 60 + int.parse(watchedParts[1]);
    final totalSeconds = int.parse(totalParts[0]) * 60 + int.parse(totalParts[1]);
    
    return totalSeconds > 0 ? watchedSeconds / totalSeconds : 0.0;
  }

  void _toggleBookmark(int lectureId) {
    setState(() {
      final lecture = lectures.firstWhere((l) => l['id'] == lectureId);
      lecture['isBookmarked'] = !lecture['isBookmarked'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lecture ${lectures.firstWhere((l) => l['id'] == lectureId)['isBookmarked'] ? 'bookmarked' : 'bookmark removed'}!'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action action performed!'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _navigateToLecture(BuildContext context, Map<String, dynamic> lecture) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LectureWatchScreen(
          lecture: lecture,
          subject: widget.subject,
          topic: widget.topic,
          subtopic: widget.subtopic,
          userRole: widget.userRole,
        ),
      ),
    );
  }
}