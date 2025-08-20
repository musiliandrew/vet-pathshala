import 'package:flutter/foundation.dart';

/// Build configuration for different environments and app store deployment
class BuildConfig {
  static const String appName = 'Vet Pathshala';
  static const String packageName = 'com.vetpathshala.app';
  static const String appDescription = 'Comprehensive educational platform for veterinary professionals';
  
  // Version information
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  static const String buildSignature = 'release-v1.0.0';
  
  // Environment configuration
  static BuildEnvironment get environment {
    if (kDebugMode) {
      return BuildEnvironment.development;
    } else if (kProfileMode) {
      return BuildEnvironment.staging;
    } else {
      return BuildEnvironment.production;
    }
  }

  // API Configuration
  static String get baseApiUrl {
    switch (environment) {
      case BuildEnvironment.development:
        return 'https://dev-api.vetpathshala.com';
      case BuildEnvironment.staging:
        return 'https://staging-api.vetpathshala.com';
      case BuildEnvironment.production:
        return 'https://api.vetpathshala.com';
    }
  }

  // Firebase Configuration
  static String get firebaseProjectId {
    switch (environment) {
      case BuildEnvironment.development:
        return 'vetpathshala-dev';
      case BuildEnvironment.staging:
        return 'vetpathshala-staging';
      case BuildEnvironment.production:
        return 'vetpathshala-prod';
    }
  }

  // Analytics Configuration
  static bool get analyticsEnabled {
    return environment == BuildEnvironment.production;
  }

  static bool get crashlyticsEnabled {
    return environment != BuildEnvironment.development;
  }

  // Feature flags
  static bool get debugMenuEnabled {
    return environment == BuildEnvironment.development;
  }

  static bool get performanceMonitoringEnabled {
    return environment != BuildEnvironment.development;
  }

  // App Store Configuration
  static AppStoreConfig get appStoreConfig {
    return AppStoreConfig(
      appName: appName,
      bundleId: packageName,
      version: version,
      buildNumber: buildNumber,
      minSdkVersion: 21, // Android API 21 (Lollipop)
      targetSdkVersion: 34, // Android API 34
      minIosVersion: '12.0',
      supportedLanguages: ['en', 'hi', 'es'],
      supportedRegions: ['US', 'IN', 'ES'],
      contentRating: '4+', // iOS
      androidContentRating: 'Everyone', // Android
    );
  }

  // Security Configuration
  static SecurityConfig get securityConfig {
    return SecurityConfig(
      enableCertificatePinning: environment == BuildEnvironment.production,
      enableObfuscation: environment == BuildEnvironment.production,
      enableR8Shrinking: environment != BuildEnvironment.development,
      enableProguard: environment == BuildEnvironment.production,
      allowHttpTraffic: environment == BuildEnvironment.development,
      enableDebugging: environment == BuildEnvironment.development,
    );
  }

  // Performance Configuration
  static PerformanceConfig get performanceConfig {
    return PerformanceConfig(
      enableCodeSplitting: true,
      enableLazyLoading: true,
      enableCaching: true,
      maxCacheSize: environment == BuildEnvironment.production ? 500 : 100, // MB
      enableImageOptimization: true,
      enableNetworkOptimization: true,
      enableMemoryOptimization: true,
    );
  }

  // Monitoring Configuration
  static MonitoringConfig get monitoringConfig {
    return MonitoringConfig(
      enableErrorTracking: environment != BuildEnvironment.development,
      enablePerformanceTracking: environment == BuildEnvironment.production,
      enableUserAnalytics: environment == BuildEnvironment.production,
      enableCrashReporting: environment != BuildEnvironment.development,
      logLevel: environment == BuildEnvironment.development ? LogLevel.debug : LogLevel.info,
    );
  }

  // Deployment targets
  static List<DeploymentTarget> get deploymentTargets {
    return [
      DeploymentTarget.androidPlayStore,
      DeploymentTarget.iosAppStore,
      DeploymentTarget.webPwa,
    ];
  }

  // Build flags for compilation
  static Map<String, dynamic> get buildFlags {
    return {
      'dart-define': {
        'ENVIRONMENT': environment.name,
        'API_URL': baseApiUrl,
        'FIREBASE_PROJECT_ID': firebaseProjectId,
        'ANALYTICS_ENABLED': analyticsEnabled.toString(),
        'CRASHLYTICS_ENABLED': crashlyticsEnabled.toString(),
        'DEBUG_MENU_ENABLED': debugMenuEnabled.toString(),
      }
    };
  }

  // Get environment-specific configuration
  static T getEnvironmentConfig<T>({
    required T development,
    required T staging,
    required T production,
  }) {
    switch (environment) {
      case BuildEnvironment.development:
        return development;
      case BuildEnvironment.staging:
        return staging;
      case BuildEnvironment.production:
        return production;
    }
  }

  // Validate build configuration
  static List<String> validateConfiguration() {
    final issues = <String>[];

    // Check version format
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
      issues.add('Invalid version format: $version');
    }

    // Check package name format
    if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$').hasMatch(packageName)) {
      issues.add('Invalid package name format: $packageName');
    }

    // Check build number
    if (buildNumber <= 0) {
      issues.add('Build number must be positive: $buildNumber');
    }

    // Environment-specific validations
    if (environment == BuildEnvironment.production) {
      if (debugMenuEnabled) {
        issues.add('Debug menu should be disabled in production');
      }
      if (!analyticsEnabled) {
        issues.add('Analytics should be enabled in production');
      }
      if (!securityConfig.enableObfuscation) {
        issues.add('Code obfuscation should be enabled in production');
      }
    }

    return issues;
  }

  // Print configuration summary
  static void printConfigurationSummary() {
    if (kDebugMode) {
      print('=== Build Configuration ===');
      print('App Name: $appName');
      print('Package Name: $packageName');
      print('Version: $version');
      print('Build Number: $buildNumber');
      print('Environment: ${environment.name}');
      print('API URL: $baseApiUrl');
      print('Firebase Project: $firebaseProjectId');
      print('Analytics Enabled: $analyticsEnabled');
      print('Debug Menu Enabled: $debugMenuEnabled');
      print('Security Config: ${securityConfig.toString()}');
      print('Performance Config: ${performanceConfig.toString()}');
      print('==============================');
    }
  }
}

/// Build environments
enum BuildEnvironment {
  development,
  staging,
  production,
}

/// Deployment targets
enum DeploymentTarget {
  androidPlayStore,
  iosAppStore,
  webPwa,
  windowsStore,
  macAppStore,
  linuxSnap,
}

/// App store configuration
class AppStoreConfig {
  final String appName;
  final String bundleId;
  final String version;
  final int buildNumber;
  final int minSdkVersion;
  final int targetSdkVersion;
  final String minIosVersion;
  final List<String> supportedLanguages;
  final List<String> supportedRegions;
  final String contentRating;
  final String androidContentRating;

  const AppStoreConfig({
    required this.appName,
    required this.bundleId,
    required this.version,
    required this.buildNumber,
    required this.minSdkVersion,
    required this.targetSdkVersion,
    required this.minIosVersion,
    required this.supportedLanguages,
    required this.supportedRegions,
    required this.contentRating,
    required this.androidContentRating,
  });

  @override
  String toString() {
    return 'AppStoreConfig(appName: $appName, bundleId: $bundleId, version: $version)';
  }
}

/// Security configuration
class SecurityConfig {
  final bool enableCertificatePinning;
  final bool enableObfuscation;
  final bool enableR8Shrinking;
  final bool enableProguard;
  final bool allowHttpTraffic;
  final bool enableDebugging;

  const SecurityConfig({
    required this.enableCertificatePinning,
    required this.enableObfuscation,
    required this.enableR8Shrinking,
    required this.enableProguard,
    required this.allowHttpTraffic,
    required this.enableDebugging,
  });

  @override
  String toString() {
    return 'SecurityConfig(obfuscation: $enableObfuscation, pinning: $enableCertificatePinning)';
  }
}

/// Performance configuration
class PerformanceConfig {
  final bool enableCodeSplitting;
  final bool enableLazyLoading;
  final bool enableCaching;
  final int maxCacheSize;
  final bool enableImageOptimization;
  final bool enableNetworkOptimization;
  final bool enableMemoryOptimization;

  const PerformanceConfig({
    required this.enableCodeSplitting,
    required this.enableLazyLoading,
    required this.enableCaching,
    required this.maxCacheSize,
    required this.enableImageOptimization,
    required this.enableNetworkOptimization,
    required this.enableMemoryOptimization,
  });

  @override
  String toString() {
    return 'PerformanceConfig(caching: $enableCaching, optimization: $enableImageOptimization)';
  }
}

/// Monitoring configuration
class MonitoringConfig {
  final bool enableErrorTracking;
  final bool enablePerformanceTracking;
  final bool enableUserAnalytics;
  final bool enableCrashReporting;
  final LogLevel logLevel;

  const MonitoringConfig({
    required this.enableErrorTracking,
    required this.enablePerformanceTracking,
    required this.enableUserAnalytics,
    required this.enableCrashReporting,
    required this.logLevel,
  });

  @override
  String toString() {
    return 'MonitoringConfig(analytics: $enableUserAnalytics, crashReporting: $enableCrashReporting)';
  }
}

/// Log levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
}