import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/note_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notes_provider.dart';

class EnhancedNoteReaderScreen extends StatefulWidget {
  final NoteModel note;

  const EnhancedNoteReaderScreen({
    super.key,
    required this.note,
  });

  @override
  State<EnhancedNoteReaderScreen> createState() => _EnhancedNoteReaderScreenState();
}

class _EnhancedNoteReaderScreenState extends State<EnhancedNoteReaderScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _toolbarController;
  
  double _readingProgress = 0.0;
  bool _showToolbar = false;
  String? _selectedText;
  
  // Reading preferences
  double _fontSize = 16.0;
  bool _isDarkMode = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _toolbarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _setupScrollListener();
    _loadNoteData();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final progress = _scrollController.offset / 
            (_scrollController.position.maxScrollExtent + 
             MediaQuery.of(context).size.height);
        setState(() {
          _readingProgress = progress.clamp(0.0, 1.0);
        });
      }
    });
  }

  void _loadNoteData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final notesProvider = context.read<NotesProvider>();
      
      if (authProvider.currentUser != null) {
        // Load note interaction data
        notesProvider.loadNote(widget.note.id, authProvider.currentUser!.id);
        // Mark as read
        notesProvider.updateReadProgress(authProvider.currentUser!.id, widget.note.id, 100);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _toolbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Clean Header
              _buildHeader(),
              
              // Progress Indicator
              _buildProgressIndicator(),
              
              // Main Content
              Expanded(
                child: _buildContent(),
              ),
              
              // Bottom Action Bar
              _buildBottomActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.primaryGreen, UnifiedTheme.primaryGreen.withOpacity(0.8)],
        ),
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.note.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_estimateReadingTime(widget.note.content)} min read',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  final isBookmarked = notesProvider.currentInteraction?.isBookmarked ?? false;
                  return IconButton(
                    onPressed: () {
                      final authProvider = context.read<AuthProvider>();
                      if (authProvider.currentUser != null) {
                        notesProvider.toggleBookmark(
                          authProvider.currentUser!.id,
                          widget.note.id,
                        );
                      }
                    },
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 8),
              
              IconButton(
                onPressed: () => _showSettingsPanel(),
                icon: const Icon(Icons.text_fields, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _readingProgress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [UnifiedTheme.primaryGreen, UnifiedTheme.blueAccent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags (Clean version without # symbols)
          if (widget.note.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.note.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Text(
                  tag, // No # symbol - clean tag
                  style: const TextStyle(
                    fontSize: 12,
                    color: UnifiedTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // AI Summary (Compact version)
          Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              if (notesProvider.aiSummary != null) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UnifiedTheme.blueAccent.withOpacity(0.1),
                        UnifiedTheme.blueAccent.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: UnifiedTheme.blueAccent.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: UnifiedTheme.blueAccent,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI Summary',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: UnifiedTheme.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notesProvider.aiSummary!,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: UnifiedTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Main Content (Clean and readable)
          SelectableText(
            widget.note.content,
            style: TextStyle(
              fontSize: _fontSize,
              height: 1.6,
              color: _isDarkMode ? Colors.white : UnifiedTheme.primaryText,
              letterSpacing: 0.3,
            ),
            onSelectionChanged: (selection, cause) {
              if (selection.isValid && !selection.isCollapsed) {
                final selectedText = widget.note.content.substring(
                  selection.start,
                  selection.end,
                );
                setState(() {
                  _selectedText = selectedText;
                });
              } else {
                setState(() {
                  _selectedText = null;
                });
              }
            },
          ),

          const SizedBox(height: 40),

          // Note metadata
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Note Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: UnifiedTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Subject ID', widget.note.subjectId),
                _buildInfoRow('Topic ID', widget.note.topicId),
                _buildInfoRow('Created', _formatDate(widget.note.createdAt)),
                if (widget.note.updatedAt.isAfter(widget.note.createdAt))
                  _buildInfoRow('Updated', _formatDate(widget.note.updatedAt)),
              ],
            ),
          ),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: UnifiedTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // TTS Button
          Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              return IconButton(
                onPressed: () {
                  if (notesProvider.isSpeaking) {
                    // Note: stopSpeaking method not available in current provider
                    return;
                  } else {
                    notesProvider.speakNote();
                  }
                },
                icon: Icon(
                  notesProvider.isSpeaking ? Icons.stop : Icons.play_arrow,
                  color: UnifiedTheme.primaryGreen,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: UnifiedTheme.primaryGreen.withOpacity(0.1),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // AI Summary Button
          Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              return IconButton(
                onPressed: notesProvider.isGeneratingSummary
                    ? null
                    : () => notesProvider.generateAISummary(),
                icon: notesProvider.isGeneratingSummary
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                style: IconButton.styleFrom(
                  backgroundColor: UnifiedTheme.blueAccent.withOpacity(0.1),
                  foregroundColor: UnifiedTheme.blueAccent,
                ),
              );
            },
          ),

          const Spacer(),

          // Share Button
          IconButton(
            onPressed: () => _shareNote(),
            icon: const Icon(Icons.share),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.grey.shade700,
            ),
          ),

          const SizedBox(width: 8),

          // More actions
          IconButton(
            onPressed: () => _showMoreActions(),
            icon: const Icon(Icons.more_vert),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
              'Reading Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Font size slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Font Size'),
                  Slider(
                    value: _fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 6,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Dark mode toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareNote() {
    // Implement share functionality
    Clipboard.setData(ClipboardData(text: widget.note.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note content copied to clipboard'),
        backgroundColor: UnifiedTheme.primaryGreen,
      ),
    );
  }

  void _showMoreActions() {
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
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Generate Flashcards'),
              onTap: () {
                Navigator.pop(context);
                // Implement flashcard generation
              },
            ),
            ListTile(
              leading: const Icon(Icons.highlight),
              title: const Text('Highlight Text'),
              onTap: () {
                Navigator.pop(context);
                // Show highlighting mode
              },
            ),
            ListTile(
              leading: const Icon(Icons.sticky_note_2),
              title: const Text('Add Sticky Note'),
              onTap: () {
                Navigator.pop(context);
                // Show sticky note creation
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  int _estimateReadingTime(String content) {
    const wordsPerMinute = 200;
    final wordCount = content.split(' ').length;
    return (wordCount / wordsPerMinute).ceil();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}