import 'package:cloud_firestore/cloud_firestore.dart';

enum QuizType { 
  practice,    // Basic practice mode
  timed,       // Timed quiz with countdown
  battle,      // Social quiz battles
  challenge,   // Daily/weekly challenges
  mock_exam    // Full mock examinations
}

enum DifficultyLevel {
  novice,
  beginner,
  intermediate,
  advanced,
  expert
}

class QuizModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final QuizType type;
  final DifficultyLevel difficulty;
  final String targetRole;
  final int timeLimit; // in seconds, 0 for unlimited
  final int questionCount;
  final int coinCost;
  final bool isPremium;
  final List<String> questionPool; // Question IDs
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final String authorId;
  final bool isActive;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.difficulty,
    required this.targetRole,
    this.timeLimit = 0,
    required this.questionCount,
    this.coinCost = 0,
    this.isPremium = false,
    required this.questionPool,
    this.settings = const {},
    required this.createdAt,
    required this.authorId,
    this.isActive = true,
  });

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      type: QuizType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => QuizType.practice,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == data['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      targetRole: data['targetRole'] ?? 'doctor',
      timeLimit: data['timeLimit'] ?? 0,
      questionCount: data['questionCount'] ?? 10,
      coinCost: data['coinCost'] ?? 0,
      isPremium: data['isPremium'] ?? false,
      questionPool: List<String>.from(data['questionPool'] ?? []),
      settings: data['settings'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      authorId: data['authorId'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'type': type.name,
      'difficulty': difficulty.name,
      'targetRole': targetRole,
      'timeLimit': timeLimit,
      'questionCount': questionCount,
      'coinCost': coinCost,
      'isPremium': isPremium,
      'questionPool': questionPool,
      'settings': settings,
      'createdAt': Timestamp.fromDate(createdAt),
      'authorId': authorId,
      'isActive': isActive,
    };
  }
}

class QuizAttemptModel {
  final String id;
  final String userId;
  final String quizId;
  final List<QuizAnswerModel> answers;
  final DateTime startTime;
  final DateTime? endTime;
  final int timeSpent; // in seconds
  final int score;
  final int totalQuestions;
  final double accuracy;
  final bool isCompleted;
  final Map<String, dynamic> metadata;

  QuizAttemptModel({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.answers,
    required this.startTime,
    this.endTime,
    this.timeSpent = 0,
    this.score = 0,
    required this.totalQuestions,
    this.accuracy = 0.0,
    this.isCompleted = false,
    this.metadata = const {},
  });

  factory QuizAttemptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizAttemptModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      answers: (data['answers'] as List<dynamic>? ?? [])
          .map((a) => QuizAnswerModel.fromMap(a))
          .toList(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      timeSpent: data['timeSpent'] ?? 0,
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      accuracy: (data['accuracy'] ?? 0.0).toDouble(),
      isCompleted: data['isCompleted'] ?? false,
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'quizId': quizId,
      'answers': answers.map((a) => a.toMap()).toList(),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'timeSpent': timeSpent,
      'score': score,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'isCompleted': isCompleted,
      'metadata': metadata,
    };
  }
}

class QuizAnswerModel {
  final String questionId;
  final int selectedAnswer;
  final int correctAnswer;
  final bool isCorrect;
  final int timeSpent; // in seconds
  final DateTime answeredAt;

  QuizAnswerModel({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.timeSpent = 0,
    required this.answeredAt,
  });

  factory QuizAnswerModel.fromMap(Map<String, dynamic> map) {
    return QuizAnswerModel(
      questionId: map['questionId'] ?? '',
      selectedAnswer: map['selectedAnswer'] ?? 0,
      correctAnswer: map['correctAnswer'] ?? 0,
      isCorrect: map['isCorrect'] ?? false,
      timeSpent: map['timeSpent'] ?? 0,
      answeredAt: (map['answeredAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'answeredAt': Timestamp.fromDate(answeredAt),
    };
  }
}

class QuizBattleModel {
  final String id;
  final String challengerId;
  final String? opponentId;
  final String quizId;
  final String category;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, QuizAttemptModel> attempts; // userId -> attempt
  final String? winnerId;
  final bool isCompleted;
  final int coinReward;

  QuizBattleModel({
    required this.id,
    required this.challengerId,
    this.opponentId,
    required this.quizId,
    required this.category,
    required this.createdAt,
    this.expiresAt,
    this.attempts = const {},
    this.winnerId,
    this.isCompleted = false,
    this.coinReward = 10,
  });

  factory QuizBattleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizBattleModel(
      id: doc.id,
      challengerId: data['challengerId'] ?? '',
      opponentId: data['opponentId'],
      quizId: data['quizId'] ?? '',
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      attempts: (data['attempts'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, QuizAttemptModel.fromFirestore(
          FakeDocumentSnapshot(value, key),
        )),
      ),
      winnerId: data['winnerId'],
      isCompleted: data['isCompleted'] ?? false,
      coinReward: data['coinReward'] ?? 10,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challengerId': challengerId,
      'opponentId': opponentId,
      'quizId': quizId,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'attempts': attempts.map((key, value) => MapEntry(key, value.toFirestore())),
      'winnerId': winnerId,
      'isCompleted': isCompleted,
      'coinReward': coinReward,
    };
  }
}

// Helper class for creating fake document snapshots
class FakeDocumentSnapshot implements DocumentSnapshot {
  final Map<String, dynamic> _data;
  final String _id;

  FakeDocumentSnapshot(this._data, this._id);

  @override
  dynamic data() => _data;

  @override
  String get id => _id;

  @override
  bool get exists => _data.isNotEmpty;

  // Other DocumentSnapshot methods not implemented for this use case
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Quiz statistics and performance tracking
class QuizStatsModel {
  final String userId;
  final String category;
  final int totalAttempts;
  final int bestScore;
  final double averageScore;
  final int totalTimeSpent;
  final int fastestTime;
  final Map<DifficultyLevel, int> difficultyBreakdown;
  final DateTime lastAttempt;

  QuizStatsModel({
    required this.userId,
    required this.category,
    this.totalAttempts = 0,
    this.bestScore = 0,
    this.averageScore = 0.0,
    this.totalTimeSpent = 0,
    this.fastestTime = 0,
    this.difficultyBreakdown = const {},
    required this.lastAttempt,
  });

  factory QuizStatsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizStatsModel(
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      totalAttempts: data['totalAttempts'] ?? 0,
      bestScore: data['bestScore'] ?? 0,
      averageScore: (data['averageScore'] ?? 0.0).toDouble(),
      totalTimeSpent: data['totalTimeSpent'] ?? 0,
      fastestTime: data['fastestTime'] ?? 0,
      difficultyBreakdown: (data['difficultyBreakdown'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(
            DifficultyLevel.values.firstWhere((e) => e.name == key),
            value as int,
          )),
      lastAttempt: (data['lastAttempt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'totalAttempts': totalAttempts,
      'bestScore': bestScore,
      'averageScore': averageScore,
      'totalTimeSpent': totalTimeSpent,
      'fastestTime': fastestTime,
      'difficultyBreakdown': difficultyBreakdown.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'lastAttempt': Timestamp.fromDate(lastAttempt),
    };
  }
}