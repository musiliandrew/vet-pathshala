import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../caching/offline_cache_manager.dart';

/// Comprehensive analytics manager for user behavior tracking
class AnalyticsManager {
  static final AnalyticsManager _instance = AnalyticsManager._internal();
  factory AnalyticsManager() => _instance;
  AnalyticsManager._internal();

  final OfflineCacheManager _cacheManager = OfflineCacheManager();
  final List<AnalyticsEvent> _eventQueue = [];
  Timer? _flushTimer;
  
  String? _userId;
  String? _sessionId;
  DateTime? _sessionStartTime;
  Map<String, dynamic>? _deviceInfo;
  Map<String, dynamic>? _appInfo;
  
  static const int maxEventQueueSize = 100;
  static const Duration flushInterval = Duration(minutes: 2);
  static const Duration sessionTimeout = Duration(minutes: 30);

  /// Initialize analytics manager
  Future<void> initialize({String? userId}) async {
    try {
      _userId = userId;
      await _initializeDeviceInfo();
      await _initializeAppInfo();
      _startNewSession();
      _startPeriodicFlush();
      
      if (kDebugMode) {
        print('AnalyticsManager initialized for user: $_userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize AnalyticsManager: $e');
      }
    }
  }

  /// Initialize device information
  Future<void> _initializeDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceInfo = {
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'hardware': androidInfo.hardware,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceInfo = {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      } else {
        _deviceInfo = {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get device info: $e');
      }
      _deviceInfo = {'platform': 'unknown'};
    }
  }

  /// Initialize app information
  Future<void> _initializeAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appInfo = {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'buildSignature': packageInfo.buildSignature,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get app info: $e');
      }
      _appInfo = {'appName': 'Vet Pathshala'};
    }
  }

  /// Start a new session
  void _startNewSession() {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _sessionStartTime = DateTime.now();
    
    trackEvent(AnalyticsEventType.sessionStart, {
      'sessionId': _sessionId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Start periodic event flushing
  void _startPeriodicFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(flushInterval, (_) => _flushEvents());
  }

  /// Track a custom event
  void trackEvent(AnalyticsEventType eventType, Map<String, dynamic> properties) {
    final event = AnalyticsEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId,
      sessionId: _sessionId,
      eventType: eventType,
      properties: Map<String, dynamic>.from(properties)
        ..addAll({
          'timestamp': DateTime.now().toIso8601String(),
          'device': _deviceInfo,
          'app': _appInfo,
        }),
      timestamp: DateTime.now(),
    );

    _eventQueue.add(event);

    if (kDebugMode) {
      print('Analytics Event: ${eventType.name} - ${properties.keys.join(', ')}');
    }

    // Auto-flush if queue is full
    if (_eventQueue.length >= maxEventQueueSize) {
      _flushEvents();
    }
  }

  /// Track screen view
  void trackScreenView(String screenName, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.screenView, {
      'screenName': screenName,
      'viewTime': DateTime.now().toIso8601String(),
      ...?properties,
    });
  }

  /// Track user action
  void trackUserAction(String action, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.userAction, {
      'action': action,
      ...?properties,
    });
  }

  /// Track video events
  void trackVideoEvent(String eventName, String videoId, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.videoInteraction, {
      'eventName': eventName,
      'videoId': videoId,
      ...?properties,
    });
  }

  /// Track quiz events
  void trackQuizEvent(String eventName, String quizId, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.quizInteraction, {
      'eventName': eventName,
      'quizId': quizId,
      ...?properties,
    });
  }

  /// Track learning progress
  void trackLearningProgress(String contentType, String contentId, double progress, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.learningProgress, {
      'contentType': contentType,
      'contentId': contentId,
      'progress': progress,
      'progressPercent': (progress * 100).round(),
      ...?properties,
    });
  }

  /// Track purchase events
  void trackPurchase(String itemType, String itemId, int coinCost, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.purchase, {
      'itemType': itemType,
      'itemId': itemId,
      'coinCost': coinCost,
      'currency': 'coins',
      ...?properties,
    });
  }

  /// Track search events
  void trackSearch(String query, String searchType, int resultCount, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.search, {
      'query': query,
      'searchType': searchType,
      'resultCount': resultCount,
      'queryLength': query.length,
      ...?properties,
    });
  }

  /// Track error events
  void trackError(String errorType, String errorMessage, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.error, {
      'errorType': errorType,
      'errorMessage': errorMessage,
      'stackTrace': StackTrace.current.toString(),
      ...?properties,
    });
  }

  /// Track performance metrics
  void trackPerformance(String metricName, double value, String unit, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.performance, {
      'metricName': metricName,
      'value': value,
      'unit': unit,
      ...?properties,
    });
  }

  /// Track feature usage
  void trackFeatureUsage(String featureName, String usageType, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.featureUsage, {
      'featureName': featureName,
      'usageType': usageType,
      ...?properties,
    });
  }

  /// Track social interactions
  void trackSocialInteraction(String interactionType, String targetType, String targetId, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.socialInteraction, {
      'interactionType': interactionType,
      'targetType': targetType,
      'targetId': targetId,
      ...?properties,
    });
  }

  /// Track gamification events
  void trackGamificationEvent(String eventType, int pointsEarned, {Map<String, dynamic>? properties}) {
    trackEvent(AnalyticsEventType.gamification, {
      'eventType': eventType,
      'pointsEarned': pointsEarned,
      ...?properties,
    });
  }

  /// Track app lifecycle events
  void trackAppLifecycle(String lifecycleEvent) {
    trackEvent(AnalyticsEventType.appLifecycle, {
      'lifecycleEvent': lifecycleEvent,
      'sessionDuration': _sessionStartTime != null 
          ? DateTime.now().difference(_sessionStartTime!).inSeconds
          : 0,
    });
  }

  /// Set user properties
  void setUserProperties(Map<String, dynamic> properties) {
    trackEvent(AnalyticsEventType.userProperties, {
      'userProperties': properties,
    });
  }

  /// Update user ID
  void setUserId(String userId) {
    final oldUserId = _userId;
    _userId = userId;
    
    trackEvent(AnalyticsEventType.userIdentification, {
      'oldUserId': oldUserId,
      'newUserId': userId,
    });
  }

  /// Flush events to storage/server
  Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty) return;

    try {
      final eventsToFlush = List<AnalyticsEvent>.from(_eventQueue);
      _eventQueue.clear();

      // Save to local cache
      await _saveEventsToCache(eventsToFlush);

      // Send to analytics server (if online)
      await _sendEventsToServer(eventsToFlush);

      if (kDebugMode) {
        print('Flushed ${eventsToFlush.length} analytics events');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to flush analytics events: $e');
      }
    }
  }

  /// Save events to local cache
  Future<void> _saveEventsToCache(List<AnalyticsEvent> events) async {
    try {
      final existingEvents = await _cacheManager.getCachedData<List<dynamic>>('analytics_events') ?? [];
      final allEvents = [...existingEvents, ...events.map((e) => e.toJson())];

      // Keep only the latest 1000 events to prevent cache from growing too large
      final eventsToKeep = allEvents.length > 1000 
          ? allEvents.sublist(allEvents.length - 1000)
          : allEvents;

      await _cacheManager.cacheData(
        key: 'analytics_events',
        data: eventsToKeep,
        type: CacheType.analytics,
        expiry: const Duration(days: 30),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save events to cache: $e');
      }
    }
  }

  /// Send events to analytics server
  Future<void> _sendEventsToServer(List<AnalyticsEvent> events) async {
    try {
      // In a real implementation, this would send events to your analytics backend
      // For now, we'll just simulate the API call
      
      if (kDebugMode) {
        print('Sending ${events.length} events to analytics server');
        for (final event in events) {
          print('  ${event.eventType.name}: ${event.properties['action'] ?? event.properties['screenName'] ?? 'N/A'}');
        }
      }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mark events as sent (in real implementation, remove from local cache after successful send)
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send events to server: $e');
      }
      // In case of failure, events remain in cache and will be retried
    }
  }

  /// Get analytics statistics
  Map<String, dynamic> getAnalyticsStats() {
    return {
      'userId': _userId,
      'sessionId': _sessionId,
      'sessionDuration': _sessionStartTime != null 
          ? DateTime.now().difference(_sessionStartTime!).inMinutes
          : 0,
      'queuedEvents': _eventQueue.length,
      'deviceInfo': _deviceInfo,
      'appInfo': _appInfo,
    };
  }

  /// Get cached events count
  Future<int> getCachedEventsCount() async {
    try {
      final events = await _cacheManager.getCachedData<List<dynamic>>('analytics_events');
      return events?.length ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all analytics data
  Future<void> clearAnalyticsData() async {
    _eventQueue.clear();
    await _cacheManager.removeCacheEntry('analytics_events');
    
    if (kDebugMode) {
      print('Analytics data cleared');
    }
  }

  /// Force flush all events
  Future<void> forceFlush() async {
    await _flushEvents();
  }

  /// Dispose resources
  void dispose() {
    _flushTimer?.cancel();
    _flushEvents(); // Final flush
  }
}

/// Analytics event model
class AnalyticsEvent {
  final String id;
  final String? userId;
  final String? sessionId;
  final AnalyticsEventType eventType;
  final Map<String, dynamic> properties;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.id,
    this.userId,
    this.sessionId,
    required this.eventType,
    required this.properties,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'sessionId': sessionId,
    'eventType': eventType.name,
    'properties': properties,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) => AnalyticsEvent(
    id: json['id'],
    userId: json['userId'],
    sessionId: json['sessionId'],
    eventType: AnalyticsEventType.values.firstWhere(
      (e) => e.name == json['eventType'],
      orElse: () => AnalyticsEventType.custom,
    ),
    properties: Map<String, dynamic>.from(json['properties']),
    timestamp: DateTime.parse(json['timestamp']),
  );
}

/// Analytics event types
enum AnalyticsEventType {
  sessionStart,
  sessionEnd,
  screenView,
  userAction,
  videoInteraction,
  quizInteraction,
  learningProgress,
  purchase,
  search,
  error,
  performance,
  featureUsage,
  socialInteraction,
  gamification,
  appLifecycle,
  userProperties,
  userIdentification,
  custom,
}