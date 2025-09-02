import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> topics;
  final int totalQuestions;
  final String difficulty;
  final bool isPremium;
  final int coinCost;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    this.icon = '',
    this.topics = const [],
    this.totalQuestions = 0,
    this.difficulty = 'medium',
    this.isPremium = false,
    this.coinCost = 0,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      totalQuestions: json['totalQuestions'] ?? 0,
      difficulty: json['difficulty'] ?? 'medium',
      isPremium: json['isPremium'] ?? false,
      coinCost: json['coinCost'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'topics': topics,
      'totalQuestions': totalQuestions,
      'difficulty': difficulty,
      'isPremium': isPremium,
      'coinCost': coinCost,
    };
  }
}

class Topic {
  final String id;
  final String name;
  final String subjectId;
  final String description;
  final List<String> subtopics;
  final int totalQuestions;
  final String difficulty;
  final bool isPremium;
  final int coinCost;

  Topic({
    required this.id,
    required this.name,
    required this.subjectId,
    this.description = '',
    this.subtopics = const [],
    this.totalQuestions = 0,
    this.difficulty = 'medium',
    this.isPremium = false,
    this.coinCost = 0,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subjectId: json['subjectId'] ?? '',
      description: json['description'] ?? '',
      subtopics: List<String>.from(json['subtopics'] ?? []),
      totalQuestions: json['totalQuestions'] ?? 0,
      difficulty: json['difficulty'] ?? 'medium',
      isPremium: json['isPremium'] ?? false,
      coinCost: json['coinCost'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subjectId': subjectId,
      'description': description,
      'subtopics': subtopics,
      'totalQuestions': totalQuestions,
      'difficulty': difficulty,
      'isPremium': isPremium,
      'coinCost': coinCost,
    };
  }
}

class Question {
  final String id;
  final String subjectId;
  final String topicId;
  final String subtopicId;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String difficulty;
  final int marks;
  final String imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final bool isActive;

  Question({
    required this.id,
    required this.subjectId,
    required this.topicId,
    this.subtopicId = '',
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
    this.difficulty = 'medium',
    this.marks = 1,
    this.imageUrl = '',
    this.tags = const [],
    required this.createdAt,
    this.isActive = true,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      subjectId: json['subjectId'] ?? '',
      topicId: json['topicId'] ?? '',
      subtopicId: json['subtopicId'] ?? '',
      questionText: json['questionText'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      marks: json['marks'] ?? 1,
      imageUrl: json['imageUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'topicId': topicId,
      'subtopicId': subtopicId,
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'difficulty': difficulty,
      'marks': marks,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class QuestionBankAttempt {
  final String id;
  final String userId;
  final String questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final int timeSpent;
  final DateTime attemptedAt;

  QuestionBankAttempt({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    this.timeSpent = 0,
    required this.attemptedAt,
  });

  factory QuestionBankAttempt.fromJson(Map<String, dynamic> json) {
    return QuestionBankAttempt(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      questionId: json['questionId'] ?? '',
      selectedAnswer: json['selectedAnswer'] ?? -1,
      isCorrect: json['isCorrect'] ?? false,
      timeSpent: json['timeSpent'] ?? 0,
      attemptedAt: DateTime.parse(json['attemptedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'attemptedAt': attemptedAt.toIso8601String(),
    };
  }
}