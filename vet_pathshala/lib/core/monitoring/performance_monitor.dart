import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../analytics/analytics_manager.dart';
import '../caching/offline_cache_manager.dart';
import 'error_tracking.dart';

/// Comprehensive performance monitoring system
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final AnalyticsManager _analytics = AnalyticsManager();
  final OfflineCacheManager _cache = OfflineCacheManager();
  final ErrorTracker _errorTracker = ErrorTracker();
  
  bool _initialized = false;
  Timer? _monitoringTimer;
  
  // Performance metrics
  final List<FrameTimingInfo> _frameTimings = [];
  final List<MemoryUsageInfo> _memoryUsages = [];
  final List<NetworkPerformanceInfo> _networkMetrics = [];
  final List<AppStartupInfo> _startupMetrics = [];
  final Map<String, PerformanceMetric> _customMetrics = {};
  
  DateTime? _appStartTime;
  DateTime? _firstFrameTime;
  int _jankyFrameCount = 0;
  int _totalFrameCount = 0;
  
  static const int maxMetricsCount = 100;
  static const Duration monitoringInterval = Duration(seconds: 30);
  static const double jankyFrameThreshold = 16.67; // 60fps threshold in ms

  /// Initialize performance monitoring
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _appStartTime = DateTime.now();
      
      // Set up frame timing monitoring
      _setupFrameTimingMonitoring();
      
      // Set up memory monitoring
      _setupMemoryMonitoring();
      
      // Start periodic monitoring
      _startPeriodicMonitoring();
      
      _initialized = true;
      
      if (kDebugMode) {
        print('PerformanceMonitor initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize PerformanceMonitor: $e');
      }
    }
  }

  /// Setup frame timing monitoring
  void _setupFrameTimingMonitoring() {
    // Monitor frame timings
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    
    // Track first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_firstFrameTime == null) {
        _firstFrameTime = DateTime.now();
        _recordAppStartupMetric();
      }
    });
  }

  /// Handle frame timings callback
  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameTime = timing.totalSpan.inMicroseconds / 1000.0; // Convert to ms
      
      _totalFrameCount++;
      
      // Check for janky frames
      if (frameTime > jankyFrameThreshold) {
        _jankyFrameCount++;
      }
      
      final frameInfo = FrameTimingInfo(
        timestamp: DateTime.now(),
        buildDuration: timing.buildDuration.inMicroseconds / 1000.0,
        rasterDuration: timing.rasterDuration.inMicroseconds / 1000.0,
        totalDuration: frameTime,
        isJanky: frameTime > jankyFrameThreshold,
      );
      
      _frameTimings.add(frameInfo);
      
      // Maintain list size
      if (_frameTimings.length > maxMetricsCount) {
        _frameTimings.removeAt(0);
      }
      
      // Report severe performance issues
      if (frameTime > jankyFrameThreshold * 3) {
        _errorTracker.reportPerformanceIssue(
          'severe_frame_drop',
          frameTime,
          jankyFrameThreshold,
          context: 'Frame rendering',
          additionalData: {
            'buildDuration': timing.buildDuration.inMicroseconds / 1000.0,
            'rasterDuration': timing.rasterDuration.inMicroseconds / 1000.0,
          },
        );
      }
    }
  }

  /// Setup memory monitoring
  void _setupMemoryMonitoring() {
    // Memory monitoring is handled in periodic monitoring
  }

  /// Start periodic monitoring
  void _startPeriodicMonitoring() {
    _monitoringTimer = Timer.periodic(monitoringInterval, (_) async {
      await _collectSystemMetrics();
    });
  }

  /// Collect system metrics
  Future<void> _collectSystemMetrics() async {
    try {
      // Collect memory usage (simulated)
      await _collectMemoryMetrics();
      
      // Collect performance metrics
      _collectPerformanceMetrics();
      
      // Send metrics to analytics
      _sendMetricsToAnalytics();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to collect system metrics: $e');
      }
    }
  }

  /// Collect memory metrics
  Future<void> _collectMemoryMetrics() async {
    try {
      // Note: Dart doesn't provide direct memory access
      // In a real implementation, you might use platform channels
      // or system-specific APIs to get actual memory usage
      
      final memoryInfo = MemoryUsageInfo(
        timestamp: DateTime.now(),
        usedMemoryMB: 0, // Would be actual memory usage
        maxMemoryMB: 0,  // Would be max available memory
        memoryPressure: MemoryPressureLevel.normal,
      );
      
      _memoryUsages.add(memoryInfo);
      
      // Maintain list size
      if (_memoryUsages.length > maxMetricsCount) {
        _memoryUsages.removeAt(0);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to collect memory metrics: $e');
      }
    }
  }

  /// Collect performance metrics
  void _collectPerformanceMetrics() {
    final now = DateTime.now();
    
    // Calculate frame rate statistics
    final recentFrames = _frameTimings.where(
      (frame) => now.difference(frame.timestamp).inMinutes < 1,
    ).toList();
    
    if (recentFrames.isNotEmpty) {
      final avgFrameTime = recentFrames
          .map((f) => f.totalDuration)
          .reduce((a, b) => a + b) / recentFrames.length;
      
      final frameRate = 1000.0 / avgFrameTime;
      final jankyFramePercent = recentFrames.where((f) => f.isJanky).length / 
          recentFrames.length * 100;
      
      // Track frame rate metric
      trackCustomMetric('frame_rate', frameRate, 'fps');
      trackCustomMetric('janky_frame_percent', jankyFramePercent, '%');
      
      // Report if frame rate is too low
      if (frameRate < 45) {
        _errorTracker.reportPerformanceIssue(
          'low_frame_rate',
          frameRate,
          60.0,
          context: 'Frame rate monitoring',
        );
      }
    }
  }

  /// Send metrics to analytics
  void _sendMetricsToAnalytics() {
    for (final metric in _customMetrics.entries) {
      if (metric.value.shouldReport()) {
        _analytics.trackPerformance(
          metric.key,
          metric.value.currentValue,
          metric.value.unit,
          properties: {
            'min': metric.value.minValue,
            'max': metric.value.maxValue,
            'avg': metric.value.averageValue,
            'count': metric.value.sampleCount,
          },
        );
        
        metric.value.resetReporting();
      }
    }
  }

  /// Record app startup metric
  void _recordAppStartupMetric() {
    if (_appStartTime == null || _firstFrameTime == null) return;
    
    final startupTime = _firstFrameTime!.difference(_appStartTime!);
    
    final startupInfo = AppStartupInfo(
      timestamp: DateTime.now(),
      coldStartDuration: startupTime,
      timeToFirstFrame: startupTime,
      isWarmStart: false, // Would determine based on app state
    );
    
    _startupMetrics.add(startupInfo);
    
    // Track startup performance
    _analytics.trackPerformance(
      'app_startup_time',
      startupTime.inMilliseconds.toDouble(),
      'ms',
      properties: {
        'isWarmStart': startupInfo.isWarmStart,
        'timeToFirstFrame': startupInfo.timeToFirstFrame.inMilliseconds,
      },
    );
    
    // Report slow startup
    if (startupTime.inMilliseconds > 3000) {
      _errorTracker.reportPerformanceIssue(
        'slow_app_startup',
        startupTime.inMilliseconds.toDouble(),
        2000.0,
        context: 'App startup',
      );
    }
  }

  /// Track network performance
  void trackNetworkPerformance({
    required String url,
    required Duration duration,
    required int responseSize,
    int? statusCode,
    String? method,
  }) {
    final networkInfo = NetworkPerformanceInfo(
      timestamp: DateTime.now(),
      url: url,
      method: method ?? 'GET',
      duration: duration,
      responseSize: responseSize,
      statusCode: statusCode,
    );
    
    _networkMetrics.add(networkInfo);
    
    // Maintain list size
    if (_networkMetrics.length > maxMetricsCount) {
      _networkMetrics.removeAt(0);
    }
    
    // Track network metrics
    _analytics.trackPerformance(
      'network_request_duration',
      duration.inMilliseconds.toDouble(),
      'ms',
      properties: {
        'url': url,
        'method': method ?? 'GET',
        'responseSize': responseSize,
        'statusCode': statusCode,
      },
    );
    
    // Report slow network requests
    if (duration.inMilliseconds > 10000) {
      _errorTracker.reportPerformanceIssue(
        'slow_network_request',
        duration.inMilliseconds.toDouble(),
        5000.0,
        context: 'Network request to $url',
        additionalData: {
          'method': method,
          'statusCode': statusCode,
          'responseSize': responseSize,
        },
      );
    }
  }

  /// Track custom performance metric
  void trackCustomMetric(String name, double value, String unit) {
    if (!_customMetrics.containsKey(name)) {
      _customMetrics[name] = PerformanceMetric(name: name, unit: unit);
    }
    
    _customMetrics[name]!.addSample(value);
  }

  /// Start performance timing
  PerformanceTimer startTiming(String operationName) {
    return PerformanceTimer(operationName, this);
  }

  /// Track screen load performance
  void trackScreenLoadTime(String screenName, Duration loadTime) {
    _analytics.trackPerformance(
      'screen_load_time',
      loadTime.inMilliseconds.toDouble(),
      'ms',
      properties: {
        'screenName': screenName,
      },
    );
    
    // Report slow screen loads
    if (loadTime.inMilliseconds > 2000) {
      _errorTracker.reportPerformanceIssue(
        'slow_screen_load',
        loadTime.inMilliseconds.toDouble(),
        1000.0,
        context: 'Screen load: $screenName',
      );
    }
  }

  /// Track widget build performance
  void trackWidgetBuildTime(String widgetName, Duration buildTime) {
    trackCustomMetric('widget_build_time_${widgetName}', 
        buildTime.inMicroseconds.toDouble(), 'μs');
    
    // Report slow widget builds
    if (buildTime.inMilliseconds > 50) {
      _errorTracker.reportPerformanceIssue(
        'slow_widget_build',
        buildTime.inMilliseconds.toDouble(),
        16.67,
        context: 'Widget build: $widgetName',
      );
    }
  }

  /// Track database operation performance
  void trackDatabaseOperation(String operation, Duration duration, int recordCount) {
    _analytics.trackPerformance(
      'database_operation_duration',
      duration.inMilliseconds.toDouble(),
      'ms',
      properties: {
        'operation': operation,
        'recordCount': recordCount,
      },
    );
    
    // Report slow database operations
    if (duration.inMilliseconds > 1000) {
      _errorTracker.reportPerformanceIssue(
        'slow_database_operation',
        duration.inMilliseconds.toDouble(),
        500.0,
        context: 'Database $operation',
        additionalData: {
          'recordCount': recordCount,
        },
      );
    }
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStatistics() {
    final stats = <String, dynamic>{};
    
    // Frame performance
    if (_frameTimings.isNotEmpty) {
      final recentFrames = _frameTimings.length > 60 
          ? _frameTimings.skip(_frameTimings.length - 60).toList()
          : _frameTimings;
      final avgFrameTime = recentFrames
          .map((f) => f.totalDuration)
          .reduce((a, b) => a + b) / recentFrames.length;
      
      stats['framePerformance'] = {
        'averageFrameTime': avgFrameTime,
        'frameRate': 1000.0 / avgFrameTime,
        'jankyFrameCount': _jankyFrameCount,
        'totalFrameCount': _totalFrameCount,
        'jankyFramePercent': (_jankyFrameCount / _totalFrameCount * 100).toStringAsFixed(1),
      };
    }
    
    // Memory usage
    if (_memoryUsages.isNotEmpty) {
      final latestMemory = _memoryUsages.last;
      stats['memoryUsage'] = {
        'currentUsageMB': latestMemory.usedMemoryMB,
        'maxMemoryMB': latestMemory.maxMemoryMB,
        'memoryPressure': latestMemory.memoryPressure.name,
      };
    }
    
    // Network performance
    if (_networkMetrics.isNotEmpty) {
      final recentRequests = _networkMetrics.length > 20 
          ? _networkMetrics.skip(_networkMetrics.length - 20).toList()
          : _networkMetrics;
      final avgDuration = recentRequests
          .map((r) => r.duration.inMilliseconds)
          .reduce((a, b) => a + b) / recentRequests.length;
      
      stats['networkPerformance'] = {
        'averageRequestTime': avgDuration,
        'totalRequests': _networkMetrics.length,
        'slowRequestCount': recentRequests.where((r) => r.duration.inMilliseconds > 5000).length,
      };
    }
    
    // Custom metrics
    stats['customMetrics'] = _customMetrics.map(
      (key, value) => MapEntry(key, {
        'current': value.currentValue,
        'average': value.averageValue,
        'min': value.minValue,
        'max': value.maxValue,
        'samples': value.sampleCount,
      }),
    );
    
    // App startup
    if (_appStartTime != null && _firstFrameTime != null) {
      stats['appStartup'] = {
        'startupTime': _firstFrameTime!.difference(_appStartTime!).inMilliseconds,
      };
    }
    
    return stats;
  }

  /// Generate performance report
  Map<String, dynamic> generatePerformanceReport() {
    return {
      'reportTimestamp': DateTime.now().toIso8601String(),
      'monitoringDuration': _appStartTime != null 
          ? DateTime.now().difference(_appStartTime!).inMinutes
          : 0,
      'statistics': getPerformanceStatistics(),
      'issues': _getPerformanceIssues(),
      'recommendations': _getPerformanceRecommendations(),
    };
  }

  /// Get performance issues
  List<Map<String, dynamic>> _getPerformanceIssues() {
    final issues = <Map<String, dynamic>>[];
    
    // Check frame rate issues
    if (_totalFrameCount > 0) {
      final jankyPercent = _jankyFrameCount / _totalFrameCount * 100;
      if (jankyPercent > 5) {
        issues.add({
          'type': 'frame_drops',
          'severity': jankyPercent > 15 ? 'high' : 'medium',
          'description': 'High percentage of janky frames: ${jankyPercent.toStringAsFixed(1)}%',
        });
      }
    }
    
    // Check network issues
    final slowNetworkRequests = _networkMetrics
        .where((r) => r.duration.inMilliseconds > 5000)
        .length;
    if (slowNetworkRequests > 0) {
      issues.add({
        'type': 'slow_network',
        'severity': 'medium',
        'description': '$slowNetworkRequests slow network requests detected',
      });
    }
    
    return issues;
  }

  /// Get performance recommendations
  List<String> _getPerformanceRecommendations() {
    final recommendations = <String>[];
    
    // Frame rate recommendations
    if (_totalFrameCount > 0) {
      final jankyPercent = _jankyFrameCount / _totalFrameCount * 100;
      if (jankyPercent > 10) {
        recommendations.add('Optimize UI rendering to reduce frame drops');
        recommendations.add('Consider using const constructors for widgets');
        recommendations.add('Implement proper list view recycling');
      }
    }
    
    // Network recommendations
    if (_networkMetrics.any((r) => r.duration.inMilliseconds > 5000)) {
      recommendations.add('Implement request caching to reduce network calls');
      recommendations.add('Add loading indicators for long-running operations');
      recommendations.add('Consider implementing request retry mechanisms');
    }
    
    return recommendations;
  }

  /// Save performance data
  Future<void> savePerformanceData() async {
    try {
      final data = {
        'frameTimings': (_frameTimings.length > 50 ? _frameTimings.skip(_frameTimings.length - 50) : _frameTimings).map((f) => f.toJson()).toList(),
        'memoryUsages': (_memoryUsages.length > 50 ? _memoryUsages.skip(_memoryUsages.length - 50) : _memoryUsages).map((m) => m.toJson()).toList(),
        'networkMetrics': (_networkMetrics.length > 50 ? _networkMetrics.skip(_networkMetrics.length - 50) : _networkMetrics).map((n) => n.toJson()).toList(),
        'customMetrics': _customMetrics.map((k, v) => MapEntry(k, v.toJson())),
        'statistics': getPerformanceStatistics(),
        'savedAt': DateTime.now().toIso8601String(),
      };
      
      await _cache.cacheData(
        key: 'performance_data',
        data: data,
        type: CacheType.analytics,
        expiry: const Duration(days: 7),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save performance data: $e');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _monitoringTimer?.cancel();
    savePerformanceData(); // Final save
  }
}

/// Performance timer utility
class PerformanceTimer {
  final String operationName;
  final PerformanceMonitor monitor;
  final DateTime startTime;
  
  PerformanceTimer(this.operationName, this.monitor) : startTime = DateTime.now();
  
  void stop({Map<String, dynamic>? additionalData}) {
    final duration = DateTime.now().difference(startTime);
    monitor.trackCustomMetric('${operationName}_duration', 
        duration.inMilliseconds.toDouble(), 'ms');
  }
}

/// Frame timing information
class FrameTimingInfo {
  final DateTime timestamp;
  final double buildDuration;
  final double rasterDuration;
  final double totalDuration;
  final bool isJanky;
  
  FrameTimingInfo({
    required this.timestamp,
    required this.buildDuration,
    required this.rasterDuration,
    required this.totalDuration,
    required this.isJanky,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'buildDuration': buildDuration,
    'rasterDuration': rasterDuration,
    'totalDuration': totalDuration,
    'isJanky': isJanky,
  };
}

/// Memory usage information
class MemoryUsageInfo {
  final DateTime timestamp;
  final double usedMemoryMB;
  final double maxMemoryMB;
  final MemoryPressureLevel memoryPressure;
  
  MemoryUsageInfo({
    required this.timestamp,
    required this.usedMemoryMB,
    required this.maxMemoryMB,
    required this.memoryPressure,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'usedMemoryMB': usedMemoryMB,
    'maxMemoryMB': maxMemoryMB,
    'memoryPressure': memoryPressure.name,
  };
}

/// Network performance information
class NetworkPerformanceInfo {
  final DateTime timestamp;
  final String url;
  final String method;
  final Duration duration;
  final int responseSize;
  final int? statusCode;
  
  NetworkPerformanceInfo({
    required this.timestamp,
    required this.url,
    required this.method,
    required this.duration,
    required this.responseSize,
    this.statusCode,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'url': url,
    'method': method,
    'duration': duration.inMilliseconds,
    'responseSize': responseSize,
    'statusCode': statusCode,
  };
}

/// App startup information
class AppStartupInfo {
  final DateTime timestamp;
  final Duration coldStartDuration;
  final Duration timeToFirstFrame;
  final bool isWarmStart;
  
  AppStartupInfo({
    required this.timestamp,
    required this.coldStartDuration,
    required this.timeToFirstFrame,
    required this.isWarmStart,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'coldStartDuration': coldStartDuration.inMilliseconds,
    'timeToFirstFrame': timeToFirstFrame.inMilliseconds,
    'isWarmStart': isWarmStart,
  };
}

/// Performance metric tracker
class PerformanceMetric {
  final String name;
  final String unit;
  final List<double> _samples = [];
  DateTime _lastReported = DateTime.now();
  
  PerformanceMetric({required this.name, required this.unit});
  
  void addSample(double value) {
    _samples.add(value);
    
    // Keep only last 100 samples
    if (_samples.length > 100) {
      _samples.removeAt(0);
    }
  }
  
  double get currentValue => _samples.isNotEmpty ? _samples.last : 0;
  double get averageValue => _samples.isNotEmpty 
      ? _samples.reduce((a, b) => a + b) / _samples.length 
      : 0;
  double get minValue => _samples.isNotEmpty ? _samples.reduce((a, b) => a < b ? a : b) : 0;
  double get maxValue => _samples.isNotEmpty ? _samples.reduce((a, b) => a > b ? a : b) : 0;
  int get sampleCount => _samples.length;
  
  bool shouldReport() {
    return DateTime.now().difference(_lastReported).inMinutes >= 1 && _samples.isNotEmpty;
  }
  
  void resetReporting() {
    _lastReported = DateTime.now();
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'unit': unit,
    'current': currentValue,
    'average': averageValue,
    'min': minValue,
    'max': maxValue,
    'samples': sampleCount,
  };
}

/// Memory pressure levels
enum MemoryPressureLevel {
  normal,
  moderate,
  critical,
}