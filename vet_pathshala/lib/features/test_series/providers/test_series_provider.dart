import 'package:flutter/material.dart';
import '../models/test_series_model.dart';
import '../services/test_series_service.dart';

class TestSeriesProvider extends ChangeNotifier {
  final TestSeriesService _testSeriesService = TestSeriesService();
  
  List<TestSeries> _testSeries = [];
  List<TestSeries> _filteredTestSeries = [];
  List<TestQuestion> _currentTestQuestions = [];
  List<TestAttempt> _userAttempts = [];
  TestAttempt? _currentAttempt;
  
  String _selectedCategory = '';
  String _selectedSubject = '';
  String _selectedDifficulty = '';
  String _searchQuery = '';
  String _sortBy = 'created'; // created, popularity, difficulty
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TestSeries> get testSeries => _testSeries;
  List<TestSeries> get filteredTestSeries => _filteredTestSeries;
  List<TestQuestion> get currentTestQuestions => _currentTestQuestions;
  List<TestAttempt> get userAttempts => _userAttempts;
  TestAttempt? get currentAttempt => _currentAttempt;
  String get selectedCategory => _selectedCategory;
  String get selectedSubject => _selectedSubject;
  String get selectedDifficulty => _selectedDifficulty;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get available categories
  List<String> get availableCategories {
    return ['practice', 'mock', 'competitive'];
  }

  // Get available subjects
  List<String> get availableSubjects {
    return _testSeries.map((test) => test.subject).toSet().toList();
  }

  // Initialize test series data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadTestSeries();
      _applyFilters();
    } catch (e) {
      _setError('Failed to load test series: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load test series
  Future<void> _loadTestSeries() async {
    _testSeries = await _testSeriesService.getTestSeries();
    notifyListeners();
  }

  // Public method to load test series with role filter
  Future<void> loadTestSeries(String userRole) async {
    _setLoading(true);
    try {
      await _loadTestSeries();
      // Filter by role if needed
      _applyFilters();
    } catch (e) {
      _setError('Failed to load test series: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user attempts
  Future<void> loadUserAttempts(String userId) async {
    try {
      _userAttempts = await _testSeriesService.getUserTestAttempts(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading user attempts: $e');
    }
  }

  // Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Set subject filter
  void setSubject(String subject) {
    _selectedSubject = subject;
    _applyFilters();
    notifyListeners();
  }

  // Set difficulty filter
  void setDifficulty(String difficulty) {
    _selectedDifficulty = difficulty;
    _applyFilters();
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Set sort option
  void setSortBy(String sortOption) {
    _sortBy = sortOption;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _selectedCategory = '';
    _selectedSubject = '';
    _selectedDifficulty = '';
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Apply filters and sorting
  void _applyFilters() {
    _filteredTestSeries = _testSeries.where((test) {
      // Category filter
      if (_selectedCategory.isNotEmpty && test.category != _selectedCategory) {
        return false;
      }

      // Subject filter
      if (_selectedSubject.isNotEmpty && test.subject != _selectedSubject) {
        return false;
      }

      // Difficulty filter
      if (_selectedDifficulty.isNotEmpty && test.difficulty != _selectedDifficulty) {
        return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!test.title.toLowerCase().contains(query) &&
            !test.subject.toLowerCase().contains(query) &&
            !test.description.toLowerCase().contains(query) &&
            !test.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    _filteredTestSeries.sort((a, b) {
      switch (_sortBy) {
        case 'created':
          return b.createdDate.compareTo(a.createdDate);
        case 'popularity':
          return b.attempts.compareTo(a.attempts);
        case 'difficulty':
          const difficultyOrder = {'easy': 0, 'medium': 1, 'hard': 2};
          final aOrder = difficultyOrder[a.difficulty] ?? 1;
          final bOrder = difficultyOrder[b.difficulty] ?? 1;
          return aOrder.compareTo(bOrder);
        case 'score':
          return b.averageScore.compareTo(a.averageScore);
        default:
          return b.createdDate.compareTo(a.createdDate);
      }
    });
  }

  // Get test series by category
  List<TestSeries> getTestSeriesByCategory(String category) {
    return _testSeries.where((test) => test.category == category).toList();
  }

  // Start test
  Future<bool> startTest(String testSeriesId, String userId) async {
    try {
      _setLoading(true);
      
      // Load test questions
      _currentTestQuestions = await _testSeriesService.getTestQuestions(testSeriesId);
      
      // Create test attempt
      _currentAttempt = await _testSeriesService.startTestAttempt(testSeriesId, userId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to start test: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Submit answer
  void submitAnswer(String questionId, int answerIndex) {
    if (_currentAttempt == null) return;
    
    final updatedAnswers = Map<String, dynamic>.from(_currentAttempt!.answers);
    updatedAnswers[questionId] = answerIndex;
    
    _currentAttempt = TestAttempt(
      id: _currentAttempt!.id,
      testSeriesId: _currentAttempt!.testSeriesId,
      userId: _currentAttempt!.userId,
      startTime: _currentAttempt!.startTime,
      endTime: _currentAttempt!.endTime,
      score: _currentAttempt!.score,
      totalQuestions: _currentAttempt!.totalQuestions,
      correctAnswers: _currentAttempt!.correctAnswers,
      incorrectAnswers: _currentAttempt!.incorrectAnswers,
      skippedQuestions: _currentAttempt!.skippedQuestions,
      percentage: _currentAttempt!.percentage,
      answers: updatedAnswers,
      isCompleted: _currentAttempt!.isCompleted,
      timeSpent: _currentAttempt!.timeSpent,
    );
    
    notifyListeners();
  }

  // Submit test
  Future<bool> submitTest() async {
    if (_currentAttempt == null) return false;
    
    try {
      _setLoading(true);
      
      // Calculate score
      int correct = 0;
      int incorrect = 0;
      int skipped = 0;
      int totalScore = 0;
      
      for (final question in _currentTestQuestions) {
        final userAnswer = _currentAttempt!.answers[question.id];
        if (userAnswer == null) {
          skipped++;
        } else if (userAnswer == question.correctAnswerIndex) {
          correct++;
          totalScore += question.marks;
        } else {
          incorrect++;
        }
      }
      
      final percentage = _currentTestQuestions.isNotEmpty 
        ? (correct / _currentTestQuestions.length) * 100 
        : 0.0;
      
      final timeSpent = DateTime.now().difference(_currentAttempt!.startTime).inSeconds;
      
      // Update attempt with results
      _currentAttempt = TestAttempt(
        id: _currentAttempt!.id,
        testSeriesId: _currentAttempt!.testSeriesId,
        userId: _currentAttempt!.userId,
        startTime: _currentAttempt!.startTime,
        endTime: DateTime.now(),
        score: totalScore,
        totalQuestions: _currentTestQuestions.length,
        correctAnswers: correct,
        incorrectAnswers: incorrect,
        skippedQuestions: skipped,
        percentage: percentage,
        answers: _currentAttempt!.answers,
        isCompleted: true,
        timeSpent: timeSpent,
      );
      
      // Submit to service
      await _testSeriesService.submitTestAttempt(_currentAttempt!);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to submit test: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user's best score for a test
  double getUserBestScore(String testSeriesId) {
    final attempts = _userAttempts.where((attempt) => 
      attempt.testSeriesId == testSeriesId && attempt.isCompleted
    ).toList();
    
    if (attempts.isEmpty) return 0.0;
    
    return attempts.map((attempt) => attempt.percentage).reduce((a, b) => a > b ? a : b);
  }

  // Get user's attempt count for a test
  int getUserAttemptCount(String testSeriesId) {
    return _userAttempts.where((attempt) => 
      attempt.testSeriesId == testSeriesId
    ).length;
  }

  // Clear current test
  void clearCurrentTest() {
    _currentAttempt = null;
    _currentTestQuestions = [];
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}