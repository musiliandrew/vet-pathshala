import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/quiz_models.dart';
import '../../../shared/models/user_model.dart';
import '../providers/advanced_quiz_provider.dart';
import '../widgets/quiz_timer_widget.dart';
import '../widgets/quiz_progress_widget.dart';
import '../widgets/quiz_question_card.dart';
import '../widgets/quiz_results_widget.dart';

class TimedQuizScreen extends StatefulWidget {
  final QuizModel quiz;
  final UserModel user;

  const TimedQuizScreen({
    super.key,
    required this.quiz,
    required this.user,
  });

  @override
  State<TimedQuizScreen> createState() => _TimedQuizScreenState();
}

class _TimedQuizScreenState extends State<TimedQuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _timerController;
  late Animation<double> _progressAnimation;
  late Animation<Color?> _timerColorAnimation;
  
  int? _selectedAnswer;
  DateTime? _questionStartTime;
  
  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _timerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _timerColorAnimation = ColorTween(
      begin: UnifiedTheme.primaryColor,
      end: Colors.red,
    ).animate(_timerController);
    
    // Start the quiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQuiz();
    });
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    _timerController.dispose();
    super.dispose();
  }
  
  void _startQuiz() {
    final provider = context.read<AdvancedQuizProvider>();
    provider.startQuiz(
      userId: widget.user.id,
      quiz: widget.quiz,
    );
    _questionStartTime = DateTime.now();
  }
  
  void _selectAnswer(int answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }
  
  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    
    final timeSpent = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inSeconds
        : 0;
    
    final provider = context.read<AdvancedQuizProvider>();
    provider.submitAnswer(
      selectedAnswer: _selectedAnswer!,
      timeSpent: timeSpent,
    );
    
    // Reset for next question
    setState(() {
      _selectedAnswer = null;
    });
    _questionStartTime = DateTime.now();
    
    // Update progress animation
    _progressController.animateTo(provider.progress);
  }
  
  void _showExitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdvancedQuizProvider>().resetQuiz();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close quiz screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        backgroundColor: UnifiedTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            widget.quiz.title,
            style: UnifiedTheme.headingStyle.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          backgroundColor: UnifiedTheme.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitDialog,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8.0),
            child: Consumer<AdvancedQuizProvider>(
              builder: (context, provider, child) {
                return AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        body: Consumer<AdvancedQuizProvider>(
          builder: (context, provider, child) {
            return _buildQuizContent(provider);
          },
        ),
      ),
    );
  }
  
  Widget _buildQuizContent(AdvancedQuizProvider provider) {
    switch (provider.state) {
      case QuizSessionState.starting:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Starting quiz...'),
            ],
          ),
        );
        
      case QuizSessionState.inProgress:
        return _buildQuizQuestion(provider);
        
      case QuizSessionState.submitting:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Submitting answer...'),
            ],
          ),
        );
        
      case QuizSessionState.completed:
        return QuizResultsWidget(
          attempt: provider.currentAttempt!,
          quiz: widget.quiz,
          onRetakeQuiz: () {
            provider.resetQuiz();
            _startQuiz();
          },
          onExit: () => Navigator.pop(context),
        );
        
      case QuizSessionState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: ${provider.errorMessage}',
                textAlign: TextAlign.center,
                style: UnifiedTheme.bodyStyle,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  provider.clearError();
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        );
        
      default:
        return const Center(child: Text('Loading...'));
    }
  }
  
  Widget _buildQuizQuestion(AdvancedQuizProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) {
      return const Center(child: Text('No question available'));
    }
    
    return Column(
      children: [
        // Timer and question info
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              // Question counter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: UnifiedTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${provider.currentQuestionIndex + 1}/${provider.totalQuestions}',
                  style: UnifiedTheme.captionStyle.copyWith(
                    color: UnifiedTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Timer (if timed quiz)
              if (provider.isTimedQuiz)
                AnimatedBuilder(
                  animation: _timerColorAnimation,
                  builder: (context, child) {
                    // Change color when time is running low
                    if (provider.remainingTimeSeconds <= 60) {
                      _timerController.forward();
                    } else {
                      _timerController.reverse();
                    }
                    
                    return QuizTimerWidget(
                      remainingTime: provider.remainingTimeSeconds,
                      color: _timerColorAnimation.value ?? UnifiedTheme.primaryColor,
                    );
                  },
                ),
            ],
          ),
        ),
        
        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: QuizQuestionCard(
              question: question,
              selectedAnswer: _selectedAnswer,
              onAnswerSelected: _selectAnswer,
              questionNumber: provider.currentQuestionIndex + 1,
            ),
          ),
        ),
        
        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Previous button (if not first question)
              if (provider.currentQuestionIndex > 0)
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: provider.previousQuestion,
                    child: const Text('Previous'),
                  ),
                ),
              
              if (provider.currentQuestionIndex > 0) const SizedBox(width: 16),
              
              // Submit/Next button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _selectedAnswer != null ? _submitAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UnifiedTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    provider.isLastQuestion ? 'Submit Quiz' : 'Next Question',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}