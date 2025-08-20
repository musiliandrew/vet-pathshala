import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'questions_list_screen.dart';

class SubtopicsScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> topic;
  final String userRole;

  const SubtopicsScreen({
    super.key,
    required this.subject,
    required this.topic,
    required this.userRole,
  });

  @override
  State<SubtopicsScreen> createState() => _SubtopicsScreenState();
}

class _SubtopicsScreenState extends State<SubtopicsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Sample subtopics data - in real app this would come from Firebase
  final List<Map<String, dynamic>> subtopics = [
    {
      'id': '01',
      'title': 'Bone Structure & Composition',
      'description': 'Study of bone anatomy, types, and cellular composition',
      'questionsCount': 156,
      'guessScore': 0.00,
    },
    {
      'id': '02',
      'title': 'Joint Classifications',
      'description': 'Types of joints, their movements and clinical significance',
      'questionsCount': 89,
      'guessScore': 0.00,
    },
    {
      'id': '03',
      'title': 'Muscle Anatomy',
      'description': 'Skeletal, cardiac, and smooth muscle structure and function',
      'questionsCount': 203,
      'guessScore': 0.00,
    },
    {
      'id': '04',
      'title': 'Muscular Disorders',
      'description': 'Common muscle diseases, injuries and treatment approaches',
      'questionsCount': 97,
      'guessScore': 0.00,
    },
    {
      'id': '05',
      'title': 'Orthopedic Conditions',
      'description': 'Bone fractures, joint diseases and surgical interventions',
      'questionsCount': 134,
      'guessScore': 0.00,
    },
  ];

  @override
  void initState() {
    super.initState();
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
                    _buildHeader(),
                    Expanded(
                      child: _buildSubtopicsList(),
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

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.primaryGreen, UnifiedTheme.primaryGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: UnifiedTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/patterns/grid_pattern.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(UnifiedTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and actions
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Language button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.translate,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UnifiedTheme.spacingL),
                
                // Title and subtitle
                Text(
                  'Subtopics',
                  style: UnifiedTheme.headerLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    shadows: [
                      const Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
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
                    '${widget.subject['title']} → ${widget.topic['title']}',
                    style: UnifiedTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtopicsList() {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Text(
              'Subtopics',
              style: UnifiedTheme.headerMedium.copyWith(
                color: UnifiedTheme.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Subtopic Cards
          Expanded(
            child: ListView.builder(
              itemCount: subtopics.length,
              itemBuilder: (context, index) {
                final subtopic = subtopics[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeOutBack,
                  margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
                  child: _buildSubtopicCard(context, subtopic),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtopicCard(BuildContext context, Map<String, dynamic> subtopic) {
    return GestureDetector(
      onTap: () => _navigateToQuestions(context, subtopic),
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
        child: Padding(
          padding: const EdgeInsets.all(UnifiedTheme.spacingL),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [UnifiedTheme.primaryGreen, UnifiedTheme.primaryGreen.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(UnifiedTheme.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: UnifiedTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.topic,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: UnifiedTheme.spacingM),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtopic['title'],
                      style: UnifiedTheme.headerMedium.copyWith(
                        color: UnifiedTheme.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: UnifiedTheme.spacingS),
                    Text(
                      subtopic['description'],
                      style: UnifiedTheme.bodyMedium.copyWith(
                        color: UnifiedTheme.secondaryText,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: UnifiedTheme.spacingM),
                    
                    // Stats Row
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.quiz,
                          '${subtopic['questionsCount']} Questions',
                          UnifiedTheme.primaryGreen,
                        ),
                        const SizedBox(width: UnifiedTheme.spacingS),
                        _buildStatChip(
                          Icons.analytics,
                          '${subtopic['guessScore']}% Score',
                          UnifiedTheme.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: UnifiedTheme.primaryGreen,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToQuestions(BuildContext context, Map<String, dynamic> subtopic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuestionsListScreen(
          subject: widget.subject,
          topic: widget.topic,
          subtopic: subtopic,
          userRole: widget.userRole,
        ),
      ),
    );
  }
}