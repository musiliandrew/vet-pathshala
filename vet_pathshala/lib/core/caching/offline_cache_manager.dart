import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../../shared/models/video_models.dart';
import '../../../shared/models/ebook_models.dart';
import '../../../shared/models/question_bank_models.dart';
import '../../../shared/models/user_model.dart';

/// Comprehensive offline cache manager for the application
class OfflineCacheManager {
  static final OfflineCacheManager _instance = OfflineCacheManager._internal();
  factory OfflineCacheManager() => _instance;
  OfflineCacheManager._internal();

  Directory? _cacheDirectory;
  final Map<String, CacheEntry> _memoryCache = {};
  Timer? _cleanupTimer;
  
  static const int maxMemoryCacheSize = 100;
  static const int maxDiskCacheSize = 500 * 1024 * 1024; // 500MB
  static const Duration defaultCacheExpiry = Duration(hours: 24);
  static const Duration longTermCacheExpiry = Duration(days: 7);

  /// Initialize the cache manager
  Future<void> initialize() async {
    try {
      _cacheDirectory = await getApplicationCacheDirectory();
      await _createCacheDirectories();
      await _loadCacheIndex();
      _startPeriodicCleanup();
      
      if (kDebugMode) {
        print('OfflineCacheManager initialized at: ${_cacheDirectory?.path}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize OfflineCacheManager: $e');
      }
    }
  }

  /// Create necessary cache directories
  Future<void> _createCacheDirectories() async {
    if (_cacheDirectory == null) return;

    final directories = [
      'videos',
      'ebooks',
      'questions',
      'images',
      'user_data',
      'analytics',
      'index',
    ];

    for (final dir in directories) {
      final directory = Directory('${_cacheDirectory!.path}/$dir');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }
  }

  /// Load cache index from disk
  Future<void> _loadCacheIndex() async {
    try {
      final indexFile = File('${_cacheDirectory!.path}/index/cache_index.json');
      if (await indexFile.exists()) {
        final indexData = await indexFile.readAsString();
        final Map<String, dynamic> index = jsonDecode(indexData);
        
        for (final entry in index.entries) {
          final entryData = entry.value as Map<String, dynamic>;
          _memoryCache[entry.key] = CacheEntry.fromJson(entryData);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load cache index: $e');
      }
    }
  }

  /// Save cache index to disk
  Future<void> _saveCacheIndex() async {
    try {
      final indexFile = File('${_cacheDirectory!.path}/index/cache_index.json');
      final indexData = <String, dynamic>{};
      
      for (final entry in _memoryCache.entries) {
        indexData[entry.key] = entry.value.toJson();
      }
      
      await indexFile.writeAsString(jsonEncode(indexData));
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save cache index: $e');
      }
    }
  }

  /// Cache data with specified type and expiry
  Future<bool> cacheData({
    required String key,
    required dynamic data,
    required CacheType type,
    Duration? expiry,
    bool forceUpdate = false,
  }) async {
    if (_cacheDirectory == null) return false;

    try {
      final effectiveExpiry = expiry ?? 
          (type == CacheType.longTerm ? longTermCacheExpiry : defaultCacheExpiry);
      
      // Check if already cached and not expired
      if (!forceUpdate && _memoryCache.containsKey(key)) {
        final existing = _memoryCache[key]!;
        if (!existing.isExpired()) {
          return true;
        }
      }

      // Serialize data
      String serializedData;
      if (data is String) {
        serializedData = data;
      } else {
        serializedData = jsonEncode(data);
      }

      // Determine file path
      final filePath = _getCacheFilePath(key, type);
      final file = File(filePath);

      // Write to disk
      await file.writeAsString(serializedData);
      
      // Update memory cache
      _memoryCache[key] = CacheEntry(
        key: key,
        type: type,
        filePath: filePath,
        size: serializedData.length,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(effectiveExpiry),
        lastAccessed: DateTime.now(),
      );

      // Manage cache size
      await _manageCacheSize();
      await _saveCacheIndex();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cache data for key $key: $e');
      }
      return false;
    }
  }

  /// Retrieve cached data
  Future<T?> getCachedData<T>(String key, {T? Function(Map<String, dynamic>)? fromJson}) async {
    if (_cacheDirectory == null || !_memoryCache.containsKey(key)) {
      return null;
    }

    try {
      final entry = _memoryCache[key]!;
      
      // Check if expired
      if (entry.isExpired()) {
        await _removeCacheEntry(key);
        return null;
      }

      // Update last accessed time
      entry.lastAccessed = DateTime.now();

      // Read from disk
      final file = File(entry.filePath);
      if (!await file.exists()) {
        await _removeCacheEntry(key);
        return null;
      }

      final content = await file.readAsString();

      // Deserialize based on type
      if (T == String) {
        return content as T;
      } else if (fromJson != null) {
        try {
          final jsonData = jsonDecode(content) as Map<String, dynamic>;
          return fromJson(jsonData);
        } catch (e) {
          if (kDebugMode) {
            print('Failed to deserialize cached data: $e');
          }
          return null;
        }
      } else {
        try {
          return jsonDecode(content) as T;
        } catch (e) {
          if (kDebugMode) {
            print('Failed to parse cached JSON: $e');
          }
          return null;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get cached data for key $key: $e');
      }
      return null;
    }
  }

  /// Cache video data
  Future<bool> cacheVideo(VideoLectureModel video) async {
    return await cacheData(
      key: 'video_${video.id}',
      data: video.toJson(),
      type: CacheType.video,
      expiry: longTermCacheExpiry,
    );
  }

  /// Get cached video
  Future<VideoLectureModel?> getCachedVideo(String videoId) async {
    return await getCachedData<VideoLectureModel>(
      'video_$videoId',
      fromJson: (json) => VideoLectureModel.fromJson(json),
    );
  }

  /// Cache ebook data
  Future<bool> cacheEbook(EbookModel ebook) async {
    return await cacheData(
      key: 'ebook_${ebook.id}',
      data: ebook.toJson(),
      type: CacheType.ebook,
      expiry: longTermCacheExpiry,
    );
  }

  /// Get cached ebook
  Future<EbookModel?> getCachedEbook(String ebookId) async {
    return await getCachedData<EbookModel>(
      'ebook_$ebookId',
      fromJson: (json) => EbookModel.fromJson(json),
    );
  }

  /// Cache question bank data
  Future<bool> cacheQuestionBank(List<QuestionModel> questions, String topicId) async {
    final questionsJson = questions.map((q) => q.toJson()).toList();
    return await cacheData(
      key: 'questions_$topicId',
      data: questionsJson,
      type: CacheType.questions,
      expiry: defaultCacheExpiry,
    );
  }

  /// Get cached question bank
  Future<List<QuestionModel>?> getCachedQuestionBank(String topicId) async {
    final questionsJson = await getCachedData<List<dynamic>>('questions_$topicId');
    if (questionsJson == null) return null;

    try {
      return questionsJson
          .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to parse cached questions: $e');
      }
      return null;
    }
  }

  /// Cache user data
  Future<bool> cacheUserData(String userId, Map<String, dynamic> userData) async {
    return await cacheData(
      key: 'user_$userId',
      data: userData,
      type: CacheType.userData,
      expiry: const Duration(hours: 6),
    );
  }

  /// Get cached user data
  Future<Map<String, dynamic>?> getCachedUserData(String userId) async {
    return await getCachedData<Map<String, dynamic>>('user_$userId');
  }

  /// Cache image
  Future<bool> cacheImage(String url, Uint8List imageData) async {
    if (_cacheDirectory == null) return false;

    try {
      final key = 'image_${url.hashCode}';
      final filePath = _getCacheFilePath(key, CacheType.image);
      final file = File(filePath);

      await file.writeAsBytes(imageData);

      _memoryCache[key] = CacheEntry(
        key: key,
        type: CacheType.image,
        filePath: filePath,
        size: imageData.length,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(longTermCacheExpiry),
        lastAccessed: DateTime.now(),
        metadata: {'originalUrl': url},
      );

      await _manageCacheSize();
      await _saveCacheIndex();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cache image: $e');
      }
      return false;
    }
  }

  /// Get cached image
  Future<Uint8List?> getCachedImage(String url) async {
    if (_cacheDirectory == null) return null;

    try {
      final key = 'image_${url.hashCode}';
      if (!_memoryCache.containsKey(key)) return null;

      final entry = _memoryCache[key]!;
      if (entry.isExpired()) {
        await _removeCacheEntry(key);
        return null;
      }

      final file = File(entry.filePath);
      if (!await file.exists()) {
        await _removeCacheEntry(key);
        return null;
      }

      entry.lastAccessed = DateTime.now();
      return await file.readAsBytes();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get cached image: $e');
      }
      return null;
    }
  }

  /// Check if data is cached and not expired
  bool isCached(String key) {
    if (!_memoryCache.containsKey(key)) return false;
    return !_memoryCache[key]!.isExpired();
  }

  /// Remove specific cache entry
  Future<void> removeCacheEntry(String key) async {
    await _removeCacheEntry(key);
    await _saveCacheIndex();
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    if (_cacheDirectory == null) return;

    try {
      // Delete all cache files
      for (final entry in _memoryCache.values) {
        final file = File(entry.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Clear memory cache
      _memoryCache.clear();

      // Save empty index
      await _saveCacheIndex();

      if (kDebugMode) {
        print('All cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear cache: $e');
      }
    }
  }

  /// Clear cache by type
  Future<void> clearCacheByType(CacheType type) async {
    try {
      final keysToRemove = <String>[];
      
      for (final entry in _memoryCache.entries) {
        if (entry.value.type == type) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        await _removeCacheEntry(key);
      }

      await _saveCacheIndex();

      if (kDebugMode) {
        print('Cache cleared for type: $type');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear cache by type: $e');
      }
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final stats = <String, dynamic>{};
    final typeStats = <CacheType, Map<String, dynamic>>{};

    int totalSize = 0;
    int expiredCount = 0;

    for (final entry in _memoryCache.values) {
      totalSize += entry.size;
      
      if (entry.isExpired()) {
        expiredCount++;
      }

      typeStats[entry.type] ??= {
        'count': 0,
        'size': 0,
        'expired': 0,
      };

      typeStats[entry.type]!['count'] = (typeStats[entry.type]!['count'] as int) + 1;
      typeStats[entry.type]!['size'] = (typeStats[entry.type]!['size'] as int) + entry.size;
      
      if (entry.isExpired()) {
        typeStats[entry.type]!['expired'] = (typeStats[entry.type]!['expired'] as int) + 1;
      }
    }

    stats['totalEntries'] = _memoryCache.length;
    stats['totalSizeBytes'] = totalSize;
    stats['totalSizeMB'] = (totalSize / (1024 * 1024)).toStringAsFixed(2);
    stats['expiredEntries'] = expiredCount;
    stats['maxSizeMB'] = (maxDiskCacheSize / (1024 * 1024)).toStringAsFixed(0);
    stats['utilizationPercent'] = ((totalSize / maxDiskCacheSize) * 100).toStringAsFixed(1);
    stats['typeBreakdown'] = typeStats.map((key, value) => MapEntry(key.toString(), value));

    return stats;
  }

  /// Start periodic cleanup
  void _startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _performCleanup(),
    );
  }

  /// Perform cleanup of expired entries
  Future<void> _performCleanup() async {
    try {
      final keysToRemove = <String>[];
      
      for (final entry in _memoryCache.entries) {
        if (entry.value.isExpired()) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        await _removeCacheEntry(key);
      }

      if (keysToRemove.isNotEmpty) {
        await _saveCacheIndex();
        
        if (kDebugMode) {
          print('Cleaned up ${keysToRemove.length} expired cache entries');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to perform cache cleanup: $e');
      }
    }
  }

  /// Manage cache size by removing oldest entries if needed
  Future<void> _manageCacheSize() async {
    int totalSize = _memoryCache.values.fold(0, (sum, entry) => sum + entry.size);
    
    if (totalSize > maxDiskCacheSize) {
      // Sort by last accessed time (oldest first)
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));

      // Remove oldest entries until under size limit
      for (final entry in sortedEntries) {
        await _removeCacheEntry(entry.key);
        totalSize -= entry.value.size;
        
        if (totalSize <= maxDiskCacheSize * 0.8) {
          break;
        }
      }

      if (kDebugMode) {
        print('Cache size management completed. New size: ${(totalSize / (1024 * 1024)).toStringAsFixed(2)}MB');
      }
    }
  }

  /// Remove a cache entry
  Future<void> _removeCacheEntry(String key) async {
    if (!_memoryCache.containsKey(key)) return;

    try {
      final entry = _memoryCache[key]!;
      final file = File(entry.filePath);
      
      if (await file.exists()) {
        await file.delete();
      }
      
      _memoryCache.remove(key);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to remove cache entry $key: $e');
      }
    }
  }

  /// Get cache file path for a key and type
  String _getCacheFilePath(String key, CacheType type) {
    final typeDir = type.toString().split('.').last;
    final safeName = key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return '${_cacheDirectory!.path}/$typeDir/$safeName.cache';
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
  }
}

/// Cache entry model
class CacheEntry {
  final String key;
  final CacheType type;
  final String filePath;
  final int size;
  final DateTime createdAt;
  final DateTime expiresAt;
  DateTime lastAccessed;
  final Map<String, dynamic>? metadata;

  CacheEntry({
    required this.key,
    required this.type,
    required this.filePath,
    required this.size,
    required this.createdAt,
    required this.expiresAt,
    required this.lastAccessed,
    this.metadata,
  });

  bool isExpired() => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'key': key,
    'type': type.toString(),
    'filePath': filePath,
    'size': size,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'lastAccessed': lastAccessed.toIso8601String(),
    'metadata': metadata,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    key: json['key'],
    type: CacheType.values.firstWhere((e) => e.toString() == json['type']),
    filePath: json['filePath'],
    size: json['size'],
    createdAt: DateTime.parse(json['createdAt']),
    expiresAt: DateTime.parse(json['expiresAt']),
    lastAccessed: DateTime.parse(json['lastAccessed']),
    metadata: json['metadata'],
  );
}

/// Cache types
enum CacheType {
  video,
  ebook,
  questions,
  image,
  userData,
  analytics,
  longTerm,
  temporary,
}