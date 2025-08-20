import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/ebook_models.dart';
import '../../../shared/models/user_model.dart';
import '../widgets/pdf_viewer_widget.dart';
import '../widgets/reading_controls_widget.dart';
import '../widgets/annotation_panel_widget.dart';
import '../widgets/bookmark_panel_widget.dart';

class EbookReaderScreen extends StatefulWidget {
  final EbookModel ebook;
  final UserModel user;
  final UserEbookModel? userEbook;

  const EbookReaderScreen({
    super.key,
    required this.ebook,
    required this.user,
    this.userEbook,
  });

  @override
  State<EbookReaderScreen> createState() => _EbookReaderScreenState();
}

class _EbookReaderScreenState extends State<EbookReaderScreen>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late AnimationController _panelController;
  
  bool _isOverlayVisible = false;
  bool _isFullscreen = false;
  String _selectedPanel = ''; // 'annotations', 'bookmarks', 'contents'
  
  int _currentPage = 1;
  int _totalPages = 100; // This would come from PDF document
  double _readingProgress = 0.0;
  Timer? _progressTimer;
  DateTime _sessionStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _panelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _currentPage = widget.userEbook?.currentPage ?? 1;
    _readingProgress = widget.userEbook?.readingProgress ?? 0.0;
    _totalPages = widget.ebook.totalPages > 0 ? widget.ebook.totalPages : 100;
    
    _startProgressTracking();
    
    // Auto-hide overlay after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (_isOverlayVisible) {
        _toggleOverlay();
      }
    });
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _panelController.dispose();
    _progressTimer?.cancel();
    _saveReadingProgress();
    super.dispose();
  }

  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _saveReadingProgress();
    });
  }

  void _saveReadingProgress() {
    final readingTime = DateTime.now().difference(_sessionStartTime).inMinutes;
    // Here you would call your service to save progress
    print('Saving progress: Page $_currentPage, Progress $_readingProgress, Time: ${readingTime}m');
  }

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
    
    if (_isOverlayVisible) {
      _overlayController.forward();
    } else {
      _overlayController.reverse();
      _closePanel(); // Close any open panels
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _openPanel(String panelType) {
    setState(() {
      _selectedPanel = panelType;
    });
    _panelController.forward();
  }

  void _closePanel() {
    _panelController.reverse().then((_) {
      setState(() {
        _selectedPanel = '';
      });
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _readingProgress = (page / _totalPages).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PDF Viewer
          GestureDetector(
            onTap: _toggleOverlay,
            child: PDFViewerWidget(
              pdfUrl: widget.ebook.pdfUrl,
              initialPage: _currentPage,
              onPageChanged: _onPageChanged,
              onDocumentLoaded: (totalPages) {
                setState(() {
                  _totalPages = totalPages;
                  _readingProgress = (_currentPage / totalPages).clamp(0.0, 1.0);
                });
              },
            ),
          ),
          
          // Top Overlay
          AnimatedBuilder(
            animation: _overlayController,
            builder: (context, child) {
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, -100 * (1 - _overlayController.value)),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: _buildTopBar(),
                  ),
                ),
              );
            },
          ),
          
          // Bottom Overlay
          AnimatedBuilder(
            animation: _overlayController,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, 150 * (1 - _overlayController.value)),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: ReadingControlsWidget(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      progress: _readingProgress,
                      onPageJump: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      onAnnotationTap: () => _openPanel('annotations'),
                      onBookmarkTap: () => _openPanel('bookmarks'),
                      onContentsTap: () => _openPanel('contents'),
                      onSettingsTap: () => _showSettingsDialog(),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Side Panel
          AnimatedBuilder(
            animation: _panelController,
            builder: (context, child) {
              if (_selectedPanel.isEmpty) return const SizedBox.shrink();
              
              return Positioned(
                right: -300 + (300 * _panelController.value),
                top: 0,
                bottom: 0,
                child: Container(
                  width: 300,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(-2, 0),
                      ),
                    ],
                  ),
                  child: _buildPanel(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        
        const SizedBox(width: 8),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.ebook.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'by ${widget.ebook.author}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        IconButton(
          onPressed: _toggleFullscreen,
          icon: Icon(
            _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            color: Colors.white,
          ),
        ),
        
        IconButton(
          onPressed: () => _showShareDialog(),
          icon: const Icon(Icons.share, color: Colors.white),
        ),
        
        IconButton(
          onPressed: () => _showMenuDialog(),
          icon: const Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPanel() {
    Widget content;
    String title;
    
    switch (_selectedPanel) {
      case 'annotations':
        title = 'Annotations';
        content = AnnotationPanelWidget(
          ebook: widget.ebook,
          user: widget.user,
          currentPage: _currentPage,
          onAnnotationTap: (annotation) {
            // Navigate to annotation page
            setState(() {
              _currentPage = annotation.pageNumber;
            });
            _closePanel();
          },
        );
        break;
      case 'bookmarks':
        title = 'Bookmarks';
        content = BookmarkPanelWidget(
          ebook: widget.ebook,
          user: widget.user,
          onBookmarkTap: (bookmark) {
            // Navigate to bookmark page
            setState(() {
              _currentPage = bookmark.pageNumber;
            });
            _closePanel();
          },
        );
        break;
      case 'contents':
        title = 'Table of Contents';
        content = _buildTableOfContents();
        break;
      default:
        title = '';
        content = const SizedBox.shrink();
    }
    
    return Column(
      children: [
        // Panel header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: UnifiedTheme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _closePanel,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
        
        // Panel content
        Expanded(child: content),
      ],
    );
  }

  Widget _buildTableOfContents() {
    // This would be populated from PDF metadata or manually created
    final chapters = [
      {'title': 'Introduction', 'page': 1},
      {'title': 'Chapter 1: Anatomy Basics', 'page': 15},
      {'title': 'Chapter 2: Cardiovascular System', 'page': 45},
      {'title': 'Chapter 3: Respiratory System', 'page': 78},
      {'title': 'Chapter 4: Digestive System', 'page': 112},
      {'title': 'Chapter 5: Nervous System', 'page': 156},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return ListTile(
          title: Text(
            chapter['title'] as String,
            style: UnifiedTheme.bodyStyle,
          ),
          subtitle: Text('Page ${chapter['page']}'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            setState(() {
              _currentPage = chapter['page'] as int;
            });
            _closePanel();
          },
        );
      },
    );
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Settings',
              style: UnifiedTheme.headingStyle.copyWith(fontSize: 18),
            ),
            
            const SizedBox(height: 24),
            
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Display Mode'),
              subtitle: const Text('Light'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // Toggle between light and dark mode
                },
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Text Size'),
              subtitle: const Text('Normal'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Show text size options
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download for Offline'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Download ebook for offline reading
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Reading Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share your progress in "${widget.ebook.title}"'),
            const SizedBox(height: 16),
            Text('Progress: ${(_readingProgress * 100).toInt()}%'),
            Text('Page: $_currentPage of $_totalPages'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Share progress to social feed
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showMenuDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Book Info'),
              onTap: () {
                Navigator.pop(context);
                // Show book information
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Write Review'),
              onTap: () {
                Navigator.pop(context);
                // Show review dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                // Show report dialog
              },
            ),
          ],
        ),
      ),
    );
  }
}