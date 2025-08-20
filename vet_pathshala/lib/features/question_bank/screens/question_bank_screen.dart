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
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerScaleAnimation;

  bool _topicsEnabled = true;

  // Enhanced subjects data with better visual design
  final List<Map<String, dynamic>> subjects = [
    {
      'id': '01',
      'title': 'Veterinary Anatomy',
      'description': 'Study of animal body structures, organs, and anatomical systems',
      'questionsCount': 2156,
      'completionRate': 68,
      'icon': Icons.pets,
      'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
      'difficulty': 'Intermediate',
      'estimatedTime': '45 min',
    },
    {
      'id': '02', 
      'title': 'Animal Physiology',
      'description': 'Understanding biological functions and life processes in animals',
      'questionsCount': 1854,
      'completionRate': 45,
      'icon': Icons.favorite,
      'gradient': [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      'difficulty': 'Advanced',
      'estimatedTime': '55 min',
    },
    {
      'id': '03',
      'title': 'Pathology & Diseases',
      'description': 'Study of diseases, their causes and effects on animal health',
      'questionsCount': 2847,
      'completionRate': 32,
      'icon': Icons.healing,
      'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      'difficulty': 'Expert',
      'estimatedTime': '60 min',
    },
    {
      'id': '04',
      'title': 'Pharmacology',
      'description': 'Drug actions, interactions and therapeutic applications in veterinary medicine',
      'questionsCount': 1534,
      'completionRate': 78,
      'icon': Icons.medication,
      'gradient': [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      'difficulty': 'Intermediate',
      'estimatedTime': '40 min',
    },
    {
      'id': '05',
      'title': 'Clinical Veterinary',
      'description': 'Practical clinical approaches and case studies in veterinary practice',
      'questionsCount': 1987,
      'completionRate': 55,
      'icon': Icons.local_hospital,
      'gradient': [const Color(0xFFfa709a), const Color(0xFFfee140)],
      'difficulty': 'Advanced',
      'estimatedTime': '50 min',
    },
    {
      'id': '06',
      'title': 'Animal Nutrition',
      'description': 'Nutritional requirements and dietary management for various animal species',
      'questionsCount': 1245,
      'completionRate': 82,
      'icon': Icons.restaurant,
      'gradient': [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
      'difficulty': 'Beginner',
      'estimatedTime': '35 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.elasticOut),
    );
    
    _headerAnimationController.forward();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _headerAnimationController.dispose();
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
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Modern App Bar
                _buildModernAppBar(context, user),
                
                // Subject Grid
                _buildSubjectGrid(context, user),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernAppBar(BuildContext context, UserModel user) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937),
            size: 18,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildToggleButton('Topics', _topicsEnabled, () {
            setState(() {
              _topicsEnabled = !_topicsEnabled;
            });
          }),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _headerScaleAnimation.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                      Color(0xFF667eea),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    
                    // Content
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question Bank',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Master veterinary sciences with comprehensive practice questions',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSubjectGrid(BuildContext context, UserModel user) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= subjects.length) return null;
            final subject = subjects[index];
            return AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.easeOutBack,
                      child: _buildModernSubjectCard(context, subject, user, index),
                    ),
                  ),
                );
              },
            );
          },
          childCount: subjects.length,
        ),
      ),
    );
  }

  Widget _buildModernSubjectCard(BuildContext context, Map<String, dynamic> subject, UserModel user, int index) {
    return GestureDetector(
      onTap: () => _navigateToSubjectTopics(context, subject, user),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (subject['gradient'][0] as Color).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: subject['gradient'],
                  ),
                ),
              ),
              
              // Decorative elements
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and difficulty
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            subject['icon'],
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            subject['difficulty'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      subject['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      subject['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Stats
                    Column(
                      children: [
                        // Progress bar
                        Container(
                          width: double.infinity,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (subject['completionRate'] as int) / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${subject['questionsCount']} questions',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${subject['completionRate']}%',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Tap ripple effect
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _navigateToSubjectTopics(context, subject, user),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isEnabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled ? Colors.transparent : Colors.white.withOpacity(0.5),
          ),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEnabled ? Icons.toggle_on : Icons.toggle_off,
              color: isEnabled ? const Color(0xFF667eea) : Colors.white.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isEnabled ? const Color(0xFF1F2937) : Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
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