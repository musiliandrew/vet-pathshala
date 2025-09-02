import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/note_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notes_provider.dart';
// Simplified widgets replaced with inline implementations

class NoteReaderScreen extends StatefulWidget {
  final NoteModel note;

  const NoteReaderScreen({
    super.key,
    required this.note,
  });

  @override
  State<NoteReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  
  bool _showActionPanel = false;
  bool _isScrolling = false;
  String? _selectedText;
  TextSelection? _currentSelection;
  int _readingProgress = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _setupScrollListener();
    _loadNoteAndInteraction();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final progress = (_scrollController.offset / _scrollController.position.maxScrollExtent * 100).round();
        if (progress != _readingProgress) {
          setState(() {
            _readingProgress = progress.clamp(0, 100);
          });
          _updateReadingProgress();
        }

        // Auto-hide action panel when scrolling
        if (_showActionPanel && _scrollController.position.isScrollingNotifier.value) {
          setState(() {
            _showActionPanel = false;
          });
        }
      }
    });
  }

  void _loadNoteAndInteraction() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final notesProvider = context.read<NotesProvider>();
      
      if (authProvider.currentUser != null) {
        notesProvider.loadNote(widget.note.id, authProvider.currentUser!.id);
      }
    });
  }

  void _updateReadingProgress() {
    final authProvider = context.read<AuthProvider>();
    final notesProvider = context.read<NotesProvider>();
    
    if (authProvider.currentUser != null) {
      notesProvider.updateReadProgress(
        authProvider.currentUser!.id,
        widget.note.id,
        _readingProgress,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF), // Soft, cute background
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          return Stack(
            children: [
              // Cute background pattern
              _buildBackgroundPattern(),
              
              // Main content with cute design
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildCuteAppBar(context, notesProvider),
                  _buildCuteProgressIndicator(),
                  _buildCuteNoteContent(context, notesProvider),
                  _buildCuteStickyNotes(notesProvider),
                  // Add some bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
              
              // Floating cute action button
              _buildCuteFloatingActions(context),
            ],
          );
        },
      ),
    );
  }

  // Cute background pattern
  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: CuteBackgroundPainter(),
      ),
    );
  }

  // Cute modern app bar
  Widget _buildCuteAppBar(BuildContext context, NotesProvider notesProvider) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6C5CE7).withOpacity(0.1),
                const Color(0xFFA29BFE).withOpacity(0.05),
                Colors.white.withOpacity(0.8),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with back button and actions
                  Row(
                    children: [
                      // Cute back button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF6C5CE7),
                            size: 18,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Cute action buttons
                      _buildCuteActionButton(
                        Icons.bookmark_outline,
                        const Color(0xFFFF7675),
                        () => _toggleBookmark(notesProvider),
                      ),
                      const SizedBox(width: 8),
                      _buildCuteActionButton(
                        Icons.share_outlined,
                        const Color(0xFF74B9FF),
                        () => _shareNote(),
                      ),
                      const SizedBox(width: 8),
                      _buildCuteActionButton(
                        Icons.more_horiz,
                        const Color(0xFF6C5CE7),
                        () => _showCuteMoreActions(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title with cute styling
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.note.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Cute metadata row - Fixed overflow
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00B894).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 12,
                              color: Color(0xFF00B894),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_estimateReadingTime(widget.note.content)}m',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF00B894),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE17055).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite_outline,
                              size: 12,
                              color: Color(0xFFE17055),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.note.likeCount}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFE17055),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Cute progress indicator
  Widget _buildCuteProgressIndicator() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6C5CE7).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _readingProgress / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_readingProgress% complete',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6C5CE7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cute note content design
  Widget _buildCuteNoteContent(BuildContext context, NotesProvider notesProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cute tags section
            if (widget.note.tags.isNotEmpty) _buildCuteTags(),
            
            // AI Summary with cute design
            Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                if (notesProvider.aiSummary != null) {
                  return _buildCuteAISummary(notesProvider.aiSummary!);
                }
                return const SizedBox.shrink();
              },
            ),
            
            // Quick action cards
            _buildCuteQuickActions(),
            
            // Main content card
            _buildCuteContentCard(notesProvider),
          ],
        ),
      ),
    );
  }

  // Original method for reference
  Widget _buildNoteContentOLD(BuildContext context, NotesProvider notesProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clean Tags Display (without # symbols)
            if (widget.note.tags.isNotEmpty) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.note.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UnifiedTheme.primaryGreen.withOpacity(0.1),
                        UnifiedTheme.primaryGreen.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 12,
                        color: UnifiedTheme.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _cleanTag(tag), // Remove # and clean the tag
                        style: TextStyle(
                          fontSize: 13,
                          color: UnifiedTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Enhanced AI Summary Section
            Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                if (notesProvider.aiSummary != null) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              UnifiedTheme.blueAccent.withOpacity(0.08),
                              UnifiedTheme.blueAccent.withOpacity(0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: UnifiedTheme.blueAccent.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: UnifiedTheme.blueAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: UnifiedTheme.blueAccent,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'AI Summary',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: UnifiedTheme.blueAccent,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: UnifiedTheme.blueAccent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'AI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              notesProvider.aiSummary!,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: UnifiedTheme.primaryText,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // This section is now handled in the new cute design - remove this old code
            const SizedBox(height: 20),

            // Clean Note Content with Selection Support
            SelectableText.rich(
              TextSpan(
                children: _buildHighlightedContent(_cleanContent(widget.note.content), notesProvider),
              ),
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: UnifiedTheme.primaryText,
                letterSpacing: 0.2,
              ),
              onSelectionChanged: (selection, cause) {
                if (selection.isValid && !selection.isCollapsed) {
                  final cleanedContent = _cleanContent(widget.note.content);
                  final selectedText = cleanedContent.substring(
                    selection.start,
                    selection.end,
                  );
                  setState(() {
                    _selectedText = selectedText;
                    _currentSelection = selection;
                  });
                  _showTextSelectionOptions();
                } else {
                  setState(() {
                    _selectedText = null;
                    _currentSelection = null;
                  });
                }
              },
              toolbarOptions: const ToolbarOptions(
                copy: true,
                selectAll: true,
              ),
            ),

            const SizedBox(height: 32),

            // Note Stats
            _buildNoteStats(),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildHighlightedContent(String content, NotesProvider notesProvider) {
    final highlights = notesProvider.currentInteraction?.highlights ?? [];
    if (highlights.isEmpty) {
      return [_buildStyledTextSpan(content)];
    }

    List<TextSpan> spans = [];
    int lastEnd = 0;

    // Sort highlights by start position
    highlights.sort((a, b) => a.startPosition.compareTo(b.startPosition));

    for (final highlight in highlights) {
      // Add text before highlight
      if (highlight.startPosition > lastEnd) {
        spans.add(_buildStyledTextSpan(content.substring(lastEnd, highlight.startPosition)));
      }

      // Add highlighted text
      spans.add(TextSpan(
        text: highlight.selectedText,
        style: TextStyle(
          backgroundColor: Color(int.parse(highlight.color.replaceFirst('#', '0xFF'))).withOpacity(0.3),
          color: UnifiedTheme.primaryText,
          fontWeight: FontWeight.w500,
        ),
      ));

      lastEnd = highlight.endPosition;
    }

    // Add remaining text
    if (lastEnd < content.length) {
      spans.add(_buildStyledTextSpan(content.substring(lastEnd)));
    }

    return spans;
  }

  // Helper function to create styled text spans for different content types
  TextSpan _buildStyledTextSpan(String text) {
    // Check if text looks like a heading (starts with capital and is short)
    if (text.trim().length < 100 && 
        text.trim().isNotEmpty && 
        text.trim()[0] == text.trim()[0].toUpperCase() &&
        !text.contains('.') && 
        text.trim().split('\n').length == 1) {
      return TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: UnifiedTheme.primaryGreen,
          height: 1.4,
        ),
      );
    }
    
    return TextSpan(
      text: text,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: UnifiedTheme.primaryText,
      ),
    );
  }

  Widget _buildStickyNotes(NotesProvider notesProvider) {
    final stickyNotes = notesProvider.currentInteraction?.stickyNotes ?? [];
    if (stickyNotes.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: UnifiedTheme.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            ...stickyNotes.map((note) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, color: Colors.yellow.shade700),
                  const SizedBox(width: 8),
                  Expanded(child: Text(note.content)),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.yellow.shade700),
                    onPressed: () => _deleteStickyNote(note.id),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 16,
                      color: UnifiedTheme.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.note.likeCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: UnifiedTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Likes',
                  style: TextStyle(
                    fontSize: 12,
                    color: UnifiedTheme.tertiaryText,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: UnifiedTheme.primaryGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.note.readCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: UnifiedTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Reads',
                  style: TextStyle(
                    fontSize: 12,
                    color: UnifiedTheme.tertiaryText,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$_readingProgress%',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: UnifiedTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 12,
                    color: UnifiedTheme.tertiaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, NotesProvider notesProvider) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        border: Border(
          right: BorderSide(color: UnifiedTheme.borderColor),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 80),
          
          // Flashcards
          _buildSidebarButton(
            icon: Icons.quiz_outlined,
            label: 'Flashcards',
            onTap: () => _showFlashcards(),
          ),
          
          // AI Summary
          _buildSidebarButton(
            icon: Icons.auto_awesome,
            label: 'AI Summary',
            onTap: () => _generateAISummary(notesProvider),
            isLoading: notesProvider.isGeneratingSummary,
          ),
          
          // Highlights
          _buildSidebarButton(
            icon: Icons.highlight_alt,
            label: 'Highlights',
            onTap: () => _showHighlights(),
          ),
          
          // Sticky Notes
          _buildSidebarButton(
            icon: Icons.sticky_note_2_outlined,
            label: 'Sticky Notes',
            onTap: () => _showStickyNotesPanel(),
          ),
          
          // Bookmarks
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final isBookmarked = notesProvider.currentInteraction?.isBookmarked ?? false;
              return _buildSidebarButton(
                icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                label: 'Bookmark',
                onTap: () {
                  if (authProvider.currentUser != null) {
                    notesProvider.toggleBookmark(
                      authProvider.currentUser!.id,
                      widget.note.id,
                    );
                  }
                },
                isActive: isBookmarked,
              );
            },
          ),
          
          const Spacer(),
          
          // Settings
          _buildSidebarButton(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => _showSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLoading = false,
  }) {
    return Tooltip(
      message: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive 
                ? UnifiedTheme.primaryGreen.withOpacity(0.1)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive 
                ? Border.all(color: UnifiedTheme.primaryGreen)
                : null,
            ),
            child: Center(
              child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(UnifiedTheme.primaryGreen),
                    ),
                  )
                : Icon(
                    icon,
                    size: 20,
                    color: isActive 
                      ? UnifiedTheme.primaryGreen
                      : UnifiedTheme.tertiaryText,
                  ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildMenuToggle() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _showActionPanel = !_showActionPanel;
        });
        if (_showActionPanel) {
          Scaffold.of(context).openEndDrawer();
        } else {
          Navigator.of(context).pop();
        }
      },
      backgroundColor: _showActionPanel ? UnifiedTheme.goldAccent : UnifiedTheme.primaryGreen,
      child: Icon(
        _showActionPanel ? Icons.close : Icons.menu,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSlideInMenu(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Drawer(
          backgroundColor: UnifiedTheme.cardBackground,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        UnifiedTheme.primaryGreen,
                        UnifiedTheme.primaryGreen.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.note_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Note Tools',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Enhance your reading experience',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildMenuTile(
                        icon: Icons.auto_awesome,
                        title: 'AI Summary',
                        subtitle: 'Generate intelligent summary',
                        color: UnifiedTheme.blueAccent,
                        onTap: () => _generateAISummary(context.read<NotesProvider>()),
                        isLoading: context.watch<NotesProvider>().isGeneratingSummary,
                      ),
                      
                      _buildMenuTile(
                        icon: Icons.volume_up,
                        title: 'Text-to-Speech',
                        subtitle: 'Listen to the note',
                        color: UnifiedTheme.primaryGreen,
                        onTap: () => context.read<NotesProvider>().speakNote(),
                        isLoading: context.watch<NotesProvider>().isSpeaking,
                      ),
                      
                      _buildMenuTile(
                        icon: Icons.quiz_outlined,
                        title: 'Generate Flashcards',
                        subtitle: 'Create study cards',
                        color: Colors.orange,
                        onTap: () => _showFlashcards(),
                      ),
                      
                      _buildMenuTile(
                        icon: Icons.highlight_alt,
                        title: 'View Highlights',
                        subtitle: 'See highlighted text',
                        color: Colors.amber,
                        onTap: () => _showHighlights(),
                      ),
                      
                      _buildMenuTile(
                        icon: Icons.sticky_note_2_outlined,
                        title: 'Sticky Notes',
                        subtitle: 'Your personal notes',
                        color: Colors.yellow.shade700,
                        onTap: () => _showStickyNotesPanel(),
                      ),
                      
                      Consumer<NotesProvider>(
                        builder: (context, notesProvider, child) {
                          final isBookmarked = notesProvider.currentInteraction?.isBookmarked ?? false;
                          return _buildMenuTile(
                            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            title: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
                            subtitle: 'Save for later',
                            color: UnifiedTheme.goldAccent,
                            onTap: () {
                              if (authProvider.currentUser != null) {
                                notesProvider.toggleBookmark(
                                  authProvider.currentUser!.id,
                                  widget.note.id,
                                );
                              }
                            },
                          );
                        },
                      ),
                      
                      const Divider(height: 32),
                      
                      _buildMenuTile(
                        icon: Icons.share_outlined,
                        title: 'Share Note',
                        subtitle: 'Share with others',
                        color: UnifiedTheme.tertiaryText,
                        onTap: () => _shareNote(),
                      ),
                      
                      _buildMenuTile(
                        icon: Icons.text_fields_outlined,
                        title: 'Text Size',
                        subtitle: 'Adjust font size',
                        color: UnifiedTheme.tertiaryText,
                        onTap: () => _showFontSizeDialog(),
                      ),
                      
                      _buildMenuTile(
                        icon: Icons.flag_outlined,
                        title: 'Report Note',
                        subtitle: 'Report inappropriate content',
                        color: UnifiedTheme.redAccent,
                        onTap: () => _reportNote(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    : Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: UnifiedTheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: UnifiedTheme.tertiaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: UnifiedTheme.tertiaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTextSelectionOptions() {
    if (_selectedText == null || _currentSelection == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selected: "${_selectedText!.length > 50 ? '${_selectedText!.substring(0, 50)}...' : _selectedText!}"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.highlight),
                  label: const Text('Highlight'),
                  onPressed: () => _highlightText(Colors.yellow),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.quiz),
                  label: const Text('Flashcard'),
                  onPressed: () => _createFlashcard(),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.note_add),
                  label: const Text('Note'),
                  onPressed: () => _addStickyNote(),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                  onPressed: () => _copyText(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _highlightText(Color color) {
    if (_currentSelection == null || _selectedText == null) return;

    final authProvider = context.read<AuthProvider>();
    final notesProvider = context.read<NotesProvider>();
    
    if (authProvider.currentUser != null) {
      final highlight = Highlight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startPosition: _currentSelection!.start,
        endPosition: _currentSelection!.end,
        selectedText: _selectedText!,
        color: '#${color.value.toRadixString(16).substring(2)}',
        createdAt: DateTime.now(),
      );

      // Add to service (this would normally update Firebase)
      // For now, we'll update the local state
      print('🎨 Adding highlight: ${highlight.selectedText}');
    }

    Navigator.pop(context);
    setState(() {
      _selectedText = null;
      _currentSelection = null;
    });
  }

  void _createFlashcard() {
    final authProvider = context.read<AuthProvider>();
    final notesProvider = context.read<NotesProvider>();
    
    if (authProvider.currentUser != null && _selectedText != null) {
      notesProvider.generateFlashcard(
        authProvider.currentUser!.id,
        widget.note.id,
        _selectedText!,
      );
    }

    Navigator.pop(context);
    setState(() {
      _selectedText = null;
      _currentSelection = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Flashcard created successfully!'),
        backgroundColor: UnifiedTheme.primaryGreen,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to flashcards screen
          },
        ),
      ),
    );
  }

  void _addStickyNote() {
    Navigator.pop(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UnifiedTheme.cardBackground,
        title: const Text('Add Note'),
        content: TextField(
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Write your note here...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (text) {
            if (text.isNotEmpty) {
              final authProvider = context.read<AuthProvider>();
              final notesProvider = context.read<NotesProvider>();
              
              if (authProvider.currentUser != null && _currentSelection != null) {
                notesProvider.addStickyNote(
                  authProvider.currentUser!.id,
                  widget.note.id,
                  text,
                  _currentSelection!.start,
                );
              }
            }
            Navigator.pop(context);
            setState(() {
              _selectedText = null;
              _currentSelection = null;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _copyText() {
    if (_selectedText != null) {
      Clipboard.setData(ClipboardData(text: _selectedText!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    Navigator.pop(context);
    setState(() {
      _selectedText = null;
      _currentSelection = null;
    });
  }

  void _deleteStickyNote(String noteId) {
    // Implementation for deleting sticky note
    print('🗑️ Deleting sticky note: $noteId');
  }

  void _shareNote() {
    // Implementation for sharing note
    print('📤 Sharing note: ${widget.note.title}');
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'report':
        _reportNote();
        break;
      case 'font_size':
        _showFontSizeDialog();
        break;
    }
  }

  void _reportNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UnifiedTheme.cardBackground,
        title: const Text('Report Note'),
        content: const Text('Please specify the reason for reporting this note.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your report. We\'ll review it shortly.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: UnifiedTheme.redAccent),
            child: const Text('Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    // Implementation for font size adjustment
    print('📝 Showing font size dialog');
  }

  int _estimateReadingTime(String content) {
    // Estimate reading time based on word count (average 200 words per minute)
    final wordCount = content.split(RegExp(r'\s+')).length;
    return (wordCount / 200).ceil();
  }

  // Sidebar action methods
  void _showFlashcards() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UnifiedTheme.cardBackground,
        title: const Row(
          children: [
            Icon(Icons.quiz, color: UnifiedTheme.primaryGreen),
            SizedBox(width: 8),
            Text('Flashcards'),
          ],
        ),
        content: const Text('Flashcards feature will help you review key concepts from this note.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Generate flashcards logic
            },
            style: ElevatedButton.styleFrom(backgroundColor: UnifiedTheme.primaryGreen),
            child: const Text('Generate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _generateAISummary(NotesProvider notesProvider) {
    notesProvider.generateAISummary();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating AI summary...'),
        backgroundColor: UnifiedTheme.primaryGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showHighlights() {
    final notesProvider = context.read<NotesProvider>();
    final highlights = notesProvider.currentInteraction?.highlights ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: UnifiedTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: UnifiedTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.highlight_alt, color: UnifiedTheme.primaryGreen),
                  const SizedBox(width: 8),
                  const Text(
                    'Highlights',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: highlights.isEmpty
                ? const Center(child: Text('No highlights yet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: highlights.length,
                    itemBuilder: (context, index) {
                      final highlight = highlights[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(int.parse(highlight.color.replaceFirst('#', '0xFF'))).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color(int.parse(highlight.color.replaceFirst('#', '0xFF'))),
                          ),
                        ),
                        child: Text(highlight.selectedText),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStickyNotesPanel() {
    final notesProvider = context.read<NotesProvider>();
    final stickyNotes = notesProvider.currentInteraction?.stickyNotes ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: UnifiedTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: UnifiedTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.sticky_note_2, color: UnifiedTheme.primaryGreen),
                  const SizedBox(width: 8),
                  const Text(
                    'Sticky Notes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Add Note'),
                    onPressed: () => _addQuickStickyNote(),
                    style: TextButton.styleFrom(
                      foregroundColor: UnifiedTheme.primaryGreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: stickyNotes.isEmpty
                ? const Center(child: Text('No sticky notes yet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: stickyNotes.length,
                    itemBuilder: (context, index) {
                      final note = stickyNotes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.yellow.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.note, color: Colors.yellow.shade700),
                            const SizedBox(width: 8),
                            Expanded(child: Text(note.content)),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.yellow.shade700),
                              onPressed: () => _deleteStickyNote(note.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _addQuickStickyNote() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          backgroundColor: UnifiedTheme.cardBackground,
          title: const Text('Add Sticky Note'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write your note here...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final authProvider = context.read<AuthProvider>();
                  final notesProvider = context.read<NotesProvider>();
                  
                  if (authProvider.currentUser != null) {
                    notesProvider.addStickyNote(
                      authProvider.currentUser!.id,
                      widget.note.id,
                      controller.text.trim(),
                      0, // Position
                    );
                  }
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: UnifiedTheme.primaryGreen),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: UnifiedTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: UnifiedTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.settings, color: UnifiedTheme.primaryGreen),
                  const SizedBox(width: 8),
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Font Size'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showFontSizeDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Theme'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme settings coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Text-to-Speech'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: UnifiedTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'like':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note liked!'),
            backgroundColor: UnifiedTheme.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'view':
        // Already tracked
        break;
      case 'report':
        _reportNote();
        break;
    }
  }

  // Helper function to clean markdown content
  String _cleanContent(String content) {
    // Remove markdown symbols and format cleanly
    return content
        .replaceAll(RegExp(r'#{1,6}\s*'), '') // Remove heading markers
        .replaceAll(RegExp(r'\*{1,2}([^*]+)\*{1,2}'), r'$1') // Remove bold/italic markers
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1') // Remove code markers
        .replaceAll(RegExp(r'>\s*'), '') // Remove blockquote markers
        .replaceAll(RegExp(r'-\s*'), '• ') // Convert dash lists to bullet points
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Clean up excessive line breaks
        .trim();
  }

  // Helper function to clean tags
  String _cleanTag(String tag) {
    return tag
        .replaceAll(RegExp(r'^#+\s*'), '') // Remove leading # symbols
        .replaceAll(RegExp(r'[_-]'), ' ') // Replace underscores and dashes with spaces
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' 
            : word)
        .join(' ')
        .trim();
  }

  // Cute action button helper
  Widget _buildCuteActionButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 16),
        padding: EdgeInsets.zero,
      ),
    );
  }

  // Cute tags widget
  Widget _buildCuteTags() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.note.tags.map((tag) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00CEC9).withOpacity(0.2),
                const Color(0xFF55E6C1).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00CEC9).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF00CEC9),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _cleanTag(tag),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF00CEC9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // Cute AI summary
  Widget _buildCuteAISummary(String summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF74B9FF),
            Color(0xFF0984E3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF74B9FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // Cute quick actions - Fixed overflow
  Widget _buildCuteQuickActions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCuteActionCard(Icons.volume_up, 'Listen', 'Audio', const Color(0xFFE17055), () => context.read<NotesProvider>().speakNote()),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCuteActionCard(Icons.quiz, 'Practice', 'Quiz', const Color(0xFFFD79A8), () => _showFlashcards()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCuteActionCard(Icons.highlight, 'Highlights', 'Notes', const Color(0xFFFFB8B8), () => _showHighlights()),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCuteActionCard(Icons.bookmark, 'Bookmark', 'Save', const Color(0xFF74B9FF), () => _toggleBookmark(context.read<NotesProvider>())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Cute action card - Compact version
  Widget _buildCuteActionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF636E72),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Cute content card
  Widget _buildCuteContentCard(NotesProvider notesProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SelectableText.rich(
        TextSpan(
          children: _buildHighlightedContent(_cleanContent(widget.note.content), notesProvider),
        ),
        style: const TextStyle(
          fontSize: 16,
          height: 1.8,
          color: Color(0xFF2D3436),
          letterSpacing: 0.3,
        ),
        onSelectionChanged: (selection, cause) {
          if (selection.isValid && !selection.isCollapsed) {
            final cleanedContent = _cleanContent(widget.note.content);
            final selectedText = cleanedContent.substring(
              selection.start,
              selection.end,
            );
            setState(() {
              _selectedText = selectedText;
              _currentSelection = selection;
            });
            _showTextSelectionOptions();
          } else {
            setState(() {
              _selectedText = null;
              _currentSelection = null;
            });
          }
        },
      ),
    );
  }

  // Cute floating actions
  Widget _buildCuteFloatingActions(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "ai_summary",
            mini: true,
            backgroundColor: const Color(0xFF74B9FF),
            onPressed: () => context.read<NotesProvider>().generateAISummary(),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "bookmark",
            backgroundColor: const Color(0xFFFF7675),
            onPressed: () => _toggleBookmark(context.read<NotesProvider>()),
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                final isBookmarked = notesProvider.currentInteraction?.isBookmarked ?? false;
                return Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Cute sticky notes
  Widget _buildCuteStickyNotes(NotesProvider notesProvider) {
    final stickyNotes = notesProvider.currentInteraction?.stickyNotes ?? [];
    if (stickyNotes.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📝 Your Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 16),
            ...stickyNotes.map((note) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEDB37), Color(0xFFFFD700)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sticky_note_2, color: Color(0xFF2D3436), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      note.content,
                      style: const TextStyle(
                        color: Color(0xFF2D3436),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF2D3436), size: 16),
                    onPressed: () => _deleteStickyNote(note.id),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Helper methods
  void _toggleBookmark(NotesProvider notesProvider) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      notesProvider.toggleBookmark(authProvider.currentUser!.id, widget.note.id);
    }
  }

  void _showCuteMoreActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'More Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 20),
            _buildMoreActionTile(Icons.quiz, 'Generate Flashcards', const Color(0xFFFD79A8), () {
              Navigator.pop(context);
              _showFlashcards();
            }),
            _buildMoreActionTile(Icons.highlight, 'View Highlights', const Color(0xFFFFB8B8), () {
              Navigator.pop(context);
              _showHighlights();
            }),
            _buildMoreActionTile(Icons.sticky_note_2, 'Add Sticky Note', const Color(0xFFFEDB37), () {
              Navigator.pop(context);
              _showStickyNotesPanel();
            }),
            _buildMoreActionTile(Icons.text_fields, 'Font Size', const Color(0xFF74B9FF), () {
              Navigator.pop(context);
              _showFontSizeDialog();
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  // Background painter
}

// Cute background painter
class CuteBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw cute floating shapes
    _drawFloatingShapes(canvas, size, paint);
    
    // Draw subtle gradient overlay
    _drawGradientOverlay(canvas, size, paint);
  }
  
  void _drawFloatingShapes(Canvas canvas, Size size, Paint paint) {
    // Cute pastel circles
    final circles = [
      {'x': size.width * 0.1, 'y': size.height * 0.15, 'r': 40.0, 'color': const Color(0xFF74B9FF).withOpacity(0.05)},
      {'x': size.width * 0.8, 'y': size.height * 0.3, 'r': 60.0, 'color': const Color(0xFFFD79A8).withOpacity(0.04)},
      {'x': size.width * 0.2, 'y': size.height * 0.7, 'r': 30.0, 'color': const Color(0xFF55E6C1).withOpacity(0.06)},
      {'x': size.width * 0.9, 'y': size.height * 0.8, 'r': 45.0, 'color': const Color(0xFFFFB8B8).withOpacity(0.05)},
      {'x': size.width * 0.05, 'y': size.height * 0.5, 'r': 25.0, 'color': const Color(0xFFE17055).withOpacity(0.04)},
    ];
    
    for (final circle in circles) {
      paint.color = circle['color'] as Color;
      canvas.drawCircle(
        Offset(circle['x'] as double, circle['y'] as double),
        circle['r'] as double,
        paint,
      );
    }
  }
  
  void _drawGradientOverlay(Canvas canvas, Size size, Paint paint) {
    // Subtle top gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.center,
      colors: [
        const Color(0xFFFAFBFF).withOpacity(0.8),
        const Color(0xFFFAFBFF).withOpacity(0.0),
      ],
    );
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.3);
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}