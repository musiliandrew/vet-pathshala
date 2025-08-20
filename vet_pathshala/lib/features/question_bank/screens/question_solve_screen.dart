import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../core/services/user_interaction_service.dart';
import '../../../shared/widgets/report_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/ai_explanation_widget.dart';

class QuestionSolveScreen extends StatefulWidget {
  final Map<String, dynamic> question;
  final Map<String, dynamic> subject;
  final Map<String, dynamic> topic;
  final String userRole;

  const QuestionSolveScreen({
    super.key,
    required this.question,
    required this.subject,
    required this.topic,
    required this.userRole,
  });

  @override
  State<QuestionSolveScreen> createState() => _QuestionSolveScreenState();
}

class _QuestionSolveScreenState extends State<QuestionSolveScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _timerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedOption = -1;
  bool _isGuessing = false;
  bool _hasAnswered = false;
  bool _showAIResponse = false;
  int _timeElapsed = 0;
  bool _isBookmarked = false;
  bool _timerStopped = false;
  bool _isLiked = false;
  int _likeCount = 0;
  int _viewCount = 0;
  int _reportCount = 0;
  int _noteCount = 0;
  
  // Sample question data with options
  final Map<String, dynamic> _questionData = {
    'questionText': 'According to ācharya charaka, the sequence of shat padartha is -',
    'options': [
      'Dravya, Guna, Karma, Sāmānya, Vishesha, Samavāya',
      'Sāmānya, Vishesha, Guna, Dravya, Karma, Samavāya',
      'Sāmānya, Vishesha, Samavāya, Dravya, Guna, Karma',
      'Dravya, Guna, Karma, Samavāya, Sāmānya, Vishesha',
    ],
    'correctAnswer': 0,
    'currentQuestionNumber': 2,
    'totalQuestions': 4267,
  };

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.question['isBookmarked'] ?? false;
    _isLiked = widget.question['isLiked'] ?? false;
    _likeCount = widget.question['likeCount'] ?? 0;
    _viewCount = widget.question['viewCount'] ?? 8;
    _reportCount = widget.question['reportCount'] ?? 0;
    _noteCount = widget.question['noteCount'] ?? 0;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _timerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _animationController.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_timerStopped) {
        setState(() {
          _timeElapsed++;
        });
        _startTimer();
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _timerStopped = true;
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Header with timer
                _buildHeader(context),
                
                // Question content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildQuestionCard(context),
                        if (_hasAnswered) _buildAIResponseSection(context),
                        _buildNavigationSection(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildFixedActionBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.primaryGreen, UnifiedTheme.primaryGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.1),
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
          
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(_timeElapsed),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Translate Button
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.translate,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(UnifiedTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UnifiedTheme.primaryGreen.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question Header
          _buildQuestionHeader(context),
          
          // Question Content
          _buildQuestionContent(context),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: UnifiedTheme.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_questionData['currentQuestionNumber']} of ${_questionData['totalQuestions']}',
            style: UnifiedTheme.headerSmall.copyWith(
              color: UnifiedTheme.primaryText,
              fontWeight: FontWeight.w700,
            ),
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
                      _isBookmarked ? Icons.star : Icons.star_border,
                      color: _isBookmarked ? Colors.white : UnifiedTheme.tertiaryText,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Report
              GestureDetector(
                onTap: _reportQuestion,
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
    );
  }

  Widget _buildQuestionContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Text
          Text(
            _questionData['questionText'],
            style: UnifiedTheme.headerSmall.copyWith(
              color: UnifiedTheme.primaryText,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Options
          ..._questionData['options'].asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _buildOptionItem(context, index, option);
          }).toList(),
          
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Guess Section
          _buildGuessSection(context),
        ],
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, int index, String option) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == _questionData['correctAnswer'];
    final showResult = _hasAnswered;
    
    Color borderColor = UnifiedTheme.borderColor;
    Color backgroundColor = Colors.white;
    Color letterColor = UnifiedTheme.tertiaryText;
    
    if (showResult && isCorrect) {
      borderColor = UnifiedTheme.lightGreen;
      backgroundColor = UnifiedTheme.lightGreen.withOpacity(0.1);
      letterColor = UnifiedTheme.lightGreen;
    } else if (showResult && isSelected && !isCorrect) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.withOpacity(0.1);
      letterColor = Colors.red;
    } else if (isSelected && !showResult) {
      borderColor = UnifiedTheme.primaryGreen;
      backgroundColor = UnifiedTheme.primaryGreen.withOpacity(0.1);
      letterColor = UnifiedTheme.primaryGreen;
    }
    
    return GestureDetector(
      onTap: _hasAnswered ? null : () => _selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
        padding: const EdgeInsets.all(UnifiedTheme.spacingM),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Option Letter
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: letterColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: UnifiedTheme.spacingM),
            
            // Option Text
            Expanded(
              child: Text(
                option,
                style: UnifiedTheme.bodyMedium.copyWith(
                  color: UnifiedTheme.primaryText,
                  height: 1.5,
                ),
              ),
            ),
            
            // Correct/Wrong indicator
            if (showResult && isCorrect)
              const Icon(
                Icons.check_circle,
                color: UnifiedTheme.lightGreen,
                size: 24,
              ),
            if (showResult && isSelected && !isCorrect)
              const Icon(
                Icons.cancel,
                color: Colors.red,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuessSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isGuessing = !_isGuessing;
          });
        },
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _isGuessing ? UnifiedTheme.primaryGreen : Colors.transparent,
                border: Border.all(color: UnifiedTheme.primaryGreen, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _isGuessing
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              'Guess Answer',
              style: UnifiedTheme.bodyLarge.copyWith(
                color: UnifiedTheme.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: UnifiedTheme.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedActionBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: UnifiedTheme.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFixedActionButton(
                icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: 'Like',
                count: _likeCount,
                onTap: () => _handleAction('like'),
                isActive: _isLiked,
              ),
              _buildFixedActionButton(
                icon: Icons.visibility_outlined,
                label: 'Views',
                count: _viewCount,
                onTap: () => _handleAction('view'),
              ),
              _buildFixedActionButton(
                icon: Icons.report_outlined,
                label: 'Report',
                count: _reportCount,
                onTap: () => _handleAction('report'),
              ),
              _buildFixedActionButton(
                icon: Icons.sticky_note_2_outlined,
                label: 'Notes',
                count: _noteCount,
                onTap: _showStickyNotes,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFixedActionButton({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final activeColor = isActive ? UnifiedTheme.primaryGreen : UnifiedTheme.primaryGreen.withOpacity(0.8);
    final bgColor = isActive ? UnifiedTheme.primaryGreen.withOpacity(0.2) : UnifiedTheme.primaryGreen.withOpacity(0.1);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activeColor.withOpacity(0.4),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: activeColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: activeColor,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(height: 1),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: activeColor.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAIResponseSection(BuildContext context) {
    if (!_showAIResponse) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingM),
        padding: const EdgeInsets.all(UnifiedTheme.spacingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: UnifiedTheme.cardShadow,
        ),
        child: Column(
          children: [
            // Answer Display
            Container(
              padding: const EdgeInsets.all(UnifiedTheme.spacingL),
              decoration: BoxDecoration(
                color: UnifiedTheme.lightBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: UnifiedTheme.borderColor, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedOption == _questionData['correctAnswer'] 
                          ? UnifiedTheme.lightGreen 
                          : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_selectedOption == _questionData['correctAnswer'] 
                              ? UnifiedTheme.lightGreen 
                              : Colors.red).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + _selectedOption),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: UnifiedTheme.spacingM),
                  Expanded(
                    child: Text(
                      _questionData['options'][_selectedOption],
                      style: UnifiedTheme.bodyMedium.copyWith(
                        color: UnifiedTheme.primaryText,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UnifiedTheme.spacingL),
            
            // Result Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _selectedOption == _questionData['correctAnswer'] 
                        ? UnifiedTheme.lightGreen 
                        : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _selectedOption == _questionData['correctAnswer'] 
                          ? Icons.check 
                          : Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedOption == _questionData['correctAnswer'] 
                      ? 'Correct Answer' 
                      : 'Wrong Answer',
                  style: UnifiedTheme.headerMedium.copyWith(
                    color: _selectedOption == _questionData['correctAnswer'] 
                        ? UnifiedTheme.lightGreen 
                        : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UnifiedTheme.spacingL),
            
            // AI Button
            GestureDetector(
              onTap: () {
                setState(() {
                  _showAIResponse = true;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [UnifiedTheme.lightGreen, UnifiedTheme.lightGreen.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: UnifiedTheme.lightGreen.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Check With AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // AI Explanation Widget
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingM),
      child: AIExplanationWidget(
        questionId: '${widget.question['id'] ?? 'demo_question'}',
        questionText: _questionData['questionText'],
        correctAnswer: _questionData['options'][_questionData['correctAnswer']],
        allOptions: List<String>.from(_questionData['options']),
        category: widget.subject['title'] ?? 'General',
        difficulty: widget.question['difficulty'] ?? 'medium',
        isExpanded: _showAIResponse,
        onToggle: () {
          setState(() {
            _showAIResponse = !_showAIResponse;
          });
        },
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
            UnifiedTheme.primaryGreen,
            () => _previousQuestion(),
          ),
          const SizedBox(width: UnifiedTheme.spacingM),
          
          // Menu Button
          GestureDetector(
            onTap: _openQuestionMenu,
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
            () => _nextQuestion(),
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

  void _selectOption(int index) {
    if (_hasAnswered) return; // Prevent answering same question multiple times
    
    setState(() {
      _selectedOption = index;
      _hasAnswered = true; // Immediately submit answer
    });
    
    // Stop the timer immediately
    _stopTimer();
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedOption == _questionData['correctAnswer'] 
              ? 'Correct! Well done!' 
              : 'Incorrect. The correct answer is ${String.fromCharCode(65 + (_questionData['correctAnswer'] as int))}',
        ),
        backgroundColor: _selectedOption == _questionData['correctAnswer'] 
            ? UnifiedTheme.lightGreen 
            : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Question bookmarked!' : 'Bookmark removed!'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _reportQuestion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question reported!'),
        backgroundColor: UnifiedTheme.goldAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleAction(String action) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;
    
    final interactionService = UserInteractionService();
    final userId = authProvider.currentUser!.id;
    final contentId = widget.question['id']?.toString() ?? 'demo_question';
    
    switch (action.toLowerCase()) {
      case 'like':
        setState(() {
          _isLiked = !_isLiked;
          _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
        });
        
        try {
          final wasLiked = await interactionService.likeContent(
            userId: userId,
            contentId: contentId,
            contentType: 'question',
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(wasLiked ? 'Question liked!' : 'Like removed'),
                backgroundColor: UnifiedTheme.primaryGreen,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          // Revert state if API call fails
          setState(() {
            _isLiked = !_isLiked;
            _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
          });
        }
        break;
        
      case 'report':
        if (mounted) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => ReportDialog(
              contentId: contentId,
              contentType: 'question',
              userId: userId,
              contentTitle: _questionData['questionText'].toString().substring(0, 50) + '...',
            ),
          );
          
          if (result == true) {
            setState(() {
              _reportCount++;
            });
          }
        }
        break;
        
      case 'view':
        setState(() {
          _viewCount++;
        });
        
        await interactionService.viewContent(
          userId: userId,
          contentId: contentId,
          contentType: 'question',
          duration: _timeElapsed,
        );
        break;
        
      default:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${action.toUpperCase()} action performed!'),
              backgroundColor: UnifiedTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
    }
  }

  void _showStickyNotes() {
    final TextEditingController notesController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                  TextButton(
                    onPressed: () {
                      if (notesController.text.trim().isNotEmpty) {
                        setState(() {
                          _noteCount++;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Note saved!'),
                            backgroundColor: UnifiedTheme.primaryGreen,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: UnifiedTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                child: TextField(
                  controller: notesController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'Write your notes here...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previousQuestion() {
    if (_questionData['currentQuestionNumber'] > 1) {
      // In a real app, this would navigate to the previous question
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Going to previous question...'),
          backgroundColor: UnifiedTheme.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is the first question!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _nextQuestion() {
    if (_selectedOption == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer first!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    if (_questionData['currentQuestionNumber'] < _questionData['totalQuestions']) {
      // In a real app, this would navigate to the next question
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Moving to next question...'),
          backgroundColor: UnifiedTheme.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is the last question!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openQuestionMenu() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        alignment: Alignment.centerRight,
        insetPadding: const EdgeInsets.only(left: 50),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with Back button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: UnifiedTheme.borderColor)),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
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
                    const SizedBox(width: 12),
                    Text(
                      'All Questions',
                      style: UnifiedTheme.headerMedium.copyWith(
                        color: UnifiedTheme.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Questions List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 50, // Sample 50 questions
                  itemBuilder: (context, index) {
                    final isCurrentQuestion = index == 1; // Assuming question 2 is current
                    final isPaidContent = index > 25; // Questions after 25 are paid
                    final isAnswered = index < 1; // Questions before current are answered
                    
                    return _buildQuestionListItem(
                      context, 
                      index, 
                      isCurrentQuestion, 
                      isPaidContent, 
                      isAnswered
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionListItem(
    BuildContext context, 
    int index, 
    bool isCurrentQuestion, 
    bool isPaidContent, 
    bool isAnswered
  ) {
    Color backgroundColor = Colors.white;
    Color borderColor = UnifiedTheme.borderColor;
    Color textColor = UnifiedTheme.primaryText;
    
    if (isCurrentQuestion) {
      backgroundColor = UnifiedTheme.primaryGreen.withOpacity(0.1);
      borderColor = UnifiedTheme.primaryGreen;
      textColor = UnifiedTheme.primaryGreen;
    } else if (isAnswered) {
      backgroundColor = UnifiedTheme.lightGreen.withOpacity(0.1);
      borderColor = UnifiedTheme.lightGreen;
      textColor = UnifiedTheme.lightGreen;
    } else if (isPaidContent) {
      backgroundColor = UnifiedTheme.goldAccent.withOpacity(0.05);
      borderColor = UnifiedTheme.goldAccent.withOpacity(0.3);
      textColor = UnifiedTheme.goldAccent;
    }
    
    return GestureDetector(
      onTap: isPaidContent ? _showPremiumDialog : () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigating to question ${index + 1}'),
            backgroundColor: UnifiedTheme.primaryGreen,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Question Number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCurrentQuestion 
                    ? UnifiedTheme.primaryGreen 
                    : isAnswered 
                        ? UnifiedTheme.lightGreen 
                        : isPaidContent 
                            ? UnifiedTheme.goldAccent 
                            : UnifiedTheme.borderColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: (isCurrentQuestion || isAnswered || isPaidContent) 
                        ? Colors.white 
                        : UnifiedTheme.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Question Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${index + 1}',
                    style: UnifiedTheme.bodyLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'According to ācharya charaka...',
                    style: UnifiedTheme.bodySmall.copyWith(
                      color: UnifiedTheme.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Status Icons
            if (isPaidContent)
              const Icon(
                Icons.lock,
                color: UnifiedTheme.goldAccent,
                size: 20,
              )
            else if (isAnswered)
              const Icon(
                Icons.check_circle,
                color: UnifiedTheme.lightGreen,
                size: 20,
              )
            else if (isCurrentQuestion)
              const Icon(
                Icons.play_circle_filled,
                color: UnifiedTheme.primaryGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.lock,
              color: UnifiedTheme.goldAccent,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Premium Content',
              style: UnifiedTheme.headerMedium.copyWith(
                color: UnifiedTheme.goldAccent,
              ),
            ),
          ],
        ),
        content: const Text(
          'This question is part of our premium content. Upgrade to access all questions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upgrade feature coming soon!'),
                  backgroundColor: UnifiedTheme.goldAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.goldAccent,
            ),
            child: const Text(
              'Upgrade',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _continueToNext() {
    _nextQuestion();
  }
}