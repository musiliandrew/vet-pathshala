import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'subtopic_questions_screen.dart';

class SubjectTopicsScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final String userRole;
  final bool showTopics;
  final bool showSubtopics;

  const SubjectTopicsScreen({
    super.key,
    required this.subject,
    required this.userRole,
    this.showTopics = true,
    this.showSubtopics = false,
  });

  @override
  State<SubjectTopicsScreen> createState() => _SubjectTopicsScreenState();
}

class _SubjectTopicsScreenState extends State<SubjectTopicsScreen> 
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
      'title': 'Musculoskeletal System',
      'description': 'Study of bones, muscles, joints and related structures in animal anatomy',
      'questionsCount': 4267,
      'guessScore': 0.00,
    },
    {
      'id': '02',
      'title': 'Cardiovascular System', 
      'description': 'Heart, blood vessels and circulatory system functions and diseases',
      'questionsCount': 503,
      'guessScore': 0.00,
    },
    {
      'id': '03',
      'title': 'Respiratory System',
      'description': 'Lung function, breathing mechanisms and respiratory diseases',
      'questionsCount': 759,
      'guessScore': 0.00,
    },
    {
      'id': '04',
      'title': 'Nervous System',
      'description': 'Brain, spinal cord, nerves and neurological functions',
      'questionsCount': 765,
      'guessScore': 0.00,
    },
    {
      'id': '05',
      'title': 'Digestive System',
      'description': 'Gastrointestinal tract, nutrition and digestive processes',
      'questionsCount': 267,
      'guessScore': 0.00,
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
                    
                    // Breadcrumb (only show if showing topics)
                    if (widget.showTopics) _buildBreadcrumb(context),
                    
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
              'Question Bank / ${widget.subject['title']}',
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
    if (!widget.showTopics) {
      // Show all questions directly for this subject
      return _buildAllQuestions(context);
    } else if (_subtopicsEnabled) {
      // Show subtopics for all topics (or selected topic)
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

  Widget _buildAllQuestions(BuildContext context) {
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
              'All Questions - ${widget.subject['title']}',
              style: UnifiedTheme.headerSmall.copyWith(
                color: UnifiedTheme.blueAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToQuestions(context, null),
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
                    Icon(
                      Icons.quiz,
                      size: 48,
                      color: UnifiedTheme.primaryGreen,
                    ),
                    const SizedBox(height: UnifiedTheme.spacingM),
                    Text(
                      'Start Practice',
                      style: UnifiedTheme.headerMedium.copyWith(
                        color: UnifiedTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: UnifiedTheme.spacingS),
                    Text(
                      '${widget.subject['questionsCount']} Questions Available',
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
    // Sample subtopics from all topics (not just one)
    final allSubtopics = [
      {'title': 'Bone Structure', 'topic': 'Musculoskeletal System'},
      {'title': 'Muscle Types', 'topic': 'Musculoskeletal System'},
      {'title': 'Joint Mechanics', 'topic': 'Musculoskeletal System'},
      {'title': 'Skeletal Development', 'topic': 'Musculoskeletal System'},
      {'title': 'Heart Anatomy', 'topic': 'Cardiovascular System'},
      {'title': 'Blood Circulation', 'topic': 'Cardiovascular System'},
      {'title': 'Cardiac Cycle', 'topic': 'Cardiovascular System'},
      {'title': 'Lung Structure', 'topic': 'Respiratory System'},
      {'title': 'Gas Exchange', 'topic': 'Respiratory System'},
      {'title': 'Breathing Mechanics', 'topic': 'Respiratory System'},
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
              'Subtopics - ${widget.subject['title']}',
              style: UnifiedTheme.headerSmall.copyWith(
                color: UnifiedTheme.goldAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allSubtopics.length,
              itemBuilder: (context, index) {
                final subtopic = allSubtopics[index];
                return _buildSubtopicCard(context, subtopic, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtopicCard(BuildContext context, Map<String, String> subtopic, int index) {
    return GestureDetector(
      onTap: () => _navigateToQuestions(context, subtopic),
      child: Container(
        margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
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
            // Subtopic content
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
                                subtopic['title']!,
                                style: UnifiedTheme.headerSmall.copyWith(
                                  color: UnifiedTheme.primaryText,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: UnifiedTheme.spacingS),
                        Text(
                          'From: ${subtopic['topic']}',
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
                        colors: [UnifiedTheme.goldAccent, UnifiedTheme.goldAccent.withOpacity(0.8)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.subdirectory_arrow_right,
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
                  Text(
                    'Score: 0%',
                    style: UnifiedTheme.bodySmall.copyWith(
                      color: UnifiedTheme.goldAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${150 + (index * 20)} Questions',
                    style: UnifiedTheme.bodySmall.copyWith(
                      color: UnifiedTheme.goldAccent,
                      fontWeight: FontWeight.w600,
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
                    child: Center(
                      child: Icon(
                        Icons.topic,
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
                  Text(
                    'Score: ${topic['guessScore'].toStringAsFixed(0)}%',
                    style: UnifiedTheme.bodySmall.copyWith(
                      color: UnifiedTheme.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${topic['questionsCount']} Questions',
                    style: UnifiedTheme.bodySmall.copyWith(
                      color: UnifiedTheme.blueAccent,
                      fontWeight: FontWeight.w600,
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
      setState(() {
        // This would typically update the selected topic and show subtopics
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SubtopicQuestionsScreen(
            subject: widget.subject,
            topic: topic,
            userRole: widget.userRole,
          ),
        ),
      );
    }
  }

  void _navigateToQuestions(BuildContext context, Map<String, dynamic>? subtopic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubtopicQuestionsScreen(
          subject: widget.subject,
          topic: subtopic ?? {'title': 'All Questions'},
          userRole: widget.userRole,
        ),
      ),
    );
  }
}