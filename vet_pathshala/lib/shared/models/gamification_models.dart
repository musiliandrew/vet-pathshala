import 'package:cloud_firestore/cloud_firestore.dart';

enum BadgeCategory {
  learning,
  social,
  achievement,
  milestone,
  special
}

enum BadgeRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary
}

enum ChallengeType {
  daily,
  weekly,
  monthly,
  seasonal,
  special_event
}

enum ChallengeStatus {
  active,
  completed,
  expired,
  locked
}

enum RewardType {
  coins,
  badge,
  title,
  unlock,
  premium_access
}

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String? iconCode;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final Map<String, dynamic> criteria;
  final int pointsReward;
  final bool isActive;
  final DateTime createdAt;
  final List<String> targetRoles;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    this.iconCode,
    required this.category,
    required this.rarity,
    required this.criteria,
    this.pointsReward = 0,
    this.isActive = true,
    required this.createdAt,
    this.targetRoles = const [],
  });

  factory BadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BadgeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      iconCode: data['iconCode'],
      category: BadgeCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => BadgeCategory.learning,
      ),
      rarity: BadgeRarity.values.firstWhere(
        (e) => e.name == data['rarity'],
        orElse: () => BadgeRarity.common,
      ),
      criteria: data['criteria'] ?? {},
      pointsReward: data['pointsReward'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      targetRoles: List<String>.from(data['targetRoles'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'iconCode': iconCode,
      'category': category.name,
      'rarity': rarity.name,
      'criteria': criteria,
      'pointsReward': pointsReward,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetRoles': targetRoles,
    };
  }
}

class UserBadgeModel {
  final String id;
  final String userId;
  final String badgeId;
  final DateTime earnedAt;
  final Map<String, dynamic> progressData;
  final bool isDisplayed;

  UserBadgeModel({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.earnedAt,
    this.progressData = const {},
    this.isDisplayed = false,
  });

  factory UserBadgeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserBadgeModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      badgeId: data['badgeId'] ?? '',
      earnedAt: (data['earnedAt'] as Timestamp).toDate(),
      progressData: data['progressData'] ?? {},
      isDisplayed: data['isDisplayed'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'badgeId': badgeId,
      'earnedAt': Timestamp.fromDate(earnedAt),
      'progressData': progressData,
      'isDisplayed': isDisplayed,
    };
  }
}

class ChallengeModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final ChallengeType type;
  final Map<String, dynamic> requirements;
  final List<RewardModel> rewards;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> targetRoles;
  final int maxParticipants;
  final int difficultyLevel;

  ChallengeModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.requirements,
    required this.rewards,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.targetRoles = const [],
    this.maxParticipants = 0, // 0 = unlimited
    this.difficultyLevel = 1,
  });

  factory ChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      type: ChallengeType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ChallengeType.daily,
      ),
      requirements: data['requirements'] ?? {},
      rewards: (data['rewards'] as List<dynamic>? ?? [])
          .map((r) => RewardModel.fromMap(r))
          .toList(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      targetRoles: List<String>.from(data['targetRoles'] ?? []),
      maxParticipants: data['maxParticipants'] ?? 0,
      difficultyLevel: data['difficultyLevel'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'requirements': requirements,
      'rewards': rewards.map((r) => r.toMap()).toList(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'targetRoles': targetRoles,
      'maxParticipants': maxParticipants,
      'difficultyLevel': difficultyLevel,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isOngoing => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
}

class UserChallengeModel {
  final String id;
  final String userId;
  final String challengeId;
  final ChallengeStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> progress;
  final double completionPercentage;

  UserChallengeModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.progress = const {},
    this.completionPercentage = 0.0,
  });

  factory UserChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserChallengeModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      challengeId: data['challengeId'] ?? '',
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ChallengeStatus.active,
      ),
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      progress: data['progress'] ?? {},
      completionPercentage: (data['completionPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'status': status.name,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'progress': progress,
      'completionPercentage': completionPercentage,
    };
  }
}

class RewardModel {
  final RewardType type;
  final int amount;
  final String? itemId;
  final String description;
  final Map<String, dynamic> metadata;

  RewardModel({
    required this.type,
    required this.amount,
    this.itemId,
    required this.description,
    this.metadata = const {},
  });

  factory RewardModel.fromMap(Map<String, dynamic> map) {
    return RewardModel(
      type: RewardType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RewardType.coins,
      ),
      amount: map['amount'] ?? 0,
      itemId: map['itemId'],
      description: map['description'] ?? '',
      metadata: map['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'amount': amount,
      'itemId': itemId,
      'description': description,
      'metadata': metadata,
    };
  }
}

class AchievementModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String? iconCode;
  final int tier;
  final List<String> prerequisites;
  final RewardModel reward;
  final Map<String, dynamic> unlockCriteria;
  final bool isSecret;
  final DateTime createdAt;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    this.iconCode,
    this.tier = 1,
    this.prerequisites = const [],
    required this.reward,
    required this.unlockCriteria,
    this.isSecret = false,
    required this.createdAt,
  });

  factory AchievementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AchievementModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      iconCode: data['iconCode'],
      tier: data['tier'] ?? 1,
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
      reward: RewardModel.fromMap(data['reward'] ?? {}),
      unlockCriteria: data['unlockCriteria'] ?? {},
      isSecret: data['isSecret'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'iconCode': iconCode,
      'tier': tier,
      'prerequisites': prerequisites,
      'reward': reward.toMap(),
      'unlockCriteria': unlockCriteria,
      'isSecret': isSecret,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class UserAchievementModel {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;
  final double progress;
  final bool isCompleted;
  final Map<String, dynamic> progressData;

  UserAchievementModel({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.progress = 0.0,
    this.isCompleted = false,
    this.progressData = const {},
  });

  factory UserAchievementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserAchievementModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      achievementId: data['achievementId'] ?? '',
      unlockedAt: (data['unlockedAt'] as Timestamp).toDate(),
      progress: (data['progress'] ?? 0.0).toDouble(),
      isCompleted: data['isCompleted'] ?? false,
      progressData: data['progressData'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'achievementId': achievementId,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'progress': progress,
      'isCompleted': isCompleted,
      'progressData': progressData,
    };
  }
}

class LeaderboardEntryModel {
  final String userId;
  final String displayName;
  final String userRole;
  final int totalPoints;
  final int rank;
  final Map<String, dynamic> stats;
  final List<String> featuredBadges;
  final DateTime lastUpdate;

  LeaderboardEntryModel({
    required this.userId,
    required this.displayName,
    required this.userRole,
    required this.totalPoints,
    required this.rank,
    this.stats = const {},
    this.featuredBadges = const [],
    required this.lastUpdate,
  });

  factory LeaderboardEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntryModel(
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      userRole: data['userRole'] ?? '',
      totalPoints: data['totalPoints'] ?? 0,
      rank: data['rank'] ?? 0,
      stats: data['stats'] ?? {},
      featuredBadges: List<String>.from(data['featuredBadges'] ?? []),
      lastUpdate: (data['lastUpdate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'userRole': userRole,
      'totalPoints': totalPoints,
      'rank': rank,
      'stats': stats,
      'featuredBadges': featuredBadges,
      'lastUpdate': Timestamp.fromDate(lastUpdate),
    };
  }
}

class StreakModel {
  final String userId;
  final String streakType; // 'daily_login', 'quiz_completion', 'study_time'
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActionDate;
  final DateTime streakStartDate;
  final Map<String, dynamic> metadata;

  StreakModel({
    required this.userId,
    required this.streakType,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActionDate,
    required this.streakStartDate,
    this.metadata = const {},
  });

  factory StreakModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StreakModel(
      userId: data['userId'] ?? '',
      streakType: data['streakType'] ?? '',
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastActionDate: (data['lastActionDate'] as Timestamp).toDate(),
      streakStartDate: (data['streakStartDate'] as Timestamp).toDate(),
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'streakType': streakType,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActionDate': Timestamp.fromDate(lastActionDate),
      'streakStartDate': Timestamp.fromDate(streakStartDate),
      'metadata': metadata,
    };
  }

  bool get isActive {
    final now = DateTime.now();
    final daysSinceLastAction = now.difference(lastActionDate).inDays;
    return daysSinceLastAction <= 1; // Allow 1 day gap
  }
}