import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social_models.dart';
import '../models/user_model.dart';
import '../services/social_service.dart';

enum SocialState {
  idle,
  loading,
  loaded,
  error
}

class SocialProvider extends ChangeNotifier {
  final SocialService _socialService = SocialService();

  // State management
  SocialState _state = SocialState.idle;
  String? _errorMessage;

  // Study Groups
  List<StudyGroupModel> _studyGroups = [];
  List<StudyGroupModel> _userStudyGroups = [];
  StudyGroupModel? _selectedGroup;
  List<GroupPostModel> _groupPosts = [];
  List<PostCommentModel> _postComments = [];

  // Social feed
  List<SocialActivityModel> _feedActivities = [];
  DocumentSnapshot? _lastActivityDocument;

  // User relationships
  List<UserModel> _followers = [];
  List<UserModel> _following = [];
  Map<String, bool> _followingStatus = {}; // userId -> isFollowing

  // User profiles
  UserSocialProfileModel? _currentUserProfile;
  Map<String, UserSocialProfileModel> _userProfiles = {};

  // Search results
  List<UserModel> _searchUsers = [];
  List<StudyGroupModel> _searchGroups = [];

  // Getters
  SocialState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == SocialState.loading;

  List<StudyGroupModel> get studyGroups => _studyGroups;
  List<StudyGroupModel> get userStudyGroups => _userStudyGroups;
  StudyGroupModel? get selectedGroup => _selectedGroup;
  List<GroupPostModel> get groupPosts => _groupPosts;
  List<PostCommentModel> get postComments => _postComments;

  List<SocialActivityModel> get feedActivities => _feedActivities;
  List<UserModel> get followers => _followers;
  List<UserModel> get following => _following;

  UserSocialProfileModel? get currentUserProfile => _currentUserProfile;
  List<UserModel> get searchUsers => _searchUsers;
  List<StudyGroupModel> get searchGroups => _searchGroups;

  // Study Groups Management
  Future<void> loadStudyGroups({
    String? targetRole,
    String? category,
    StudyGroupType? type,
  }) async {
    try {
      _setState(SocialState.loading);
      _studyGroups = await _socialService.getStudyGroups(
        targetRole: targetRole,
        category: category,
        type: type,
      );
      _setState(SocialState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadUserStudyGroups(String userId) async {
    try {
      _userStudyGroups = await _socialService.getUserStudyGroups(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<String> createStudyGroup({
    required String name,
    required String description,
    required String category,
    required String targetRole,
    required String createdBy,
    StudyGroupType type = StudyGroupType.public,
    int maxMembers = 50,
  }) async {
    try {
      _setState(SocialState.loading);
      
      final group = StudyGroupModel(
        id: '',
        name: name,
        description: description,
        category: category,
        targetRole: targetRole,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        type: type,
        maxMembers: maxMembers,
      );

      final groupId = await _socialService.createStudyGroup(group);
      
      // Reload user's groups
      await loadUserStudyGroups(createdBy);
      
      _setState(SocialState.loaded);
      return groupId;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> joinStudyGroup(String groupId, String userId) async {
    try {
      await _socialService.joinStudyGroup(groupId, userId);
      
      // Update local state
      final groupIndex = _studyGroups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final updatedGroup = StudyGroupModel(
          id: _studyGroups[groupIndex].id,
          name: _studyGroups[groupIndex].name,
          description: _studyGroups[groupIndex].description,
          imageUrl: _studyGroups[groupIndex].imageUrl,
          type: _studyGroups[groupIndex].type,
          category: _studyGroups[groupIndex].category,
          targetRole: _studyGroups[groupIndex].targetRole,
          createdBy: _studyGroups[groupIndex].createdBy,
          createdAt: _studyGroups[groupIndex].createdAt,
          memberIds: [..._studyGroups[groupIndex].memberIds, userId],
          maxMembers: _studyGroups[groupIndex].maxMembers,
          isActive: _studyGroups[groupIndex].isActive,
          settings: _studyGroups[groupIndex].settings,
        );
        
        _studyGroups[groupIndex] = updatedGroup;
        
        if (_selectedGroup?.id == groupId) {
          _selectedGroup = updatedGroup;
        }
      }
      
      // Reload user's groups
      await loadUserStudyGroups(userId);
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> leaveStudyGroup(String groupId, String userId) async {
    try {
      await _socialService.leaveStudyGroup(groupId, userId);
      
      // Update local state
      final groupIndex = _studyGroups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final memberIds = List<String>.from(_studyGroups[groupIndex].memberIds);
        memberIds.remove(userId);
        
        final updatedGroup = StudyGroupModel(
          id: _studyGroups[groupIndex].id,
          name: _studyGroups[groupIndex].name,
          description: _studyGroups[groupIndex].description,
          imageUrl: _studyGroups[groupIndex].imageUrl,
          type: _studyGroups[groupIndex].type,
          category: _studyGroups[groupIndex].category,
          targetRole: _studyGroups[groupIndex].targetRole,
          createdBy: _studyGroups[groupIndex].createdBy,
          createdAt: _studyGroups[groupIndex].createdAt,
          memberIds: memberIds,
          maxMembers: _studyGroups[groupIndex].maxMembers,
          isActive: _studyGroups[groupIndex].isActive,
          settings: _studyGroups[groupIndex].settings,
        );
        
        _studyGroups[groupIndex] = updatedGroup;
        
        if (_selectedGroup?.id == groupId) {
          _selectedGroup = updatedGroup;
        }
      }
      
      // Reload user's groups
      await loadUserStudyGroups(userId);
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void selectGroup(StudyGroupModel group) {
    _selectedGroup = group;
    _groupPosts.clear();
    notifyListeners();
  }

  // Group Posts Management
  Future<void> loadGroupPosts(String groupId, {bool refresh = false}) async {
    try {
      if (refresh) {
        _groupPosts.clear();
      }
      
      final posts = await _socialService.getGroupPosts(groupId: groupId);
      
      if (refresh) {
        _groupPosts = posts;
      } else {
        _groupPosts.addAll(posts);
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<String> createGroupPost({
    required String groupId,
    required String authorId,
    required String content,
    List<String> imageUrls = const [],
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    try {
      final post = GroupPostModel(
        id: '',
        groupId: groupId,
        authorId: authorId,
        content: content,
        imageUrls: imageUrls,
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
        createdAt: DateTime.now(),
      );

      final postId = await _socialService.createGroupPost(post);
      
      // Reload posts
      await loadGroupPosts(groupId, refresh: true);
      
      return postId;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      await _socialService.likePost(postId, userId);
      
      // Update local state
      final postIndex = _groupPosts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final likedBy = List<String>.from(_groupPosts[postIndex].likedBy);
        if (!likedBy.contains(userId)) {
          likedBy.add(userId);
          
          _groupPosts[postIndex] = GroupPostModel(
            id: _groupPosts[postIndex].id,
            groupId: _groupPosts[postIndex].groupId,
            authorId: _groupPosts[postIndex].authorId,
            content: _groupPosts[postIndex].content,
            imageUrls: _groupPosts[postIndex].imageUrls,
            attachmentUrl: _groupPosts[postIndex].attachmentUrl,
            attachmentType: _groupPosts[postIndex].attachmentType,
            createdAt: _groupPosts[postIndex].createdAt,
            likedBy: likedBy,
            commentsCount: _groupPosts[postIndex].commentsCount,
            isPinned: _groupPosts[postIndex].isPinned,
            metadata: _groupPosts[postIndex].metadata,
          );
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _socialService.unlikePost(postId, userId);
      
      // Update local state
      final postIndex = _groupPosts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final likedBy = List<String>.from(_groupPosts[postIndex].likedBy);
        likedBy.remove(userId);
        
        _groupPosts[postIndex] = GroupPostModel(
          id: _groupPosts[postIndex].id,
          groupId: _groupPosts[postIndex].groupId,
          authorId: _groupPosts[postIndex].authorId,
          content: _groupPosts[postIndex].content,
          imageUrls: _groupPosts[postIndex].imageUrls,
          attachmentUrl: _groupPosts[postIndex].attachmentUrl,
          attachmentType: _groupPosts[postIndex].attachmentType,
          createdAt: _groupPosts[postIndex].createdAt,
          likedBy: likedBy,
          commentsCount: _groupPosts[postIndex].commentsCount,
          isPinned: _groupPosts[postIndex].isPinned,
          metadata: _groupPosts[postIndex].metadata,
        );
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Comments Management
  Future<void> loadPostComments(String postId) async {
    try {
      _postComments = await _socialService.getPostComments(postId: postId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<String> addComment({
    required String postId,
    required String authorId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final comment = PostCommentModel(
        id: '',
        postId: postId,
        authorId: authorId,
        content: content,
        createdAt: DateTime.now(),
        parentCommentId: parentCommentId,
      );

      final commentId = await _socialService.addComment(comment);
      
      // Reload comments
      await loadPostComments(postId);
      
      // Update post comment count in local state
      final postIndex = _groupPosts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _groupPosts[postIndex] = GroupPostModel(
          id: _groupPosts[postIndex].id,
          groupId: _groupPosts[postIndex].groupId,
          authorId: _groupPosts[postIndex].authorId,
          content: _groupPosts[postIndex].content,
          imageUrls: _groupPosts[postIndex].imageUrls,
          attachmentUrl: _groupPosts[postIndex].attachmentUrl,
          attachmentType: _groupPosts[postIndex].attachmentType,
          createdAt: _groupPosts[postIndex].createdAt,
          likedBy: _groupPosts[postIndex].likedBy,
          commentsCount: _groupPosts[postIndex].commentsCount + 1,
          isPinned: _groupPosts[postIndex].isPinned,
          metadata: _groupPosts[postIndex].metadata,
        );
      }
      
      return commentId;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // User Following
  Future<void> followUser(String followerId, String followingId) async {
    try {
      await _socialService.followUser(followerId, followingId);
      _followingStatus[followingId] = true;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      await _socialService.unfollowUser(followerId, followingId);
      _followingStatus[followingId] = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> checkIfFollowing(String followerId, String followingId) async {
    try {
      if (_followingStatus.containsKey(followingId)) {
        return _followingStatus[followingId]!;
      }
      
      final isFollowing = await _socialService.isFollowing(followerId, followingId);
      _followingStatus[followingId] = isFollowing;
      return isFollowing;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadFollowers(String userId) async {
    try {
      _followers = await _socialService.getFollowers(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadFollowing(String userId) async {
    try {
      _following = await _socialService.getFollowing(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Social Feed
  Future<void> loadFeedActivities(String userId, {bool refresh = false}) async {
    try {
      if (refresh) {
        _feedActivities.clear();
        _lastActivityDocument = null;
      }
      
      final activities = await _socialService.getFeedActivities(
        userId: userId,
        lastDocument: _lastActivityDocument,
      );
      
      if (refresh) {
        _feedActivities = activities;
      } else {
        _feedActivities.addAll(activities);
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // User Profile
  Future<void> loadUserSocialProfile(String userId) async {
    try {
      final profile = await _socialService.getUserSocialProfile(userId);
      
      if (userId == _currentUserProfile?.userId) {
        _currentUserProfile = profile;
      }
      
      _userProfiles[userId] = profile;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateCurrentUserProfile(UserSocialProfileModel profile) async {
    try {
      await _socialService.updateUserSocialProfile(profile);
      _currentUserProfile = profile;
      _userProfiles[profile.userId] = profile;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Search
  Future<void> searchUsers(String query, {String? role}) async {
    try {
      _searchUsers = await _socialService.searchUsers(query: query, role: role);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> searchStudyGroups(String query, {String? targetRole}) async {
    try {
      _searchGroups = await _socialService.searchStudyGroups(
        query: query,
        targetRole: targetRole,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
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
      return await _socialService.shareContent(
        sharedBy: sharedBy,
        contentType: contentType,
        contentId: contentId,
        message: message,
        sharedWith: sharedWith,
        contentData: contentData,
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Utility methods
  void _setState(SocialState newState) {
    _state = newState;
    if (newState != SocialState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _state = SocialState.error;
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == SocialState.error) {
      _state = SocialState.idle;
    }
    notifyListeners();
  }

  void clearSearchResults() {
    _searchUsers.clear();
    _searchGroups.clear();
    notifyListeners();
  }

  UserSocialProfileModel? getUserProfile(String userId) {
    return _userProfiles[userId];
  }

  bool isUserFollowed(String userId) {
    return _followingStatus[userId] ?? false;
  }
}