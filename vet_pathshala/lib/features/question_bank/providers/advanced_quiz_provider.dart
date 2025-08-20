import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/quiz_models.dart';
import '../../../shared/models/user_model.dart';
import '../services/advanced_quiz_service.dart';

enum QuizSessionState {
  idle,
  starting,
  inProgress,
  paused,
  submitting,
  completed,
  error
}

class AdvancedQuizProvider extends ChangeNotifier {
  final AdvancedQuizService _quizService = AdvancedQuizService();

  // Current quiz session state
  QuizSessionState _state = QuizSessionState.idle;
  QuizModel? _currentQuiz;
  QuizAttemptModel? _currentAttempt;
  List<QuestionModel> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  Timer? _timer;
  int _remainingTimeSeconds = 0;
  String? _errorMessage;

  // Quiz data
  List<QuizModel> _availableQuizzes = [];
  List<QuizBattleModel> _availableBattles = [];
  List<Map<String, dynamic>> _leaderboard = [];
  List<QuizAttemptModel> _userAttempts = [];

  // Getters
  QuizSessionState get state => _state;
  QuizModel? get currentQuiz => _currentQuiz;
  QuizAttemptModel? get currentAttempt => _currentAttempt;
  List<QuestionModel> get currentQuestions => _currentQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuestionModel? get currentQuestion => 
      _currentQuestions.isNotEmpty && _currentQuestionIndex < _currentQuestions.length 
          ? _currentQuestions[_currentQuestionIndex] 
          : null;
  int get remainingTimeSeconds => _remainingTimeSeconds;
  String? get errorMessage => _errorMessage;
  bool get isTimedQuiz => _currentQuiz?.timeLimit != null && _currentQuiz!.timeLimit > 0;
  bool get isLastQuestion => _currentQuestionIndex >= _currentQuestions.length - 1;
  int get totalQuestions => _currentQuestions.length;
  double get progress => _currentQuestions.isNotEmpty 
      ? (_currentQuestionIndex + 1) / _currentQuestions.length 
      : 0.0;

  List<QuizModel> get availableQuizzes => _availableQuizzes;
  List<QuizBattleModel> get availableBattles => _availableBattles;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  List<QuizAttemptModel> get userAttempts => _userAttempts;

  // Load available quizzes
  Future<void> loadQuizzes({
    required String userRole,
    String? category,
    QuizType? type,
    DifficultyLevel? difficulty,
  }) async {
    try {
      _setState(QuizSessionState.starting);
      _availableQuizzes = await _quizService.getQuizzes(
        userRole: userRole,
        category: category,
        type: type,
        difficulty: difficulty,
      );
      _setState(QuizSessionState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Start a new quiz
  Future<void> startQuiz({
    required String userId,
    required QuizModel quiz,
  }) async {
    try {
      _setState(QuizSessionState.starting);
      _currentQuiz = quiz;
      
      // Start the quiz attempt
      _currentAttempt = await _quizService.startQuiz(
        userId: userId,
        quizId: quiz.id,
        quiz: quiz,
      );

      // Load questions for this quiz
      await _loadQuizQuestions();

      // Start timer if it's a timed quiz
      if (quiz.timeLimit > 0) {
        _startTimer(quiz.timeLimit);
      }

      _currentQuestionIndex = 0;
      _setState(QuizSessionState.inProgress);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Submit answer for current question
  Future<void> submitAnswer({
    required int selectedAnswer,
    required int timeSpent,
  }) async {
    try {
      if (_currentAttempt == null || currentQuestion == null) {
        throw Exception('No active quiz or question');
      }

      _setState(QuizSessionState.submitting);

      await _quizService.submitQuizAnswer(
        attemptId: _currentAttempt!.id,
        questionId: currentQuestion!.id,
        selectedAnswer: selectedAnswer,
        timeSpent: timeSpent,
      );

      // Move to next question or complete quiz
      if (_currentQuestionIndex < _currentQuestions.length - 1) {
        _currentQuestionIndex++;
        _setState(QuizSessionState.inProgress);
      } else {
        await _completeQuiz();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Skip current question
  void skipQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    } else {
      _completeQuiz();
    }
  }

  // Go to previous question (if allowed)
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Pause quiz (for non-timed quizzes)
  void pauseQuiz() {
    if (!isTimedQuiz && _state == QuizSessionState.inProgress) {
      _setState(QuizSessionState.paused);
      _timer?.cancel();
    }
  }

  // Resume quiz
  void resumeQuiz() {
    if (_state == QuizSessionState.paused) {
      _setState(QuizSessionState.inProgress);
      if (isTimedQuiz && _remainingTimeSeconds > 0) {
        _startTimer(_remainingTimeSeconds);
      }
    }
  }

  // Complete current quiz
  Future<void> _completeQuiz() async {
    try {
      _setState(QuizSessionState.submitting);
      _timer?.cancel();

      if (_currentAttempt != null) {
        _currentAttempt = await _quizService.completeQuiz(_currentAttempt!.id);
      }

      _setState(QuizSessionState.completed);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Force complete quiz (when time runs out)
  Future<void> forceCompleteQuiz() async {
    await _completeQuiz();
  }

  // Reset quiz session
  void resetQuiz() {
    _timer?.cancel();
    _currentQuiz = null;
    _currentAttempt = null;
    _currentQuestions.clear();
    _currentQuestionIndex = 0;
    _remainingTimeSeconds = 0;
    _setState(QuizSessionState.idle);
  }

  // Load quiz battles
  Future<void> loadAvailableBattles({
    required String userId,
    String? category,
  }) async {
    try {
      _availableBattles = await _quizService.getAvailableBattles(
        userId: userId,
        category: category,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Create quiz battle
  Future<String> createQuizBattle({
    required String challengerId,
    required String category,
    String? opponentId,
    int coinReward = 10,
  }) async {
    try {
      final battleId = await _quizService.createQuizBattle(
        challengerId: challengerId,
        category: category,
        opponentId: opponentId,
        coinReward: coinReward,
      );
      
      // Reload battles list
      await loadAvailableBattles(userId: challengerId, category: category);
      
      return battleId;
    } catch (e) {
      throw Exception('Failed to create battle: $e');
    }
  }

  // Join quiz battle
  Future<void> joinQuizBattle({
    required String battleId,
    required String userId,
  }) async {
    try {
      await _quizService.joinQuizBattle(
        battleId: battleId,
        userId: userId,
      );
      
      // Reload battles list
      await loadAvailableBattles(userId: userId);
    } catch (e) {
      throw Exception('Failed to join battle: $e');
    }
  }

  // Load leaderboard
  Future<void> loadLeaderboard({
    String? quizId,
    String? category,
    String? targetRole,
    Duration period = const Duration(days: 30),
  }) async {
    try {
      _leaderboard = await _quizService.getLeaderboard(
        quizId: quizId,
        category: category,
        targetRole: targetRole,
        period: period,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load user's quiz history
  Future<void> loadUserAttempts({
    required String userId,
    String? quizId,
    bool completedOnly = true,
  }) async {
    try {
      _userAttempts = await _quizService.getUserAttempts(
        userId: userId,
        quizId: quizId,
        completedOnly: completedOnly,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Private helper methods
  void _setState(QuizSessionState newState) {
    _state = newState;
    if (newState != QuizSessionState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _state = QuizSessionState.error;
    _errorMessage = error;
    _timer?.cancel();
    notifyListeners();
  }

  void _startTimer(int seconds) {
    _remainingTimeSeconds = seconds;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingTimeSeconds--;
      notifyListeners();
      
      if (_remainingTimeSeconds <= 0) {
        timer.cancel();
        forceCompleteQuiz();
      }
    });
  }

  Future<void> _loadQuizQuestions() async {
    if (_currentAttempt?.metadata['selectedQuestions'] != null) {
      final questionIds = List<String>.from(
        _currentAttempt!.metadata['selectedQuestions']
      );
      
      // Load questions from Firestore
      final firestore = FirebaseFirestore.instance;
      _currentQuestions.clear();
      for (final questionId in questionIds) {
        try {
          final doc = await firestore
              .collection('questions')
              .doc(questionId)
              .get();
          
          if (doc.exists) {
            _currentQuestions.add(QuestionModel.fromFirestore(doc));
          }
        } catch (e) {
          print('Failed to load question $questionId: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    if (_state == QuizSessionState.error) {
      _state = QuizSessionState.idle;
    }
    notifyListeners();
  }

  // Get formatted time string
  String get formattedTimeRemaining {
    final minutes = _remainingTimeSeconds ~/ 60;
    final seconds = _remainingTimeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Check if user can afford quiz
  bool canAffordQuiz(QuizModel quiz, int userCoins) {
    return !quiz.isPremium || userCoins >= quiz.coinCost;
  }
}