import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'lecture_list_screen.dart';

class LectureSubtopicsScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> topic;
  final String userRole;

  const LectureSubtopicsScreen({
    super.key,
    required this.subject,
    required this.topic,
    required this.userRole,
  });

  @override
  State<LectureSubtopicsScreen> createState() => _LectureSubtopicsScreenState();
}

class _LectureSubtopicsScreenState extends State<LectureSubtopicsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  // Sample subtopics data - in real app this would come from Firebase
  final List<Map<String, dynamic>> subtopics = [
    {
      'id': 1,
      'title': 'Cell Structure & Function',
      'description': 'Basic cellular components and their roles in animal biology',
      'lecturesCount': 8,
      'watchedCount': 0,
      'duration': '2.4 hrs',
      'isBookmarked': false,
      'difficulty': 'Beginner',
    },
    {
      'id': 2,
      'title': 'Tissue Organization',
      'description': 'How cells organize into tissues and tissue types',
      'lecturesCount': 6,
      'watchedCount': 0,
      'duration': '1.8 hrs',
      'isBookmarked': true,
      'difficulty': 'Intermediate',
    },
    {
      'id': 3,
      'title': 'Organ Development',
      'description': 'Formation and development of major organ systems',
      'lecturesCount': 10,
      'watchedCount': 0,
      'duration': '3.2 hrs',
      'isBookmarked': false,
      'difficulty': 'Advanced',
    },
    {
      'id': 4,
      'title': 'Comparative Structures',
      'description': 'Comparing structures across different animal species',
      'lecturesCount': 12,
      'watchedCount': 0,
      'duration': '3.8 hrs',
      'isBookmarked': false,
      'difficulty': 'Advanced',
    },
    {
      'id': 5,
      'title': 'Clinical Applications',
      'description': 'Practical applications in veterinary practice',
      'lecturesCount': 9,
      'watchedCount': 0,
      'duration': '2.7 hrs',
      'isBookmarked': false,
      'difficulty': 'Expert',
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
              
              // Search Section
              _buildSearchSection(context),
              
              // Subtopics List
              Expanded(
                child: _buildSubtopicsList(context),
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
              widget.topic['title'],
              style: UnifiedTheme.headerLarge.copyWith(
                color: UnifiedTheme.primaryText,
                fontSize: 24,
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
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      color: Colors.white,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Video Lectures / ${widget.subject['title']} / ${widget.topic['title']} / Subtopics',
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
                hintText: 'Search subtopics',
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
          
          // Results Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${subtopics.length} Subtopics Found',
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
                  'Progress: 0%',
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

  Widget _buildSubtopicsList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL),
      child: ListView.builder(
        itemCount: subtopics.length,
        itemBuilder: (context, index) {
          final subtopic = subtopics[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
            child: _buildSubtopicCard(context, subtopic),
          );
        },
      ),
    );
  }

  Widget _buildSubtopicCard(BuildContext context, Map<String, dynamic> subtopic) {
    return GestureDetector(
      onTap: () => _navigateToLectures(context, subtopic),
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
            // Subtopic Header
            Padding(
              padding: const EdgeInsets.all(UnifiedTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and bookmark
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtopic['title'],
                          style: UnifiedTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: UnifiedTheme.primaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: UnifiedTheme.spacingS),
                      
                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UnifiedTheme.spacingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(subtopic['difficulty']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subtopic['difficulty'],
                          style: UnifiedTheme.bodySmall.copyWith(
                            color: _getDifficultyColor(subtopic['difficulty']),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: UnifiedTheme.spacingS),
                      
                      GestureDetector(
                        onTap: () => _toggleBookmark(subtopic['id']),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            subtopic['isBookmarked'] ? Icons.bookmark : Icons.bookmark_border,
                            color: subtopic['isBookmarked'] ? UnifiedTheme.goldAccent : UnifiedTheme.tertiaryText,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UnifiedTheme.spacingM),
                  
                  // Description
                  Text(
                    subtopic['description'],
                    style: UnifiedTheme.bodyLarge.copyWith(
                      color: UnifiedTheme.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: UnifiedTheme.spacingM),
                  
                  // Stats row
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: UnifiedTheme.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${subtopic['lecturesCount']} lectures',
                        style: UnifiedTheme.bodySmall.copyWith(
                          color: UnifiedTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: UnifiedTheme.spacingM),
                      
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: UnifiedTheme.tertiaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subtopic['duration'],
                        style: UnifiedTheme.bodySmall.copyWith(
                          color: UnifiedTheme.tertiaryText,
                        ),
                      ),
                      const Spacer(),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: UnifiedTheme.lightGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${subtopic['watchedCount']}/${subtopic['lecturesCount']} watched',
                          style: UnifiedTheme.bodySmall.copyWith(
                            color: UnifiedTheme.lightGreen,
                            fontWeight: FontWeight.w600,
                          ),
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
                  _buildActionButton('Like', 0),
                  _buildActionButton('Notes', 0),
                  _buildActionButton('Share', 0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: UnifiedTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Watch',
                          style: UnifiedTheme.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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
            count.toString(),
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

  void _toggleBookmark(int subtopicId) {
    setState(() {
      final subtopic = subtopics.firstWhere((s) => s['id'] == subtopicId);
      subtopic['isBookmarked'] = !subtopic['isBookmarked'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subtopic ${subtopics.firstWhere((s) => s['id'] == subtopicId)['isBookmarked'] ? 'bookmarked' : 'bookmark removed'}!'),
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

  void _navigateToLectures(BuildContext context, Map<String, dynamic> subtopic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LectureListScreen(
          subject: widget.subject,
          topic: widget.topic,
          subtopic: subtopic,
          userRole: widget.userRole,
        ),
      ),
    );
  }
}