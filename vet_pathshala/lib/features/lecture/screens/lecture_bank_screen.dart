import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'lecture_topics_screen.dart';

class LectureBankScreen extends StatefulWidget {
  const LectureBankScreen({super.key});

  @override
  State<LectureBankScreen> createState() => _LectureBankScreenState();
}

class _LectureBankScreenState extends State<LectureBankScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _topicsEnabled = true;
  bool _subtopicsEnabled = false;

  // Sample subjects data - in real app this would come from Firebase
  final List<Map<String, dynamic>> subjects = [
    {
      'id': '01',
      'title': 'Veterinary Anatomy',
      'description': 'Video lectures on animal body structure and organ systems',
      'lecturesCount': 156,
      'watchedCount': 0,
      'duration': '24.5 hrs',
      'color': UnifiedTheme.primaryGreen,
    },
    {
      'id': '02', 
      'title': 'Animal Physiology',
      'description': 'Understanding body functions and biological processes',
      'lecturesCount': 134,
      'watchedCount': 0,
      'duration': '18.2 hrs',
      'color': UnifiedTheme.lightGreen,
    },
    {
      'id': '03',
      'title': 'Pathology & Diseases',
      'description': 'Study of diseases, their causes and effects on animals',
      'lecturesCount': 198,
      'watchedCount': 0,
      'duration': '32.4 hrs',
      'color': UnifiedTheme.blueAccent,
    },
    {
      'id': '04',
      'title': 'Pharmacology',
      'description': 'Drug actions, interactions and therapeutic applications',
      'lecturesCount': 112,
      'watchedCount': 0,
      'duration': '16.8 hrs',
      'color': UnifiedTheme.goldAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Please sign in to access lectures')),
          );
        }

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
                        // Header with video character
                        _buildHeader(context, user),
                        
                        // Subject List
                        Expanded(
                          child: _buildSubjectList(context, user),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return UnifiedTheme.buildGradientContainer(
      child: Column(
        children: [
          // Top navigation bar with back button and topics toggle
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _buildToggleButton('Topics', _topicsEnabled, () {
                    setState(() {
                      _topicsEnabled = !_topicsEnabled;
                      if (!_topicsEnabled) _subtopicsEnabled = false;
                    });
                  }),
                  const SizedBox(width: 8),
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
          const SizedBox(height: UnifiedTheme.spacingXXL),
          
          // Video character with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 3),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -8 * (0.5 - (value * 2 - 1).abs())),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Title and subtitle
          Text(
            'Video Lectures',
            style: UnifiedTheme.headerLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              'Choose your study subject',
              style: UnifiedTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Subjects Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: UnifiedTheme.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: UnifiedTheme.blueAccent.withOpacity(0.3)),
            ),
            child: Text(
              'Available Courses',
              style: UnifiedTheme.headerMedium.copyWith(
                color: UnifiedTheme.blueAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Subject Cards
          Expanded(
            child: ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeOutBack,
                  margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
                  child: _buildSubjectCard(context, subject, user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> subject, UserModel user) {
    return GestureDetector(
      onTap: () => _navigateToSubjectTopics(context, subject, user),
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
            // Subject card content
            Padding(
              padding: const EdgeInsets.all(UnifiedTheme.spacingL),
              child: Column(
                children: [
                  // Header with number and icon
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: UnifiedTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            subject['id'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [subject['color'], subject['color'].withOpacity(0.8)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.video_library,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UnifiedTheme.spacingM),
                  
                  // Title and description
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject['title'],
                          style: UnifiedTheme.headerSmall.copyWith(
                            color: UnifiedTheme.primaryText,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: UnifiedTheme.spacingS),
                        Text(
                          subject['description'],
                          style: UnifiedTheme.bodyMedium.copyWith(
                            color: UnifiedTheme.secondaryText,
                            height: 1.3,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
                        '${subject['lecturesCount']} Lectures',
                        style: UnifiedTheme.bodySmall.copyWith(
                          color: UnifiedTheme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Duration: ${subject['duration']}',
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
                      '${subject['watchedCount']}/${subject['lecturesCount']} Watched',
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
          color: isEnabled ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isEnabled ? UnifiedTheme.primaryGreen : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _navigateToSubjectTopics(BuildContext context, Map<String, dynamic> subject, UserModel user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LectureTopicsScreen(
          subject: subject,
          userRole: user.userRole,
          showTopics: _topicsEnabled,
          showSubtopics: _subtopicsEnabled,
        ),
      ),
    );
  }
}