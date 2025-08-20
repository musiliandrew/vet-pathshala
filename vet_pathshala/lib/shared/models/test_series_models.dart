import 'package:cloud_firestore/cloud_firestore.dart';

// Test Series Models
class TestSeriesModel {
  final String id;
  final String title;
  final String description;
  final String category; // e.g., "Anatomy", "Pharmacology"
  final String targetRole; // "doctor", "pharmacist", "farmer"
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isFeatured;
  final String imageUrl;
  final int totalTests;
  final int totalQuestions;
  final int totalDuration; // in minutes
  final List<String> testIds; // References to individual tests
  final Map<String, dynamic> metadata;

  TestSeriesModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetRole,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.isFeatured,
    required this.imageUrl,
    required this.totalTests,
    required this.totalQuestions,
    required this.totalDuration,
    required this.testIds,
    required this.metadata,
  });

  factory TestSeriesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestSeriesModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      targetRole: data['targetRole'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
      totalTests: data['totalTests'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      totalDuration: data['totalDuration'] ?? 0,
      testIds: List<String>.from(data['testIds'] ?? []),
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'targetRole': targetRole,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'isFeatured': isFeatured,
      'imageUrl': imageUrl,
      'totalTests': totalTests,
      'totalQuestions': totalQuestions,
      'totalDuration': totalDuration,
      'testIds': testIds,
      'metadata': metadata,
    };
  }
}

// Individual Test Model
class TestModel {
  final String id;
  final String seriesId; // Reference to parent test series
  final String title;
  final String description;
  final DateTime scheduledDate;
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // in minutes
  final int totalQuestions;
  final int totalMarks;
  final List<String> questionIds;
  final bool isPublished;
  final bool isLive;
  final TestType testType;
  final Map<String, dynamic> instructions;
  final Map<String, dynamic> metadata;

  TestModel({
    required this.id,
    required this.seriesId,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalQuestions,
    required this.totalMarks,
    required this.questionIds,
    required this.isPublished,
    required this.isLive,
    required this.testType,
    required this.instructions,
    required this.metadata,
  });

  factory TestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestModel(
      id: doc.id,
      seriesId: data['seriesId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      scheduledDate: (data['scheduledDate'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      duration: data['duration'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      totalMarks: data['totalMarks'] ?? 0,
      questionIds: List<String>.from(data['questionIds'] ?? []),
      isPublished: data['isPublished'] ?? false,
      isLive: data['isLive'] ?? false,
      testType: TestType.values.firstWhere(
        (e) => e.name == data['testType'],
        orElse: () => TestType.practice,
      ),
      instructions: data['instructions'] ?? {},
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'seriesId': seriesId,
      'title': title,
      'description': description,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'duration': duration,
      'totalQuestions': totalQuestions,
      'totalMarks': totalMarks,
      'questionIds': questionIds,
      'isPublished': isPublished,
      'isLive': isLive,
      'testType': testType.name,
      'instructions': instructions,
      'metadata': metadata,
    };
  }

  bool get isAvailable {
    final now = DateTime.now();
    return isPublished && now.isAfter(scheduledDate);
  }

  bool get isOngoing {
    final now = DateTime.now();
    return isLive && now.isAfter(startTime) && now.isBefore(endTime);
  }
}

// Test Attempt Model
class TestAttemptModel {
  final String id;
  final String userId;
  final String testId;
  final String seriesId;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final int timeSpent; // in seconds
  final int totalMarks;
  final int obtainedMarks;
  final double percentage;
  final List<TestAnswerModel> answers;
  final int rank;
  final bool isCompleted;
  final Map<String, dynamic> breakdown; // category-wise marks
  final Map<String, dynamic> metadata;

  TestAttemptModel({
    required this.id,
    required this.userId,
    required this.testId,
    required this.seriesId,
    required this.startedAt,
    this.submittedAt,
    required this.timeSpent,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.percentage,
    required this.answers,
    required this.rank,
    required this.isCompleted,
    required this.breakdown,
    required this.metadata,
  });

  factory TestAttemptModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestAttemptModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      testId: data['testId'] ?? '',
      seriesId: data['seriesId'] ?? '',
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      submittedAt: data['submittedAt'] != null 
          ? (data['submittedAt'] as Timestamp).toDate() 
          : null,
      timeSpent: data['timeSpent'] ?? 0,
      totalMarks: data['totalMarks'] ?? 0,
      obtainedMarks: data['obtainedMarks'] ?? 0,
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      answers: (data['answers'] as List? ?? [])
          .map((a) => TestAnswerModel.fromMap(a))
          .toList(),
      rank: data['rank'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      breakdown: data['breakdown'] ?? {},
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'testId': testId,
      'seriesId': seriesId,
      'startedAt': Timestamp.fromDate(startedAt),
      'submittedAt': submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'timeSpent': timeSpent,
      'totalMarks': totalMarks,
      'obtainedMarks': obtainedMarks,
      'percentage': percentage,
      'answers': answers.map((a) => a.toMap()).toList(),
      'rank': rank,
      'isCompleted': isCompleted,
      'breakdown': breakdown,
      'metadata': metadata,
    };
  }
}

// Test Answer Model
class TestAnswerModel {
  final String questionId;
  final int selectedAnswer;
  final int correctAnswer;
  final bool isCorrect;
  final int timeSpent; // in seconds
  final DateTime answeredAt;

  TestAnswerModel({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.timeSpent,
    required this.answeredAt,
  });

  factory TestAnswerModel.fromMap(Map<String, dynamic> data) {
    return TestAnswerModel(
      questionId: data['questionId'] ?? '',
      selectedAnswer: data['selectedAnswer'] ?? -1,
      correctAnswer: data['correctAnswer'] ?? -1,
      isCorrect: data['isCorrect'] ?? false,
      timeSpent: data['timeSpent'] ?? 0,
      answeredAt: data['answeredAt'] is Timestamp
          ? (data['answeredAt'] as Timestamp).toDate()
          : DateTime.now(),
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

// PYP (Previous Year Papers) Models
class PYPModel {
  final String id;
  final String title;
  final int year;
  final String examType; // e.g., "NEET", "JEE", "VETERINARY_ENTRANCE"
  final String category;
  final String targetRole;
  final DateTime uploadedAt;
  final List<String> questionIds;
  final int totalQuestions;
  final int totalMarks;
  final int duration; // in minutes
  final bool isActive;
  final String paperUrl; // PDF URL if available
  final Map<String, dynamic> metadata;

  PYPModel({
    required this.id,
    required this.title,
    required this.year,
    required this.examType,
    required this.category,
    required this.targetRole,
    required this.uploadedAt,
    required this.questionIds,
    required this.totalQuestions,
    required this.totalMarks,
    required this.duration,
    required this.isActive,
    required this.paperUrl,
    required this.metadata,
  });

  factory PYPModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PYPModel(
      id: doc.id,
      title: data['title'] ?? '',
      year: data['year'] ?? DateTime.now().year,
      examType: data['examType'] ?? '',
      category: data['category'] ?? '',
      targetRole: data['targetRole'] ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      questionIds: List<String>.from(data['questionIds'] ?? []),
      totalQuestions: data['totalQuestions'] ?? 0,
      totalMarks: data['totalMarks'] ?? 0,
      duration: data['duration'] ?? 0,
      isActive: data['isActive'] ?? false,
      paperUrl: data['paperUrl'] ?? '',
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'year': year,
      'examType': examType,
      'category': category,
      'targetRole': targetRole,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'questionIds': questionIds,
      'totalQuestions': totalQuestions,
      'totalMarks': totalMarks,
      'duration': duration,
      'isActive': isActive,
      'paperUrl': paperUrl,
      'metadata': metadata,
    };
  }
}

// Test Results and Victory Modal Data
class TestResultModel {
  final String attemptId;
  final int finalScore;
  final int totalMarks;
  final double percentage;
  final int rank;
  final int totalParticipants;
  final int timeSpent; // in seconds
  final Map<String, int> categoryWiseScores; // e.g., {"Easy": 80, "Medium": 60}
  final int xpEarned;
  final int coinsEarned;
  final bool isPassed;
  final List<LeaderboardEntry> topRankers;

  TestResultModel({
    required this.attemptId,
    required this.finalScore,
    required this.totalMarks,
    required this.percentage,
    required this.rank,
    required this.totalParticipants,
    required this.timeSpent,
    required this.categoryWiseScores,
    required this.xpEarned,
    required this.coinsEarned,
    required this.isPassed,
    required this.topRankers,
  });
}

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int score;
  final int timeSpent;
  final int rank;
  final String profileImage;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.score,
    required this.timeSpent,
    required this.rank,
    required this.profileImage,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> data) {
    return LeaderboardEntry(
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      score: data['score'] ?? 0,
      timeSpent: data['timeSpent'] ?? 0,
      rank: data['rank'] ?? 0,
      profileImage: data['profileImage'] ?? '',
    );
  }
}

// Enums
enum TestType { practice, mock, live, championship }

enum TestStatus { upcoming, live, completed, expired }

enum DifficultyBreakdown { easy, medium, hard }