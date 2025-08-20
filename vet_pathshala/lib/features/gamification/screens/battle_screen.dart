import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class BattleScreen extends StatefulWidget {
  final String battleType;
  final String opponent;
  final String subject;
  final String difficulty;

  const BattleScreen({
    super.key,
    required this.battleType,
    required this.opponent,
    required this.subject,
    this.difficulty = 'Medium',
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _pulseController;
  int _currentQuestion = 1;
  int _totalQuestions = 10;
  int _timeLeft = 30;
  int _playerScore = 0;
  int _opponentScore = 0;
  String? _selectedAnswer;
  bool _showResult = false;

  // Sample question
  final Map<String, dynamic> _currentQuestionData = {
    'question': 'What is the normal body temperature range for dogs?',
    'options': [
      '36.5°C - 37.5°C',
      '38.0°C - 39.2°C',
      '39.5°C - 40.5°C',
      '37.0°C - 38.0°C',
    ],
    'correctAnswer': '38.0°C - 39.2°C',
    'explanation': 'Normal canine body temperature ranges from 38.0°C to 39.2°C (100.4°F to 102.6°F).',
  };

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _startTimer();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timerController.forward();
    _timerController.addListener(() {
      setState(() {
        _timeLeft = (30 * (1 - _timerController.value)).round();
      });
      
      if (_timerController.isCompleted) {
        _autoSubmitAnswer();
      }
    });
  }

  void _autoSubmitAnswer() {
    if (_selectedAnswer == null) {
      _selectedAnswer = _currentQuestionData['options'][0];
    }
    _submitAnswer();
  }

  void _submitAnswer() {
    setState(() {
      _showResult = true;
    });

    // Simulate opponent answering
    bool isCorrect = _selectedAnswer == _currentQuestionData['correctAnswer'];
    bool opponentCorrect = DateTime.now().millisecond % 3 != 0; // 66% chance opponent is correct

    if (isCorrect) _playerScore += 10;
    if (opponentCorrect) _opponentScore += 10;

    Future.delayed(const Duration(seconds: 3), () {
      if (_currentQuestion < _totalQuestions) {
        _nextQuestion();
      } else {
        _showFinalResults();
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestion++;
      _timeLeft = 30;
      _selectedAnswer = null;
      _showResult = false;
    });
    _timerController.reset();
    _startTimer();
  }

  void _showFinalResults() {
    String result = '';
    Color resultColor = Colors.grey;
    
    if (_playerScore > _opponentScore) {
      result = '🎉 Victory!';
      resultColor = Colors.green;
    } else if (_playerScore < _opponentScore) {
      result = '😔 Defeat';
      resultColor = Colors.red;
    } else {
      result = '🤝 Draw';
      resultColor = Colors.orange;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: UnifiedTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(result, style: TextStyle(color: resultColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Final Score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('You'),
                    Text('$_playerScore', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text(widget.opponent),
                    Text('$_opponentScore', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('🏆 +50 XP earned'),
            const Text('💰 +5 coins earned'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to gamification screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: UnifiedTheme.primaryGreen),
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with scores and timer
            _buildHeader(),
            
            // Question progress
            _buildProgressBar(),
            
            // Question content
            Expanded(
              child: _buildQuestionSection(),
            ),
            
            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.primaryGreen, UnifiedTheme.primaryGreen.withOpacity(0.8)],
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          
          // Player score
          Expanded(
            child: Column(
              children: [
                const Text('You', style: TextStyle(color: Colors.white70)),
                Text('$_playerScore', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // Timer
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _timeLeft <= 10 ? Colors.red : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: _timeLeft <= 10 ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(_pulseController.value * 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
                child: Text(
                  '$_timeLeft',
                  style: TextStyle(
                    color: _timeLeft <= 10 ? Colors.white : UnifiedTheme.primaryGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          
          // Opponent score
          Expanded(
            child: Column(
              children: [
                Text(widget.opponent, style: const TextStyle(color: Colors.white70)),
                Text('$_opponentScore', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question $_currentQuestion of $_totalQuestions'),
              Text('${widget.subject}'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _currentQuestion / _totalQuestions,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(UnifiedTheme.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: UnifiedTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _currentQuestionData['question'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Answer options
          Expanded(
            child: ListView.builder(
              itemCount: _currentQuestionData['options'].length,
              itemBuilder: (context, index) {
                final option = _currentQuestionData['options'][index];
                final isSelected = _selectedAnswer == option;
                final isCorrect = option == _currentQuestionData['correctAnswer'];
                
                Color backgroundColor = UnifiedTheme.cardBackground;
                Color borderColor = Colors.grey.shade300;
                Color textColor = UnifiedTheme.primaryText;
                
                if (_showResult) {
                  if (isCorrect) {
                    backgroundColor = Colors.green.shade50;
                    borderColor = Colors.green;
                    textColor = Colors.green.shade700;
                  } else if (isSelected && !isCorrect) {
                    backgroundColor = Colors.red.shade50;
                    borderColor = Colors.red;
                    textColor = Colors.red.shade700;
                  }
                } else if (isSelected) {
                  backgroundColor = UnifiedTheme.primaryGreen.withOpacity(0.1);
                  borderColor = UnifiedTheme.primaryGreen;
                  textColor = UnifiedTheme.primaryGreen;
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: _showResult ? null : () {
                      setState(() {
                        _selectedAnswer = option;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor, width: 2),
                              color: isSelected || (_showResult && isCorrect) ? borderColor : Colors.transparent,
                            ),
                            child: (isSelected || (_showResult && isCorrect)) ? 
                              Icon(Icons.check, color: Colors.white, size: 16) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (_showResult && isCorrect)
                            const Icon(Icons.check_circle, color: Colors.green),
                          if (_showResult && isSelected && !isCorrect)
                            const Icon(Icons.cancel, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Explanation (shown after answering)
          if (_showResult) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_currentQuestionData['explanation']),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Battle type indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.battleType.toUpperCase(),
              style: TextStyle(
                color: UnifiedTheme.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Submit button
          if (!_showResult && _selectedAnswer != null)
            ElevatedButton(
              onPressed: _submitAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: UnifiedTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Submit Answer', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}