import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'question_solve_screen.dart';

class QuestionsListScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> topic;
  final Map<String, dynamic> subtopic;
  final String userRole;

  const QuestionsListScreen({
    super.key,
    required this.subject,
    required this.topic,
    required this.subtopic,
    required this.userRole,
  });

  @override
  State<QuestionsListScreen> createState() => _QuestionsListScreenState();
}

class _QuestionsListScreenState extends State<QuestionsListScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _showBookmarked = false;
  bool _showReported = false;

  // Sample questions data - in real app this would come from Firebase
  List<Map<String, dynamic>> get questions {
    final bool isAllQuestionsMode = widget.subtopic['title'] == 'All Questions';
    
    if (isAllQuestionsMode) {
      // Return more questions from various topics/subtopics
      return [
        {
          'id': 1,
          'questionText': 'What are the main components of the musculoskeletal system?',
          'isSolved': false,
          'isBookmarked': true,
          'viewCount': 15,
          'likeCount': 3,
          'reportCount': 0,
          'noteCount': 2,
          'lastViewed': '2 hours ago',
          'author': 'Dr. Anderson',
          'topic': 'Musculoskeletal System',
          'subtopic': 'Bone Structure',
        },
        {
          'id': 2,
          'questionText': 'Which chamber of the heart receives oxygenated blood?',
          'isSolved': true,
          'isBookmarked': false,
          'viewCount': 22,
          'likeCount': 5,
          'reportCount': 0,
          'noteCount': 0,
          'lastViewed': '1 day ago',
          'author': 'Prof. Johnson',
          'topic': 'Cardiovascular System',
          'subtopic': 'Heart Anatomy',
        },
        {
          'id': 3,
          'questionText': 'What is the primary function of alveoli in the respiratory system?',
          'isSolved': false,
          'isBookmarked': false,
          'viewCount': 8,
          'likeCount': 1,
          'reportCount': 0,
          'noteCount': 1,
          'lastViewed': '3 hours ago',
          'author': 'Dr. Smith',
          'topic': 'Respiratory System',
          'subtopic': 'Gas Exchange',
        },
        {
          'id': 4,
          'questionText': 'Which neurotransmitter is associated with the parasympathetic nervous system?',
          'isSolved': false,
          'isBookmarked': true,
          'viewCount': 12,
          'likeCount': 2,
          'reportCount': 0,
          'noteCount': 0,
          'lastViewed': '4 hours ago',
          'author': 'Dr. Wilson',
          'topic': 'Nervous System',
          'subtopic': 'Neurotransmitters',
        },
        {
          'id': 5,
          'questionText': 'What is the role of bile in digestion?',
          'isSolved': true,
          'isBookmarked': false,
          'viewCount': 18,
          'likeCount': 4,
          'reportCount': 0,
          'noteCount': 1,
          'lastViewed': '1 day ago',
          'author': 'Prof. Davis',
          'topic': 'Digestive System',
          'subtopic': 'Liver Function',
        },
        {
          'id': 6,
          'questionText': 'Which type of joint allows the greatest range of motion?',
          'isSolved': false,
          'isBookmarked': false,
          'viewCount': 7,
          'likeCount': 1,
          'reportCount': 0,
          'noteCount': 0,
          'lastViewed': null,
          'author': 'Dr. Brown',
          'topic': 'Musculoskeletal System',
          'subtopic': 'Joint Types',
        },
        {
          'id': 7,
          'questionText': 'What is the normal resting heart rate range for healthy adults?',
          'isSolved': true,
          'isBookmarked': true,
          'viewCount': 25,
          'likeCount': 6,
          'reportCount': 0,
          'noteCount': 2,
          'lastViewed': '6 hours ago',
          'author': 'Dr. Taylor',
          'topic': 'Cardiovascular System',
          'subtopic': 'Heart Rate',
        },
        {
          'id': 8,
          'questionText': 'Which respiratory muscle is the primary muscle of inspiration?',
          'isSolved': false,
          'isBookmarked': false,
          'viewCount': 10,
          'likeCount': 2,
          'reportCount': 0,
          'noteCount': 1,
          'lastViewed': '2 hours ago',
          'author': 'Prof. Miller',
          'topic': 'Respiratory System',
          'subtopic': 'Breathing Mechanics',
        },
      ];
    } else {
      // Return questions specific to the selected subtopic
      return [
        {
          'id': 1,
          'questionText': '"पंचकर्म" शब्द का सर्वप्रथम उल्लेख किया गया था -',
          'isSolved': false,
          'isBookmarked': true,
          'viewCount': 6,
          'likeCount': 0,
          'reportCount': 0,
          'noteCount': 0,
          'lastViewed': '1 week ago',
          'author': 'पाठ्य पुस्त',
        },
        {
          'id': 2,
          'questionText': 'According to acharya charaka, the sequence of shat padartha is -',
          'isSolved': true,
          'isBookmarked': false,
          'viewCount': 9,
          'likeCount': 0,
          'reportCount': 0,
          'noteCount': 0,
          'lastViewed': '42 minutes ago',
          'author': 'Dr. Sharma',
        },
        {
          'id': 3,
          'questionText': 'What is tridanda ?',
          'isSolved': false,
          'isBookmarked': false,
          'viewCount': 2,
          'likeCount': 0,
          'reportCount': 0,
          'noteCount': 0,
          'lastViewed': null,
          'author': 'Prof. Kumar',
        },
        {
          'id': 4,
          'questionText': 'Given below are two statements, Select the correct answer from the options below.',
          'isSolved': false,
          'isBookmarked': false,
          'viewCount': 0,
          'likeCount': 0,
          'reportCount': 0,
          'noteCount': 0,
          'lastViewed': null,
          'author': 'Quiz Master',
          'hasInfo': true,
        },
        {
          'id': 5,
          'questionText': 'Given below are two statements, Statement 1',
          'isSolved': false,
          'isBookmarked': false,
          'viewCount': 0,
          'likeCount': 0,
          'reportCount': 0,
          'noteCount': 0,
          'lastViewed': null,
          'author': 'Test Bank',
          'hasInfo': true,
        },
      ];
    }
  }

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
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterSection(),
            Expanded(
              child: _buildQuestionsList(),
            ),
          ],
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
                  'Questions',
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
                    '${widget.subject['title']} → ${widget.topic['title']} → ${widget.subtopic['title']}',
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

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(UnifiedTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: UnifiedTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search questions...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: UnifiedTheme.secondaryText),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(width: UnifiedTheme.spacingM),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: UnifiedTheme.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                // Show filter options
              },
              icon: const Icon(Icons.tune, color: UnifiedTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    final filteredQuestions = questions.where((question) {
      final searchTerm = _searchController.text.toLowerCase();
      return question['questionText'].toString().toLowerCase().contains(searchTerm);
    }).toList();

    if (filteredQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: UnifiedTheme.secondaryText,
            ),
            const SizedBox(height: UnifiedTheme.spacingM),
            Text(
              'No questions found',
              style: UnifiedTheme.headerMedium.copyWith(
                color: UnifiedTheme.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingM),
      itemCount: filteredQuestions.length,
      itemBuilder: (context, index) {
        final question = filteredQuestions[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
          child: _buildQuestionCard(question),
        );
      },
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return GestureDetector(
      onTap: () => _navigateToQuestion(question),
      child: Container(
        padding: const EdgeInsets.all(UnifiedTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
          border: Border.all(color: UnifiedTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic/Subtopic info (for All Questions mode)
            if (widget.subtopic['title'] == 'All Questions' && question['topic'] != null) ...[
              Row(
                children: [
                  _buildStatChip(
                    Icons.folder_outlined,
                    question['topic'],
                    Colors.orange.shade600,
                  ),
                  const SizedBox(width: UnifiedTheme.spacingS),
                  if (question['subtopic'] != null)
                    _buildStatChip(
                      Icons.label_outline,
                      question['subtopic'],
                      Colors.purple.shade600,
                    ),
                ],
              ),
              const SizedBox(height: UnifiedTheme.spacingS),
            ],
            
            // Question text
            Text(
              question['questionText'],
              style: UnifiedTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: UnifiedTheme.spacingM),
            
            // Stats row
            Row(
              children: [
                _buildStatChip(
                  Icons.visibility_outlined,
                  question['viewCount'].toString(),
                  Colors.blue,
                ),
                const SizedBox(width: UnifiedTheme.spacingS),
                if (question['isBookmarked'] == true)
                  _buildStatChip(
                    Icons.bookmark,
                    'Saved',
                    UnifiedTheme.primaryGreen,
                  ),
                const SizedBox(width: UnifiedTheme.spacingS),
                if (question['isSolved'] == true)
                  _buildStatChip(
                    Icons.check_circle,
                    'Solved',
                    Colors.green,
                  ),
                const Spacer(),
                if (question['lastViewed'] != null)
                  Text(
                    question['lastViewed'],
                    style: UnifiedTheme.bodySmall.copyWith(
                      color: UnifiedTheme.secondaryText,
                    ),
                  ),
              ],
            ),
          ],
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

  void _navigateToQuestion(Map<String, dynamic> question) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuestionSolveScreen(
          question: question,
          subject: widget.subject,
          topic: widget.topic,
          userRole: widget.userRole,
        ),
      ),
    );
  }
}