import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_models.dart';

class VideoLectureService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Video Lecture Management
  Future<List<VideoLectureModel>> getVideos({
    VideoCategory? category,
    VideoAccessLevel? accessLevel,
    String? targetRole,
    VideoStatus status = VideoStatus.published,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('video_lectures')
          .where('status', isEqualTo: status.name);

      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      if (accessLevel != null) {
        query = query.where('accessLevel', isEqualTo: accessLevel.name);
      }

      if (targetRole != null) {
        query = query.where('targetRoles', arrayContains: targetRole);
      }

      final snapshot = await query
          .orderBy('rating', descending: true)
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => VideoLectureModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get videos: $e');
    }
  }

  Future<VideoLectureModel?> getVideoById(String videoId) async {
    try {
      final doc = await _firestore.collection('video_lectures').doc(videoId).get();
      
      if (doc.exists) {
        return VideoLectureModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get video: $e');
    }
  }

  Future<List<VideoLectureModel>> searchVideos({
    required String query,
    String? targetRole,
    VideoCategory? category,
    int limit = 20,
  }) async {
    try {
      Query firestoreQuery = _firestore
          .collection('video_lectures')
          .where('status', isEqualTo: VideoStatus.published.name);

      if (targetRole != null) {
        firestoreQuery = firestoreQuery.where('targetRoles', arrayContains: targetRole);
      }

      if (category != null) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category.name);
      }

      final snapshot = await firestoreQuery.limit(100).get();
      
      final videos = snapshot.docs
          .map((doc) => VideoLectureModel.fromFirestore(doc))
          .where((video) =>
              video.title.toLowerCase().contains(query.toLowerCase()) ||
              video.description.toLowerCase().contains(query.toLowerCase()) ||
              video.instructor.toLowerCase().contains(query.toLowerCase()) ||
              video.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .take(limit)
          .toList();

      return videos;
    } catch (e) {
      throw Exception('Failed to search videos: $e');
    }
  }

  Future<List<VideoLectureModel>> getFeaturedVideos(String? targetRole, {int limit = 10}) async {
    try {
      Query query = _firestore
          .collection('video_lectures')
          .where('status', isEqualTo: VideoStatus.published.name);

      if (targetRole != null) {
        query = query.where('targetRoles', arrayContains: targetRole);
      }

      final snapshot = await query
          .orderBy('rating', descending: true)
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => VideoLectureModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get featured videos: $e');
    }
  }

  Future<List<VideoLectureModel>> getVideosByInstructor(String instructor, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('video_lectures')
          .where('instructor', isEqualTo: instructor)
          .where('status', isEqualTo: VideoStatus.published.name)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => VideoLectureModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get instructor videos: $e');
    }
  }

  // Video Progress Management
  Future<UserVideoProgressModel?> getUserProgress(String userId, String videoId) async {
    try {
      final snapshot = await _firestore
          .collection('user_video_progress')
          .where('userId', isEqualTo: userId)
          .where('videoId', isEqualTo: videoId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserVideoProgressModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user progress: $e');
    }
  }

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
      final existingProgress = await getUserProgress(userId, videoId);
      
      if (existingProgress != null) {
        // Update existing progress
        final updateData = <String, dynamic>{
          'currentPosition': currentPosition,
          'watchedPercentage': watchedPercentage,
          'lastWatchedAt': FieldValue.serverTimestamp(),
        };

        if (isCompleted != null) {
          updateData['isCompleted'] = isCompleted;
        }

        if (selectedQuality != null) {
          updateData['selectedQuality'] = selectedQuality.name;
        }

        if (selectedSubtitleLanguage != null) {
          updateData['selectedSubtitleLanguage'] = selectedSubtitleLanguage.name;
        }

        if (playbackSpeed != null) {
          updateData['playbackSpeed'] = playbackSpeed;
        }

        if (additionalWatchTime != null) {
          updateData['totalWatchTime'] = FieldValue.increment(additionalWatchTime);
        }

        await _firestore
            .collection('user_video_progress')
            .doc(existingProgress.id)
            .update(updateData);
      } else {
        // Create new progress record
        final newProgress = UserVideoProgressModel(
          id: '',
          userId: userId,
          videoId: videoId,
          currentPosition: currentPosition,
          watchedPercentage: watchedPercentage,
          isCompleted: isCompleted ?? false,
          bookmarks: [],
          notes: [],
          selectedQuality: selectedQuality ?? VideoQuality.auto,
          selectedSubtitleLanguage: selectedSubtitleLanguage,
          playbackSpeed: playbackSpeed ?? 1.0,
          totalWatchTime: additionalWatchTime ?? 0,
          watchCount: 1,
          lastWatchedAt: DateTime.now(),
          createdAt: DateTime.now(),
          watchData: {},
        );

        await _firestore
            .collection('user_video_progress')
            .add(newProgress.toFirestore());

        // Increment video view count
        await _firestore.collection('video_lectures').doc(videoId).update({
          'viewCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw Exception('Failed to update video progress: $e');
    }
  }

  Future<List<UserVideoProgressModel>> getUserWatchHistory(String userId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('user_video_progress')
          .where('userId', isEqualTo: userId)
          .orderBy('lastWatchedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserVideoProgressModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get watch history: $e');
    }
  }

  // Video Bookmarks Management
  Future<void> addVideoBookmark({
    required String userId,
    required String videoId,
    required int timestamp,
    required String title,
    String note = '',
  }) async {
    try {
      final userProgress = await getUserProgress(userId, videoId);
      
      if (userProgress != null) {
        final newBookmark = VideoBookmarkModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: timestamp,
          title: title,
          note: note,
          createdAt: DateTime.now(),
        );

        final updatedBookmarks = [...userProgress.bookmarks, newBookmark];

        await _firestore
            .collection('user_video_progress')
            .doc(userProgress.id)
            .update({
              'bookmarks': updatedBookmarks.map((b) => b.toMap()).toList(),
            });
      } else {
        // Create progress record with bookmark
        await updateVideoProgress(
          userId: userId,
          videoId: videoId,
          currentPosition: timestamp,
          watchedPercentage: 0.0,
        );
        
        // Add bookmark after creating progress
        await addVideoBookmark(
          userId: userId,
          videoId: videoId,
          timestamp: timestamp,
          title: title,
          note: note,
        );
      }
    } catch (e) {
      throw Exception('Failed to add video bookmark: $e');
    }
  }

  Future<void> deleteVideoBookmark({
    required String userId,
    required String videoId,
    required String bookmarkId,
  }) async {
    try {
      final userProgress = await getUserProgress(userId, videoId);
      
      if (userProgress != null) {
        final updatedBookmarks = userProgress.bookmarks
            .where((bookmark) => bookmark.id != bookmarkId)
            .toList();

        await _firestore
            .collection('user_video_progress')
            .doc(userProgress.id)
            .update({
              'bookmarks': updatedBookmarks.map((b) => b.toMap()).toList(),
            });
      }
    } catch (e) {
      throw Exception('Failed to delete video bookmark: $e');
    }
  }

  // Video Notes Management
  Future<void> addVideoNote({
    required String userId,
    required String videoId,
    required int timestamp,
    required String content,
  }) async {
    try {
      final userProgress = await getUserProgress(userId, videoId);
      
      if (userProgress != null) {
        final newNote = VideoNoteModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: timestamp,
          content: content,
          createdAt: DateTime.now(),
        );

        final updatedNotes = [...userProgress.notes, newNote];

        await _firestore
            .collection('user_video_progress')
            .doc(userProgress.id)
            .update({
              'notes': updatedNotes.map((n) => n.toMap()).toList(),
            });
      } else {
        // Create progress record with note
        await updateVideoProgress(
          userId: userId,
          videoId: videoId,
          currentPosition: timestamp,
          watchedPercentage: 0.0,
        );
        
        // Add note after creating progress
        await addVideoNote(
          userId: userId,
          videoId: videoId,
          timestamp: timestamp,
          content: content,
        );
      }
    } catch (e) {
      throw Exception('Failed to add video note: $e');
    }
  }

  Future<void> updateVideoNote({
    required String userId,
    required String videoId,
    required String noteId,
    required String content,
  }) async {
    try {
      final userProgress = await getUserProgress(userId, videoId);
      
      if (userProgress != null) {
        final updatedNotes = userProgress.notes.map((note) {
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

        await _firestore
            .collection('user_video_progress')
            .doc(userProgress.id)
            .update({
              'notes': updatedNotes.map((n) => n.toMap()).toList(),
            });
      }
    } catch (e) {
      throw Exception('Failed to update video note: $e');
    }
  }

  Future<void> deleteVideoNote({
    required String userId,
    required String videoId,
    required String noteId,
  }) async {
    try {
      final userProgress = await getUserProgress(userId, videoId);
      
      if (userProgress != null) {
        final updatedNotes = userProgress.notes
            .where((note) => note.id != noteId)
            .toList();

        await _firestore
            .collection('user_video_progress')
            .doc(userProgress.id)
            .update({
              'notes': updatedNotes.map((n) => n.toMap()).toList(),
            });
      }
    } catch (e) {
      throw Exception('Failed to delete video note: $e');
    }
  }

  // Playlist Management
  Future<List<VideoPlaylistModel>> getPlaylists({
    VideoCategory? category,
    String? targetRole,
    bool publicOnly = true,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('video_playlists');

      if (publicOnly) {
        query = query.where('isPublic', isEqualTo: true);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      if (targetRole != null) {
        query = query.where('targetRoles', arrayContains: targetRole);
      }

      final snapshot = await query
          .orderBy('rating', descending: true)
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => VideoPlaylistModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get playlists: $e');
    }
  }

  Future<VideoPlaylistModel?> getPlaylistById(String playlistId) async {
    try {
      final doc = await _firestore.collection('video_playlists').doc(playlistId).get();
      
      if (doc.exists) {
        return VideoPlaylistModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get playlist: $e');
    }
  }

  Future<List<VideoLectureModel>> getPlaylistVideos(String playlistId) async {
    try {
      final playlist = await getPlaylistById(playlistId);
      if (playlist == null) return [];

      final videos = <VideoLectureModel>[];
      for (final videoId in playlist.videoIds) {
        final video = await getVideoById(videoId);
        if (video != null) {
          videos.add(video);
        }
      }

      return videos;
    } catch (e) {
      throw Exception('Failed to get playlist videos: $e');
    }
  }

  // Video Quality and Streaming
  Future<Map<VideoQuality, String>> getVideoQualityUrls(String videoId) async {
    try {
      final video = await getVideoById(videoId);
      return video?.qualityUrls ?? {};
    } catch (e) {
      throw Exception('Failed to get video quality URLs: $e');
    }
  }

  Future<List<SubtitleModel>> getVideoSubtitles(String videoId) async {
    try {
      final video = await getVideoById(videoId);
      return video?.subtitles ?? [];
    } catch (e) {
      throw Exception('Failed to get video subtitles: $e');
    }
  }

  // Analytics and Statistics
  Future<Map<String, dynamic>> getVideoAnalytics(String videoId) async {
    try {
      final video = await getVideoById(videoId);
      if (video == null) return {};

      // Get user progress data for analytics
      final progressSnapshot = await _firestore
          .collection('user_video_progress')
          .where('videoId', isEqualTo: videoId)
          .get();

      final progressData = progressSnapshot.docs
          .map((doc) => UserVideoProgressModel.fromFirestore(doc))
          .toList();

      final totalViews = video.viewCount;
      final uniqueViewers = progressData.length;
      final completionRate = progressData.where((p) => p.isCompleted).length / 
          (uniqueViewers > 0 ? uniqueViewers : 1);
      final averageWatchTime = progressData.isEmpty 
          ? 0 
          : progressData.map((p) => p.totalWatchTime).reduce((a, b) => a + b) / uniqueViewers;
      final averageProgress = progressData.isEmpty
          ? 0.0
          : progressData.map((p) => p.watchedPercentage).reduce((a, b) => a + b) / uniqueViewers;

      return {
        'totalViews': totalViews,
        'uniqueViewers': uniqueViewers,
        'completionRate': completionRate,
        'averageWatchTime': averageWatchTime,
        'averageProgress': averageProgress,
        'rating': video.rating,
        'duration': video.duration,
        'bookmarkCount': progressData.fold<int>(0, (sum, p) => sum + p.bookmarks.length),
        'noteCount': progressData.fold<int>(0, (sum, p) => sum + p.notes.length),
      };
    } catch (e) {
      throw Exception('Failed to get video analytics: $e');
    }
  }

  Future<Map<String, dynamic>> getUserVideoStatistics(String userId) async {
    try {
      final progressData = await getUserWatchHistory(userId);

      final totalVideosWatched = progressData.length;
      final totalWatchTime = progressData.fold<int>(0, (sum, p) => sum + p.totalWatchTime);
      final completedVideos = progressData.where((p) => p.isCompleted).length;
      final averageProgress = progressData.isEmpty
          ? 0.0
          : progressData.map((p) => p.watchedPercentage).reduce((a, b) => a + b) / totalVideosWatched;
      final totalBookmarks = progressData.fold<int>(0, (sum, p) => sum + p.bookmarks.length);
      final totalNotes = progressData.fold<int>(0, (sum, p) => sum + p.notes.length);

      return {
        'totalVideosWatched': totalVideosWatched,
        'totalWatchTime': totalWatchTime,
        'completedVideos': completedVideos,
        'averageProgress': averageProgress,
        'totalBookmarks': totalBookmarks,
        'totalNotes': totalNotes,
        'completionRate': totalVideosWatched > 0 ? completedVideos / totalVideosWatched : 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get user video statistics: $e');
    }
  }

  // Premium Access Management
  Future<bool> hasAccessToVideo(String userId, String videoId) async {
    try {
      final video = await getVideoById(videoId);
      if (video == null) return false;

      // Free videos are always accessible
      if (video.accessLevel == VideoAccessLevel.free) {
        return true;
      }

      // Check if user has already accessed this video
      final userProgress = await getUserProgress(userId, videoId);
      if (userProgress != null) {
        return true;
      }

      // For premium videos, check subscription or coin balance
      // This would integrate with your existing payment/subscription system
      return false;
    } catch (e) {
      return false;
    }
  }

  // Video Download Management
  Future<bool> canDownloadVideo(String userId, String videoId) async {
    try {
      final video = await getVideoById(videoId);
      if (video == null || !video.isDownloadable) return false;

      return await hasAccessToVideo(userId, videoId);
    } catch (e) {
      return false;
    }
  }

  Future<void> markVideoAsDownloaded(String userId, String videoId) async {
    try {
      final userProgress = await getUserProgress(userId, videoId);
      
      if (userProgress != null) {
        await _firestore
            .collection('user_video_progress')
            .doc(userProgress.id)
            .update({
              'watchData.isDownloaded': true,
              'watchData.downloadedAt': FieldValue.serverTimestamp(),
            });

        // Increment download count
        await _firestore.collection('video_lectures').doc(videoId).update({
          'downloadCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw Exception('Failed to mark video as downloaded: $e');
    }
  }

  // Sample Data Generation (for development)
  Future<void> createSampleVideoData() async {
    final sampleVideos = [
      VideoLectureModel(
        id: 'video_1',
        title: 'Canine Anatomy: Heart and Cardiovascular System',
        description: 'Complete guide to understanding canine cardiovascular anatomy, including heart chambers, valves, and blood circulation pathways.',
        instructor: 'Dr. Sarah Johnson',
        instructorBio: 'DVM, PhD in Veterinary Cardiology with 15+ years experience',
        thumbnailUrl: 'https://example.com/thumbnails/heart_anatomy.jpg',
        videoUrl: 'https://example.com/videos/heart_anatomy.mp4',
        targetRoles: ['Doctor', 'Student'],
        category: VideoCategory.anatomy,
        accessLevel: VideoAccessLevel.free,
        status: VideoStatus.published,
        duration: 1800, // 30 minutes
        coinCost: 0,
        qualityUrls: {
          VideoQuality.sd_480: 'https://example.com/videos/heart_480p.mp4',
          VideoQuality.hd_720: 'https://example.com/videos/heart_720p.mp4',
          VideoQuality.hd_1080: 'https://example.com/videos/heart_1080p.mp4',
        },
        chapters: [
          VideoChapterModel(
            id: 'chapter_1',
            title: 'Introduction to Cardiac Anatomy',
            description: 'Overview of heart structure',
            startTime: 0,
            endTime: 300,
            thumbnailUrl: 'https://example.com/chapters/intro.jpg',
            keyPoints: ['Heart chambers', 'Anatomical position'],
            metadata: {},
          ),
          VideoChapterModel(
            id: 'chapter_2',
            title: 'Heart Valves and Function',
            description: 'Detailed valve anatomy',
            startTime: 300,
            endTime: 900,
            thumbnailUrl: 'https://example.com/chapters/valves.jpg',
            keyPoints: ['Tricuspid valve', 'Mitral valve', 'Aortic valve'],
            metadata: {},
          ),
        ],
        subtitles: [
          SubtitleModel(
            id: 'sub_1',
            language: SubtitleLanguage.english,
            languageCode: 'en',
            subtitleUrl: 'https://example.com/subtitles/heart_en.vtt',
            cues: [],
            isDefault: true,
          ),
        ],
        rating: 4.8,
        viewCount: 1250,
        downloadCount: 380,
        isDownloadable: true,
        metadata: {'difficulty': 'intermediate', 'credits': 2},
        tags: ['heart', 'cardiology', 'anatomy', 'veterinary'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        publishedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      // Add more sample videos as needed
    ];

    // This would be used in development/testing
    print('Sample video data structure ready for implementation');
  }
}