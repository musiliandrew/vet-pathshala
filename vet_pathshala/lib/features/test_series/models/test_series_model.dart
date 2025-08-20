import 'package:cloud_firestore/cloud_firestore.dart';

class TestSeries {
  final String id;
  final String title;
  final String description;
  final String subject;
  final List<String> topics;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String category; // 'mock', 'practice', 'competitive'
  final int totalQuestions;
  final int duration; // in minutes
  final int maxMarks;
  final bool isPremium;
  final int coinCost;
  final DateTime createdDate;
  final DateTime? scheduledDate;
  final bool isLive;
  final int attempts;
  final double averageScore;
  final List<String> tags;
  final String thumbnailUrl;
  final String targetRole; // doctor, pharmacist, farmer
  final List<String> testIds; // List of individual test IDs
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  TestSeries({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.topics,
    required this.difficulty,
    required this.category,
    required this.totalQuestions,
    required this.duration,
    required this.maxMarks,
    this.isPremium = false,
    this.coinCost = 0,
    required this.createdDate,
    this.scheduledDate,
    this.isLive = false,
    this.attempts = 0,
    this.averageScore = 0.0,
    this.tags = const [],
    this.thumbnailUrl = '',
    required this.targetRole,
    this.testIds = const [],
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory TestSeries.fromJson(Map<String, dynamic> json) {
    return TestSeries(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      difficulty: json['difficulty'] ?? 'medium',
      category: json['category'] ?? 'practice',
      totalQuestions: json['totalQuestions'] ?? 0,
      duration: json['duration'] ?? 60,
      maxMarks: json['maxMarks'] ?? 100,
      isPremium: json['isPremium'] ?? false,
      coinCost: json['coinCost'] ?? 0,
      createdDate: DateTime.parse(json['createdDate'] ?? DateTime.now().toIso8601String()),
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : null,
      isLive: json['isLive'] ?? false,
      attempts: json['attempts'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'topics': topics,
      'difficulty': difficulty,
      'category': category,
      'totalQuestions': totalQuestions,
      'duration': duration,
      'maxMarks': maxMarks,
      'isPremium': isPremium,
      'coinCost': coinCost,
      'createdDate': createdDate.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'isLive': isLive,
      'attempts': attempts,
      'averageScore': averageScore,
      'tags': tags,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

class TestAttempt {
  final String id;
  final String testSeriesId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedQuestions;
  final double percentage;
  final Map<String, dynamic> answers; // questionId -> selectedAnswer
  final bool isCompleted;
  final int timeSpent; // in seconds

  TestAttempt({
    required this.id,
    required this.testSeriesId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.score = 0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.skippedQuestions = 0,
    this.percentage = 0.0,
    this.answers = const {},
    this.isCompleted = false,
    this.timeSpent = 0,
  });

  factory TestAttempt.fromJson(Map<String, dynamic> json) {
    return TestAttempt(
      id: json['id'] ?? '',
      testSeriesId: json['testSeriesId'] ?? '',
      userId: json['userId'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      incorrectAnswers: json['incorrectAnswers'] ?? 0,
      skippedQuestions: json['skippedQuestions'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      answers: Map<String, dynamic>.from(json['answers'] ?? {}),
      isCompleted: json['isCompleted'] ?? false,
      timeSpent: json['timeSpent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testSeriesId': testSeriesId,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'skippedQuestions': skippedQuestions,
      'percentage': percentage,
      'answers': answers,
      'isCompleted': isCompleted,
      'timeSpent': timeSpent,
    };
  }
}

class TestQuestion {
  final String id;
  final String testSeriesId;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String topic;
  final String difficulty;
  final int marks;
  final String imageUrl;

  TestQuestion({
    required this.id,
    required this.testSeriesId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
    this.topic = '',
    this.difficulty = 'medium',
    this.marks = 1,
    this.imageUrl = '',
  });

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    return TestQuestion(
      id: json['id'] ?? '',
      testSeriesId: json['testSeriesId'] ?? '',
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
      topic: json['topic'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      marks: json['marks'] ?? 1,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testSeriesId': testSeriesId,
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'topic': topic,
      'difficulty': difficulty,
      'marks': marks,
      'imageUrl': imageUrl,
    };
  }
}