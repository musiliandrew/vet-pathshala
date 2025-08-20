import 'package:cloud_firestore/cloud_firestore.dart';

enum StudyGroupType {
  public,
  private,
  premium
}

enum GroupMemberRole {
  admin,
  moderator,
  member
}

enum ActivityType {
  quiz_completed,
  note_shared,
  achievement_unlocked,
  study_streak,
  group_joined,
  challenge_won,
  milestone_reached
}

class StudyGroupModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final StudyGroupType type;
  final String category;
  final String targetRole;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final int maxMembers;
  final bool isActive;
  final Map<String, dynamic> settings;

  StudyGroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.category,
    required this.targetRole,
    required this.createdBy,
    required this.createdAt,
    this.memberIds = const [],
    this.maxMembers = 50,
    this.isActive = true,
    this.settings = const {},
  });

  factory StudyGroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyGroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      type: StudyGroupType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => StudyGroupType.public,
      ),
      category: data['category'] ?? '',
      targetRole: data['targetRole'] ?? 'doctor',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      maxMembers: data['maxMembers'] ?? 50,
      isActive: data['isActive'] ?? true,
      settings: data['settings'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'category': category,
      'targetRole': targetRole,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'memberIds': memberIds,
      'maxMembers': maxMembers,
      'isActive': isActive,
      'settings': settings,
    };
  }

  int get memberCount => memberIds.length;
  bool get isFull => memberIds.length >= maxMembers;
}

class GroupMemberModel {
  final String userId;
  final String groupId;
  final GroupMemberRole role;
  final DateTime joinedAt;
  final int contributionScore;
  final bool isActive;
  final Map<String, dynamic> stats;

  GroupMemberModel({
    required this.userId,
    required this.groupId,
    required this.role,
    required this.joinedAt,
    this.contributionScore = 0,
    this.isActive = true,
    this.stats = const {},
  });

  factory GroupMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupMemberModel(
      userId: data['userId'] ?? '',
      groupId: data['groupId'] ?? '',
      role: GroupMemberRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => GroupMemberRole.member,
      ),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      contributionScore: data['contributionScore'] ?? 0,
      isActive: data['isActive'] ?? true,
      stats: data['stats'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'groupId': groupId,
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'contributionScore': contributionScore,
      'isActive': isActive,
      'stats': stats,
    };
  }
}

class GroupPostModel {
  final String id;
  final String groupId;
  final String authorId;
  final String content;
  final List<String> imageUrls;
  final String? attachmentUrl;
  final String? attachmentType;
  final DateTime createdAt;
  final List<String> likedBy;
  final int commentsCount;
  final bool isPinned;
  final Map<String, dynamic> metadata;

  GroupPostModel({
    required this.id,
    required this.groupId,
    required this.authorId,
    required this.content,
    this.imageUrls = const [],
    this.attachmentUrl,
    this.attachmentType,
    required this.createdAt,
    this.likedBy = const [],
    this.commentsCount = 0,
    this.isPinned = false,
    this.metadata = const {},
  });

  factory GroupPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupPostModel(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      attachmentUrl: data['attachmentUrl'],
      attachmentType: data['attachmentType'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
      isPinned: data['isPinned'] ?? false,
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'authorId': authorId,
      'content': content,
      'imageUrls': imageUrls,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
      'commentsCount': commentsCount,
      'isPinned': isPinned,
      'metadata': metadata,
    };
  }

  int get likesCount => likedBy.length;
  bool isLikedBy(String userId) => likedBy.contains(userId);
}

class PostCommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final List<String> likedBy;
  final String? parentCommentId; // For nested replies

  PostCommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.likedBy = const [],
    this.parentCommentId,
  });

  factory PostCommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostCommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      parentCommentId: data['parentCommentId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorId': authorId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
      'parentCommentId': parentCommentId,
    };
  }

  int get likesCount => likedBy.length;
  bool isLikedBy(String userId) => likedBy.contains(userId);
}

class UserFollowModel {
  final String followerId;
  final String followingId;
  final DateTime followedAt;
  final bool isActive;

  UserFollowModel({
    required this.followerId,
    required this.followingId,
    required this.followedAt,
    this.isActive = true,
  });

  factory UserFollowModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserFollowModel(
      followerId: data['followerId'] ?? '',
      followingId: data['followingId'] ?? '',
      followedAt: (data['followedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'followerId': followerId,
      'followingId': followingId,
      'followedAt': Timestamp.fromDate(followedAt),
      'isActive': isActive,
    };
  }
}

class SocialActivityModel {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final bool isPublic;

  SocialActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.data = const {},
    this.isPublic = true,
  });

  factory SocialActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ActivityType.quiz_completed,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      data: data['data'] ?? {},
      isPublic: data['isPublic'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'data': data,
      'isPublic': isPublic,
    };
  }
}

class SharedContentModel {
  final String id;
  final String sharedBy;
  final String contentType; // 'quiz', 'note', 'achievement'
  final String contentId;
  final String? message;
  final List<String> sharedWith; // User IDs or group IDs
  final DateTime sharedAt;
  final int viewCount;
  final Map<String, dynamic> contentData;

  SharedContentModel({
    required this.id,
    required this.sharedBy,
    required this.contentType,
    required this.contentId,
    this.message,
    this.sharedWith = const [],
    required this.sharedAt,
    this.viewCount = 0,
    this.contentData = const {},
  });

  factory SharedContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SharedContentModel(
      id: doc.id,
      sharedBy: data['sharedBy'] ?? '',
      contentType: data['contentType'] ?? '',
      contentId: data['contentId'] ?? '',
      message: data['message'],
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      sharedAt: (data['sharedAt'] as Timestamp).toDate(),
      viewCount: data['viewCount'] ?? 0,
      contentData: data['contentData'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sharedBy': sharedBy,
      'contentType': contentType,
      'contentId': contentId,
      'message': message,
      'sharedWith': sharedWith,
      'sharedAt': Timestamp.fromDate(sharedAt),
      'viewCount': viewCount,
      'contentData': contentData,
    };
  }
}

class UserSocialProfileModel {
  final String userId;
  final String bio;
  final String? profileImageUrl;
  final List<String> interests;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isPublic;
  final DateTime lastActive;
  final Map<String, dynamic> socialStats;

  UserSocialProfileModel({
    required this.userId,
    this.bio = '',
    this.profileImageUrl,
    this.interests = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isPublic = true,
    required this.lastActive,
    this.socialStats = const {},
  });

  factory UserSocialProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSocialProfileModel(
      userId: doc.id,
      bio: data['bio'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      interests: List<String>.from(data['interests'] ?? []),
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      isPublic: data['isPublic'] ?? true,
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      socialStats: data['socialStats'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'interests': interests,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isPublic': isPublic,
      'lastActive': Timestamp.fromDate(lastActive),
      'socialStats': socialStats,
    };
  }
}