import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'question_solve_screen.dart';

class SubtopicQuestionsScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> topic;
  final String userRole;

  const SubtopicQuestionsScreen({
    super.key,
    required this.subject,
    required this.topic,
    required this.userRole,
  });

  @override
  State<SubtopicQuestionsScreen> createState() => _SubtopicQuestionsScreenState();
}

class _SubtopicQuestionsScreenState extends State<SubtopicQuestionsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _showBookmarked = false;
  bool _showReported = false;

  // Sample questions data - in real app this would come from Firebase
  final List<Map<String, dynamic>> questions = [
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
              
              // Questions List
              Expanded(
                child: _buildQuestionsList(context),
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
          'Question Bank / ${widget.subject['title']} / ${widget.topic['title']}',
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
                hintText: 'Search',
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
                    _buildFilterCheckbox('Bookmarked', _showBookmarked, (value) {
                      setState(() {
                        _showBookmarked = value;
                      });
                    }),
                    const SizedBox(width: UnifiedTheme.spacingXL),
                    _buildFilterCheckbox('Reported', _showReported, (value) {
                      setState(() {
                        _showReported = value;
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
                '${questions.length} Result Found',
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
                  'Guess Score: 0%',
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

  Widget _buildQuestionsList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL),
      child: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
            child: _buildQuestionCard(context, question),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, Map<String, dynamic> question) {
    return GestureDetector(
      onTap: () => _navigateToQuestion(context, question),
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
            // Question Header
            Padding(
              padding: const EdgeInsets.all(UnifiedTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number and status
                  Row(
                    children: [
                      Text(
                        'Q.${question['id'].toString().padLeft(2, '0')}',
                        style: UnifiedTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: UnifiedTheme.primaryText,
                        ),
                      ),
                      const SizedBox(width: UnifiedTheme.spacingS),
                      if (question['isSolved'])
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
                                Icons.check,
                                color: UnifiedTheme.lightGreen,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Solved',
                                style: UnifiedTheme.bodySmall.copyWith(
                                  color: UnifiedTheme.lightGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (question['lastViewed'] != null) ...[
                        const SizedBox(width: UnifiedTheme.spacingS),
                        Text(
                          'View ${question['lastViewed']}',
                          style: UnifiedTheme.bodySmall.copyWith(
                            color: UnifiedTheme.tertiaryText,
                          ),
                        ),
                      ],
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _toggleBookmark(question['id']),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            question['isBookmarked'] ? Icons.star : Icons.star_border,
                            color: question['isBookmarked'] ? UnifiedTheme.goldAccent : UnifiedTheme.tertiaryText,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: UnifiedTheme.spacingM),
                  
                  // Question Text
                  Text(
                    question['questionText'],
                    style: UnifiedTheme.bodyLarge.copyWith(
                      color: UnifiedTheme.primaryText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
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
                  _buildActionButton('👍 Like', question['likeCount']),
                  _buildActionButton('👁️ View', question['viewCount']),
                  _buildActionButton('📋 Report', question['reportCount']),
                  _buildActionButton('📝 Notes', question['noteCount']),
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
      onTap: () => _handleActionTap(label),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: UnifiedTheme.bodyMedium.copyWith(
              color: UnifiedTheme.tertiaryText,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: UnifiedTheme.bodyMedium.copyWith(
              color: UnifiedTheme.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBookmark(int questionId) {
    setState(() {
      final question = questions.firstWhere((q) => q['id'] == questionId);
      question['isBookmarked'] = !question['isBookmarked'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Question ${questions.firstWhere((q) => q['id'] == questionId)['isBookmarked'] ? 'bookmarked' : 'bookmark removed'}!'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleActionTap(String action) {
    if (action.contains('Notes')) {
      _showStickyNotes();
    } else if (action.contains('Report')) {
      _showReportDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$action performed!'),
          backgroundColor: UnifiedTheme.primaryGreen,
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
                    'Sticky Notes',
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
                    hintText: 'Write your notes here...\n\n• Key points\n• Important concepts\n• Personal insights',
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: UnifiedTheme.borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notes saved successfully!'),
                            backgroundColor: UnifiedTheme.primaryGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UnifiedTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.report_problem,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Report Question',
              style: UnifiedTheme.headerSmall.copyWith(
                color: UnifiedTheme.primaryText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you reporting this question?',
              style: UnifiedTheme.bodyMedium.copyWith(
                color: UnifiedTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            ...['Incorrect Answer', 'Inappropriate Content', 'Duplicate Question', 'Poor Quality', 'Other'].map(
              (reason) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Radio<String>(
                  value: reason,
                  groupValue: null,
                  onChanged: (value) {},
                  activeColor: UnifiedTheme.primaryGreen,
                ),
                title: Text(
                  reason,
                  style: UnifiedTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Question reported for: $reason'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: UnifiedTheme.tertiaryText),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToQuestion(BuildContext context, Map<String, dynamic> question) {
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