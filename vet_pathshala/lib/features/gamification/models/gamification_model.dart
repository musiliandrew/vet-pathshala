import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int pointsReward;
  final int coinsReward;
  final String category; // 'learning', 'social', 'milestone'
  final Map<String, dynamic> requirements;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.pointsReward,
    required this.coinsReward,
    required this.category,
    required this.requirements,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Achievement(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? 'trophy',
      pointsReward: data['pointsReward'] ?? 0,
      coinsReward: data['coinsReward'] ?? 0,
      category: data['category'] ?? '',
      requirements: data['requirements'] ?? {},
      isUnlocked: data['isUnlocked'] ?? false,
      unlockedAt: data['unlockedAt'] != null
          ? (data['unlockedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'pointsReward': pointsReward,
      'coinsReward': coinsReward,
      'category': category,
      'requirements': requirements,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
    };
  }
}

class UserGameStats {
  final String userId;
  final int totalPoints;
  final int totalCoins;
  final int currentStreak;
  final int maxStreak;
  final int questionsAnswered;
  final int correctAnswers;
  final int lessonsCompleted;
  final int notesRead;
  final int achievementsUnlocked;
  final int rank;
  final DateTime lastActiveDate;
  final Map<String, int> categoryStats;

  UserGameStats({
    required this.userId,
    this.totalPoints = 0,
    this.totalCoins = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.lessonsCompleted = 0,
    this.notesRead = 0,
    this.achievementsUnlocked = 0,
    this.rank = 0,
    required this.lastActiveDate,
    this.categoryStats = const {},
  });

  factory UserGameStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserGameStats(
      userId: doc.id,
      totalPoints: data['totalPoints'] ?? 0,
      totalCoins: data['totalCoins'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      maxStreak: data['maxStreak'] ?? 0,
      questionsAnswered: data['questionsAnswered'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      lessonsCompleted: data['lessonsCompleted'] ?? 0,
      notesRead: data['notesRead'] ?? 0,
      achievementsUnlocked: data['achievementsUnlocked'] ?? 0,
      rank: data['rank'] ?? 0,
      lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categoryStats: Map<String, int>.from(data['categoryStats'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalPoints': totalPoints,
      'totalCoins': totalCoins,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'lessonsCompleted': lessonsCompleted,
      'notesRead': notesRead,
      'achievementsUnlocked': achievementsUnlocked,
      'rank': rank,
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'categoryStats': categoryStats,
    };
  }

  double get accuracy => questionsAnswered > 0 ? correctAnswers / questionsAnswered : 0.0;
  
  int get level {
    if (totalPoints < 100) return 1;
    if (totalPoints < 500) return 2;
    if (totalPoints < 1000) return 3;
    if (totalPoints < 2500) return 4;
    if (totalPoints < 5000) return 5;
    if (totalPoints < 10000) return 6;
    if (totalPoints < 20000) return 7;
    if (totalPoints < 50000) return 8;
    if (totalPoints < 100000) return 9;
    return 10;
  }

  String get levelTitle {
    switch (level) {
      case 1: return 'Novice';
      case 2: return 'Student';
      case 3: return 'Apprentice';
      case 4: return 'Practitioner';
      case 5: return 'Professional';
      case 6: return 'Expert';
      case 7: return 'Specialist';
      case 8: return 'Master';
      case 9: return 'Legend';
      case 10: return 'Grandmaster';
      default: return 'Student';
    }
  }

  int get pointsToNextLevel {
    const levelThresholds = [0, 100, 500, 1000, 2500, 5000, 10000, 20000, 50000, 100000];
    if (level >= 10) return 0;
    return levelThresholds[level] - totalPoints;
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type; // 'questions', 'lessons', 'streak'
  final Map<String, dynamic> requirements;
  final int pointsReward;
  final int coinsReward;
  final DateTime validDate;
  final bool isCompleted;
  final DateTime? completedAt;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirements,
    required this.pointsReward,
    required this.coinsReward,
    required this.validDate,
    this.isCompleted = false,
    this.completedAt,
  });

  factory DailyChallenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyChallenge(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      requirements: data['requirements'] ?? {},
      pointsReward: data['pointsReward'] ?? 0,
      coinsReward: data['coinsReward'] ?? 0,
      validDate: (data['validDate'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  bool get isValid {
    final today = DateTime.now();
    return validDate.year == today.year &&
           validDate.month == today.month &&
           validDate.day == today.day;
  }
}

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? profileImageUrl;
  final int totalPoints;
  final int rank;
  final String userRole;
  final int questionsAnswered;
  final double accuracy;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.profileImageUrl,
    required this.totalPoints,
    required this.rank,
    required this.userRole,
    required this.questionsAnswered,
    required this.accuracy,
  });

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      userId: doc.id,
      displayName: data['displayName'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      totalPoints: data['totalPoints'] ?? 0,
      rank: data['rank'] ?? 0,
      userRole: data['userRole'] ?? '',
      questionsAnswered: data['questionsAnswered'] ?? 0,
      accuracy: (data['accuracy'] ?? 0).toDouble(),
    );
  }
}

class PointsTransaction {
  final String id;
  final String userId;
  final int points;
  final String type; // 'earned', 'bonus', 'penalty'
  final String reason; // 'correct_answer', 'streak_bonus', 'achievement', etc.
  final String? referenceId;
  final DateTime createdAt;

  PointsTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.reason,
    this.referenceId,
    required this.createdAt,
  });

  factory PointsTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PointsTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      points: data['points'] ?? 0,
      type: data['type'] ?? '',
      reason: data['reason'] ?? '',
      referenceId: data['referenceId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'points': points,
      'type': type,
      'reason': reason,
      'referenceId': referenceId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}