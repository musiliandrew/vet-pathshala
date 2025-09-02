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
  
  // NEW: Scheduled release system
  final String batchYear; // e.g., '2025-2026'
  final String releaseSchedule; // 'daily', 'twice_daily', 'alternate_days', 'weekly'
  final List<ScheduledTest> scheduledTests; // Pre-added tests with release dates
  final String scheduleDocumentUrl; // PDF/Image URL for schedule
  final List<String> featureIds; // Features included in subscription
  final bool requiresSubscription; // Premium access control

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
    // NEW fields
    this.batchYear = '',
    this.releaseSchedule = 'daily',
    this.scheduledTests = const [],
    this.scheduleDocumentUrl = '',
    this.featureIds = const [],
    this.requiresSubscription = true,
  });

  factory TestSeries.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestSeries.fromJson({
      'id': doc.id,
      ...data,
    });
  }

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
      createdDate: json['createdDate'] is Timestamp 
          ? (json['createdDate'] as Timestamp).toDate()
          : DateTime.parse(json['createdDate'] ?? DateTime.now().toIso8601String()),
      scheduledDate: json['scheduledDate'] != null 
          ? (json['scheduledDate'] is Timestamp 
              ? (json['scheduledDate'] as Timestamp).toDate()
              : DateTime.parse(json['scheduledDate']))
          : null,
      isLive: json['isLive'] ?? false,
      attempts: json['attempts'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      targetRole: json['targetRole'] ?? 'doctor',
      testIds: List<String>.from(json['testIds'] ?? []),
      startDate: json['startDate'] is Timestamp 
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: json['endDate'] is Timestamp 
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.parse(json['endDate'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String()),
      isActive: json['isActive'] ?? true,
      // NEW fields
      batchYear: json['batchYear'] ?? '',
      releaseSchedule: json['releaseSchedule'] ?? 'daily',
      scheduledTests: (json['scheduledTests'] as List<dynamic>?)?.map((test) => ScheduledTest.fromJson(test)).toList() ?? [],
      scheduleDocumentUrl: json['scheduleDocumentUrl'] ?? '',
      featureIds: List<String>.from(json['featureIds'] ?? []),
      requiresSubscription: json['requiresSubscription'] ?? true,
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
      'targetRole': targetRole,
      'testIds': testIds,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      // NEW fields
      'batchYear': batchYear,
      'releaseSchedule': releaseSchedule,
      'scheduledTests': scheduledTests.map((test) => test.toJson()).toList(),
      'scheduleDocumentUrl': scheduleDocumentUrl,
      'featureIds': featureIds,
      'requiresSubscription': requiresSubscription,
    };
  }
  
  // Helper methods
  bool get isCurrentlyActive => 
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate) && isActive;
  
  List<ScheduledTest> get availableTests {
    final now = DateTime.now();
    return scheduledTests.where((test) => now.isAfter(test.releaseDate) || now.isAtSameMomentAs(test.releaseDate)).toList();
  }
  
  List<ScheduledTest> get upcomingTests {
    final now = DateTime.now();
    return scheduledTests.where((test) => now.isBefore(test.releaseDate)).toList();
  }
  
  int get availableTestsCount => availableTests.length;
  int get upcomingTestsCount => upcomingTests.length;
  
  ScheduledTest? get nextTest {
    final upcoming = upcomingTests;
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.releaseDate.compareTo(b.releaseDate));
    return upcoming.first;
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

  factory TestQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestQuestion.fromJson({
      'id': doc.id,
      ...data,
    });
  }

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

// NEW: Scheduled Test Model for Test Series with Timed Release
class ScheduledTest {
  final String id;
  final String testSeriesId;
  final String title;
  final String description;
  final DateTime releaseDate; // When this test becomes available
  final int sequenceNumber; // Order in the series (1, 2, 3...)
  final List<String> questionIds;
  final int duration; // in minutes
  final int maxMarks;
  final bool isReleased;
  final String testType; // 'daily', 'mock', 'weekly'
  final List<String> topics;
  final String difficulty;
  
  ScheduledTest({
    required this.id,
    required this.testSeriesId,
    required this.title,
    required this.description,
    required this.releaseDate,
    required this.sequenceNumber,
    this.questionIds = const [],
    this.duration = 60,
    this.maxMarks = 100,
    this.isReleased = false,
    this.testType = 'daily',
    this.topics = const [],
    this.difficulty = 'medium',
  });
  
  factory ScheduledTest.fromJson(Map<String, dynamic> json) {
    return ScheduledTest(
      id: json['id'] ?? '',
      testSeriesId: json['testSeriesId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      releaseDate: DateTime.parse(json['releaseDate'] ?? DateTime.now().toIso8601String()),
      sequenceNumber: json['sequenceNumber'] ?? 1,
      questionIds: List<String>.from(json['questionIds'] ?? []),
      duration: json['duration'] ?? 60,
      maxMarks: json['maxMarks'] ?? 100,
      isReleased: json['isReleased'] ?? false,
      testType: json['testType'] ?? 'daily',
      topics: List<String>.from(json['topics'] ?? []),
      difficulty: json['difficulty'] ?? 'medium',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testSeriesId': testSeriesId,
      'title': title,
      'description': description,
      'releaseDate': releaseDate.toIso8601String(),
      'sequenceNumber': sequenceNumber,
      'questionIds': questionIds,
      'duration': duration,
      'maxMarks': maxMarks,
      'isReleased': isReleased,
      'testType': testType,
      'topics': topics,
      'difficulty': difficulty,
    };
  }
  
  // Helper methods
  bool get isAvailable => DateTime.now().isAfter(releaseDate) || DateTime.now().isAtSameMomentAs(releaseDate);
  bool get isUpcoming => DateTime.now().isBefore(releaseDate);
  
  String get statusText {
    if (isAvailable) return 'Available Now';
    final hoursUntil = releaseDate.difference(DateTime.now()).inHours;
    if (hoursUntil < 24) return 'Releases in ${hoursUntil}h';
    final daysUntil = releaseDate.difference(DateTime.now()).inDays;
    return 'Releases in ${daysUntil}d';
  }
}