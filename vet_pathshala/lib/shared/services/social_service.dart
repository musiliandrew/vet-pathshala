import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social_models.dart';
import '../models/user_model.dart';

class SocialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Study Groups
  Future<String> createStudyGroup(StudyGroupModel group) async {
    try {
      final docRef = await _firestore.collection('study_groups').add(group.toFirestore());
      
      // Add creator as admin member
      await _addGroupMember(
        docRef.id,
        group.createdBy,
        GroupMemberRole.admin,
      );
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create study group: $e');
    }
  }

  Future<List<StudyGroupModel>> getStudyGroups({
    String? targetRole,
    String? category,
    StudyGroupType? type,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('study_groups')
          .where('isActive', isEqualTo: true);

      if (targetRole != null) {
        query = query.where('targetRole', isEqualTo: targetRole);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => StudyGroupModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get study groups: $e');
    }
  }

  Future<List<StudyGroupModel>> getUserStudyGroups(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('study_groups')
          .where('memberIds', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StudyGroupModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user study groups: $e');
    }
  }

  Future<void> joinStudyGroup(String groupId, String userId) async {
    try {
      final groupDoc = await _firestore.collection('study_groups').doc(groupId).get();
      
      if (!groupDoc.exists) {
        throw Exception('Study group not found');
      }

      final group = StudyGroupModel.fromFirestore(groupDoc);
      
      if (group.isFull) {
        throw Exception('Study group is full');
      }

      if (group.memberIds.contains(userId)) {
        throw Exception('Already a member of this group');
      }

      // Add user to group
      await _firestore.collection('study_groups').doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });

      // Add member record
      await _addGroupMember(groupId, userId, GroupMemberRole.member);

      // Create activity
      await _createSocialActivity(
        userId: userId,
        type: ActivityType.group_joined,
        title: 'Joined Study Group',
        description: 'Joined "${group.name}" study group',
        data: {'groupId': groupId, 'groupName': group.name},
      );
    } catch (e) {
      throw Exception('Failed to join study group: $e');
    }
  }

  Future<void> leaveStudyGroup(String groupId, String userId) async {
    try {
      // Remove user from group
      await _firestore.collection('study_groups').doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });

      // Update member record
      await _firestore
          .collection('group_members')
          .where('groupId', isEqualTo: groupId)
          .where('userId', isEqualTo: userId)
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.update({'isActive': false});
        }
      });
    } catch (e) {
      throw Exception('Failed to leave study group: $e');
    }
  }

  Future<void> _addGroupMember(String groupId, String userId, GroupMemberRole role) async {
    final member = GroupMemberModel(
      userId: userId,
      groupId: groupId,
      role: role,
      joinedAt: DateTime.now(),
    );

    await _firestore.collection('group_members').add(member.toFirestore());
  }

  // Group Posts
  Future<String> createGroupPost(GroupPostModel post) async {
    try {
      final docRef = await _firestore.collection('group_posts').add(post.toFirestore());
      
      // Update user's post count
      await _updateUserSocialStats(post.authorId, {'postsCount': FieldValue.increment(1)});
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create group post: $e');
    }
  }

  Future<List<GroupPostModel>> getGroupPosts({
    required String groupId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('group_posts')
          .where('groupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.limit(limit).get();

      return snapshot.docs
          .map((doc) => GroupPostModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get group posts: $e');
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      await _firestore.collection('group_posts').doc(postId).update({
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _firestore.collection('group_posts').doc(postId).update({
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  // Comments
  Future<String> addComment(PostCommentModel comment) async {
    try {
      final docRef = await _firestore.collection('post_comments').add(comment.toFirestore());
      
      // Update post comment count
      await _firestore.collection('group_posts').doc(comment.postId).update({
        'commentsCount': FieldValue.increment(1),
      });
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<List<PostCommentModel>> getPostComments({
    required String postId,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('post_comments')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: false)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostCommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get post comments: $e');
    }
  }

  // User Following
  Future<void> followUser(String followerId, String followingId) async {
    try {
      if (followerId == followingId) {
        throw Exception('Cannot follow yourself');
      }

      final follow = UserFollowModel(
        followerId: followerId,
        followingId: followingId,
        followedAt: DateTime.now(),
      );

      await _firestore.collection('user_follows').add(follow.toFirestore());

      // Update follower and following counts
      await _updateUserSocialStats(followerId, {
        'followingCount': FieldValue.increment(1),
      });
      
      await _updateUserSocialStats(followingId, {
        'followersCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      final snapshot = await _firestore
          .collection('user_follows')
          .where('followerId', isEqualTo: followerId)
          .where('followingId', isEqualTo: followingId)
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({'isActive': false});
      }

      // Update follower and following counts
      await _updateUserSocialStats(followerId, {
        'followingCount': FieldValue.increment(-1),
      });
      
      await _updateUserSocialStats(followingId, {
        'followersCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final snapshot = await _firestore
          .collection('user_follows')
          .where('followerId', isEqualTo: followerId)
          .where('followingId', isEqualTo: followingId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserModel>> getFollowers(String userId, {int limit = 20}) async {
    try {
      final followSnapshot = await _firestore
          .collection('user_follows')
          .where('followingId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();

      final followerIds = followSnapshot.docs
          .map((doc) => doc.data()['followerId'] as String)
          .toList();

      if (followerIds.isEmpty) return [];

      final userSnapshots = await Future.wait(
        followerIds.map((id) => _firestore.collection('users').doc(id).get())
      );

      return userSnapshots
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  Future<List<UserModel>> getFollowing(String userId, {int limit = 20}) async {
    try {
      final followSnapshot = await _firestore
          .collection('user_follows')
          .where('followerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();

      final followingIds = followSnapshot.docs
          .map((doc) => doc.data()['followingId'] as String)
          .toList();

      if (followingIds.isEmpty) return [];

      final userSnapshots = await Future.wait(
        followingIds.map((id) => _firestore.collection('users').doc(id).get())
      );

      return userSnapshots
          .where((doc) => doc.exists)
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }

  // Social Activities
  Future<void> _createSocialActivity({
    required String userId,
    required ActivityType type,
    required String title,
    required String description,
    Map<String, dynamic> data = const {},
    bool isPublic = true,
  }) async {
    try {
      final activity = SocialActivityModel(
        id: '',
        userId: userId,
        type: type,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        data: data,
        isPublic: isPublic,
      );

      await _firestore.collection('social_activities').add(activity.toFirestore());
    } catch (e) {
      print('Failed to create social activity: $e');
    }
  }

  Future<List<SocialActivityModel>> getFeedActivities({
    required String userId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      // Get user's following list
      final followingSnapshot = await _firestore
          .collection('user_follows')
          .where('followerId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final followingIds = followingSnapshot.docs
          .map((doc) => doc.data()['followingId'] as String)
          .toList();

      // Include user's own activities
      followingIds.add(userId);

      if (followingIds.isEmpty) return [];

      Query query = _firestore
          .collection('social_activities')
          .where('userId', whereIn: followingIds)
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.limit(limit).get();

      return snapshot.docs
          .map((doc) => SocialActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get feed activities: $e');
    }
  }

  // Content Sharing
  Future<String> shareContent({
    required String sharedBy,
    required String contentType,
    required String contentId,
    String? message,
    List<String> sharedWith = const [],
    Map<String, dynamic> contentData = const {},
  }) async {
    try {
      final sharedContent = SharedContentModel(
        id: '',
        sharedBy: sharedBy,
        contentType: contentType,
        contentId: contentId,
        message: message,
        sharedWith: sharedWith,
        sharedAt: DateTime.now(),
        contentData: contentData,
      );

      final docRef = await _firestore
          .collection('shared_content')
          .add(sharedContent.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to share content: $e');
    }
  }

  // User Social Profile
  Future<UserSocialProfileModel> getUserSocialProfile(String userId) async {
    try {
      final doc = await _firestore.collection('user_social_profiles').doc(userId).get();
      
      if (doc.exists) {
        return UserSocialProfileModel.fromFirestore(doc);
      } else {
        // Create default profile
        final defaultProfile = UserSocialProfileModel(
          userId: userId,
          lastActive: DateTime.now(),
        );
        
        await _firestore
            .collection('user_social_profiles')
            .doc(userId)
            .set(defaultProfile.toFirestore());
        
        return defaultProfile;
      }
    } catch (e) {
      throw Exception('Failed to get user social profile: $e');
    }
  }

  Future<void> updateUserSocialProfile(UserSocialProfileModel profile) async {
    try {
      await _firestore
          .collection('user_social_profiles')
          .doc(profile.userId)
          .update(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user social profile: $e');
    }
  }

  Future<void> _updateUserSocialStats(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('user_social_profiles')
          .doc(userId)
          .update(updates);
    } catch (e) {
      print('Failed to update user social stats: $e');
    }
  }

  // Search functionality
  Future<List<UserModel>> searchUsers({
    required String query,
    String? role,
    int limit = 20,
  }) async {
    try {
      Query userQuery = _firestore.collection('users');

      if (role != null) {
        userQuery = userQuery.where('userRole', isEqualTo: role);
      }

      // Firestore doesn't support full-text search, so we'll do client-side filtering
      final snapshot = await userQuery.limit(100).get();
      
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) =>
              user.displayName.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .take(limit)
          .toList();

      return users;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<List<StudyGroupModel>> searchStudyGroups({
    required String query,
    String? targetRole,
    int limit = 20,
  }) async {
    try {
      Query groupQuery = _firestore
          .collection('study_groups')
          .where('isActive', isEqualTo: true);

      if (targetRole != null) {
        groupQuery = groupQuery.where('targetRole', isEqualTo: targetRole);
      }

      final snapshot = await groupQuery.limit(100).get();
      
      final groups = snapshot.docs
          .map((doc) => StudyGroupModel.fromFirestore(doc))
          .where((group) =>
              group.name.toLowerCase().contains(query.toLowerCase()) ||
              group.description.toLowerCase().contains(query.toLowerCase()))
          .take(limit)
          .toList();

      return groups;
    } catch (e) {
      throw Exception('Failed to search study groups: $e');
    }
  }

  // Notification helpers
  Future<void> recordQuizCompletion({
    required String userId,
    required String quizTitle,
    required int score,
    required String category,
  }) async {
    await _createSocialActivity(
      userId: userId,
      type: ActivityType.quiz_completed,
      title: 'Quiz Completed',
      description: 'Scored $score% in $quizTitle',
      data: {
        'quizTitle': quizTitle,
        'score': score,
        'category': category,
      },
    );
  }

  Future<void> recordAchievement({
    required String userId,
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    await _createSocialActivity(
      userId: userId,
      type: ActivityType.achievement_unlocked,
      title: 'Achievement Unlocked',
      description: achievementTitle,
      data: {
        'achievementTitle': achievementTitle,
        'achievementDescription': achievementDescription,
      },
    );
  }

  Future<void> recordStudyStreak({
    required String userId,
    required int streakDays,
  }) async {
    await _createSocialActivity(
      userId: userId,
      type: ActivityType.study_streak,
      title: 'Study Streak',
      description: '$streakDays days study streak!',
      data: {
        'streakDays': streakDays,
      },
    );
  }
}