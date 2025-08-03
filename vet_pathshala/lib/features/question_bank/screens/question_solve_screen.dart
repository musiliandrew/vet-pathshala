import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

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
      if (mounted) {
        setState(() {
          _timeElapsed++;
        });
        _startTimer();
      }
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
          
          // Action Bar
          _buildActionBar(context),
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

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: UnifiedTheme.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton('Like', 0, () => _handleAction('like')),
          _buildActionButton('View', widget.question['viewCount'] ?? 8, () => _handleAction('view')),
          _buildActionButton('Report', 0, () => _handleAction('report')),
          _buildActionButton('Notes', 0, () => _showStickyNotes),
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
              label.replaceAll('👍 ', '').replaceAll('👁️ ', '').replaceAll('📋 ', '').replaceAll('📝 ', ''),
              style: UnifiedTheme.bodySmall.copyWith(
                color: UnifiedTheme.tertiaryText,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: UnifiedTheme.bodySmall.copyWith(
                color: UnifiedTheme.tertiaryText,
              ),
            ),
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
    
    // AI Response Display
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingM),
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.blueAccent.withOpacity(0.1), UnifiedTheme.blueAccent.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UnifiedTheme.blueAccent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.smart_toy,
                color: UnifiedTheme.blueAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Explanation',
                style: UnifiedTheme.headerSmall.copyWith(
                  color: UnifiedTheme.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: UnifiedTheme.spacingM),
          Text(
            'The correct answer is A - Dravya, Guna, Karma, Sāmānya, Vishesha, Samavāya. According to Charaka Samhita, this is the traditional sequence of the six categories (shat padartha) in Ayurvedic philosophy. Your selected answer represents a different philosophical arrangement.',
            style: UnifiedTheme.bodyMedium.copyWith(
              color: UnifiedTheme.blueAccent,
              height: 1.6,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingM),
          GestureDetector(
            onTap: () => _continueToNext(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: UnifiedTheme.blueAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Continue to Next Question →',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
    setState(() {
      _selectedOption = index;
    });
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

  void _handleAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${action.toUpperCase()} action performed!'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showStickyNotes() {
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
    Navigator.pop(context);
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
    
    if (!_hasAnswered) {
      setState(() {
        _hasAnswered = true;
      });
      return;
    }
    
    // Move to next question - in real app this would navigate to next question
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Answer ${String.fromCharCode(65 + _selectedOption)} submitted! Moving to next question.'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openQuestionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 250,
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
                'Question Menu',
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
                  final isCurrentQuestion = index == 1; // Assuming question 2 is current
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Navigating to question ${index + 1}'),
                          backgroundColor: UnifiedTheme.primaryGreen,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrentQuestion 
                            ? UnifiedTheme.primaryGreen 
                            : UnifiedTheme.lightBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrentQuestion 
                              ? UnifiedTheme.primaryGreen 
                              : UnifiedTheme.borderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrentQuestion 
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

  void _continueToNext() {
    _nextQuestion();
  }
}