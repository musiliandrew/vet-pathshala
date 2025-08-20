import 'package:cloud_firestore/cloud_firestore.dart';

/// Enhanced Video Model for dynamic content management
class EnhancedVideoModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String instructorBio;
  final String? thumbnailUrl;
  final String videoUrl;
  final Map<String, String> qualityUrls; // 360p, 720p, 1080p
  final int duration; // in seconds
  final String category;
  final String subcategory;
  final List<String> targetRoles;
  final String accessLevel; // free, premium
  final int coinCost;
  final String difficulty; // beginner, intermediate, advanced
  final List<String> tags;
  final List<VideoChapter> chapters;
  final List<VideoSubtitle> subtitles;
  final bool isActive;
  final bool featured;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final VideoStats stats;

  EnhancedVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    this.instructorBio = '',
    this.thumbnailUrl,
    required this.videoUrl,
    this.qualityUrls = const {},
    this.duration = 0,
    required this.category,
    this.subcategory = '',
    this.targetRoles = const [],
    this.accessLevel = 'free',
    this.coinCost = 0,
    this.difficulty = 'beginner',
    this.tags = const [],
    this.chapters = const [],
    this.subtitles = const [],
    this.isActive = true,
    this.featured = false,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = 'admin',
    required this.stats,
  });

  factory EnhancedVideoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return EnhancedVideoModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructor: data['instructor'] ?? data['author'] ?? 'Unknown Instructor',
      instructorBio: data['instructorBio'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
      videoUrl: data['videoUrl'] ?? '',
      qualityUrls: Map<String, String>.from(data['qualityUrls'] ?? {}),
      duration: data['duration'] ?? 0,
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      targetRoles: data['targetRoles'] != null 
          ? List<String>.from(data['targetRoles']) 
          : [data['targetRole'] ?? 'doctor'], // Handle single targetRole from your data
      accessLevel: data['accessLevel'] ?? 'free',
      coinCost: data['coinCost'] ?? 0,
      difficulty: data['difficulty'] ?? 'beginner',
      tags: List<String>.from(data['tags'] ?? []),
      chapters: (data['chapters'] as List<dynamic>?)
          ?.map((chapter) => VideoChapter.fromMap(chapter))
          .toList() ?? [],
      subtitles: (data['subtitles'] as List<dynamic>?)
          ?.map((subtitle) => VideoSubtitle.fromMap(subtitle))
          .toList() ?? [],
      isActive: data['isActive'] ?? true,
      featured: data['featured'] ?? false,
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? data['authorId'] ?? 'admin',
      stats: VideoStats.fromMap(data['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'instructor': instructor,
      'instructorBio': instructorBio,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'qualityUrls': qualityUrls,
      'duration': duration,
      'category': category,
      'subcategory': subcategory,
      'targetRoles': targetRoles,
      'accessLevel': accessLevel,
      'coinCost': coinCost,
      'difficulty': difficulty,
      'tags': tags,
      'chapters': chapters.map((c) => c.toMap()).toList(),
      'subtitles': subtitles.map((s) => s.toMap()).toList(),
      'isActive': isActive,
      'featured': featured,
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'stats': stats.toMap(),
    };
  }
}

class VideoChapter {
  final String title;
  final int timestamp;
  final String description;

  VideoChapter({
    required this.title,
    required this.timestamp,
    this.description = '',
  });

  factory VideoChapter.fromMap(Map<String, dynamic> map) {
    return VideoChapter(
      title: map['title'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'timestamp': timestamp,
      'description': description,
    };
  }
}

class VideoSubtitle {
  final String language;
  final String vttUrl;

  VideoSubtitle({
    required this.language,
    required this.vttUrl,
  });

  factory VideoSubtitle.fromMap(Map<String, dynamic> map) {
    return VideoSubtitle(
      language: map['language'] ?? 'en',
      vttUrl: map['vttUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'vttUrl': vttUrl,
    };
  }
}

class VideoStats {
  final int views;
  final int likes;
  final int completions;
  final double averageRating;

  VideoStats({
    this.views = 0,
    this.likes = 0,
    this.completions = 0,
    this.averageRating = 0.0,
  });

  factory VideoStats.fromMap(Map<String, dynamic> map) {
    return VideoStats(
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      completions: map['completions'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'views': views,
      'likes': likes,
      'completions': completions,
      'averageRating': averageRating,
    };
  }
}

/// Enhanced Question Model for dynamic quiz management
class EnhancedQuestionModel {
  final String id;
  final String question;
  final String questionType; // mcq, true_false, fill_blank
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String category;
  final String subcategory;
  final String subject;
  final String topic;
  final String difficulty; // easy, medium, hard
  final List<String> targetRoles;
  final List<String> tags;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final QuestionStats stats;

  EnhancedQuestionModel({
    required this.id,
    required this.question,
    required this.questionType,
    this.options = const [],
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    this.subcategory = '',
    required this.subject,
    required this.topic,
    this.difficulty = 'easy',
    this.targetRoles = const [],
    this.tags = const [],
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = 'admin',
    required this.stats,
  });

  factory EnhancedQuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Handle backward compatibility with your existing data structure
    String questionText = data['question'] ?? data['questionText'] ?? '';
    String correctAnswerStr = '';
    
    // Handle your numeric correctAnswer format
    if (data['correctAnswer'] is int) {
      int correctIndex = data['correctAnswer'] as int;
      List<String> options = List<String>.from(data['options'] ?? []);
      correctAnswerStr = correctIndex < options.length ? options[correctIndex] : '';
    } else {
      correctAnswerStr = data['correctAnswer']?.toString() ?? '';
    }
    
    return EnhancedQuestionModel(
      id: doc.id,
      question: questionText,
      questionType: data['questionType'] ?? (data['options'] != null ? 'multiple_choice' : 'text'),
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: correctAnswerStr,
      explanation: data['explanation'] ?? 'No explanation provided',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      subject: data['subject'] ?? data['category'] ?? '',
      topic: data['topic'] ?? data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'beginner',
      targetRoles: data['targetRoles'] != null 
          ? List<String>.from(data['targetRoles']) 
          : [data['targetRole'] ?? 'doctor'], // Handle single targetRole from your data
      tags: List<String>.from(data['tags'] ?? []),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? data['authorId'] ?? 'admin',
      stats: QuestionStats.fromMap(data['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'questionType': questionType,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'category': category,
      'subcategory': subcategory,
      'subject': subject,
      'topic': topic,
      'difficulty': difficulty,
      'targetRoles': targetRoles,
      'tags': tags,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'stats': stats.toMap(),
    };
  }
}

class QuestionStats {
  final int attempts;
  final int correctAttempts;
  final double avgTime;

  QuestionStats({
    this.attempts = 0,
    this.correctAttempts = 0,
    this.avgTime = 0.0,
  });

  factory QuestionStats.fromMap(Map<String, dynamic> map) {
    return QuestionStats(
      attempts: map['attempts'] ?? 0,
      correctAttempts: map['correctAttempts'] ?? 0,
      avgTime: (map['avgTime'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attempts': attempts,
      'correctAttempts': correctAttempts,
      'avgTime': avgTime,
    };
  }
}

/// Enhanced E-book Model for library management
class EnhancedEbookModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String? coverImageUrl;
  final String pdfUrl;
  final String category;
  final String subcategory;
  final List<String> targetRoles;
  final String accessLevel;
  final int coinCost;
  final int pages;
  final String language;
  final List<String> tags;
  final List<EbookChapter> chapters;
  final bool isActive;
  final bool featured;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final EbookStats stats;

  EnhancedEbookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    this.coverImageUrl,
    required this.pdfUrl,
    required this.category,
    this.subcategory = '',
    this.targetRoles = const [],
    this.accessLevel = 'free',
    this.coinCost = 0,
    this.pages = 0,
    this.language = 'en',
    this.tags = const [],
    this.chapters = const [],
    this.isActive = true,
    this.featured = false,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = 'admin',
    required this.stats,
  });

  factory EnhancedEbookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return EnhancedEbookModel(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      coverImageUrl: data['coverImageUrl'],
      pdfUrl: data['pdfUrl'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      targetRoles: List<String>.from(data['targetRoles'] ?? []),
      accessLevel: data['accessLevel'] ?? 'free',
      coinCost: data['coinCost'] ?? 0,
      pages: data['pages'] ?? 0,
      language: data['language'] ?? 'en',
      tags: List<String>.from(data['tags'] ?? []),
      chapters: (data['chapters'] as List<dynamic>?)
          ?.map((chapter) => EbookChapter.fromMap(chapter))
          .toList() ?? [],
      isActive: data['isActive'] ?? true,
      featured: data['featured'] ?? false,
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? 'admin',
      stats: EbookStats.fromMap(data['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'pdfUrl': pdfUrl,
      'category': category,
      'subcategory': subcategory,
      'targetRoles': targetRoles,
      'accessLevel': accessLevel,
      'coinCost': coinCost,
      'pages': pages,
      'language': language,
      'tags': tags,
      'chapters': chapters.map((c) => c.toMap()).toList(),
      'isActive': isActive,
      'featured': featured,
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'stats': stats.toMap(),
    };
  }
}

class EbookChapter {
  final String title;
  final int pageStart;
  final int pageEnd;

  EbookChapter({
    required this.title,
    required this.pageStart,
    required this.pageEnd,
  });

  factory EbookChapter.fromMap(Map<String, dynamic> map) {
    return EbookChapter(
      title: map['title'] ?? '',
      pageStart: map['pageStart'] ?? 0,
      pageEnd: map['pageEnd'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'pageStart': pageStart,
      'pageEnd': pageEnd,
    };
  }
}

class EbookStats {
  final int downloads;
  final int readers;
  final double averageProgress;

  EbookStats({
    this.downloads = 0,
    this.readers = 0,
    this.averageProgress = 0.0,
  });

  factory EbookStats.fromMap(Map<String, dynamic> map) {
    return EbookStats(
      downloads: map['downloads'] ?? 0,
      readers: map['readers'] ?? 0,
      averageProgress: (map['averageProgress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'downloads': downloads,
      'readers': readers,
      'averageProgress': averageProgress,
    };
  }
}

/// Enhanced User Model with subscription and stats
class EnhancedUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // doctor, pharmacist, farmer, admin
  final String plan; // free, premium
  final int coins;
  final String? profileImage;
  final String bio;
  final String specialization;
  final String location;
  final String? farmSize; // for farmers
  final List<String> animalTypes; // for farmers
  final UserPreferences preferences;
  final UserSubscription? subscription;
  final UserStats stats;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  EnhancedUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.plan = 'free',
    this.coins = 100,
    this.profileImage,
    this.bio = '',
    this.specialization = '',
    this.location = '',
    this.farmSize,
    this.animalTypes = const [],
    required this.preferences,
    this.subscription,
    required this.stats,
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EnhancedUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return EnhancedUserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? '',
      plan: data['plan'] ?? 'free',
      coins: data['coins'] ?? 100,
      profileImage: data['profileImage'],
      bio: data['bio'] ?? '',
      specialization: data['specialization'] ?? '',
      location: data['location'] ?? '',
      farmSize: data['farmSize'],
      animalTypes: List<String>.from(data['animalTypes'] ?? []),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      subscription: data['subscription'] != null 
          ? UserSubscription.fromMap(data['subscription'])
          : null,
      stats: UserStats.fromMap(data['stats'] ?? {}),
      isActive: data['isActive'] ?? true,
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'plan': plan,
      'coins': coins,
      'profileImage': profileImage,
      'bio': bio,
      'specialization': specialization,
      'location': location,
      'farmSize': farmSize,
      'animalTypes': animalTypes,
      'preferences': preferences.toMap(),
      'subscription': subscription?.toMap(),
      'stats': stats.toMap(),
      'isActive': isActive,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class UserPreferences {
  final String language;
  final bool notifications;
  final String theme;

  UserPreferences({
    this.language = 'en',
    this.notifications = true,
    this.theme = 'light',
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      language: map['language'] ?? 'en',
      notifications: map['notifications'] ?? true,
      theme: map['theme'] ?? 'light',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'notifications': notifications,
      'theme': theme,
    };
  }
}

class UserSubscription {
  final String type; // monthly, yearly
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  UserSubscription({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory UserSubscription.fromMap(Map<String, dynamic> map) {
    return UserSubscription(
      type: map['type'] ?? 'monthly',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
    };
  }
}

class UserStats {
  final int totalWatchTime;
  final int coursesCompleted;
  final int quizzesAttempted;
  final int currentStreak;
  final int maxStreak;

  UserStats({
    this.totalWatchTime = 0,
    this.coursesCompleted = 0,
    this.quizzesAttempted = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalWatchTime: map['totalWatchTime'] ?? 0,
      coursesCompleted: map['coursesCompleted'] ?? 0,
      quizzesAttempted: map['quizzesAttempted'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      maxStreak: map['maxStreak'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalWatchTime': totalWatchTime,
      'coursesCompleted': coursesCompleted,
      'quizzesAttempted': quizzesAttempted,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
    };
  }
}