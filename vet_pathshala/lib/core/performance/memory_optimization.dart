import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Memory optimization utilities for the application
class MemoryOptimization {
  static final MemoryOptimization _instance = MemoryOptimization._internal();
  factory MemoryOptimization() => _instance;
  MemoryOptimization._internal();

  final Map<String, dynamic> _memoryCache = {};
  final Queue<String> _cacheOrder = Queue<String>();
  static const int maxCacheSize = 50;
  
  Timer? _cleanupTimer;

  /// Initialize memory optimization
  void initialize() {
    _setupPeriodicCleanup();
  }

  /// Setup periodic memory cleanup
  void _setupPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performCleanup(),
    );
  }

  /// Cache data with memory limit
  void cacheData(String key, dynamic data) {
    if (_memoryCache.containsKey(key)) {
      _cacheOrder.remove(key);
    } else if (_memoryCache.length >= maxCacheSize) {
      final oldestKey = _cacheOrder.removeFirst();
      _memoryCache.remove(oldestKey);
    }

    _memoryCache[key] = data;
    _cacheOrder.add(key);
  }

  /// Get cached data
  T? getCachedData<T>(String key) {
    final data = _memoryCache[key];
    if (data != null) {
      // Move to end of queue (most recently used)
      _cacheOrder.remove(key);
      _cacheOrder.add(key);
      return data as T?;
    }
    return null;
  }

  /// Remove specific cached data
  void removeCachedData(String key) {
    _memoryCache.remove(key);
    _cacheOrder.remove(key);
  }

  /// Clear all cached data
  void clearCache() {
    _memoryCache.clear();
    _cacheOrder.clear();
  }

  /// Perform memory cleanup
  void _performCleanup() {
    if (kDebugMode) {
      print('Performing memory cleanup...');
      print('Cache size before: ${_memoryCache.length}');
    }

    // Remove oldest 25% of cache items if cache is full
    if (_memoryCache.length >= maxCacheSize * 0.75) {
      final itemsToRemove = (_memoryCache.length * 0.25).round();
      for (int i = 0; i < itemsToRemove && _cacheOrder.isNotEmpty; i++) {
        final key = _cacheOrder.removeFirst();
        _memoryCache.remove(key);
      }
    }

    if (kDebugMode) {
      print('Cache size after: ${_memoryCache.length}');
    }

    // Force garbage collection in debug mode
    if (kDebugMode) {
      // Note: Dart doesn't have explicit GC, but we can trigger it indirectly
      _triggerGarbageCollection();
    }
  }

  /// Trigger garbage collection (debug only)
  void _triggerGarbageCollection() {
    // Create and dispose temporary objects to encourage GC
    for (int i = 0; i < 1000; i++) {
      final temp = List.filled(100, i);
      temp.clear();
    }
  }

  /// Get memory usage statistics
  Map<String, dynamic> getMemoryStats() {
    return {
      'cacheSize': _memoryCache.length,
      'maxCacheSize': maxCacheSize,
      'cacheUtilization': (_memoryCache.length / maxCacheSize * 100).round(),
      'cachedKeys': _cacheOrder.toList(),
    };
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    clearCache();
  }
}

/// Image memory optimization
class ImageMemoryOptimizer {
  static const Map<String, int> _imageSizeCache = {};
  static const int maxImageCacheSize = 20;
  static final Queue<String> _imageOrder = Queue<String>();

  /// Optimize image loading
  static void cacheImageSize(String url, int sizeInBytes) {
    if (_imageSizeCache.containsKey(url)) {
      _imageOrder.remove(url);
    } else if (_imageSizeCache.length >= maxImageCacheSize) {
      final oldestUrl = _imageOrder.removeFirst();
      _imageSizeCache.remove(oldestUrl);
    }

    _imageSizeCache[url] = sizeInBytes;
    _imageOrder.add(url);
  }

  /// Get recommended image resolution based on screen size
  static String getOptimalImageUrl(String baseUrl, double screenWidth) {
    String resolution;
    
    if (screenWidth <= 480) {
      resolution = 'w480';
    } else if (screenWidth <= 720) {
      resolution = 'w720';
    } else if (screenWidth <= 1080) {
      resolution = 'w1080';
    } else {
      resolution = 'w1440';
    }

    // Append resolution parameter to URL
    final separator = baseUrl.contains('?') ? '&' : '?';
    return '$baseUrl${separator}resolution=$resolution';
  }

  /// Clear image cache
  static void clearImageCache() {
    _imageSizeCache.clear();
    _imageOrder.clear();
  }

  /// Get image cache statistics
  static Map<String, dynamic> getImageCacheStats() {
    final totalSize = _imageSizeCache.values.fold<int>(0, (sum, size) => sum + size);
    
    return {
      'cachedImages': _imageSizeCache.length,
      'totalSizeBytes': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'averageSizeKB': _imageSizeCache.isNotEmpty 
          ? ((totalSize / _imageSizeCache.length) / 1024).toStringAsFixed(2)
          : '0',
    };
  }
}

/// Widget memory optimization helpers
class WidgetMemoryOptimizer {
  /// Create memory-efficient list builder
  static Widget createOptimizedListView({
    required int itemCount,
    required Widget Function(BuildContext context, int index) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _MemoryOptimizedListItem(
          key: ValueKey('list_item_$index'),
          index: index,
          builder: itemBuilder,
        );
      },
      // Optimize for memory by limiting cached extent
      cacheExtent: 1000, // Limit cached items
    );
  }

  /// Create memory-efficient grid builder
  static Widget createOptimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext context, int index) itemBuilder,
    required int crossAxisCount,
    ScrollController? controller,
    double childAspectRatio = 1.0,
    EdgeInsets? padding,
  }) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _MemoryOptimizedListItem(
          key: ValueKey('grid_item_$index'),
          index: index,
          builder: itemBuilder,
        );
      },
      cacheExtent: 800,
    );
  }
}

/// Memory-optimized list item wrapper
class _MemoryOptimizedListItem extends StatefulWidget {
  final int index;
  final Widget Function(BuildContext context, int index) builder;

  const _MemoryOptimizedListItem({
    super.key,
    required this.index,
    required this.builder,
  });

  @override
  State<_MemoryOptimizedListItem> createState() => _MemoryOptimizedListItemState();
}

class _MemoryOptimizedListItemState extends State<_MemoryOptimizedListItem>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => false; // Don't keep alive to save memory

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.builder(context, widget.index);
  }
}

/// Memory monitoring utilities
class MemoryMonitor {
  static final Map<String, int> _allocations = {};
  static Timer? _monitoringTimer;

  /// Start memory monitoring
  static void startMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _logMemoryUsage(),
    );
  }

  /// Stop memory monitoring
  static void stopMonitoring() {
    _monitoringTimer?.cancel();
  }

  /// Record memory allocation
  static void recordAllocation(String component, int sizeInBytes) {
    _allocations[component] = (_allocations[component] ?? 0) + sizeInBytes;
  }

  /// Record memory deallocation
  static void recordDeallocation(String component, int sizeInBytes) {
    _allocations[component] = (_allocations[component] ?? 0) - sizeInBytes;
    if (_allocations[component]! <= 0) {
      _allocations.remove(component);
    }
  }

  /// Log current memory usage
  static void _logMemoryUsage() {
    if (kDebugMode) {
      print('=== Memory Usage Report ===');
      _allocations.forEach((component, size) {
        final sizeMB = (size / (1024 * 1024)).toStringAsFixed(2);
        print('$component: ${sizeMB}MB');
      });
      
      final totalSize = _allocations.values.fold<int>(0, (sum, size) => sum + size);
      final totalMB = (totalSize / (1024 * 1024)).toStringAsFixed(2);
      print('Total: ${totalMB}MB');
      print('==========================');
    }
  }

  /// Get memory usage statistics
  static Map<String, dynamic> getMemoryUsageStats() {
    final totalSize = _allocations.values.fold<int>(0, (sum, size) => sum + size);
    
    return {
      'totalSizeBytes': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'componentBreakdown': Map.from(_allocations),
      'componentCount': _allocations.length,
    };
  }

  /// Clear all memory records
  static void clearRecords() {
    _allocations.clear();
  }
}