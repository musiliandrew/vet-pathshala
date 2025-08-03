import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'lecture_subtopics_screen.dart';
import 'lecture_list_screen.dart';

class LectureTopicsScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final String userRole;
  final bool showTopics;
  final bool showSubtopics;

  const LectureTopicsScreen({
    super.key,
    required this.subject,
    required this.userRole,
    this.showTopics = true,
    this.showSubtopics = false,
  });

  @override
  State<LectureTopicsScreen> createState() => _LectureTopicsScreenState();
}

class _LectureTopicsScreenState extends State<LectureTopicsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late bool _topicsEnabled;
  late bool _subtopicsEnabled;

  // Sample topics data - in real app this would come from Firebase
  final List<Map<String, dynamic>> topics = [
    {
      'id': '01',
      'title': 'Basic Anatomy',
      'description': 'Foundational concepts and structures in veterinary anatomy',
      'lecturesCount': 24,
      'watchedCount': 0,
      'duration': '4.2 hrs',
    },
    {
      'id': '02',
      'title': 'Organ Systems', 
      'description': 'Detailed study of various organ systems in animals',
      'lecturesCount': 32,
      'watchedCount': 0,
      'duration': '6.8 hrs',
    },
    {
      'id': '03',
      'title': 'Comparative Anatomy',
      'description': 'Comparing anatomical structures across different species',
      'lecturesCount': 18,
      'watchedCount': 0,
      'duration': '3.5 hrs',
    },
    {
      'id': '04',
      'title': 'Clinical Applications',
      'description': 'Practical applications of anatomy in clinical practice',
      'lecturesCount': 28,
      'watchedCount': 0,
      'duration': '5.2 hrs',
    },
    {
      'id': '05',
      'title': 'Advanced Structures',
      'description': 'Complex anatomical structures and relationships',
      'lecturesCount': 16,
      'watchedCount': 0,
      'duration': '2.8 hrs',
    },
  ];

  @override
  void initState() {
    super.initState();
    _topicsEnabled = widget.showTopics;
    _subtopicsEnabled = widget.showSubtopics;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Header
                    _buildHeader(context),
                    
                    // Breadcrumb
                    _buildBreadcrumb(context),
                    
                    // Content based on toggle states
                    Expanded(
                      child: _buildContent(context),
                    ),
                  ],
                ),
              ),
            );
          },
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: UnifiedTheme.primaryGreen, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: UnifiedTheme.primaryGreen,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: UnifiedTheme.spacingM),
          
          // Title
          Expanded(
            child: Text(
              widget.subject['title'],
              style: UnifiedTheme.headerMedium.copyWith(
                color: UnifiedTheme.primaryText,
              ),
            ),
          ),
          
          // Translate Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'TE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
      child: Column(
        children: [
          // Breadcrumb text
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Video Lectures / ${widget.subject['title']}',
              style: UnifiedTheme.bodyMedium.copyWith(
                color: UnifiedTheme.primaryGreen,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingM),
          
          // Toggle buttons
          Row(
            children: [
              _buildToggleButton('Topics', _topicsEnabled, () {
                setState(() {
                  _topicsEnabled = !_topicsEnabled;
                  if (!_topicsEnabled) _subtopicsEnabled = false;
                });
              }),
              const SizedBox(width: UnifiedTheme.spacingM),
              _buildToggleButton('Subtopics', _subtopicsEnabled, () {
                setState(() {
                  _subtopicsEnabled = !_subtopicsEnabled;
                  if (_subtopicsEnabled) _topicsEnabled = true;
                });
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!_topicsEnabled) {
      // Show all lectures directly
      return _buildAllLectures(context);
    } else if (_subtopicsEnabled) {
      // Show subtopics after selecting a topic
      return _buildSubtopicsList(context);
    } else {
      // Show topics list
      return _buildTopicsList(context);
    }
  }

  Widget _buildTopicsList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      child: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
            child: _buildTopicCard(context, topic),
          );
        },
      ),
    );
  }

  Widget _buildAllLectures(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingL),
            decoration: BoxDecoration(
              color: UnifiedTheme.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: UnifiedTheme.blueAccent.withOpacity(0.3)),
            ),
            child: Text(
              'All Lectures - ${widget.subject['title']}',
              style: UnifiedTheme.headerSmall.copyWith(
                color: UnifiedTheme.blueAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToLectures(context, null),
              child: Container(
                padding: const EdgeInsets.all(UnifiedTheme.spacingL),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.video_library,
                      size: 48,
                      color: UnifiedTheme.primaryGreen,
                    ),
                    const SizedBox(height: UnifiedTheme.spacingM),
                    Text(
                      'Start Watching',
                      style: UnifiedTheme.headerMedium.copyWith(
                        color: UnifiedTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: UnifiedTheme.spacingS),
                    Text(
                      '${widget.subject['lecturesCount']} Lectures Available',
                      style: UnifiedTheme.bodyLarge.copyWith(
                        color: UnifiedTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtopicsList(BuildContext context) {
    // Sample subtopics for demonstration
    final subtopics = [
      'Basic Cell Structure',
      'Tissue Types',
      'Bone Formation',
      'Muscle Development',
    ];

    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingL),
            decoration: BoxDecoration(
              color: UnifiedTheme.goldAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: UnifiedTheme.goldAccent.withOpacity(0.3)),
            ),
            child: Text(
              'Subtopics - Basic Anatomy',
              style: UnifiedTheme.headerSmall.copyWith(
                color: UnifiedTheme.goldAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: subtopics.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _navigateToLectures(context, {'title': subtopics[index]}),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
                    padding: const EdgeInsets.all(UnifiedTheme.spacingL),
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
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: UnifiedTheme.goldAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: UnifiedTheme.spacingM),
                        Expanded(
                          child: Text(
                            subtopics[index],
                            style: UnifiedTheme.bodyLarge.copyWith(
                              color: UnifiedTheme.primaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.play_circle_outline,
                          size: 24,
                          color: UnifiedTheme.primaryGreen,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, Map<String, dynamic> topic) {
    return GestureDetector(
      onTap: () => _navigateToSubtopics(context, topic),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(UnifiedTheme.radiusXL),
          border: Border.all(color: UnifiedTheme.borderColor),
          boxShadow: UnifiedTheme.cardShadow,
        ),
        child: Column(
          children: [
            // Topic card content
            Padding(
              padding: const EdgeInsets.all(UnifiedTheme.spacingL),
              child: Row(
                children: [
                  // Number and content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: UnifiedTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  topic['id'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: UnifiedTheme.spacingM),
                            Expanded(
                              child: Text(
                                topic['title'],
                                style: UnifiedTheme.headerSmall.copyWith(
                                  color: UnifiedTheme.primaryText,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UnifiedTheme.spacingS),
                        Text(
                          topic['description'],
                          style: UnifiedTheme.bodyMedium.copyWith(
                            color: UnifiedTheme.secondaryText,
                            height: 1.4,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [UnifiedTheme.blueAccent, UnifiedTheme.blueAccent.withOpacity(0.8)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats footer
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UnifiedTheme.spacingL,
                vertical: UnifiedTheme.spacingM,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: UnifiedTheme.borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${topic['lecturesCount']} Lectures',
                        style: UnifiedTheme.bodySmall.copyWith(
                          color: UnifiedTheme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Duration: ${topic['duration']}',
                        style: UnifiedTheme.bodySmall.copyWith(
                          color: UnifiedTheme.tertiaryText,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: UnifiedTheme.lightGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${topic['watchedCount']}/${topic['lecturesCount']} Watched',
                      style: UnifiedTheme.bodySmall.copyWith(
                        color: UnifiedTheme.lightGreen,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildToggleButton(String text, bool isEnabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isEnabled ? UnifiedTheme.primaryGreen.withOpacity(0.1) : UnifiedTheme.lightBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled ? UnifiedTheme.primaryGreen : UnifiedTheme.borderColor,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isEnabled ? UnifiedTheme.primaryGreen : UnifiedTheme.tertiaryText,
            fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _navigateToSubtopics(BuildContext context, Map<String, dynamic> topic) {
    if (_subtopicsEnabled) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LectureSubtopicsScreen(
            subject: widget.subject,
            topic: topic,
            userRole: widget.userRole,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LectureListScreen(
            subject: widget.subject,
            topic: topic,
            userRole: widget.userRole,
          ),
        ),
      );
    }
  }

  void _navigateToLectures(BuildContext context, Map<String, dynamic>? subtopic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LectureListScreen(
          subject: widget.subject,
          topic: subtopic ?? {'title': 'All Lectures'},
          userRole: widget.userRole,
        ),
      ),
    );
  }
}