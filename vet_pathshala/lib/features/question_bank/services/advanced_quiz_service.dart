import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/quiz_models.dart';
import '../../../shared/models/user_model.dart';

class AdvancedQuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  // Create a new quiz template
  Future<String> createQuiz(QuizModel quiz) async {
    try {
      final docRef = await _firestore.collection('quizzes').add(quiz.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create quiz: $e');
    }
  }

  // Get available quizzes for a role and category
  Future<List<QuizModel>> getQuizzes({
    required String userRole,
    String? category,
    QuizType? type,
    DifficultyLevel? difficulty,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('quizzes')
          .where('targetRole', isEqualTo: userRole)
          .where('isActive', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty.name);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get quizzes: $e');
    }
  }

  // Start a new quiz attempt
  Future<QuizAttemptModel> startQuiz({
    required String userId,
    required String quizId,
    required QuizModel quiz,
  }) async {
    try {
      // Generate questions from the pool
      final selectedQuestions = await _selectQuestionsFromPool(
        quiz.questionPool,
        quiz.questionCount,
      );

      final attempt = QuizAttemptModel(
        id: '', // Will be set by Firestore
        userId: userId,
        quizId: quizId,
        answers: [],
        startTime: DateTime.now(),
        totalQuestions: selectedQuestions.length,
        metadata: {
          'selectedQuestions': selectedQuestions,
          'quizType': quiz.type.name,
          'timeLimit': quiz.timeLimit,
        },
      );

      final docRef = await _firestore
          .collection('quiz_attempts')
          .add(attempt.toFirestore());

      return attempt.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to start quiz: $e');
    }
  }

  // Submit an answer during a quiz
  Future<void> submitQuizAnswer({
    required String attemptId,
    required String questionId,
    required int selectedAnswer,
    required int timeSpent,
  }) async {
    try {
      // Get the question to verify correct answer
      final questionDoc = await _firestore
          .collection('questions')
          .doc(questionId)
          .get();

      if (!questionDoc.exists) {
        throw Exception('Question not found');
      }

      final question = QuestionModel.fromFirestore(questionDoc);
      final isCorrect = question.correctAnswer == selectedAnswer;

      final answer = QuizAnswerModel(
        questionId: questionId,
        selectedAnswer: selectedAnswer,
        correctAnswer: question.correctAnswer,
        isCorrect: isCorrect,
        timeSpent: timeSpent,
        answeredAt: DateTime.now(),
      );

      // Update the attempt with the new answer
      await _firestore.collection('quiz_attempts').doc(attemptId).update({
        'answers': FieldValue.arrayUnion([answer.toMap()]),
      });
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  // Complete a quiz attempt and calculate final score
  Future<QuizAttemptModel> completeQuiz(String attemptId) async {
    try {
      final attemptDoc = await _firestore
          .collection('quiz_attempts')
          .doc(attemptId)
          .get();

      if (!attemptDoc.exists) {
        throw Exception('Quiz attempt not found');
      }

      final attempt = QuizAttemptModel.fromFirestore(attemptDoc);
      final correctAnswers = attempt.answers.where((a) => a.isCorrect).length;
      final totalTime = attempt.answers.fold<int>(
        0,
        (sum, answer) => sum + answer.timeSpent,
      );

      final accuracy = attempt.totalQuestions > 0
          ? correctAnswers / attempt.totalQuestions
          : 0.0;

      // Calculate advanced scoring with time bonus
      final baseScore = (correctAnswers * 100) ~/ attempt.totalQuestions;
      final timeBonus = _calculateTimeBonus(totalTime, attempt.totalQuestions);
      final finalScore = (baseScore + timeBonus).clamp(0, 100);

      final completedAttempt = QuizAttemptModel(
        id: attempt.id,
        userId: attempt.userId,
        quizId: attempt.quizId,
        answers: attempt.answers,
        startTime: attempt.startTime,
        endTime: DateTime.now(),
        timeSpent: totalTime,
        score: finalScore,
        totalQuestions: attempt.totalQuestions,
        accuracy: accuracy,
        isCompleted: true,
        metadata: attempt.metadata,
      );

      // Update the attempt in Firestore
      await _firestore
          .collection('quiz_attempts')
          .doc(attemptId)
          .update(completedAttempt.toFirestore());

      // Update user statistics
      await _updateUserQuizStats(attempt.userId, completedAttempt);

      return completedAttempt;
    } catch (e) {
      throw Exception('Failed to complete quiz: $e');
    }
  }

  // Get user's quiz attempts history
  Future<List<QuizAttemptModel>> getUserAttempts({
    required String userId,
    String? quizId,
    bool completedOnly = false,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId);

      if (quizId != null) {
        query = query.where('quizId', isEqualTo: quizId);
      }

      if (completedOnly) {
        query = query.where('isCompleted', isEqualTo: true);
      }

      final snapshot = await query
          .orderBy('startTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => QuizAttemptModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user attempts: $e');
    }
  }

  // Create a quiz battle challenge
  Future<String> createQuizBattle({
    required String challengerId,
    required String category,
    String? opponentId,
    int coinReward = 10,
  }) async {
    try {
      // Find a suitable quiz for the battle
      final availableQuizzes = await getQuizzes(
        userRole: 'doctor', // This should be dynamic based on challenger's role
        category: category,
        type: QuizType.battle,
      );

      if (availableQuizzes.isEmpty) {
        throw Exception('No battle quizzes available for this category');
      }

      final selectedQuiz = availableQuizzes[_random.nextInt(availableQuizzes.length)];

      final battle = QuizBattleModel(
        id: '',
        challengerId: challengerId,
        opponentId: opponentId,
        quizId: selectedQuiz.id,
        category: category,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        coinReward: coinReward,
      );

      final docRef = await _firestore
          .collection('quiz_battles')
          .add(battle.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create quiz battle: $e');
    }
  }

  // Join a quiz battle
  Future<void> joinQuizBattle({
    required String battleId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('quiz_battles').doc(battleId).update({
        'opponentId': userId,
      });
    } catch (e) {
      throw Exception('Failed to join quiz battle: $e');
    }
  }

  // Get available quiz battles
  Future<List<QuizBattleModel>> getAvailableBattles({
    required String userId,
    String? category,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection('quiz_battles')
          .where('isCompleted', isEqualTo: false)
          .where('challengerId', isNotEqualTo: userId);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => QuizBattleModel.fromFirestore(doc))
          .where((battle) => 
            battle.opponentId == null || battle.opponentId == userId)
          .toList();
    } catch (e) {
      throw Exception('Failed to get available battles: $e');
    }
  }

  // Get leaderboard for a specific quiz or category
  Future<List<Map<String, dynamic>>> getLeaderboard({
    String? quizId,
    String? category,
    String? targetRole,
    Duration period = const Duration(days: 30),
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection('quiz_attempts')
          .where('isCompleted', isEqualTo: true);

      if (quizId != null) {
        query = query.where('quizId', isEqualTo: quizId);
      }

      // Filter by time period
      final cutoffDate = DateTime.now().subtract(period);
      query = query.where('endTime', isGreaterThan: Timestamp.fromDate(cutoffDate));

      final snapshot = await query
          .orderBy('score', descending: true)
          .orderBy('timeSpent', descending: false)
          .limit(limit * 2) // Get more to filter duplicates
          .get();

      // Group by user and get best score for each
      final userBestScores = <String, Map<String, dynamic>>{};
      
      for (final doc in snapshot.docs) {
        final attempt = QuizAttemptModel.fromFirestore(doc);
        
        if (!userBestScores.containsKey(attempt.userId) ||
            userBestScores[attempt.userId]!['score'] < attempt.score) {
          
          // Get user details
          final userDoc = await _firestore
              .collection('users')
              .doc(attempt.userId)
              .get();
          
          if (userDoc.exists) {
            final user = UserModel.fromFirestore(userDoc);
            userBestScores[attempt.userId] = {
              'userId': attempt.userId,
              'displayName': user.displayName,
              'userRole': user.userRole,
              'score': attempt.score,
              'accuracy': attempt.accuracy,
              'timeSpent': attempt.timeSpent,
              'attempts': 1,
            };
          }
        }
      }

      // Sort and return top performers
      final leaderboard = userBestScores.values.toList();
      leaderboard.sort((a, b) {
        final scoreComparison = b['score'].compareTo(a['score']);
        if (scoreComparison != 0) return scoreComparison;
        return a['timeSpent'].compareTo(b['timeSpent']);
      });

      return leaderboard.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
  }

  // Private helper methods
  Future<List<String>> _selectQuestionsFromPool(
    List<String> questionPool,
    int count,
  ) async {
    try {
      if (questionPool.length <= count) {
        return questionPool;
      }

      // Randomly select questions from the pool
      final shuffled = List<String>.from(questionPool)..shuffle(_random);
      return shuffled.take(count).toList();
    } catch (e) {
      throw Exception('Failed to select questions: $e');
    }
  }

  int _calculateTimeBonus(int totalTimeSeconds, int questionCount) {
    // Calculate average time per question
    final avgTimePerQuestion = totalTimeSeconds / questionCount;
    
    // Bonus for answering quickly (max 10 points)
    // Optimal time is 30 seconds per question
    const optimalTimePerQuestion = 30;
    
    if (avgTimePerQuestion <= optimalTimePerQuestion) {
      final efficiency = optimalTimePerQuestion / avgTimePerQuestion;
      return (efficiency * 10).clamp(0, 10).toInt();
    }
    
    return 0;
  }

  Future<void> _updateUserQuizStats(
    String userId,
    QuizAttemptModel attempt,
  ) async {
    try {
      final statsDoc = await _firestore
          .collection('user_quiz_stats')
          .doc('${userId}_${attempt.metadata['quizType']}')
          .get();

      if (statsDoc.exists) {
        // Update existing stats
        final currentStats = QuizStatsModel.fromFirestore(statsDoc);
        
        final updatedStats = QuizStatsModel(
          userId: userId,
          category: attempt.metadata['category'] ?? '',
          totalAttempts: currentStats.totalAttempts + 1,
          bestScore: math.max(currentStats.bestScore, attempt.score),
          averageScore: (currentStats.averageScore * currentStats.totalAttempts + attempt.score) 
              / (currentStats.totalAttempts + 1),
          totalTimeSpent: currentStats.totalTimeSpent + attempt.timeSpent,
          fastestTime: currentStats.fastestTime == 0 
              ? attempt.timeSpent 
              : math.min(currentStats.fastestTime, attempt.timeSpent),
          difficultyBreakdown: currentStats.difficultyBreakdown,
          lastAttempt: attempt.endTime ?? DateTime.now(),
        );

        await _firestore
            .collection('user_quiz_stats')
            .doc('${userId}_${attempt.metadata['quizType']}')
            .update(updatedStats.toFirestore());
      } else {
        // Create new stats
        final newStats = QuizStatsModel(
          userId: userId,
          category: attempt.metadata['category'] ?? '',
          totalAttempts: 1,
          bestScore: attempt.score,
          averageScore: attempt.score.toDouble(),
          totalTimeSpent: attempt.timeSpent,
          fastestTime: attempt.timeSpent,
          lastAttempt: attempt.endTime ?? DateTime.now(),
        );

        await _firestore
            .collection('user_quiz_stats')
            .doc('${userId}_${attempt.metadata['quizType']}')
            .set(newStats.toFirestore());
      }
    } catch (e) {
      print('Failed to update user quiz stats: $e');
    }
  }
}

// Extension method for QuizAttemptModel
extension QuizAttemptModelExtension on QuizAttemptModel {
  QuizAttemptModel copyWith({
    String? id,
    String? userId,
    String? quizId,
    List<QuizAnswerModel>? answers,
    DateTime? startTime,
    DateTime? endTime,
    int? timeSpent,
    int? score,
    int? totalQuestions,
    double? accuracy,
    bool? isCompleted,
    Map<String, dynamic>? metadata,
  }) {
    return QuizAttemptModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      answers: answers ?? this.answers,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeSpent: timeSpent ?? this.timeSpent,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      accuracy: accuracy ?? this.accuracy,
      isCompleted: isCompleted ?? this.isCompleted,
      metadata: metadata ?? this.metadata,
    );
  }
}