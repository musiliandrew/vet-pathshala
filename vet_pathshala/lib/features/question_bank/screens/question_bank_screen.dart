import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/question_provider.dart';
import 'subject_topics_screen.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _topicsEnabled = true;

  // Sample subjects data - in real app this would come from Firebase
  final List<Map<String, dynamic>> subjects = [
    {
      'id': '01',
      'title': 'Veterinary Anatomy',
      'description': 'Comprehensive study of animal body structure and organ systems',
      'questionsCount': 6561,
      'guessScore': 0.00,
      'color': UnifiedTheme.primaryGreen,
    },
    {
      'id': '02', 
      'title': 'Animal Physiology',
      'description': 'Understanding body functions and biological processes in animals',
      'questionsCount': 4654,
      'guessScore': 0.00,
      'color': UnifiedTheme.lightGreen,
    },
    {
      'id': '03',
      'title': 'Pathology & Diseases',
      'description': 'Study of diseases, their causes and effects on animal health',
      'questionsCount': 8847,
      'guessScore': 0.00,
      'color': UnifiedTheme.blueAccent,
    },
    {
      'id': '04',
      'title': 'Pharmacology',
      'description': 'Drug actions, interactions and therapeutic applications',
      'questionsCount': 5234,
      'guessScore': 0.00,
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
            body: Center(child: Text('Please sign in to access questions')),
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
                        // Header with thinking character
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
    return Container(
      width: double.infinity,
      height: 280, // Fixed height for the header
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/q_bank.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to gradient if image fails to load
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [UnifiedTheme.primaryGreen, UnifiedTheme.lightGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Overlay for better text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UnifiedTheme.primaryGreen.withOpacity(0.7),
                    UnifiedTheme.lightGreen.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(UnifiedTheme.spacingL),
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
                            });
                          }),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  
                  // Title and subtitle (centered content)
                  Text(
                    'Question Bank',
                    style: UnifiedTheme.headerLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      shadows: [
                        const Shadow(
                          color: Colors.black54,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: UnifiedTheme.spacingM),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Choose your study subject',
                      style: UnifiedTheme.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          const Shadow(
                            color: Colors.black54,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
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
              color: UnifiedTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Text(
              'Subjects',
              style: UnifiedTheme.headerMedium.copyWith(
                color: UnifiedTheme.primaryGreen,
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
                        child: Center(
                          child: Icon(
                            Icons.book,
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
                  Text(
                    'Score: ${subject['guessScore'].toStringAsFixed(0)}%',
                    style: UnifiedTheme.bodySmall.copyWith(
                      color: UnifiedTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${subject['questionsCount']} Questions',
                    style: UnifiedTheme.bodySmall.copyWith(
                      color: UnifiedTheme.secondaryText,
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
    if (_topicsEnabled) {
      // Navigate to Topics page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SubjectTopicsScreen(
            subject: subject,
            userRole: user.userRole,
            showTopics: true,
            showSubtopics: false,
          ),
        ),
      );
    } else {
      // Navigate directly to all questions for this subject
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SubjectTopicsScreen(
            subject: subject,
            userRole: user.userRole,
            showTopics: false,
            showSubtopics: false,
          ),
        ),
      );
    }
  }
}