import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'analytics_manager.dart';
import '../caching/offline_cache_manager.dart';

/// Advanced user behavior tracking and analysis
class UserBehaviorTracker {
  static final UserBehaviorTracker _instance = UserBehaviorTracker._internal();
  factory UserBehaviorTracker() => _instance;
  UserBehaviorTracker._internal();

  final AnalyticsManager _analytics = AnalyticsManager();
  final OfflineCacheManager _cache = OfflineCacheManager();
  
  Timer? _sessionTimer;
  Timer? _inactivityTimer;
  
  DateTime? _screenStartTime;
  String? _currentScreen;
  final Map<String, Duration> _screenTimeMap = {};
  final Map<String, int> _screenVisitCount = {};
  final List<UserAction> _userActionHistory = [];
  final Map<String, DateTime> _featureFirstUse = {};
  final Map<String, int> _featureUsageCount = {};
  
  bool _isTracking = false;
  DateTime? _sessionStart;
  DateTime? _lastActivity;
  int _totalSessions = 0;
  Duration _totalAppTime = Duration.zero;
  
  static const Duration inactivityThreshold = Duration(minutes: 5);
  static const int maxActionHistorySize = 1000;

  /// Initialize behavior tracking
  Future<void> initialize() async {
    try {
      await _loadBehaviorData();
      _startSessionTracking();
      _isTracking = true;
      
      if (kDebugMode) {
        print('UserBehaviorTracker initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize UserBehaviorTracker: $e');
      }
    }
  }

  /// Start session tracking
  void _startSessionTracking() {
    _sessionStart = DateTime.now();
    _lastActivity = DateTime.now();
    _totalSessions++;
    
    _sessionTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateSessionTime(),
    );
    
    _resetInactivityTimer();
  }

  /// Update session time
  void _updateSessionTime() {
    if (_sessionStart != null) {
      _totalAppTime = DateTime.now().difference(_sessionStart!);
      _saveBehaviorData();
    }
  }

  /// Reset inactivity timer
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityThreshold, () {
      _handleInactivity();
    });
  }

  /// Handle user inactivity
  void _handleInactivity() {
    _analytics.trackEvent(AnalyticsEventType.userAction, {
      'action': 'inactivity_detected',
      'inactiveDuration': inactivityThreshold.inMinutes,
      'currentScreen': _currentScreen,
    });
  }

  /// Track screen entry
  void trackScreenEntry(String screenName, {Map<String, dynamic>? properties}) {
    if (!_isTracking) return;

    // Track exit of previous screen
    if (_currentScreen != null && _screenStartTime != null) {
      _trackScreenExit();
    }

    // Track entry of new screen
    _currentScreen = screenName;
    _screenStartTime = DateTime.now();
    _lastActivity = DateTime.now();
    
    _screenVisitCount[screenName] = (_screenVisitCount[screenName] ?? 0) + 1;
    
    _analytics.trackScreenView(screenName, properties: {
      'visitCount': _screenVisitCount[screenName],
      'isFirstVisit': _screenVisitCount[screenName] == 1,
      ...?properties,
    });

    _resetInactivityTimer();
  }

  /// Track screen exit
  void _trackScreenExit() {
    if (_currentScreen == null || _screenStartTime == null) return;

    final screenTime = DateTime.now().difference(_screenStartTime!);
    _screenTimeMap[_currentScreen!] = 
        (_screenTimeMap[_currentScreen!] ?? Duration.zero) + screenTime;

    _analytics.trackEvent(AnalyticsEventType.userAction, {
      'action': 'screen_exit',
      'screenName': _currentScreen,
      'timeSpent': screenTime.inSeconds,
      'timeSpentFormatted': _formatDuration(screenTime),
    });
  }

  /// Track user action
  void trackAction(String actionType, String actionName, {Map<String, dynamic>? properties}) {
    if (!_isTracking) return;

    _lastActivity = DateTime.now();
    
    final action = UserAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      actionType: actionType,
      actionName: actionName,
      screenName: _currentScreen,
      timestamp: DateTime.now(),
      properties: properties ?? {},
    );

    _userActionHistory.add(action);
    
    // Maintain action history size
    if (_userActionHistory.length > maxActionHistorySize) {
      _userActionHistory.removeAt(0);
    }

    _analytics.trackUserAction(actionName, properties: {
      'actionType': actionType,
      'screen': _currentScreen,
      'sequenceNumber': _userActionHistory.length,
      ...?properties,
    });

    _resetInactivityTimer();
  }

  /// Track tap gesture
  void trackTap(String elementName, {Map<String, dynamic>? properties}) {
    trackAction('tap', elementName, properties: {
      'gestureType': 'tap',
      ...?properties,
    });
  }

  /// Track long press gesture
  void trackLongPress(String elementName, {Map<String, dynamic>? properties}) {
    trackAction('long_press', elementName, properties: {
      'gestureType': 'long_press',
      ...?properties,
    });
  }

  /// Track swipe gesture
  void trackSwipe(String direction, String elementName, {Map<String, dynamic>? properties}) {
    trackAction('swipe', elementName, properties: {
      'gestureType': 'swipe',
      'direction': direction,
      ...?properties,
    });
  }

  /// Track scroll behavior
  void trackScroll(String elementName, double scrollPosition, double maxScroll, {Map<String, dynamic>? properties}) {
    final scrollPercentage = maxScroll > 0 ? (scrollPosition / maxScroll * 100).round() : 0;
    
    trackAction('scroll', elementName, properties: {
      'scrollPosition': scrollPosition,
      'scrollPercentage': scrollPercentage,
      'maxScroll': maxScroll,
      ...?properties,
    });
  }

  /// Track form interactions
  void trackFormInteraction(String formName, String fieldName, String interactionType, {Map<String, dynamic>? properties}) {
    trackAction('form_interaction', '$formName.$fieldName', properties: {
      'formName': formName,
      'fieldName': fieldName,
      'interactionType': interactionType,
      ...?properties,
    });
  }

  /// Track search behavior
  void trackSearchBehavior(String query, String searchType, int resultCount, int selectedIndex) {
    trackAction('search', 'query_submitted', properties: {
      'query': query,
      'searchType': searchType,
      'queryLength': query.length,
      'resultCount': resultCount,
    });

    if (selectedIndex >= 0) {
      trackAction('search', 'result_selected', properties: {
        'query': query,
        'selectedIndex': selectedIndex,
        'resultPosition': selectedIndex + 1,
      });
    }

    _analytics.trackSearch(query, searchType, resultCount, properties: {
      'selectedIndex': selectedIndex,
    });
  }

  /// Track feature usage
  void trackFeatureUsage(String featureName, String usageType, {Map<String, dynamic>? properties}) {
    if (!_featureFirstUse.containsKey(featureName)) {
      _featureFirstUse[featureName] = DateTime.now();
      _analytics.trackFeatureUsage(featureName, 'first_use', properties: properties);
    }

    _featureUsageCount[featureName] = (_featureUsageCount[featureName] ?? 0) + 1;

    trackAction('feature_usage', featureName, properties: {
      'usageType': usageType,
      'usageCount': _featureUsageCount[featureName],
      'isFirstUse': _featureUsageCount[featureName] == 1,
      ...?properties,
    });

    _analytics.trackFeatureUsage(featureName, usageType, properties: {
      'usageCount': _featureUsageCount[featureName],
      ...?properties,
    });
  }

  /// Track learning pattern
  void trackLearningPattern(String contentType, String contentId, Map<String, dynamic> learningData) {
    trackAction('learning', 'content_interaction', properties: {
      'contentType': contentType,
      'contentId': contentId,
      'learningData': learningData,
    });

    // Analyze learning patterns
    _analyzeLearningPattern(contentType, learningData);
  }

  /// Analyze learning patterns
  void _analyzeLearningPattern(String contentType, Map<String, dynamic> learningData) {
    // Calculate engagement score
    final engagementScore = _calculateEngagementScore(learningData);
    
    // Track learning effectiveness
    if (learningData.containsKey('timeSpent') && learningData.containsKey('progress')) {
      final timeSpent = learningData['timeSpent'] as int;
      final progress = learningData['progress'] as double;
      final efficiency = progress > 0 ? timeSpent / progress : 0;

      _analytics.trackEvent(AnalyticsEventType.learningProgress, {
        'contentType': contentType,
        'engagementScore': engagementScore,
        'learningEfficiency': efficiency,
        'timeSpent': timeSpent,
        'progress': progress,
      });
    }
  }

  /// Calculate engagement score
  double _calculateEngagementScore(Map<String, dynamic> data) {
    double score = 0.5; // Base score

    // Factor in time spent
    if (data.containsKey('timeSpent')) {
      final timeSpent = data['timeSpent'] as int;
      score += min(timeSpent / 300, 0.3); // Max 0.3 for 5 minutes
    }

    // Factor in progress
    if (data.containsKey('progress')) {
      final progress = data['progress'] as double;
      score += progress * 0.4; // Max 0.4 for 100% progress
    }

    // Factor in interactions
    if (data.containsKey('interactions')) {
      final interactions = data['interactions'] as int;
      score += min(interactions / 10, 0.2); // Max 0.2 for 10+ interactions
    }

    return min(score, 1.0);
  }

  /// Track error patterns
  void trackErrorPattern(String errorType, String errorMessage, String context) {
    trackAction('error', errorType, properties: {
      'errorMessage': errorMessage,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _analytics.trackError(errorType, errorMessage, properties: {
      'context': context,
      'screen': _currentScreen,
    });
  }

  /// Track performance metrics
  void trackPerformanceMetric(String metricName, double value, String unit) {
    trackAction('performance', metricName, properties: {
      'value': value,
      'unit': unit,
    });

    _analytics.trackPerformance(metricName, value, unit, properties: {
      'screen': _currentScreen,
    });
  }

  /// Track user preferences
  void trackUserPreference(String preferenceName, dynamic preferenceValue) {
    trackAction('preference', preferenceName, properties: {
      'value': preferenceValue,
      'valueType': preferenceValue.runtimeType.toString(),
    });
  }

  /// Get user behavior insights
  Map<String, dynamic> getBehaviorInsights() {
    final totalScreenTime = _screenTimeMap.values.fold(Duration.zero, (sum, duration) => sum + duration);
    final mostUsedScreen = _getMostUsedScreen();
    final averageSessionTime = _totalSessions > 0 ? _totalAppTime.inMinutes / _totalSessions : 0;

    return {
      'totalSessions': _totalSessions,
      'totalAppTime': _formatDuration(_totalAppTime),
      'averageSessionTime': '${averageSessionTime.round()} minutes',
      'totalScreenTime': _formatDuration(totalScreenTime),
      'mostUsedScreen': mostUsedScreen,
      'screenTimeBreakdown': _getScreenTimeBreakdown(),
      'featureUsageStats': _getFeatureUsageStats(),
      'recentActions': _getRecentActions(10),
      'learningPatterns': _getLearningPatterns(),
    };
  }

  /// Get most used screen
  String? _getMostUsedScreen() {
    if (_screenTimeMap.isEmpty) return null;
    
    return _screenTimeMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get screen time breakdown
  Map<String, String> _getScreenTimeBreakdown() {
    return _screenTimeMap.map((screen, duration) => 
        MapEntry(screen, _formatDuration(duration)));
  }

  /// Get feature usage statistics
  Map<String, dynamic> _getFeatureUsageStats() {
    return {
      'mostUsedFeatures': _getMostUsedFeatures(),
      'totalFeaturesUsed': _featureUsageCount.length,
      'averageFeatureUsage': _featureUsageCount.values.isNotEmpty 
          ? (_featureUsageCount.values.reduce((a, b) => a + b) / _featureUsageCount.length).round()
          : 0,
    };
  }

  /// Get most used features
  List<Map<String, dynamic>> _getMostUsedFeatures() {
    final sortedFeatures = _featureUsageCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedFeatures.take(5).map((entry) => {
      'feature': entry.key,
      'usageCount': entry.value,
      'firstUsed': _featureFirstUse[entry.key]?.toIso8601String(),
    }).toList();
  }

  /// Get recent actions
  List<Map<String, dynamic>> _getRecentActions(int count) {
    final recentActions = _userActionHistory.reversed.take(count).toList();
    return recentActions.map((action) => action.toJson()).toList();
  }

  /// Get learning patterns
  Map<String, dynamic> _getLearningPatterns() {
    final learningActions = _userActionHistory
        .where((action) => action.actionType == 'learning')
        .toList();

    if (learningActions.isEmpty) return {};

    final contentTypes = <String, int>{};
    for (final action in learningActions) {
      final contentType = action.properties['contentType'] as String?;
      if (contentType != null) {
        contentTypes[contentType] = (contentTypes[contentType] ?? 0) + 1;
      }
    }

    return {
      'totalLearningActions': learningActions.length,
      'contentTypePreferences': contentTypes,
      'averageLearningSessionLength': _calculateAverageLearningSession(),
    };
  }

  /// Calculate average learning session length
  double _calculateAverageLearningSession() {
    final learningScreens = ['video_lecture', 'quiz', 'ebook_reader', 'notes'];
    final learningTimes = learningScreens
        .map((screen) => _screenTimeMap[screen]?.inMinutes ?? 0)
        .where((time) => time > 0);

    if (learningTimes.isEmpty) return 0;
    return learningTimes.reduce((a, b) => a + b) / learningTimes.length;
  }

  /// Format duration
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Load behavior data from cache
  Future<void> _loadBehaviorData() async {
    try {
      final data = await _cache.getCachedData<Map<String, dynamic>>('user_behavior_data');
      if (data != null) {
        _totalSessions = data['totalSessions'] ?? 0;
        _totalAppTime = Duration(milliseconds: data['totalAppTimeMs'] ?? 0);
        
        final screenTimeData = data['screenTimeMap'] as Map<String, dynamic>?;
        if (screenTimeData != null) {
          _screenTimeMap.clear();
          screenTimeData.forEach((key, value) {
            _screenTimeMap[key] = Duration(milliseconds: value);
          });
        }

        final visitCountData = data['screenVisitCount'] as Map<String, dynamic>?;
        if (visitCountData != null) {
          _screenVisitCount.clear();
          _screenVisitCount.addAll(Map<String, int>.from(visitCountData));
        }

        final featureUsageData = data['featureUsageCount'] as Map<String, dynamic>?;
        if (featureUsageData != null) {
          _featureUsageCount.clear();
          _featureUsageCount.addAll(Map<String, int>.from(featureUsageData));
        }

        final featureFirstUseData = data['featureFirstUse'] as Map<String, dynamic>?;
        if (featureFirstUseData != null) {
          _featureFirstUse.clear();
          featureFirstUseData.forEach((key, value) {
            _featureFirstUse[key] = DateTime.parse(value);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load behavior data: $e');
      }
    }
  }

  /// Save behavior data to cache
  Future<void> _saveBehaviorData() async {
    try {
      final data = {
        'totalSessions': _totalSessions,
        'totalAppTimeMs': _totalAppTime.inMilliseconds,
        'screenTimeMap': _screenTimeMap.map((key, value) => MapEntry(key, value.inMilliseconds)),
        'screenVisitCount': _screenVisitCount,
        'featureUsageCount': _featureUsageCount,
        'featureFirstUse': _featureFirstUse.map((key, value) => MapEntry(key, value.toIso8601String())),
        'lastSaved': DateTime.now().toIso8601String(),
      };

      await _cache.cacheData(
        key: 'user_behavior_data',
        data: data,
        type: CacheType.userData,
        expiry: const Duration(days: 365),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save behavior data: $e');
      }
    }
  }

  /// End current session
  void endSession() {
    if (_currentScreen != null) {
      _trackScreenExit();
    }

    _analytics.trackAppLifecycle('session_end');
    _saveBehaviorData();
    
    _sessionTimer?.cancel();
    _inactivityTimer?.cancel();
  }

  /// Dispose resources
  void dispose() {
    endSession();
  }
}

/// User action model
class UserAction {
  final String id;
  final String actionType;
  final String actionName;
  final String? screenName;
  final DateTime timestamp;
  final Map<String, dynamic> properties;

  UserAction({
    required this.id,
    required this.actionType,
    required this.actionName,
    this.screenName,
    required this.timestamp,
    required this.properties,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'actionType': actionType,
    'actionName': actionName,
    'screenName': screenName,
    'timestamp': timestamp.toIso8601String(),
    'properties': properties,
  };

  factory UserAction.fromJson(Map<String, dynamic> json) => UserAction(
    id: json['id'],
    actionType: json['actionType'],
    actionName: json['actionName'],
    screenName: json['screenName'],
    timestamp: DateTime.parse(json['timestamp']),
    properties: Map<String, dynamic>.from(json['properties']),
  );
}