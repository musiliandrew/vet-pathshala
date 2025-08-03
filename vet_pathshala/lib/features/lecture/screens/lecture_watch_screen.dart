import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class LectureWatchScreen extends StatefulWidget {
  final Map<String, dynamic> lecture;
  final Map<String, dynamic> subject;
  final Map<String, dynamic> topic;
  final Map<String, dynamic>? subtopic;
  final String userRole;

  const LectureWatchScreen({
    super.key,
    required this.lecture,
    required this.subject,
    required this.topic,
    this.subtopic,
    required this.userRole,
  });

  @override
  State<LectureWatchScreen> createState() => _LectureWatchScreenState();
}

class _LectureWatchScreenState extends State<LectureWatchScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isPlaying = false;
  bool _isCompleted = false;
  bool _isBookmarked = false;
  int _currentTime = 0;
  int _duration = 930; // 15:30 in seconds
  double _playbackSpeed = 1.0;
  
  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.lecture['isBookmarked'] ?? false;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    _startTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isPlaying && _currentTime < _duration) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isPlaying) {
          setState(() {
            _currentTime++;
          });
          _startTimer();
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Breadcrumb with timer
              _buildBreadcrumbWithTimer(context),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLectureHeader(context),
                      _buildVideoPlayer(context),
                      _buildTopicSection(context),
                      _buildDescription(context),
                      _buildNavigationSection(context),
                      _buildActionBar(context),
                    ],
                  ),
                ),
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
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: UnifiedTheme.borderColor)),
      ),
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
              widget.lecture['title'],
              style: UnifiedTheme.headerLarge.copyWith(
                color: UnifiedTheme.primaryText,
                fontSize: 20,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

  Widget _buildBreadcrumbWithTimer(BuildContext context) {
    String breadcrumb = 'Video Lectures / ${widget.subject['title']}';
    
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      color: Colors.white,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: UnifiedTheme.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              breadcrumb,
              style: UnifiedTheme.bodyMedium.copyWith(
                color: UnifiedTheme.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: UnifiedTheme.lightGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: UnifiedTheme.lightGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  color: UnifiedTheme.lightGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_currentTime),
                  style: UnifiedTheme.bodyMedium.copyWith(
                    color: UnifiedTheme.lightGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 of ${widget.subject['lecturesCount'] ?? 156}',
                style: UnifiedTheme.headerSmall.copyWith(
                  color: UnifiedTheme.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  // Completion checkbox
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCompleted = !_isCompleted;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _isCompleted ? UnifiedTheme.primaryGreen : Colors.transparent,
                        border: Border.all(color: UnifiedTheme.primaryGreen, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _isCompleted
                          ? const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mark as Complete',
                    style: UnifiedTheme.bodyMedium.copyWith(
                      color: UnifiedTheme.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Bookmark
                  GestureDetector(
                    onTap: _toggleBookmark,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isBookmarked ? UnifiedTheme.primaryGreen : UnifiedTheme.borderColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: _isBookmarked ? Colors.white : UnifiedTheme.tertiaryText,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Report
                  GestureDetector(
                    onTap: _reportLecture,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: UnifiedTheme.goldAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Lecture title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.lecture['title'],
              style: UnifiedTheme.headerMedium.copyWith(
                color: UnifiedTheme.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(UnifiedTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: UnifiedTheme.cardShadow,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Video placeholder
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              ),
              
              // Video controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Progress bar
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _duration > 0 ? _currentTime / _duration : 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: UnifiedTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Controls row
                      Row(
                        children: [
                          // Play/Pause button
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: UnifiedTheme.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Time display
                          Text(
                            '${_formatTime(_currentTime)} / ${_formatTime(_duration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          
                          // Speed control
                          GestureDetector(
                            onTap: _showSpeedOptions,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_playbackSpeed}x',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Fullscreen
                          GestureDetector(
                            onTap: _toggleFullscreen,
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL),
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Row(
        children: [
          Text(
            'Topic Covered: ',
            style: UnifiedTheme.bodyLarge.copyWith(
              color: UnifiedTheme.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            widget.topic['title'],
            style: UnifiedTheme.bodyLarge.copyWith(
              color: UnifiedTheme.lightGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(UnifiedTheme.spacingL),
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UnifiedTheme.borderColor),
        boxShadow: UnifiedTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: UnifiedTheme.headerSmall.copyWith(
              color: UnifiedTheme.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingM),
          Text(
            widget.lecture['description'] + 
            '\n\nThis comprehensive lecture covers essential concepts in veterinary anatomy, providing detailed insights into animal body structures and their functions. Students will learn about the fundamental principles that govern anatomical organization and how these principles apply to various animal species.',
            style: UnifiedTheme.bodyLarge.copyWith(
              color: UnifiedTheme.primaryText,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Instructor info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: UnifiedTheme.primaryGreen,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: UnifiedTheme.spacingM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructor',
                    style: UnifiedTheme.bodySmall.copyWith(
                      color: UnifiedTheme.tertiaryText,
                    ),
                  ),
                  Text(
                    widget.lecture['instructor'],
                    style: UnifiedTheme.bodyMedium.copyWith(
                      color: UnifiedTheme.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          _buildNavButton(
            '← Previous',
            UnifiedTheme.tertiaryText,
            () => _previousLecture(),
          ),
          const SizedBox(width: UnifiedTheme.spacingM),
          
          // Menu Button
          GestureDetector(
            onTap: _openLectureMenu,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: UnifiedTheme.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: UnifiedTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: UnifiedTheme.spacingM),
          
          // Next Button
          _buildNavButton(
            'Next →',
            UnifiedTheme.primaryGreen,
            () => _nextLecture(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL, vertical: UnifiedTheme.spacingM),
      margin: const EdgeInsets.all(UnifiedTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton('Like', widget.lecture['likes'] ?? 0, () => _handleAction('like')),
          _buildActionButton('View', widget.lecture['views'] ?? 0, () => _handleAction('view')),
          _buildActionButton('Notes', 0, () => _showStickyNotes),
          _buildActionButton('Share', 0, () => _handleAction('share')),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: UnifiedTheme.lightBackground,
          borderRadius: BorderRadius.circular(6),
        ),
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
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _startTimer();
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Lecture bookmarked!' : 'Bookmark removed!'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _reportLecture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lecture reported!'),
        backgroundColor: UnifiedTheme.goldAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSpeedOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Playback Speed',
                style: UnifiedTheme.headerMedium.copyWith(
                  color: UnifiedTheme.primaryText,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                  return ListTile(
                    title: Text('${speed}x'),
                    trailing: _playbackSpeed == speed ? const Icon(Icons.check, color: UnifiedTheme.primaryGreen) : null,
                    onTap: () {
                      setState(() {
                        _playbackSpeed = speed;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFullscreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fullscreen mode activated'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showStickyNotes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: UnifiedTheme.borderColor)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.note_add,
                    color: UnifiedTheme.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lecture Notes',
                    style: UnifiedTheme.headerMedium.copyWith(
                      color: UnifiedTheme.primaryText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const TextField(
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: 'Take notes during the lecture...\n\n• Key concepts\n• Important points\n• Questions to review',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: UnifiedTheme.tertiaryText,
                      height: 1.5,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${action.toUpperCase()} action performed!'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _previousLecture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Going to previous lecture'),
        backgroundColor: UnifiedTheme.tertiaryText,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _nextLecture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Going to next lecture'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _openLectureMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: UnifiedTheme.borderColor)),
              ),
              child: Text(
                'Lecture Menu',
                style: UnifiedTheme.headerMedium.copyWith(
                  color: UnifiedTheme.primaryText,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 25,
                itemBuilder: (context, index) {
                  final isCurrentLecture = index == 0; // Assuming lecture 1 is current
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Navigating to lecture ${index + 1}'),
                          backgroundColor: UnifiedTheme.primaryGreen,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrentLecture 
                            ? UnifiedTheme.primaryGreen 
                            : UnifiedTheme.lightBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrentLecture 
                              ? UnifiedTheme.primaryGreen 
                              : UnifiedTheme.borderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrentLecture 
                                ? Colors.white 
                                : UnifiedTheme.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}