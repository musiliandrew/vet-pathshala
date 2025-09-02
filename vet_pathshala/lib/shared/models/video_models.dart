import 'package:cloud_firestore/cloud_firestore.dart';

// Enums for video system
enum VideoQuality { 
  auto, 
  sd_360, 
  sd_480, 
  hd_720, 
  hd_1080,
  uhd_4k 
}

enum VideoStatus { 
  draft, 
  published, 
  archived, 
  processing 
}

enum VideoAccessLevel { 
  free, 
  premium, 
  subscription, 
  coins 
}

enum SubtitleLanguage { 
  english, 
  hindi, 
  spanish, 
  french, 
  german 
}

enum VideoCategory {
  anatomy,
  physiology,
  pathology,
  pharmacology,
  surgery,
  medicine,
  reproduction,
  nutrition,
  behavior,
  emergency,
  diagnostics,
  clinical_skills
}

// Main video lecture model
class VideoLectureModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String instructorBio;
  final String thumbnailUrl;
  final String videoUrl;
  final List<String> targetRoles;
  final VideoCategory category;
  final VideoAccessLevel accessLevel;
  final VideoStatus status;
  final int duration; // in seconds
  final int coinCost;
  final Map<VideoQuality, String> qualityUrls;
  final List<VideoChapterModel> chapters;
  final List<SubtitleModel> subtitles;
  final double rating;
  final int viewCount;
  final int downloadCount;
  final bool isDownloadable;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  VideoLectureModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.instructorBio,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.targetRoles,
    required this.category,
    required this.accessLevel,
    required this.status,
    required this.duration,
    required this.coinCost,
    required this.qualityUrls,
    required this.chapters,
    required this.subtitles,
    required this.rating,
    required this.viewCount,
    required this.downloadCount,
    required this.isDownloadable,
    required this.metadata,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  factory VideoLectureModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VideoLectureModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructor: data['instructor'] ?? '',
      instructorBio: data['instructorBio'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      targetRoles: List<String>.from(data['targetRoles'] ?? []),
      category: VideoCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => VideoCategory.anatomy,
      ),
      accessLevel: VideoAccessLevel.values.firstWhere(
        (e) => e.name == data['accessLevel'],
        orElse: () => VideoAccessLevel.free,
      ),
      status: VideoStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => VideoStatus.draft,
      ),
      duration: data['duration'] ?? 0,
      coinCost: data['coinCost'] ?? 0,
      qualityUrls: Map<VideoQuality, String>.from(
        (data['qualityUrls'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(
            VideoQuality.values.firstWhere(
              (e) => e.name == key,
              orElse: () => VideoQuality.auto,
            ),
            value.toString(),
          ),
        ),
      ),
      chapters: (data['chapters'] as List<dynamic>? ?? [])
          .map((chapter) => VideoChapterModel.fromMap(chapter))
          .toList(),
      subtitles: (data['subtitles'] as List<dynamic>? ?? [])
          .map((subtitle) => SubtitleModel.fromMap(subtitle))
          .toList(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      viewCount: data['viewCount'] ?? 0,
      downloadCount: data['downloadCount'] ?? 0,
      isDownloadable: data['isDownloadable'] ?? false,
      metadata: data['metadata'] ?? {},
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
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
      'targetRoles': targetRoles,
      'category': category.name,
      'accessLevel': accessLevel.name,
      'status': status.name,
      'duration': duration,
      'coinCost': coinCost,
      'qualityUrls': qualityUrls.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
      'subtitles': subtitles.map((subtitle) => subtitle.toMap()).toList(),
      'rating': rating,
      'viewCount': viewCount,
      'downloadCount': downloadCount,
      'isDownloadable': isDownloadable,
      'metadata': metadata,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
    };
  }

  // JSON methods for caching
  factory VideoLectureModel.fromJson(Map<String, dynamic> json) {
    return VideoLectureModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      instructorBio: json['instructorBio'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      targetRoles: List<String>.from(json['targetRoles'] ?? []),
      category: VideoCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => VideoCategory.anatomy,
      ),
      accessLevel: VideoAccessLevel.values.firstWhere(
        (e) => e.name == json['accessLevel'],
        orElse: () => VideoAccessLevel.free,
      ),
      status: VideoStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VideoStatus.draft,
      ),
      duration: json['duration'] ?? 0,
      coinCost: json['coinCost'] ?? 0,
      qualityUrls: Map<VideoQuality, String>.from(
        (json['qualityUrls'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(
            VideoQuality.values.firstWhere(
              (e) => e.name == key,
              orElse: () => VideoQuality.auto,
            ),
            value.toString(),
          ),
        ),
      ),
      chapters: (json['chapters'] as List<dynamic>? ?? [])
          .map((chapter) => VideoChapterModel.fromMap(chapter))
          .toList(),
      subtitles: (json['subtitles'] as List<dynamic>? ?? [])
          .map((subtitle) => SubtitleModel.fromMap(subtitle))
          .toList(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      viewCount: json['viewCount'] ?? 0,
      downloadCount: json['downloadCount'] ?? 0,
      isDownloadable: json['isDownloadable'] ?? false,
      metadata: json['metadata'] ?? {},
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'instructorBio': instructorBio,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'targetRoles': targetRoles,
      'category': category.name,
      'accessLevel': accessLevel.name,
      'status': status.name,
      'duration': duration,
      'coinCost': coinCost,
      'qualityUrls': qualityUrls.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
      'subtitles': subtitles.map((subtitle) => subtitle.toMap()).toList(),
      'rating': rating,
      'viewCount': viewCount,
      'downloadCount': downloadCount,
      'isDownloadable': isDownloadable,
      'metadata': metadata,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

// Video chapter model for navigation
class VideoChapterModel {
  final String id;
  final String title;
  final String description;
  final int startTime; // in seconds
  final int endTime; // in seconds
  final String thumbnailUrl;
  final List<String> keyPoints;
  final Map<String, dynamic> metadata;

  VideoChapterModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.thumbnailUrl,
    required this.keyPoints,
    required this.metadata,
  });

  factory VideoChapterModel.fromMap(Map<String, dynamic> map) {
    return VideoChapterModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: map['startTime'] ?? 0,
      endTime: map['endTime'] ?? 0,
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      keyPoints: List<String>.from(map['keyPoints'] ?? []),
      metadata: map['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'thumbnailUrl': thumbnailUrl,
      'keyPoints': keyPoints,
      'metadata': metadata,
    };
  }

  int get duration => endTime - startTime;

  String get formattedStartTime {
    final minutes = startTime ~/ 60;
    final seconds = startTime % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// Subtitle model for multi-language support
class SubtitleModel {
  final String id;
  final SubtitleLanguage language;
  final String languageCode;
  final String subtitleUrl;
  final List<SubtitleCueModel> cues;
  final bool isDefault;

  SubtitleModel({
    required this.id,
    required this.language,
    required this.languageCode,
    required this.subtitleUrl,
    required this.cues,
    required this.isDefault,
  });

  factory SubtitleModel.fromMap(Map<String, dynamic> map) {
    return SubtitleModel(
      id: map['id'] ?? '',
      language: SubtitleLanguage.values.firstWhere(
        (e) => e.name == map['language'],
        orElse: () => SubtitleLanguage.english,
      ),
      languageCode: map['languageCode'] ?? 'en',
      subtitleUrl: map['subtitleUrl'] ?? '',
      cues: (map['cues'] as List<dynamic>? ?? [])
          .map((cue) => SubtitleCueModel.fromMap(cue))
          .toList(),
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language': language.name,
      'languageCode': languageCode,
      'subtitleUrl': subtitleUrl,
      'cues': cues.map((cue) => cue.toMap()).toList(),
      'isDefault': isDefault,
    };
  }
}

// Individual subtitle cue
class SubtitleCueModel {
  final int startTime; // in milliseconds
  final int endTime; // in milliseconds
  final String text;

  SubtitleCueModel({
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  factory SubtitleCueModel.fromMap(Map<String, dynamic> map) {
    return SubtitleCueModel(
      startTime: map['startTime'] ?? 0,
      endTime: map['endTime'] ?? 0,
      text: map['text'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'text': text,
    };
  }
}

// User video progress tracking
class UserVideoProgressModel {
  final String id;
  final String userId;
  final String videoId;
  final int currentPosition; // in seconds
  final double watchedPercentage;
  final bool isCompleted;
  final List<VideoBookmarkModel> bookmarks;
  final List<VideoNoteModel> notes;
  final VideoQuality selectedQuality;
  final SubtitleLanguage? selectedSubtitleLanguage;
  final double playbackSpeed;
  final int totalWatchTime; // in seconds
  final int watchCount;
  final DateTime lastWatchedAt;
  final DateTime createdAt;
  final Map<String, dynamic> watchData;

  UserVideoProgressModel({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.currentPosition,
    required this.watchedPercentage,
    required this.isCompleted,
    required this.bookmarks,
    required this.notes,
    required this.selectedQuality,
    this.selectedSubtitleLanguage,
    required this.playbackSpeed,
    required this.totalWatchTime,
    required this.watchCount,
    required this.lastWatchedAt,
    required this.createdAt,
    required this.watchData,
  });

  factory UserVideoProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserVideoProgressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      videoId: data['videoId'] ?? '',
      currentPosition: data['currentPosition'] ?? 0,
      watchedPercentage: (data['watchedPercentage'] ?? 0.0).toDouble(),
      isCompleted: data['isCompleted'] ?? false,
      bookmarks: (data['bookmarks'] as List<dynamic>? ?? [])
          .map((bookmark) => VideoBookmarkModel.fromMap(bookmark))
          .toList(),
      notes: (data['notes'] as List<dynamic>? ?? [])
          .map((note) => VideoNoteModel.fromMap(note))
          .toList(),
      selectedQuality: VideoQuality.values.firstWhere(
        (e) => e.name == data['selectedQuality'],
        orElse: () => VideoQuality.auto,
      ),
      selectedSubtitleLanguage: data['selectedSubtitleLanguage'] != null
          ? SubtitleLanguage.values.firstWhere(
              (e) => e.name == data['selectedSubtitleLanguage'],
              orElse: () => SubtitleLanguage.english,
            )
          : null,
      playbackSpeed: (data['playbackSpeed'] ?? 1.0).toDouble(),
      totalWatchTime: data['totalWatchTime'] ?? 0,
      watchCount: data['watchCount'] ?? 0,
      lastWatchedAt: (data['lastWatchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      watchData: data['watchData'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'videoId': videoId,
      'currentPosition': currentPosition,
      'watchedPercentage': watchedPercentage,
      'isCompleted': isCompleted,
      'bookmarks': bookmarks.map((bookmark) => bookmark.toMap()).toList(),
      'notes': notes.map((note) => note.toMap()).toList(),
      'selectedQuality': selectedQuality.name,
      'selectedSubtitleLanguage': selectedSubtitleLanguage?.name,
      'playbackSpeed': playbackSpeed,
      'totalWatchTime': totalWatchTime,
      'watchCount': watchCount,
      'lastWatchedAt': Timestamp.fromDate(lastWatchedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'watchData': watchData,
    };
  }
}

// Video bookmark model
class VideoBookmarkModel {
  final String id;
  final int timestamp; // in seconds
  final String title;
  final String note;
  final DateTime createdAt;

  VideoBookmarkModel({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.note,
    required this.createdAt,
  });

  factory VideoBookmarkModel.fromMap(Map<String, dynamic> map) {
    return VideoBookmarkModel(
      id: map['id'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      title: map['title'] ?? '',
      note: map['note'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'title': title,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  String get formattedTimestamp {
    final minutes = timestamp ~/ 60;
    final seconds = timestamp % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// Video note model
class VideoNoteModel {
  final String id;
  final int timestamp; // in seconds
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VideoNoteModel({
    required this.id,
    required this.timestamp,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory VideoNoteModel.fromMap(Map<String, dynamic> map) {
    return VideoNoteModel(
      id: map['id'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  String get formattedTimestamp {
    final minutes = timestamp ~/ 60;
    final seconds = timestamp % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// Video playlist model
class VideoPlaylistModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final List<String> videoIds;
  final String createdBy;
  final VideoCategory category;
  final VideoAccessLevel accessLevel;
  final int coinCost;
  final List<String> targetRoles;
  final bool isPublic;
  final double rating;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  VideoPlaylistModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoIds,
    required this.createdBy,
    required this.category,
    required this.accessLevel,
    required this.coinCost,
    required this.targetRoles,
    required this.isPublic,
    required this.rating,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoPlaylistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VideoPlaylistModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoIds: List<String>.from(data['videoIds'] ?? []),
      createdBy: data['createdBy'] ?? '',
      category: VideoCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => VideoCategory.anatomy,
      ),
      accessLevel: VideoAccessLevel.values.firstWhere(
        (e) => e.name == data['accessLevel'],
        orElse: () => VideoAccessLevel.free,
      ),
      coinCost: data['coinCost'] ?? 0,
      targetRoles: List<String>.from(data['targetRoles'] ?? []),
      isPublic: data['isPublic'] ?? true,
      rating: (data['rating'] ?? 0.0).toDouble(),
      viewCount: data['viewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoIds': videoIds,
      'createdBy': createdBy,
      'category': category.name,
      'accessLevel': accessLevel.name,
      'coinCost': coinCost,
      'targetRoles': targetRoles,
      'isPublic': isPublic,
      'rating': rating,
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  int get videoCount => videoIds.length;
}

// Video quality options for UI
extension VideoQualityExtension on VideoQuality {
  String get displayName {
    switch (this) {
      case VideoQuality.auto:
        return 'Auto';
      case VideoQuality.sd_360:
        return '360p';
      case VideoQuality.sd_480:
        return '480p';
      case VideoQuality.hd_720:
        return '720p HD';
      case VideoQuality.hd_1080:
        return '1080p Full HD';
      case VideoQuality.uhd_4k:
        return '4K UHD';
    }
  }

  int get resolution {
    switch (this) {
      case VideoQuality.auto:
        return 0;
      case VideoQuality.sd_360:
        return 360;
      case VideoQuality.sd_480:
        return 480;
      case VideoQuality.hd_720:
        return 720;
      case VideoQuality.hd_1080:
        return 1080;
      case VideoQuality.uhd_4k:
        return 2160;
    }
  }
}

// Subtitle language extensions
extension SubtitleLanguageExtension on SubtitleLanguage {
  String get displayName {
    switch (this) {
      case SubtitleLanguage.english:
        return 'English';
      case SubtitleLanguage.hindi:
        return 'Hindi';
      case SubtitleLanguage.spanish:
        return 'Spanish';
      case SubtitleLanguage.french:
        return 'French';
      case SubtitleLanguage.german:
        return 'German';
    }
  }

  String get languageCode {
    switch (this) {
      case SubtitleLanguage.english:
        return 'en';
      case SubtitleLanguage.hindi:
        return 'hi';
      case SubtitleLanguage.spanish:
        return 'es';
      case SubtitleLanguage.french:
        return 'fr';
      case SubtitleLanguage.german:
        return 'de';
    }
  }
}