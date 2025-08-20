import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'offline_cache_manager.dart';
import '../../../shared/services/video_lecture_service.dart';
import '../../../shared/models/video_models.dart';
import '../../../shared/models/user_model.dart';

/// Manages offline synchronization and data consistency
class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;
  OfflineSyncManager._internal();

  final OfflineCacheManager _cacheManager = OfflineCacheManager();
  final Connectivity _connectivity = Connectivity();
  
  Timer? _syncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  bool _isOnline = false;
  bool _isSyncing = false;
  final List<PendingSyncOperation> _pendingOperations = [];
  final StreamController<SyncStatus> _syncStatusController = StreamController.broadcast();
  
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  /// Initialize the sync manager
  Future<void> initialize() async {
    try {
      await _cacheManager.initialize();
      await _checkConnectivity();
      _startConnectivityMonitoring();
      await _loadPendingOperations();
      _startPeriodicSync();
      
      if (kDebugMode) {
        print('OfflineSyncManager initialized. Online: $_isOnline');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize OfflineSyncManager: $e');
      }
    }
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;
      
      if (_isOnline) {
        _triggerSync();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check connectivity: $e');
      }
    }
  }

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) async {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;
        
        if (kDebugMode) {
          print('Connectivity changed: $result (Online: $_isOnline)');
        }

        if (!wasOnline && _isOnline) {
          // Just came back online
          _syncStatusController.add(SyncStatus.backOnline);
          await Future.delayed(const Duration(seconds: 2)); // Wait for connection to stabilize
          _triggerSync();
        } else if (wasOnline && !_isOnline) {
          // Just went offline
          _syncStatusController.add(SyncStatus.offline);
        }
      },
    );
  }

  /// Start periodic sync when online
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 15), // Sync every 15 minutes
      (_) {
        if (_isOnline) {
          _triggerSync();
        }
      },
    );
  }

  /// Trigger a sync operation
  Future<void> _triggerSync() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      await _syncPendingOperations();
      await _syncCriticalData();
      
      _syncStatusController.add(SyncStatus.completed);
      
      if (kDebugMode) {
        print('Sync completed successfully');
      }
    } catch (e) {
      _syncStatusController.add(SyncStatus.failed);
      
      if (kDebugMode) {
        print('Sync failed: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync pending operations
  Future<void> _syncPendingOperations() async {
    final operationsToSync = List<PendingSyncOperation>.from(_pendingOperations);
    final successfulOperations = <PendingSyncOperation>[];

    for (final operation in operationsToSync) {
      try {
        await _executeSyncOperation(operation);
        successfulOperations.add(operation);
        
        if (kDebugMode) {
          print('Synced operation: ${operation.type} for ${operation.entityId}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to sync operation ${operation.id}: $e');
        }
        
        // Check if operation is too old and should be discarded
        if (DateTime.now().difference(operation.createdAt).inDays > 7) {
          successfulOperations.add(operation); // Mark for removal
          
          if (kDebugMode) {
            print('Discarding old operation: ${operation.id}');
          }
        }
      }
    }

    // Remove successful operations
    for (final operation in successfulOperations) {
      _pendingOperations.remove(operation);
    }

    await _savePendingOperations();
  }

  /// Execute a specific sync operation
  Future<void> _executeSyncOperation(PendingSyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.videoProgress:
        await _syncVideoProgress(operation);
        break;
      case SyncOperationType.videoBookmark:
        await _syncVideoBookmark(operation);
        break;
      case SyncOperationType.videoNote:
        await _syncVideoNote(operation);
        break;
      case SyncOperationType.userPreferences:
        await _syncUserPreferences(operation);
        break;
      case SyncOperationType.quizResult:
        await _syncQuizResult(operation);
        break;
      case SyncOperationType.ebookProgress:
        await _syncEbookProgress(operation);
        break;
    }
  }

  /// Sync video progress
  Future<void> _syncVideoProgress(PendingSyncOperation operation) async {
    final data = operation.data;
    final videoService = VideoLectureService();
    
    await videoService.updateVideoProgress(
      userId: data['userId'],
      videoId: data['videoId'],
      currentPosition: data['currentPosition'],
      watchedPercentage: data['watchedPercentage'],
      isCompleted: data['isCompleted'],
      selectedQuality: data['selectedQuality'] != null 
          ? VideoQuality.values.firstWhere((q) => q.toString() == data['selectedQuality'])
          : null,
      selectedSubtitleLanguage: data['selectedSubtitleLanguage'] != null
          ? SubtitleLanguage.values.firstWhere((l) => l.toString() == data['selectedSubtitleLanguage'])
          : null,
      playbackSpeed: data['playbackSpeed'],
      additionalWatchTime: data['additionalWatchTime'],
    );
  }

  /// Sync video bookmark
  Future<void> _syncVideoBookmark(PendingSyncOperation operation) async {
    final data = operation.data;
    final videoService = VideoLectureService();
    
    await videoService.addVideoBookmark(
      userId: data['userId'],
      videoId: data['videoId'],
      timestamp: data['timestamp'],
      title: data['title'],
      note: data['note'] ?? '',
    );
  }

  /// Sync video note
  Future<void> _syncVideoNote(PendingSyncOperation operation) async {
    final data = operation.data;
    final videoService = VideoLectureService();
    
    await videoService.addVideoNote(
      userId: data['userId'],
      videoId: data['videoId'],
      timestamp: data['timestamp'],
      content: data['content'],
    );
  }

  /// Sync user preferences
  Future<void> _syncUserPreferences(PendingSyncOperation operation) async {
    // Implement user preferences sync
    if (kDebugMode) {
      print('Syncing user preferences: ${operation.data}');
    }
  }

  /// Sync quiz result
  Future<void> _syncQuizResult(PendingSyncOperation operation) async {
    // Implement quiz result sync
    if (kDebugMode) {
      print('Syncing quiz result: ${operation.data}');
    }
  }

  /// Sync ebook progress
  Future<void> _syncEbookProgress(PendingSyncOperation operation) async {
    // Implement ebook progress sync
    if (kDebugMode) {
      print('Syncing ebook progress: ${operation.data}');
    }
  }

  /// Sync critical data from server
  Future<void> _syncCriticalData() async {
    // Sync user profile updates
    // Sync content updates
    // Sync system notifications
    
    if (kDebugMode) {
      print('Syncing critical data from server');
    }
  }

  /// Add operation to pending sync queue
  Future<void> addPendingOperation({
    required SyncOperationType type,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    final operation = PendingSyncOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      entityId: entityId,
      data: data,
      createdAt: DateTime.now(),
    );

    _pendingOperations.add(operation);
    await _savePendingOperations();

    // Try to sync immediately if online
    if (_isOnline && !_isSyncing) {
      _triggerSync();
    }

    if (kDebugMode) {
      print('Added pending operation: ${operation.type} for ${operation.entityId}');
    }
  }

  /// Load pending operations from cache
  Future<void> _loadPendingOperations() async {
    try {
      final operationsJson = await _cacheManager.getCachedData<List<dynamic>>('pending_sync_operations');
      if (operationsJson != null) {
        _pendingOperations.clear();
        for (final opJson in operationsJson) {
          _pendingOperations.add(PendingSyncOperation.fromJson(opJson));
        }
        
        if (kDebugMode) {
          print('Loaded ${_pendingOperations.length} pending operations');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load pending operations: $e');
      }
    }
  }

  /// Save pending operations to cache
  Future<void> _savePendingOperations() async {
    try {
      final operationsJson = _pendingOperations.map((op) => op.toJson()).toList();
      await _cacheManager.cacheData(
        key: 'pending_sync_operations',
        data: operationsJson,
        type: CacheType.userData,
        expiry: const Duration(days: 30),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save pending operations: $e');
      }
    }
  }

  /// Get data with offline support
  Future<T?> getDataWithOfflineSupport<T>({
    required String cacheKey,
    required Future<T> Function() onlineDataFetcher,
    required T? Function(Map<String, dynamic>) cacheDeserializer,
    Duration? cacheExpiry,
  }) async {
    // Try to get from cache first
    final cachedData = await _cacheManager.getCachedData<T>(
      cacheKey,
      fromJson: cacheDeserializer,
    );

    if (_isOnline) {
      try {
        // Fetch fresh data when online
        final freshData = await onlineDataFetcher();
        
        // Cache the fresh data
        if (freshData != null) {
          await _cacheManager.cacheData(
            key: cacheKey,
            data: freshData,
            type: CacheType.temporary,
            expiry: cacheExpiry,
          );
        }
        
        return freshData;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch online data, falling back to cache: $e');
        }
        
        // Fall back to cached data if online fetch fails
        return cachedData;
      }
    } else {
      // Return cached data when offline
      return cachedData;
    }
  }

  /// Force sync all data
  Future<void> forceSyncAll() async {
    if (!_isOnline) {
      _syncStatusController.add(SyncStatus.failed);
      throw Exception('Cannot sync while offline');
    }

    await _triggerSync();
  }

  /// Clear all offline data
  Future<void> clearOfflineData() async {
    _pendingOperations.clear();
    await _savePendingOperations();
    await _cacheManager.clearAllCache();
    
    _syncStatusController.add(SyncStatus.cleared);
    
    if (kDebugMode) {
      print('All offline data cleared');
    }
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'pendingOperations': _pendingOperations.length,
      'operationsByType': _getOperationsByType(),
      'oldestPendingOperation': _pendingOperations.isNotEmpty
          ? _pendingOperations
              .map((op) => op.createdAt)
              .reduce((a, b) => a.isBefore(b) ? a : b)
              .toIso8601String()
          : null,
      'cacheStats': _cacheManager.getCacheStats(),
    };
  }

  /// Get operations grouped by type
  Map<String, int> _getOperationsByType() {
    final typeCount = <String, int>{};
    for (final op in _pendingOperations) {
      final type = op.type.toString();
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }
    return typeCount;
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}

/// Pending sync operation model
class PendingSyncOperation {
  final String id;
  final SyncOperationType type;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  PendingSyncOperation({
    required this.id,
    required this.type,
    required this.entityId,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'entityId': entityId,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PendingSyncOperation.fromJson(Map<String, dynamic> json) => PendingSyncOperation(
    id: json['id'],
    type: SyncOperationType.values.firstWhere((e) => e.toString() == json['type']),
    entityId: json['entityId'],
    data: Map<String, dynamic>.from(json['data']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

/// Sync operation types
enum SyncOperationType {
  videoProgress,
  videoBookmark,
  videoNote,
  userPreferences,
  quizResult,
  ebookProgress,
}

/// Sync status types
enum SyncStatus {
  offline,
  syncing,
  completed,
  failed,
  backOnline,
  cleared,
}