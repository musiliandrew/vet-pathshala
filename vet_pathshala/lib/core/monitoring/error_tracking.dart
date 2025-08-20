import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../analytics/analytics_manager.dart';
import '../caching/offline_cache_manager.dart';

/// Comprehensive error tracking and crash reporting system
class ErrorTracker {
  static final ErrorTracker _instance = ErrorTracker._internal();
  factory ErrorTracker() => _instance;
  ErrorTracker._internal();

  final AnalyticsManager _analytics = AnalyticsManager();
  final OfflineCacheManager _cache = OfflineCacheManager();
  
  bool _initialized = false;
  final List<ErrorReport> _errorQueue = [];
  Timer? _reportingTimer;
  
  static const int maxErrorQueueSize = 50;
  static const Duration reportingInterval = Duration(minutes: 5);

  /// Initialize error tracking
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Set up Flutter error handling
      FlutterError.onError = _handleFlutterError;
      
      // Set up platform error handling
      PlatformDispatcher.instance.onError = _handlePlatformError;
      
      // Set up isolate error handling
      Isolate.current.addErrorListener(
        RawReceivePort((dynamic pair) {
          final List<dynamic> errorAndStacktrace = pair as List<dynamic>;
          _handleIsolateError(
            errorAndStacktrace.first,
            errorAndStacktrace.last as StackTrace?,
          );
        }).sendPort,
      );

      _startErrorReporting();
      _initialized = true;
      
      if (kDebugMode) {
        print('ErrorTracker initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize ErrorTracker: $e');
      }
    }
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    // Log to console in debug mode
    if (kDebugMode) {
      FlutterError.presentError(details);
    }

    // Create error report
    final error = ErrorReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.flutter,
      message: details.exception.toString(),
      stackTrace: details.stack?.toString(),
      context: details.context?.toString(),
      library: details.library,
      timestamp: DateTime.now(),
      severity: _determineSeverity(details.exception),
      additionalData: {
        'silent': details.silent,
        'informationCollector': details.informationCollector?.toString(),
      },
    );

    _reportError(error);
  }

  /// Handle platform-specific errors
  bool _handlePlatformError(Object error, StackTrace stackTrace) {
    final errorReport = ErrorReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.platform,
      message: error.toString(),
      stackTrace: stackTrace.toString(),
      timestamp: DateTime.now(),
      severity: ErrorSeverity.high,
      additionalData: {
        'platform': defaultTargetPlatform.toString(),
      },
    );

    _reportError(errorReport);
    return true; // Handled
  }

  /// Handle isolate errors
  void _handleIsolateError(dynamic error, StackTrace? stackTrace) {
    final errorReport = ErrorReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.isolate,
      message: error.toString(),
      stackTrace: stackTrace?.toString(),
      timestamp: DateTime.now(),
      severity: ErrorSeverity.critical,
      additionalData: {
        'isolate': Isolate.current.debugName ?? 'unnamed',
      },
    );

    _reportError(errorReport);
  }

  /// Report custom errors
  void reportError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity? severity,
    Map<String, dynamic>? additionalData,
  }) {
    final errorReport = ErrorReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.custom,
      message: error.toString(),
      stackTrace: stackTrace?.toString() ?? StackTrace.current.toString(),
      context: context,
      timestamp: DateTime.now(),
      severity: severity ?? ErrorSeverity.medium,
      additionalData: additionalData ?? {},
    );

    _reportError(errorReport);
  }

  /// Report network errors
  void reportNetworkError(
    String url,
    int? statusCode,
    String message, {
    String? method,
    Map<String, String>? headers,
    String? requestBody,
    String? responseBody,
  }) {
    final errorReport = ErrorReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.network,
      message: 'Network Error: $message',
      context: 'URL: $url',
      timestamp: DateTime.now(),
      severity: _determineNetworkErrorSeverity(statusCode),
      additionalData: {
        'url': url,
        'method': method ?? 'GET',
        'statusCode': statusCode,
        'headers': headers,
        'requestBody': requestBody,
        'responseBody': responseBody,
      },
    );

    _reportError(errorReport);
  }

  /// Report user-facing errors
  void reportUserError(
    String userMessage,
    String technicalMessage, {
    String? screen,
    String? action,
    Map<String, dynamic>? additionalData,
  }) {
    final errorReport = ErrorReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.user,
      message: technicalMessage,
      context: 'User Message: $userMessage',
      timestamp: DateTime.now(),
      severity: ErrorSeverity.low,
      additionalData: {
        'userMessage': userMessage,
        'screen': screen,
        'action': action,
        ...?additionalData,
      },
    );

    _reportError(errorReport);
  }

  /// Report performance issues
  void reportPerformanceIssue(
    String issueType,
    double value,
    double threshold, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorReport = ErrorReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ErrorType.performance,
      message: 'Performance Issue: $issueType',
      context: context,
      timestamp: DateTime.now(),
      severity: _determinePerformanceIssueSeverity(value, threshold),
      additionalData: {
        'issueType': issueType,
        'value': value,
        'threshold': threshold,
        'ratio': value / threshold,
        ...?additionalData,
      },
    );

    _reportError(errorReport);
  }

  /// Internal error reporting
  void _reportError(ErrorReport error) {
    // Add to queue
    _errorQueue.add(error);
    
    // Maintain queue size
    if (_errorQueue.length > maxErrorQueueSize) {
      _errorQueue.removeAt(0);
    }

    // Log to analytics
    _analytics.trackError(
      error.type.name,
      error.message,
      properties: {
        'severity': error.severity.name,
        'context': error.context,
        'library': error.library,
        'timestamp': error.timestamp.toIso8601String(),
      },
    );

    // Log to console in debug mode
    if (kDebugMode) {
      print('ERROR [${error.severity.name.toUpperCase()}]: ${error.message}');
      if (error.stackTrace != null) {
        print('Stack Trace:\n${error.stackTrace}');
      }
    }

    // Immediate reporting for critical errors
    if (error.severity == ErrorSeverity.critical) {
      _flushErrorReports();
    }
  }

  /// Start periodic error reporting
  void _startErrorReporting() {
    _reportingTimer?.cancel();
    _reportingTimer = Timer.periodic(reportingInterval, (_) {
      _flushErrorReports();
    });
  }

  /// Flush error reports
  Future<void> _flushErrorReports() async {
    if (_errorQueue.isEmpty) return;

    try {
      final errorsToReport = List<ErrorReport>.from(_errorQueue);
      _errorQueue.clear();

      // Save to local cache
      await _saveErrorsToCache(errorsToReport);

      // Send to crash reporting service
      await _sendErrorsToService(errorsToReport);

      if (kDebugMode) {
        print('Reported ${errorsToReport.length} errors');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to flush error reports: $e');
      }
    }
  }

  /// Save errors to local cache
  Future<void> _saveErrorsToCache(List<ErrorReport> errors) async {
    try {
      final existingErrors = await _cache.getCachedData<List<dynamic>>('error_reports') ?? [];
      final allErrors = [
        ...existingErrors,
        ...errors.map((e) => e.toJson()),
      ];

      // Keep only the latest 200 errors to prevent cache from growing too large
      final errorsToKeep = allErrors.length > 200 
          ? allErrors.sublist(allErrors.length - 200)
          : allErrors;

      await _cache.cacheData(
        key: 'error_reports',
        data: errorsToKeep,
        type: CacheType.analytics,
        expiry: const Duration(days: 30),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save errors to cache: $e');
      }
    }
  }

  /// Send errors to crash reporting service
  Future<void> _sendErrorsToService(List<ErrorReport> errors) async {
    try {
      // In a real implementation, this would send to services like:
      // - Firebase Crashlytics
      // - Sentry
      // - Bugsnag
      // - Custom crash reporting endpoint

      if (kDebugMode) {
        print('Sending ${errors.length} errors to crash reporting service');
        for (final error in errors) {
          print('  ${error.type.name}: ${error.message.substring(0, 50)}...');
        }
      }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

    } catch (e) {
      if (kDebugMode) {
        print('Failed to send errors to service: $e');
      }
    }
  }

  /// Determine error severity
  ErrorSeverity _determineSeverity(dynamic exception) {
    if (exception is AssertionError) {
      return ErrorSeverity.high;
    } else if (exception is NoSuchMethodError) {
      return ErrorSeverity.critical;
    } else if (exception is RangeError) {
      return ErrorSeverity.high;
    } else if (exception is FormatException) {
      return ErrorSeverity.medium;
    } else if (exception is TypeError) {
      return ErrorSeverity.critical;
    } else {
      return ErrorSeverity.medium;
    }
  }

  /// Determine network error severity
  ErrorSeverity _determineNetworkErrorSeverity(int? statusCode) {
    if (statusCode == null) return ErrorSeverity.high;
    
    if (statusCode >= 500) {
      return ErrorSeverity.high;
    } else if (statusCode >= 400) {
      return ErrorSeverity.medium;
    } else {
      return ErrorSeverity.low;
    }
  }

  /// Determine performance issue severity
  ErrorSeverity _determinePerformanceIssueSeverity(double value, double threshold) {
    final ratio = value / threshold;
    
    if (ratio >= 3.0) {
      return ErrorSeverity.critical;
    } else if (ratio >= 2.0) {
      return ErrorSeverity.high;
    } else if (ratio >= 1.5) {
      return ErrorSeverity.medium;
    } else {
      return ErrorSeverity.low;
    }
  }

  /// Get error statistics
  Map<String, dynamic> getErrorStatistics() {
    return {
      'totalErrors': _errorQueue.length,
      'errorsByType': _getErrorsByType(),
      'errorsBySeverity': _getErrorsBySeverity(),
      'recentErrors': _errorQueue.reversed.take(5).map((e) => e.toJson()).toList(),
    };
  }

  /// Get errors grouped by type
  Map<String, int> _getErrorsByType() {
    final typeCount = <String, int>{};
    for (final error in _errorQueue) {
      final type = error.type.name;
      typeCount[type] = (typeCount[type] ?? 0) + 1;
    }
    return typeCount;
  }

  /// Get errors grouped by severity
  Map<String, int> _getErrorsBySeverity() {
    final severityCount = <String, int>{};
    for (final error in _errorQueue) {
      final severity = error.severity.name;
      severityCount[severity] = (severityCount[severity] ?? 0) + 1;
    }
    return severityCount;
  }

  /// Get cached errors count
  Future<int> getCachedErrorsCount() async {
    try {
      final errors = await _cache.getCachedData<List<dynamic>>('error_reports');
      return errors?.length ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Clear error cache
  Future<void> clearErrorCache() async {
    _errorQueue.clear();
    await _cache.removeCacheEntry('error_reports');
  }

  /// Force flush all errors
  Future<void> forceFlush() async {
    await _flushErrorReports();
  }

  /// Dispose resources
  void dispose() {
    _reportingTimer?.cancel();
    _flushErrorReports(); // Final flush
  }
}

/// Error report model
class ErrorReport {
  final String id;
  final ErrorType type;
  final String message;
  final String? stackTrace;
  final String? context;
  final String? library;
  final DateTime timestamp;
  final ErrorSeverity severity;
  final Map<String, dynamic> additionalData;

  ErrorReport({
    required this.id,
    required this.type,
    required this.message,
    this.stackTrace,
    this.context,
    this.library,
    required this.timestamp,
    required this.severity,
    required this.additionalData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'message': message,
    'stackTrace': stackTrace,
    'context': context,
    'library': library,
    'timestamp': timestamp.toIso8601String(),
    'severity': severity.name,
    'additionalData': additionalData,
  };

  factory ErrorReport.fromJson(Map<String, dynamic> json) => ErrorReport(
    id: json['id'],
    type: ErrorType.values.firstWhere((e) => e.name == json['type']),
    message: json['message'],
    stackTrace: json['stackTrace'],
    context: json['context'],
    library: json['library'],
    timestamp: DateTime.parse(json['timestamp']),
    severity: ErrorSeverity.values.firstWhere((e) => e.name == json['severity']),
    additionalData: Map<String, dynamic>.from(json['additionalData']),
  );
}

/// Error types
enum ErrorType {
  flutter,
  platform,
  isolate,
  network,
  user,
  performance,
  custom,
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}