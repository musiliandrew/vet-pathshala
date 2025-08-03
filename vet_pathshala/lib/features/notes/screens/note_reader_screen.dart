import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/note_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_action_panel.dart';
import '../widgets/sticky_note_widget.dart';
import '../widgets/ai_summary_widget.dart';
import '../widgets/text_selection_toolbar.dart';

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
      backgroundColor: UnifiedTheme.backgroundColor,
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(context, notesProvider),
              _buildProgressIndicator(),
              _buildNoteContent(context, notesProvider),
              _buildStickyNotes(notesProvider),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      bottomSheet: _showActionPanel ? _buildActionPanel() : null,
    );
  }

  Widget _buildAppBar(BuildContext context, NotesProvider notesProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: UnifiedTheme.backgroundColor,
      foregroundColor: UnifiedTheme.primaryText,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios),
      ),
      actions: [
        // Bookmark button
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.currentUser == null) return const SizedBox.shrink();
            
            final isBookmarked = notesProvider.currentInteraction?.isBookmarked ?? false;
            return IconButton(
              onPressed: () => notesProvider.toggleBookmark(
                authProvider.currentUser!.id,
                widget.note.id,
              ),
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? UnifiedTheme.goldAccent : UnifiedTheme.tertiaryText,
              ),
            );
          },
        ),
        
        // Share button
        IconButton(
          onPressed: _shareNote,
          icon: const Icon(Icons.share_outlined),
        ),
        
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          color: UnifiedTheme.cardBackground,
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: UnifiedTheme.tertiaryText),
                  SizedBox(width: 12),
                  Text('Report'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'font_size',
              child: Row(
                children: [
                  Icon(Icons.text_fields_outlined, color: UnifiedTheme.tertiaryText),
                  SizedBox(width: 12),
                  Text('Text Size'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.note.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: UnifiedTheme.primaryText,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                UnifiedTheme.backgroundColor,
                UnifiedTheme.backgroundColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: UnifiedTheme.tertiaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Dr. ${widget.note.authorId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: UnifiedTheme.tertiaryText,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: UnifiedTheme.tertiaryText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_estimateReadingTime(widget.note.content)} min read',
                      style: TextStyle(
                        fontSize: 12,
                        color: UnifiedTheme.tertiaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SliverToBoxAdapter(
      child: Container(
        height: 4,
        color: UnifiedTheme.borderColor,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: _readingProgress / 100,
          child: Container(
            color: UnifiedTheme.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteContent(BuildContext context, NotesProvider notesProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: UnifiedTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: UnifiedTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags
            if (widget.note.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.note.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 12,
                      color: UnifiedTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // AI Summary Section
            Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                if (notesProvider.aiSummary != null) {
                  return AISummaryWidget(
                    summary: notesProvider.aiSummary!,
                    onDismiss: () => setState(() {}),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Note Content with Selection Support
            SelectableText.rich(
              TextSpan(
                children: _buildHighlightedContent(widget.note.content, notesProvider),
              ),
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: UnifiedTheme.primaryText,
              ),
              onSelectionChanged: (selection, cause) {
                if (selection.isValid && !selection.isCollapsed) {
                  final selectedText = widget.note.content.substring(
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
      return [TextSpan(text: content)];
    }

    List<TextSpan> spans = [];
    int lastEnd = 0;

    // Sort highlights by start position
    highlights.sort((a, b) => a.startPosition.compareTo(b.startPosition));

    for (final highlight in highlights) {
      // Add text before highlight
      if (highlight.startPosition > lastEnd) {
        spans.add(TextSpan(
          text: content.substring(lastEnd, highlight.startPosition),
        ));
      }

      // Add highlighted text
      spans.add(TextSpan(
        text: highlight.selectedText,
        style: TextStyle(
          backgroundColor: Color(int.parse(highlight.color.replaceFirst('#', '0xFF'))),
          color: UnifiedTheme.primaryText,
        ),
      ));

      lastEnd = highlight.endPosition;
    }

    // Add remaining text
    if (lastEnd < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastEnd),
      ));
    }

    return spans;
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
            ...stickyNotes.map((note) => StickyNoteWidget(
              stickyNote: note,
              onDelete: () => _deleteStickyNote(note.id),
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

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AI Summary Button
        Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            return FloatingActionButton(
              heroTag: 'ai_summary',
              onPressed: notesProvider.isGeneratingSummary 
                ? null 
                : () => notesProvider.generateAISummary(),
              backgroundColor: UnifiedTheme.blueAccent,
              foregroundColor: Colors.white,
              mini: true,
              child: notesProvider.isGeneratingSummary
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.auto_awesome, size: 20),
            );
          },
        ),
        
        const SizedBox(height: 8),
        
        // Text-to-Speech Button
        Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            return FloatingActionButton(
              heroTag: 'tts',
              onPressed: notesProvider.isSpeaking 
                ? null 
                : () => notesProvider.speakNote(),
              backgroundColor: UnifiedTheme.primaryGreen,
              foregroundColor: Colors.white,
              mini: true,
              child: notesProvider.isSpeaking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.volume_up, size: 20),
            );
          },
        ),
        
        const SizedBox(height: 8),
        
        // Action Panel Toggle
        FloatingActionButton(
          heroTag: 'actions',
          onPressed: () {
            setState(() {
              _showActionPanel = !_showActionPanel;
            });
          },
          backgroundColor: _showActionPanel ? UnifiedTheme.goldAccent : UnifiedTheme.tertiaryText,
          foregroundColor: Colors.white,
          child: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }

  Widget _buildActionPanel() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.currentUser == null) return const SizedBox.shrink();
        
        return NoteActionPanel(
          note: widget.note,
          userId: authProvider.currentUser!.id,
          onClose: () => setState(() => _showActionPanel = false),
        );
      },
    );
  }

  void _showTextSelectionOptions() {
    if (_selectedText == null || _currentSelection == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomTextSelectionToolbar(
        selectedText: _selectedText!,
        onHighlight: (color) => _highlightText(color),
        onCreateFlashcard: () => _createFlashcard(),
        onAddStickyNote: () => _addStickyNote(),
        onCopy: () => _copyText(),
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
}