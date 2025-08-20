import 'package:flutter/foundation.dart';
import '../models/video_models.dart';
import '../models/user_model.dart';
import '../services/video_lecture_service.dart';
import '../../features/coins/providers/coin_provider.dart';

class VideoProvider with ChangeNotifier {
  final VideoLectureService _videoService = VideoLectureService();
  
  // State variables
  List<VideoLectureModel> _videos = [];
  List<VideoLectureModel> _featuredVideos = [];
  List<UserVideoProgressModel> _userProgress = [];
  List<VideoPlaylistModel> _playlists = [];
  
  bool _isLoading = false;
  bool _isLoadingFeatured = false;
  bool _isLoadingProgress = false;
  String _error = '';
  
  VideoCategory? _selectedCategory;
  VideoAccessLevel? _selectedAccessLevel;
  String _searchQuery = '';

  // Getters
  List<VideoLectureModel> get videos => _videos;
  List<VideoLectureModel> get featuredVideos => _featuredVideos;
  List<UserVideoProgressModel> get userProgress => _userProgress;
  List<VideoPlaylistModel> get playlists => _playlists;
  
  bool get isLoading => _isLoading;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingProgress => _isLoadingProgress;
  String get error => _error;
  
  VideoCategory? get selectedCategory => _selectedCategory;
  VideoAccessLevel? get selectedAccessLevel => _selectedAccessLevel;
  String get searchQuery => _searchQuery;

  // Load videos with filters
  Future<void> loadVideos({
    VideoCategory? category,
    VideoAccessLevel? accessLevel,
    String? targetRole,
    int limit = 20,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final videos = await _videoService.getVideos(
        category: category,
        accessLevel: accessLevel,
        targetRole: targetRole,
        limit: limit,
      );

      _videos = videos;
      _selectedCategory = category;
      _selectedAccessLevel = accessLevel;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load featured videos
  Future<void> loadFeaturedVideos(String? targetRole, {int limit = 10}) async {
    try {
      _isLoadingFeatured = true;
      notifyListeners();

      final featuredVideos = await _videoService.getFeaturedVideos(targetRole, limit: limit);
      _featuredVideos = featuredVideos;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  // Search videos
  Future<void> searchVideos({
    required String query,
    String? targetRole,
    VideoCategory? category,
    int limit = 20,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      _searchQuery = query;
      notifyListeners();

      if (query.isEmpty) {
        await loadVideos(category: category, targetRole: targetRole, limit: limit);
        return;
      }

      final searchResults = await _videoService.searchVideos(
        query: query,
        targetRole: targetRole,
        category: category,
        limit: limit,
      );

      _videos = searchResults;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user's watch history and progress
  Future<void> loadUserProgress(String userId) async {
    try {
      _isLoadingProgress = true;
      notifyListeners();

      final userProgress = await _videoService.getUserWatchHistory(userId);
      _userProgress = userProgress;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingProgress = false;
      notifyListeners();
    }
  }

  // Get specific video by ID
  Future<VideoLectureModel?> getVideoById(String videoId) async {
    try {
      return await _videoService.getVideoById(videoId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Get user progress for specific video
  Future<UserVideoProgressModel?> getUserVideoProgress(String userId, String videoId) async {
    try {
      return await _videoService.getUserProgress(userId, videoId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update video progress
  Future<void> updateVideoProgress({
    required String userId,
    required String videoId,
    required int currentPosition,
    required double watchedPercentage,
    bool? isCompleted,
    VideoQuality? selectedQuality,
    SubtitleLanguage? selectedSubtitleLanguage,
    double? playbackSpeed,
    int? additionalWatchTime,
  }) async {
    try {
      await _videoService.updateVideoProgress(
        userId: userId,
        videoId: videoId,
        currentPosition: currentPosition,
        watchedPercentage: watchedPercentage,
        isCompleted: isCompleted,
        selectedQuality: selectedQuality,
        selectedSubtitleLanguage: selectedSubtitleLanguage,
        playbackSpeed: playbackSpeed,
        additionalWatchTime: additionalWatchTime,
      );

      // Update local state
      final existingIndex = _userProgress.indexWhere(
        (progress) => progress.userId == userId && progress.videoId == videoId,
      );

      if (existingIndex >= 0) {
        final existing = _userProgress[existingIndex];
        final updated = UserVideoProgressModel(
          id: existing.id,
          userId: existing.userId,
          videoId: existing.videoId,
          currentPosition: currentPosition,
          watchedPercentage: watchedPercentage,
          isCompleted: isCompleted ?? existing.isCompleted,
          bookmarks: existing.bookmarks,
          notes: existing.notes,
          selectedQuality: selectedQuality ?? existing.selectedQuality,
          selectedSubtitleLanguage: selectedSubtitleLanguage ?? existing.selectedSubtitleLanguage,
          playbackSpeed: playbackSpeed ?? existing.playbackSpeed,
          totalWatchTime: existing.totalWatchTime + (additionalWatchTime ?? 0),
          watchCount: existing.watchCount,
          lastWatchedAt: DateTime.now(),
          createdAt: existing.createdAt,
          watchData: existing.watchData,
        );
        
        _userProgress[existingIndex] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Video bookmark management
  Future<void> addVideoBookmark({
    required String userId,
    required String videoId,
    required int timestamp,
    required String title,
    String note = '',
  }) async {
    try {
      await _videoService.addVideoBookmark(
        userId: userId,
        videoId: videoId,
        timestamp: timestamp,
        title: title,
        note: note,
      );

      // Update local state
      final progressIndex = _userProgress.indexWhere(
        (progress) => progress.userId == userId && progress.videoId == videoId,
      );

      if (progressIndex >= 0) {
        final newBookmark = VideoBookmarkModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: timestamp,
          title: title,
          note: note,
          createdAt: DateTime.now(),
        );

        final existing = _userProgress[progressIndex];
        final updatedBookmarks = [...existing.bookmarks, newBookmark];
        
        _userProgress[progressIndex] = UserVideoProgressModel(
          id: existing.id,
          userId: existing.userId,
          videoId: existing.videoId,
          currentPosition: existing.currentPosition,
          watchedPercentage: existing.watchedPercentage,
          isCompleted: existing.isCompleted,
          bookmarks: updatedBookmarks,
          notes: existing.notes,
          selectedQuality: existing.selectedQuality,
          selectedSubtitleLanguage: existing.selectedSubtitleLanguage,
          playbackSpeed: existing.playbackSpeed,
          totalWatchTime: existing.totalWatchTime,
          watchCount: existing.watchCount,
          lastWatchedAt: existing.lastWatchedAt,
          createdAt: existing.createdAt,
          watchData: existing.watchData,
        );
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteVideoBookmark({
    required String userId,
    required String videoId,
    required String bookmarkId,
  }) async {
    try {
      await _videoService.deleteVideoBookmark(
        userId: userId,
        videoId: videoId,
        bookmarkId: bookmarkId,
      );

      // Update local state
      final progressIndex = _userProgress.indexWhere(
        (progress) => progress.userId == userId && progress.videoId == videoId,
      );

      if (progressIndex >= 0) {
        final existing = _userProgress[progressIndex];
        final updatedBookmarks = existing.bookmarks
            .where((bookmark) => bookmark.id != bookmarkId)
            .toList();
        
        _userProgress[progressIndex] = UserVideoProgressModel(
          id: existing.id,
          userId: existing.userId,
          videoId: existing.videoId,
          currentPosition: existing.currentPosition,
          watchedPercentage: existing.watchedPercentage,
          isCompleted: existing.isCompleted,
          bookmarks: updatedBookmarks,
          notes: existing.notes,
          selectedQuality: existing.selectedQuality,
          selectedSubtitleLanguage: existing.selectedSubtitleLanguage,
          playbackSpeed: existing.playbackSpeed,
          totalWatchTime: existing.totalWatchTime,
          watchCount: existing.watchCount,
          lastWatchedAt: existing.lastWatchedAt,
          createdAt: existing.createdAt,
          watchData: existing.watchData,
        );
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Video note management
  Future<void> addVideoNote({
    required String userId,
    required String videoId,
    required int timestamp,
    required String content,
  }) async {
    try {
      await _videoService.addVideoNote(
        userId: userId,
        videoId: videoId,
        timestamp: timestamp,
        content: content,
      );

      // Update local state
      final progressIndex = _userProgress.indexWhere(
        (progress) => progress.userId == userId && progress.videoId == videoId,
      );

      if (progressIndex >= 0) {
        final newNote = VideoNoteModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: timestamp,
          content: content,
          createdAt: DateTime.now(),
        );

        final existing = _userProgress[progressIndex];
        final updatedNotes = [...existing.notes, newNote];
        
        _userProgress[progressIndex] = UserVideoProgressModel(
          id: existing.id,
          userId: existing.userId,
          videoId: existing.videoId,
          currentPosition: existing.currentPosition,
          watchedPercentage: existing.watchedPercentage,
          isCompleted: existing.isCompleted,
          bookmarks: existing.bookmarks,
          notes: updatedNotes,
          selectedQuality: existing.selectedQuality,
          selectedSubtitleLanguage: existing.selectedSubtitleLanguage,
          playbackSpeed: existing.playbackSpeed,
          totalWatchTime: existing.totalWatchTime,
          watchCount: existing.watchCount,
          lastWatchedAt: existing.lastWatchedAt,
          createdAt: existing.createdAt,
          watchData: existing.watchData,
        );
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateVideoNote({
    required String userId,
    required String videoId,
    required String noteId,
    required String content,
  }) async {
    try {
      await _videoService.updateVideoNote(
        userId: userId,
        videoId: videoId,
        noteId: noteId,
        content: content,
      );

      // Update local state
      final progressIndex = _userProgress.indexWhere(
        (progress) => progress.userId == userId && progress.videoId == videoId,
      );

      if (progressIndex >= 0) {
        final existing = _userProgress[progressIndex];
        final updatedNotes = existing.notes.map((note) {
          if (note.id == noteId) {
            return VideoNoteModel(
              id: note.id,
              timestamp: note.timestamp,
              content: content,
              createdAt: note.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return note;
        }).toList();
        
        _userProgress[progressIndex] = UserVideoProgressModel(
          id: existing.id,
          userId: existing.userId,
          videoId: existing.videoId,
          currentPosition: existing.currentPosition,
          watchedPercentage: existing.watchedPercentage,
          isCompleted: existing.isCompleted,
          bookmarks: existing.bookmarks,
          notes: updatedNotes,
          selectedQuality: existing.selectedQuality,
          selectedSubtitleLanguage: existing.selectedSubtitleLanguage,
          playbackSpeed: existing.playbackSpeed,
          totalWatchTime: existing.totalWatchTime,
          watchCount: existing.watchCount,
          lastWatchedAt: existing.lastWatchedAt,
          createdAt: existing.createdAt,
          watchData: existing.watchData,
        );
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteVideoNote({
    required String userId,
    required String videoId,
    required String noteId,
  }) async {
    try {
      await _videoService.deleteVideoNote(
        userId: userId,
        videoId: videoId,
        noteId: noteId,
      );

      // Update local state
      final progressIndex = _userProgress.indexWhere(
        (progress) => progress.userId == userId && progress.videoId == videoId,
      );

      if (progressIndex >= 0) {
        final existing = _userProgress[progressIndex];
        final updatedNotes = existing.notes
            .where((note) => note.id != noteId)
            .toList();
        
        _userProgress[progressIndex] = UserVideoProgressModel(
          id: existing.id,
          userId: existing.userId,
          videoId: existing.videoId,
          currentPosition: existing.currentPosition,
          watchedPercentage: existing.watchedPercentage,
          isCompleted: existing.isCompleted,
          bookmarks: existing.bookmarks,
          notes: updatedNotes,
          selectedQuality: existing.selectedQuality,
          selectedSubtitleLanguage: existing.selectedSubtitleLanguage,
          playbackSpeed: existing.playbackSpeed,
          totalWatchTime: existing.totalWatchTime,
          watchCount: existing.watchCount,
          lastWatchedAt: existing.lastWatchedAt,
          createdAt: existing.createdAt,
          watchData: existing.watchData,
        );
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Playlist management
  Future<void> loadPlaylists({
    VideoCategory? category,
    String? targetRole,
    int limit = 20,
  }) async {
    try {
      final playlists = await _videoService.getPlaylists(
        category: category,
        targetRole: targetRole,
        limit: limit,
      );
      
      _playlists = playlists;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Premium access and coin integration
  Future<bool> hasAccessToVideo(String userId, String videoId) async {
    try {
      return await _videoService.hasAccessToVideo(userId, videoId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> purchaseVideoAccess({
    required String userId,
    required String videoId,
    required int coinCost,
    required CoinProvider coinProvider,
  }) async {
    try {
      // Check if user has enough coins
      if (!coinProvider.hasEnoughCoins(coinCost)) {
        _error = 'Insufficient coins';
        notifyListeners();
        return false;
      }

      // Deduct coins
      final success = await coinProvider.processPayment(
        userId: userId,
        featureType: 'video_access',
        amount: coinCost,
      );

      if (success) {
        // Grant access by updating user progress (this would typically be handled by the backend)
        // For now, we'll simulate successful access
        return true;
      }

      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Award coins for video completion and milestones
  Future<void> awardVideoCompletionCoins({
    required String userId,
    required String videoId,
    required double completionPercentage,
    required CoinProvider coinProvider,
  }) async {
    try {
      // Award coins for different completion milestones
      if (completionPercentage >= 1.0) {
        // Full video completion
        await coinProvider.awardReadingCoins(
          userId: userId,
          ebookId: videoId,
          progressIncrement: 1.0,
          bookCompleted: true,
        );
      } else if (completionPercentage >= 0.5) {
        // 50% completion milestone
        await coinProvider.awardReadingCoins(
          userId: userId,
          ebookId: videoId,
          progressIncrement: 0.5,
          chapterCompleted: true,
        );
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get video analytics
  Future<Map<String, dynamic>> getVideoAnalytics(String videoId) async {
    try {
      return await _videoService.getVideoAnalytics(videoId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  // Get user video statistics
  Future<Map<String, dynamic>> getUserVideoStatistics(String userId) async {
    try {
      return await _videoService.getUserVideoStatistics(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  // Download management
  Future<bool> canDownloadVideo(String userId, String videoId) async {
    try {
      return await _videoService.canDownloadVideo(userId, videoId);
    } catch (e) {
      return false;
    }
  }

  Future<void> markVideoAsDownloaded(String userId, String videoId) async {
    try {
      await _videoService.markVideoAsDownloaded(userId, videoId);
      
      // Update local state if needed
      final progressIndex = _userProgress.indexWhere(
        (progress) => progress.userId == userId && progress.videoId == videoId,
      );

      if (progressIndex >= 0) {
        final existing = _userProgress[progressIndex];
        final updatedWatchData = Map<String, dynamic>.from(existing.watchData);
        updatedWatchData['isDownloaded'] = true;
        updatedWatchData['downloadedAt'] = DateTime.now().toIso8601String();
        
        _userProgress[progressIndex] = UserVideoProgressModel(
          id: existing.id,
          userId: existing.userId,
          videoId: existing.videoId,
          currentPosition: existing.currentPosition,
          watchedPercentage: existing.watchedPercentage,
          isCompleted: existing.isCompleted,
          bookmarks: existing.bookmarks,
          notes: existing.notes,
          selectedQuality: existing.selectedQuality,
          selectedSubtitleLanguage: existing.selectedSubtitleLanguage,
          playbackSpeed: existing.playbackSpeed,
          totalWatchTime: existing.totalWatchTime,
          watchCount: existing.watchCount,
          lastWatchedAt: existing.lastWatchedAt,
          createdAt: existing.createdAt,
          watchData: updatedWatchData,
        );
        
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Utility methods
  void clearError() {
    _error = '';
    notifyListeners();
  }

  void setSelectedCategory(VideoCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedAccessLevel(VideoAccessLevel? accessLevel) {
    _selectedAccessLevel = accessLevel;
    notifyListeners();
  }

  UserVideoProgressModel? getUserProgressForVideo(String userId, String videoId) {
    try {
      return _userProgress.firstWhere(
        (progress) => progress.userId == userId && progress.videoId == videoId,
      );
    } catch (e) {
      return null;
    }
  }

  List<VideoLectureModel> getVideosByCategory(VideoCategory category) {
    return _videos.where((video) => video.category == category).toList();
  }

  List<VideoLectureModel> getVideosByInstructor(String instructor) {
    return _videos.where((video) => video.instructor == instructor).toList();
  }

  List<UserVideoProgressModel> getInProgressVideos(String userId) {
    return _userProgress
        .where((progress) => 
            progress.userId == userId && 
            progress.watchedPercentage > 0 && 
            progress.watchedPercentage < 1.0)
        .toList();
  }

  List<UserVideoProgressModel> getCompletedVideos(String userId) {
    return _userProgress
        .where((progress) => 
            progress.userId == userId && 
            progress.isCompleted)
        .toList();
  }

  // Get user's learning statistics
  Map<String, dynamic> getUserLearningStats(String userId) {
    final userVideos = _userProgress.where((p) => p.userId == userId).toList();
    
    final totalVideosStarted = userVideos.length;
    final completedVideos = userVideos.where((p) => p.isCompleted).length;
    final inProgressVideos = userVideos.where(
      (p) => p.watchedPercentage > 0 && p.watchedPercentage < 1.0,
    ).length;
    final totalWatchTime = userVideos.fold<int>(
      0,
      (sum, p) => sum + p.totalWatchTime,
    );
    final averageProgress = userVideos.isEmpty 
        ? 0.0 
        : userVideos.fold<double>(
            0.0,
            (sum, p) => sum + p.watchedPercentage,
          ) / totalVideosStarted;
    final totalBookmarks = userVideos.fold<int>(
      0,
      (sum, p) => sum + p.bookmarks.length,
    );
    final totalNotes = userVideos.fold<int>(
      0,
      (sum, p) => sum + p.notes.length,
    );

    return {
      'totalVideosStarted': totalVideosStarted,
      'completedVideos': completedVideos,
      'inProgressVideos': inProgressVideos,
      'totalWatchTime': totalWatchTime,
      'averageProgress': averageProgress,
      'totalBookmarks': totalBookmarks,
      'totalNotes': totalNotes,
      'completionRate': totalVideosStarted > 0 ? completedVideos / totalVideosStarted : 0.0,
    };
  }
}