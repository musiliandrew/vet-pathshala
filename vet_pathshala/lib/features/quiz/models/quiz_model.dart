import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final String category;
  final String difficulty; // 'easy', 'medium', 'hard'
  final List<String> tags;
  final String? imageUrl;
  final int timeLimit; // seconds
  final int points;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    required this.category,
    this.difficulty = 'medium',
    this.tags = const [],
    this.imageUrl,
    this.timeLimit = 30,
    this.points = 10,
  });

  factory QuizQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizQuestion(
      id: doc.id,
      questionText: data['questionText'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
      explanation: data['explanation'],
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      tags: List<String>.from(data['tags'] ?? []),
      imageUrl: data['imageUrl'],
      timeLimit: data['timeLimit'] ?? 30,
      points: data['points'] ?? 10,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'category': category,
      'difficulty': difficulty,
      'tags': tags,
      'imageUrl': imageUrl,
      'timeLimit': timeLimit,
      'points': points,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  String get correctAnswer => options[correctAnswerIndex];
  bool isCorrect(int selectedIndex) => selectedIndex == correctAnswerIndex;
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final List<String> questionIds;
  final int timeLimit; // minutes
  final int passingScore; // percentage
  final bool isPublic;
  final String createdBy;
  final DateTime createdAt;
  final List<String> tags;
  final String? thumbnailUrl;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.difficulty = 'medium',
    required this.questionIds,
    this.timeLimit = 30,
    this.passingScore = 60,
    this.isPublic = true,
    required this.createdBy,
    required this.createdAt,
    this.tags = const [],
    this.thumbnailUrl,
  });

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quiz(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      questionIds: List<String>.from(data['questionIds'] ?? []),
      timeLimit: data['timeLimit'] ?? 30,
      passingScore: data['passingScore'] ?? 60,
      isPublic: data['isPublic'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      thumbnailUrl: data['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'questionIds': questionIds,
      'timeLimit': timeLimit,
      'passingScore': passingScore,
      'isPublic': isPublic,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  int get totalQuestions => questionIds.length;
  int get estimatedDuration => (questionIds.length * 1.5).ceil(); // minutes
}

class QuizAttempt {
  final String id;
  final String userId;
  final String quizId;
  final Map<String, int> answers; // questionId -> selectedIndex
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final double percentage;
  final bool isPassed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int timeSpent; // seconds
  final String status; // 'in_progress', 'completed', 'abandoned'

  QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.answers,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
    required this.isPassed,
    required this.startedAt,
    this.completedAt,
    required this.timeSpent,
    this.status = 'in_progress',
  });

  factory QuizAttempt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizAttempt(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      answers: Map<String, int>.from(data['answers'] ?? {}),
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      percentage: (data['percentage'] ?? 0).toDouble(),
      isPassed: data['isPassed'] ?? false,
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      timeSpent: data['timeSpent'] ?? 0,
      status: data['status'] ?? 'in_progress',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'quizId': quizId,
      'answers': answers,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'percentage': percentage,
      'isPassed': isPassed,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'timeSpent': timeSpent,
      'status': status,
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  String get formattedTime => '${(timeSpent / 60).floor()}:${(timeSpent % 60).toString().padLeft(2, '0')}';
}

class QuizStats {
  final String quizId;
  final int totalAttempts;
  final int completedAttempts;
  final double averageScore;
  final double passRate;
  final Map<String, int> difficultyBreakdown;
  final DateTime lastUpdated;

  QuizStats({
    required this.quizId,
    required this.totalAttempts,
    required this.completedAttempts,
    required this.averageScore,
    required this.passRate,
    required this.difficultyBreakdown,
    required this.lastUpdated,
  });

  factory QuizStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizStats(
      quizId: doc.id,
      totalAttempts: data['totalAttempts'] ?? 0,
      completedAttempts: data['completedAttempts'] ?? 0,
      averageScore: (data['averageScore'] ?? 0).toDouble(),
      passRate: (data['passRate'] ?? 0).toDouble(),
      difficultyBreakdown: Map<String, int>.from(data['difficultyBreakdown'] ?? {}),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  double get completionRate => totalAttempts > 0 ? completedAttempts / totalAttempts : 0.0;
  String get difficultyLabel {
    if (averageScore >= 80) return 'Easy';
    if (averageScore >= 60) return 'Medium';
    return 'Hard';
  }
}