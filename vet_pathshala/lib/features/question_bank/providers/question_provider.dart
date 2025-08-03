import 'package:flutter/foundation.dart';
import '../../../shared/models/user_model.dart';
import '../services/question_service.dart';

enum QuestionBankState { initial, loading, loaded, error }

class QuestionProvider extends ChangeNotifier {
  final QuestionService _questionService = QuestionService();

  QuestionBankState _state = QuestionBankState.initial;
  List<QuestionModel> _questions = [];
  List<String> _categories = [];
  Map<String, dynamic> _userStats = {};
  String? _errorMessage;
  String _selectedCategory = '';
  String _selectedDifficulty = '';
  String _searchQuery = '';

  // Getters
  QuestionBankState get state => _state;
  List<QuestionModel> get questions => _questions;
  List<String> get categories => _categories;
  Map<String, dynamic> get userStats => _userStats;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get selectedDifficulty => _selectedDifficulty;
  String get searchQuery => _searchQuery;
  bool get isLoading => _state == QuestionBankState.loading;

  // Load categories for user role
  Future<void> loadCategories(String userRole) async {
    try {
      _setState(QuestionBankState.loading);
      _categories = await _questionService.getCategoriesByRole(userRole);
      _setState(QuestionBankState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load questions by category
  Future<void> loadQuestionsByCategory({
    required String category,
    required String userRole,
  }) async {
    try {
      _setState(QuestionBankState.loading);
      _selectedCategory = category;
      _questions = await _questionService.getQuestionsByCategory(
        category: category,
        userRole: userRole,
      );
      _setState(QuestionBankState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load questions by difficulty
  Future<void> loadQuestionsByDifficulty({
    required String difficulty,
    required String userRole,
  }) async {
    try {
      _setState(QuestionBankState.loading);
      _selectedDifficulty = difficulty;
      _questions = await _questionService.getQuestionsByDifficulty(
        difficulty: difficulty,
        userRole: userRole,
      );
      _setState(QuestionBankState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Search questions
  Future<void> searchQuestions({
    required String query,
    required String userRole,
  }) async {
    try {
      _setState(QuestionBankState.loading);
      _searchQuery = query;
      if (query.isEmpty) {
        _questions = [];
        _setState(QuestionBankState.loaded);
        return;
      }
      
      _questions = await _questionService.searchQuestions(
        searchQuery: query,
        userRole: userRole,
      );
      _setState(QuestionBankState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Get random questions for practice
  Future<List<QuestionModel>> getRandomQuestions({
    required String userRole,
    String? category,
    String? difficulty,
    int count = 10,
  }) async {
    try {
      return await _questionService.getRandomQuestions(
        userRole: userRole,
        category: category,
        difficulty: difficulty,
        count: count,
      );
    } catch (e) {
      throw Exception('Failed to get random questions: $e');
    }
  }

  // Submit answer
  Future<bool> submitAnswer({
    required String questionId,
    required int selectedAnswer,
    required String userId,
  }) async {
    try {
      return await _questionService.submitAnswer(
        questionId: questionId,
        selectedAnswer: selectedAnswer,
        userId: userId,
      );
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  // Load user statistics
  Future<void> loadUserStatistics(String userId) async {
    try {
      _userStats = await _questionService.getUserStatistics(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading user statistics: $e');
    }
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = '';
    _selectedDifficulty = '';
    _searchQuery = '';
    _questions = [];
    _setState(QuestionBankState.initial);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(QuestionBankState newState) {
    _state = newState;
    if (newState != QuestionBankState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _state = QuestionBankState.error;
    _errorMessage = error;
    notifyListeners();
  }
}