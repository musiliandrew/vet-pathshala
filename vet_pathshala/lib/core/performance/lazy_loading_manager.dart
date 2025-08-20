import 'package:flutter/material.dart';

/// Manager for implementing lazy loading throughout the app
class LazyLoadingManager {
  static const int defaultPageSize = 20;
  static const double triggerThreshold = 0.8;

  /// Creates a lazy loading widget wrapper
  static Widget createLazyLoader({
    required Widget Function() builder,
    bool preload = false,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return _LazyWidget(
      builder: builder,
      preload: preload,
      delay: delay,
    );
  }

  /// Creates a paginated list with lazy loading
  static Widget createPaginatedList<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    required Future<List<T>> Function(int page) onLoadMore,
    required bool Function() hasMore,
    ScrollController? scrollController,
    Widget? loadingWidget,
    Widget? errorWidget,
    int pageSize = defaultPageSize,
  }) {
    return _PaginatedLazyList<T>(
      items: items,
      itemBuilder: itemBuilder,
      onLoadMore: onLoadMore,
      hasMore: hasMore,
      scrollController: scrollController,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      pageSize: pageSize,
    );
  }

  /// Creates a lazy loading image with placeholder
  static Widget createLazyImage({
    required String imageUrl,
    Widget? placeholder,
    Widget? errorWidget,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    return _LazyImage(
      imageUrl: imageUrl,
      placeholder: placeholder,
      errorWidget: errorWidget,
      fit: fit,
      width: width,
      height: height,
    );
  }
}

class _LazyWidget extends StatefulWidget {
  final Widget Function() builder;
  final bool preload;
  final Duration delay;

  const _LazyWidget({
    required this.builder,
    required this.preload,
    required this.delay,
  });

  @override
  State<_LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<_LazyWidget> {
  Widget? _child;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.preload) {
      _loadWidget();
    }
  }

  void _loadWidget() {
    if (_isLoaded) return;
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _child = widget.builder();
          _isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded && !widget.preload) {
      _loadWidget();
    }

    return _child ?? const SizedBox.shrink();
  }
}

class _PaginatedLazyList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<List<T>> Function(int page) onLoadMore;
  final bool Function() hasMore;
  final ScrollController? scrollController;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final int pageSize;

  const _PaginatedLazyList({
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.hasMore,
    this.scrollController,
    this.loadingWidget,
    this.errorWidget,
    this.pageSize = LazyLoadingManager.defaultPageSize,
  });

  @override
  State<_PaginatedLazyList<T>> createState() => _PaginatedLazyListState<T>();
}

class _PaginatedLazyListState<T> extends State<_PaginatedLazyList<T>> {
  late ScrollController _scrollController;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * LazyLoadingManager.triggerThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !widget.hasMore()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newItems = await widget.onLoadMore(_currentPage + 1);
      setState(() {
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length + (_isLoading || _error != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.items.length) {
          return widget.itemBuilder(context, widget.items[index], index);
        }

        // Loading or error indicator
        if (_error != null) {
          return widget.errorWidget ??
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Error loading more items: $_error'),
                    ElevatedButton(
                      onPressed: _loadMore,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
        }

        return widget.loadingWidget ??
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
      },
    );
  }
}

class _LazyImage extends StatefulWidget {
  final String imageUrl;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxFit fit;
  final double? width;
  final double? height;

  const _LazyImage({
    required this.imageUrl,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<_LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<_LazyImage> {
  bool _isVisible = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.imageUrl),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0 && !_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        child: _isVisible
            ? Image.network(
                widget.imageUrl,
                fit: widget.fit,
                width: widget.width,
                height: widget.height,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return widget.placeholder ??
                      Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                },
                errorBuilder: (context, error, stackTrace) {
                  _hasError = true;
                  return widget.errorWidget ??
                      const Icon(Icons.error, color: Colors.grey);
                },
              )
            : widget.placeholder ??
                Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
      ),
    );
  }
}

// Placeholder for visibility detector (would use visibility_detector package in real app)
class VisibilityDetector extends StatefulWidget {
  final Key key;
  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  void initState() {
    super.initState();
    // Simulate visibility detection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onVisibilityChanged(VisibilityInfo(visibleFraction: 1.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class VisibilityInfo {
  final double visibleFraction;
  
  VisibilityInfo({required this.visibleFraction});
}