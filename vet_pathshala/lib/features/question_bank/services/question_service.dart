import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/user_model.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get questions filtered by category and role
  Future<List<QuestionModel>> getQuestionsByCategory({
    required String category,
    required String userRole,
    int limit = 20,
  }) async {
    try {
      final query = await _firestore
          .collection('questions')
          .where('category', isEqualTo: category)
          .where('targetRole', isEqualTo: userRole)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  // Get questions by difficulty level
  Future<List<QuestionModel>> getQuestionsByDifficulty({
    required String difficulty,
    required String userRole,
    int limit = 20,
  }) async {
    try {
      final query = await _firestore
          .collection('questions')
          .where('difficulty', isEqualTo: difficulty)
          .where('targetRole', isEqualTo: userRole)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load questions by difficulty: $e');
    }
  }

  // Search questions by text
  Future<List<QuestionModel>> searchQuestions({
    required String searchQuery,
    required String userRole,
    int limit = 20,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation - for production, consider using Algolia
      final query = await _firestore
          .collection('questions')
          .where('targetRole', isEqualTo: userRole)
          .orderBy('createdAt', descending: true)
          .limit(100) // Get more to filter locally
          .get();

      final allQuestions = query.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();

      // Filter by search query locally
      return allQuestions
          .where((question) =>
              question.questionText.toLowerCase().contains(searchQuery.toLowerCase()) ||
              question.category.toLowerCase().contains(searchQuery.toLowerCase()))
          .take(limit)
          .toList();
    } catch (e) {
      throw Exception('Failed to search questions: $e');
    }
  }

  // Get all categories for a specific role
  Future<List<String>> getCategoriesByRole(String userRole) async {
    try {
      final query = await _firestore
          .collection('questions')
          .where('targetRole', isEqualTo: userRole)
          .get();

      final categories = query.docs
          .map((doc) => doc.data()['category'] as String)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      throw Exception('Failed to load categories: $e');
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
      Query query = _firestore
          .collection('questions')
          .where('targetRole', isEqualTo: userRole);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (difficulty != null && difficulty.isNotEmpty) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.limit(count * 3).get(); // Get more for randomization
      final questions = snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();

      // Shuffle and return requested count
      questions.shuffle();
      return questions.take(count).toList();
    } catch (e) {
      throw Exception('Failed to get random questions: $e');
    }
  }

  // Submit answer and calculate score
  Future<bool> submitAnswer({
    required String questionId,
    required int selectedAnswer,
    required String userId,
  }) async {
    try {
      // Get the question to check correct answer
      final questionDoc = await _firestore
          .collection('questions')
          .doc(questionId)
          .get();

      if (!questionDoc.exists) {
        throw Exception('Question not found');
      }

      final question = QuestionModel.fromFirestore(questionDoc);
      final isCorrect = question.correctAnswer == selectedAnswer;

      // Record the answer
      await _firestore.collection('user_answers').add({
        'userId': userId,
        'questionId': questionId,
        'selectedAnswer': selectedAnswer,
        'correctAnswer': question.correctAnswer,
        'isCorrect': isCorrect,
        'timestamp': FieldValue.serverTimestamp(),
        'category': question.category,
        'difficulty': question.difficulty,
        'targetRole': question.targetRole,
      });

      return isCorrect;
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  // Get user's answer history
  Future<List<Map<String, dynamic>>> getUserAnswerHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final query = await _firestore
          .collection('user_answers')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to load answer history: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final query = await _firestore
          .collection('user_answers')
          .where('userId', isEqualTo: userId)
          .get();

      final answers = query.docs;
      final correctAnswers = answers.where((doc) => doc.data()['isCorrect'] == true).length;
      final totalAnswers = answers.length;
      
      // Calculate category-wise performance
      final categoryStats = <String, Map<String, int>>{};
      for (final doc in answers) {
        final category = doc.data()['category'] as String;
        final isCorrect = doc.data()['isCorrect'] as bool;
        
        categoryStats[category] ??= {'correct': 0, 'total': 0};
        categoryStats[category]!['total'] = categoryStats[category]!['total']! + 1;
        if (isCorrect) {
          categoryStats[category]!['correct'] = categoryStats[category]!['correct']! + 1;
        }
      }

      return {
        'totalQuestions': totalAnswers,
        'correctAnswers': correctAnswers,
        'accuracy': totalAnswers > 0 ? (correctAnswers / totalAnswers * 100).round() : 0,
        'categoryStats': categoryStats,
      };
    } catch (e) {
      throw Exception('Failed to load user statistics: $e');
    }
  }
}