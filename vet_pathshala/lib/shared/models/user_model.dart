import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { doctor, pharmacist, farmer }

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String userRole; // "doctor", "pharmacist", "farmer"
  final String? specialization;
  final int? experienceYears;
  final bool profileCompleted;
  final DateTime? createdTime;
  final int coins;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    required this.userRole,
    this.specialization,
    this.experienceYears,
    this.profileCompleted = false,
    this.createdTime,
    this.coins = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'],
      userRole: data['userRole'] ?? 'doctor',
      specialization: data['specialization'],
      experienceYears: data['experienceYears'],
      profileCompleted: data['profileCompleted'] ?? false,
      createdTime: (data['createdTime'] as Timestamp?)?.toDate(),
      coins: data['coins'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'userRole': userRole,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'profileCompleted': profileCompleted,
      'createdTime': createdTime != null ? Timestamp.fromDate(createdTime!) : FieldValue.serverTimestamp(),
      'coins': coins,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? userRole,
    String? specialization,
    int? experienceYears,
    bool? profileCompleted,
    DateTime? createdTime,
    int? coins,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userRole: userRole ?? this.userRole,
      specialization: specialization ?? this.specialization,
      experienceYears: experienceYears ?? this.experienceYears,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdTime: createdTime ?? this.createdTime,
      coins: coins ?? this.coins,
    );
  }

  // Helper methods for compatibility with existing code
  String get name => displayName;
  UserRole get role => UserRole.values.firstWhere(
    (role) => role.name == userRole,
    orElse: () => UserRole.doctor,
  );
  bool get isProfileComplete => profileCompleted;
}

// Data models for existing collections
class QuestionModel {
  final String id;
  final String authorId;
  final String category;
  final int correctAnswer;
  final DateTime createdAt;
  final String difficulty;
  final List<String> options;
  final String questionText;
  final String questionType;
  final String targetRole;

  QuestionModel({
    required this.id,
    required this.authorId,
    required this.category,
    required this.correctAnswer,
    required this.createdAt,
    required this.difficulty,
    required this.options,
    required this.questionText,
    required this.questionType,
    required this.targetRole,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      category: data['category'] ?? '',
      correctAnswer: data['correctAnswer'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      difficulty: data['difficulty'] ?? 'beginner',
      options: List<String>.from(data['options'] ?? []),
      questionText: data['questionText'] ?? '',
      questionType: data['questionType'] ?? 'multiple_choice',
      targetRole: data['targetRole'] ?? 'doctor',
    );
  }
}

class LectureModel {
  final String id;
  final String category;
  final DateTime createdAt;
  final String description;
  final int duration;
  final String targetRole;
  final String title;
  final String videoUrl;

  LectureModel({
    required this.id,
    required this.category,
    required this.createdAt,
    required this.description,
    required this.duration,
    required this.targetRole,
    required this.title,
    required this.videoUrl,
  });

  factory LectureModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LectureModel(
      id: doc.id,
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      duration: data['duration'] ?? 0,
      targetRole: data['targetRole'] ?? 'doctor',
      title: data['title'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
    );
  }
}

class NoteModel {
  final String id;
  final String authorId;
  final String category;
  final String content;
  final DateTime createdAt;
  final String downloadUrl;
  final String targetRole;
  final String title;

  NoteModel({
    required this.id,
    required this.authorId,
    required this.category,
    required this.content,
    required this.createdAt,
    required this.downloadUrl,
    required this.targetRole,
    required this.title,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      category: data['category'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      downloadUrl: data['downloadUrl'] ?? '',
      targetRole: data['targetRole'] ?? 'doctor',
      title: data['title'] ?? '',
    );
  }
}

class CoinTransactionModel {
  final String id;
  final int amount;
  final DateTime createdAt;
  final String reason;
  final String type;
  final String userId;

  CoinTransactionModel({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.reason,
    required this.type,
    required this.userId,
  });

  factory CoinTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoinTransactionModel(
      id: doc.id,
      amount: data['amount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reason: data['reason'] ?? '',
      type: data['type'] ?? 'earned',
      userId: data['userId'] ?? '',
    );
  }
}

class SubscriptionModel {
  final String id;
  final DateTime endDate;
  final String planType;
  final int price;
  final DateTime startDate;
  final String status;
  final String userId;

  SubscriptionModel({
    required this.id,
    required this.endDate,
    required this.planType,
    required this.price,
    required this.startDate,
    required this.status,
    required this.userId,
  });

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      endDate: (data['endDate'] as Timestamp).toDate(),
      planType: data['planType'] ?? 'basic',
      price: data['price'] ?? 0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'inactive',
      userId: data['userId'] ?? '',
    );
  }
}

class UserProfile {
  final String? organization;
  final String? specialization;
  final String? experienceLevel;
  final String? location;
  final String? state;
  final String? profileImageUrl;
  final List<String>? interests;
  final String? bio;

  UserProfile({
    this.organization,
    this.specialization,
    this.experienceLevel,
    this.location,
    this.state,
    this.profileImageUrl,
    this.interests,
    this.bio,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      organization: map['organization'],
      specialization: map['specialization'],
      experienceLevel: map['experienceLevel'],
      location: map['location'],
      state: map['state'],
      profileImageUrl: map['profileImageUrl'],
      interests: map['interests'] != null ? List<String>.from(map['interests']) : null,
      bio: map['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organization': organization,
      'specialization': specialization,
      'experienceLevel': experienceLevel,
      'location': location,
      'state': state,
      'profileImageUrl': profileImageUrl,
      'interests': interests,
      'bio': bio,
    };
  }

  UserProfile copyWith({
    String? organization,
    String? specialization,
    String? experienceLevel,
    String? location,
    String? state,
    String? profileImageUrl,
    List<String>? interests,
    String? bio,
  }) {
    return UserProfile(
      organization: organization ?? this.organization,
      specialization: specialization ?? this.specialization,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      location: location ?? this.location,
      state: state ?? this.state,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
    );
  }
}

class UserPreferences {
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool offlineDownloads;
  final String language;
  final String theme;
  final List<String>? subscribedTopics;

  UserPreferences({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.offlineDownloads = true,
    this.language = 'en',
    this.theme = 'light',
    this.subscribedTopics,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      pushNotifications: map['pushNotifications'] ?? true,
      offlineDownloads: map['offlineDownloads'] ?? true,
      language: map['language'] ?? 'en',
      theme: map['theme'] ?? 'light',
      subscribedTopics: map['subscribedTopics'] != null 
          ? List<String>.from(map['subscribedTopics']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'offlineDownloads': offlineDownloads,
      'language': language,
      'theme': theme,
      'subscribedTopics': subscribedTopics,
    };
  }

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? offlineDownloads,
    String? language,
    String? theme,
    List<String>? subscribedTopics,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      offlineDownloads: offlineDownloads ?? this.offlineDownloads,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
    );
  }
}

class UserStats {
  final int questionsAnswered;
  final int correctAnswers;
  final int streak;
  final int coinsEarned;
  final int coinsSpent;
  final int battlesWon;
  final int battlesLost;
  final int studyTimeMinutes;
  final DateTime lastActiveDate;
  final Map<String, int>? subjectStats;

  UserStats({
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.streak = 0,
    this.coinsEarned = 0,
    this.coinsSpent = 0,
    this.battlesWon = 0,
    this.battlesLost = 0,
    this.studyTimeMinutes = 0,
    required this.lastActiveDate,
    this.subjectStats,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      questionsAnswered: map['questionsAnswered'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      streak: map['streak'] ?? 0,
      coinsEarned: map['coinsEarned'] ?? 0,
      coinsSpent: map['coinsSpent'] ?? 0,
      battlesWon: map['battlesWon'] ?? 0,
      battlesLost: map['battlesLost'] ?? 0,
      studyTimeMinutes: map['studyTimeMinutes'] ?? 0,
      lastActiveDate: (map['lastActiveDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subjectStats: map['subjectStats'] != null 
          ? Map<String, int>.from(map['subjectStats'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'streak': streak,
      'coinsEarned': coinsEarned,
      'coinsSpent': coinsSpent,
      'battlesWon': battlesWon,
      'battlesLost': battlesLost,
      'studyTimeMinutes': studyTimeMinutes,
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'subjectStats': subjectStats,
    };
  }

  double get accuracy => questionsAnswered > 0 ? correctAnswers / questionsAnswered : 0.0;
  int get coinsBalance => coinsEarned - coinsSpent;
  int get totalBattles => battlesWon + battlesLost;
  double get winRate => totalBattles > 0 ? battlesWon / totalBattles : 0.0;

  UserStats copyWith({
    int? questionsAnswered,
    int? correctAnswers,
    int? streak,
    int? coinsEarned,
    int? coinsSpent,
    int? battlesWon,
    int? battlesLost,
    int? studyTimeMinutes,
    DateTime? lastActiveDate,
    Map<String, int>? subjectStats,
  }) {
    return UserStats(
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      streak: streak ?? this.streak,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      coinsSpent: coinsSpent ?? this.coinsSpent,
      battlesWon: battlesWon ?? this.battlesWon,
      battlesLost: battlesLost ?? this.battlesLost,
      studyTimeMinutes: studyTimeMinutes ?? this.studyTimeMinutes,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      subjectStats: subjectStats ?? this.subjectStats,
    );
  }
}