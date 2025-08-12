import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../../gamification/providers/gamification_provider.dart';

class QuizService extends ChangeNotifier {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GamificationProvider _gamificationProvider = GamificationProvider();

  // State
  List<Quiz> _availableQuizzes = [];
  List<QuizQuestion> _currentQuizQuestions = [];
  QuizAttempt? _currentAttempt;
  Map<String, int> _currentAnswers = {};
  int _currentQuestionIndex = 0;
  DateTime? _quizStartTime;
  bool _isLoading = false;

  // Getters
  List<Quiz> get availableQuizzes => _availableQuizzes;
  List<QuizQuestion> get currentQuizQuestions => _currentQuizQuestions;
  QuizAttempt? get currentAttempt => _currentAttempt;
  Map<String, int> get currentAnswers => _currentAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  bool get hasActiveQuiz => _currentAttempt != null && _currentAttempt!.isInProgress;

  QuizQuestion? get currentQuestion {
    if (_currentQuizQuestions.isEmpty || _currentQuestionIndex >= _currentQuizQuestions.length) {
      return null;
    }
    return _currentQuizQuestions[_currentQuestionIndex];
  }

  int get totalQuestions => _currentQuizQuestions.length;
  int get questionsAnswered => _currentAnswers.length;
  int get questionsRemaining => totalQuestions - questionsAnswered;
  double get progressPercentage => totalQuestions > 0 ? questionsAnswered / totalQuestions : 0.0;

  // Load available quizzes
  Future<void> loadAvailableQuizzes({String? category, String? difficulty}) async {
    try {
      _isLoading = true;
      notifyListeners();

      Query query = _firestore
          .collection('quizzes')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (difficulty != null && difficulty.isNotEmpty) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.get();
      _availableQuizzes = snapshot.docs
          .map((doc) => Quiz.fromFirestore(doc))
          .toList();

      debugPrint('✅ Loaded ${_availableQuizzes.length} quizzes');
    } catch (e) {
      debugPrint('❌ Error loading quizzes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start a quiz
  Future<bool> startQuiz(String quizId, String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load quiz
      final quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists) {
        throw Exception('Quiz not found');
      }

      final quiz = Quiz.fromFirestore(quizDoc);

      // Load questions
      final questionDocs = await _firestore
          .collection('quiz_questions')
          .where(FieldPath.documentId, whereIn: quiz.questionIds)
          .get();

      _currentQuizQuestions = questionDocs.docs
          .map((doc) => QuizQuestion.fromFirestore(doc))
          .toList();

      // Shuffle questions for variety
      _currentQuizQuestions.shuffle();

      // Create attempt
      _currentAttempt = QuizAttempt(
        id: _generateAttemptId(),
        userId: userId,
        quizId: quizId,
        answers: {},
        score: 0,
        totalQuestions: _currentQuizQuestions.length,
        correctAnswers: 0,
        percentage: 0.0,
        isPassed: false,
        startedAt: DateTime.now(),
        timeSpent: 0,
        status: 'in_progress',
      );

      // Save attempt to Firestore
      await _firestore
          .collection('quiz_attempts')
          .doc(_currentAttempt!.id)
          .set(_currentAttempt!.toFirestore());

      // Reset state
      _currentAnswers = {};
      _currentQuestionIndex = 0;
      _quizStartTime = DateTime.now();

      debugPrint('✅ Quiz started: ${quiz.title}');
      return true;
    } catch (e) {
      debugPrint('❌ Error starting quiz: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Answer current question
  Future<bool> answerQuestion(int selectedAnswerIndex) async {
    try {
      final question = currentQuestion;
      if (question == null || _currentAttempt == null) return false;

      // Store answer
      _currentAnswers[question.id] = selectedAnswerIndex;

      // Update attempt in Firestore
      await _firestore
          .collection('quiz_attempts')
          .doc(_currentAttempt!.id)
          .update({
        'answers': _currentAnswers,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Award points for gamification if correct
      final isCorrect = question.isCorrect(selectedAnswerIndex);
      if (isCorrect) {
        await _gamificationProvider.onQuestionAnswered(true, question.category);
      }

      debugPrint('📝 Question answered: ${isCorrect ? "✅ Correct" : "❌ Wrong"}');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error answering question: $e');
      return false;
    }
  }

  // Move to next question
  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuizQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Move to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Jump to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < _currentQuizQuestions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  // Check if question is answered
  bool isQuestionAnswered(String questionId) {
    return _currentAnswers.containsKey(questionId);
  }

  // Get answer for question
  int? getAnswerForQuestion(String questionId) {
    return _currentAnswers[questionId];
  }

  // Complete quiz
  Future<QuizAttempt?> completeQuiz() async {
    try {
      if (_currentAttempt == null) return null;

      _isLoading = true;
      notifyListeners();

      // Calculate results
      int correctAnswers = 0;
      int totalScore = 0;

      for (final question in _currentQuizQuestions) {
        final selectedAnswer = _currentAnswers[question.id];
        if (selectedAnswer != null && question.isCorrect(selectedAnswer)) {
          correctAnswers++;
          totalScore += question.points;
        }
      }

      final percentage = (correctAnswers / _currentQuizQuestions.length) * 100;
      final timeSpent = _quizStartTime != null 
          ? DateTime.now().difference(_quizStartTime!).inSeconds
          : 0;

      // Get quiz to check passing score
      final quizDoc = await _firestore
          .collection('quizzes')
          .doc(_currentAttempt!.quizId)
          .get();
      final quiz = Quiz.fromFirestore(quizDoc);
      final isPassed = percentage >= quiz.passingScore;

      // Update attempt
      final completedAttempt = QuizAttempt(
        id: _currentAttempt!.id,
        userId: _currentAttempt!.userId,
        quizId: _currentAttempt!.quizId,
        answers: _currentAnswers,
        score: totalScore,
        totalQuestions: _currentQuizQuestions.length,
        correctAnswers: correctAnswers,
        percentage: percentage,
        isPassed: isPassed,
        startedAt: _currentAttempt!.startedAt,
        completedAt: DateTime.now(),
        timeSpent: timeSpent,
        status: 'completed',
      );

      // Save to Firestore
      await _firestore
          .collection('quiz_attempts')
          .doc(completedAttempt.id)
          .update(completedAttempt.toFirestore());

      // Award completion points
      await _gamificationProvider.awardPoints(
        points: isPassed ? 50 : 25,
        reason: isPassed ? 'quiz_passed' : 'quiz_completed',
        referenceId: quiz.id,
      );

      _currentAttempt = completedAttempt;

      debugPrint('✅ Quiz completed: $correctAnswers/$totalQuestions (${percentage.toInt()}%)');
      return completedAttempt;
    } catch (e) {
      debugPrint('❌ Error completing quiz: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user's quiz history
  Future<List<QuizAttempt>> getUserQuizHistory(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => QuizAttempt.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading quiz history: $e');
      return [];
    }
  }

  // Get quiz statistics
  Future<QuizStats?> getQuizStats(String quizId) async {
    try {
      final doc = await _firestore
          .collection('quiz_stats')
          .doc(quizId)
          .get();

      if (!doc.exists) return null;
      return QuizStats.fromFirestore(doc);
    } catch (e) {
      debugPrint('❌ Error loading quiz stats: $e');
      return null;
    }
  }

  // Create a new quiz (admin function)
  Future<bool> createQuiz(Quiz quiz) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(quiz.id)
          .set(quiz.toFirestore());

      debugPrint('✅ Quiz created: ${quiz.title}');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating quiz: $e');
      return false;
    }
  }

  // Add question to quiz (admin function)
  Future<bool> addQuestionToQuiz(QuizQuestion question) async {
    try {
      await _firestore
          .collection('quiz_questions')
          .doc(question.id)
          .set(question.toFirestore());

      debugPrint('✅ Question added: ${question.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding question: $e');
      return false;
    }
  }

  // Reset current quiz
  void resetQuiz() {
    _currentAttempt = null;
    _currentQuizQuestions = [];
    _currentAnswers = {};
    _currentQuestionIndex = 0;
    _quizStartTime = null;
    notifyListeners();
  }

  // Generate unique attempt ID
  String _generateAttemptId() {
    return 'attempt_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Quick quiz categories
  List<String> get availableCategories {
    return _availableQuizzes
        .map((quiz) => quiz.category)
        .toSet()
        .toList()
      ..sort();
  }

  // Filter quizzes by category
  List<Quiz> getQuizzesByCategory(String category) {
    return _availableQuizzes
        .where((quiz) => quiz.category == category)
        .toList();
  }

  // Search quizzes
  List<Quiz> searchQuizzes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _availableQuizzes.where((quiz) {
      return quiz.title.toLowerCase().contains(lowercaseQuery) ||
          quiz.description.toLowerCase().contains(lowercaseQuery) ||
          quiz.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}