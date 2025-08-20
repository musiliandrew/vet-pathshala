import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/video_models.dart';

class VideoBookmarksWidget extends StatefulWidget {
  final VideoLectureModel video;
  final List<VideoBookmarkModel> bookmarks;
  final List<VideoNoteModel> notes;
  final int currentPosition;
  final Function(int timestamp) onBookmarkTap;
  final Function(VideoBookmarkModel) onBookmarkAdded;
  final Function(String bookmarkId) onBookmarkDeleted;
  final Function(VideoNoteModel) onNoteAdded;
  final Function(String noteId, String content) onNoteUpdated;
  final Function(String noteId) onNoteDeleted;
  final VoidCallback onClose;

  const VideoBookmarksWidget({
    super.key,
    required this.video,
    required this.bookmarks,
    required this.notes,
    required this.currentPosition,
    required this.onBookmarkTap,
    required this.onBookmarkAdded,
    required this.onBookmarkDeleted,
    required this.onNoteAdded,
    required this.onNoteUpdated,
    required this.onNoteDeleted,
    required this.onClose,
  });

  @override
  State<VideoBookmarksWidget> createState() => _VideoBookmarksWidgetState();
}

class _VideoBookmarksWidgetState extends State<VideoBookmarksWidget> 
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<VideoBookmarkModel> get _filteredBookmarks {
    if (_searchQuery.isEmpty) {
      return widget.bookmarks;
    }
    
    return widget.bookmarks.where((bookmark) =>
      bookmark.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      bookmark.note.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<VideoNoteModel> get _filteredNotes {
    if (_searchQuery.isEmpty) {
      return widget.notes;
    }
    
    return widget.notes.where((note) =>
      note.content.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Search bar
          _buildSearchBar(),
          
          // Tab bar
          _buildTabBar(),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookmarksList(),
                _buildNotesList(),
              ],
            ),
          ),
          
          // Add button
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bookmarks & Notes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.bookmarks.length} bookmarks • ${widget.notes.length} notes',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search bookmarks and notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: UnifiedTheme.primaryColor),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey.shade50,
      child: TabBar(
        controller: _tabController,
        labelColor: UnifiedTheme.primaryColor,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: UnifiedTheme.primaryColor,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark),
                const SizedBox(width: 8),
                Text('Bookmarks (${_filteredBookmarks.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.note),
                const SizedBox(width: 8),
                Text('Notes (${_filteredNotes.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList() {
    if (_filteredBookmarks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border,
        title: _searchQuery.isEmpty ? 'No bookmarks yet' : 'No bookmarks found',
        subtitle: _searchQuery.isEmpty 
            ? 'Add bookmarks to save important moments'
            : 'Try a different search term',
      );
    }

    final sortedBookmarks = List<VideoBookmarkModel>.from(_filteredBookmarks)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedBookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = sortedBookmarks[index];
        return _buildBookmarkCard(bookmark);
      },
    );
  }

  Widget _buildBookmarkCard(VideoBookmarkModel bookmark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => widget.onBookmarkTap(bookmark.timestamp),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Timestamp
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: UnifiedTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bookmark.formattedTimestamp,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: UnifiedTheme.primaryColor,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Actions
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 16, color: Colors.grey.shade600),
                    onSelected: (value) => _handleBookmarkAction(value, bookmark),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Title
              Text(
                bookmark.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Note (if exists)
              if (bookmark.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  bookmark.note,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Footer
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatRelativeTime(bookmark.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Play button
                  InkWell(
                    onTap: () => widget.onBookmarkTap(bookmark.timestamp),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: UnifiedTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            size: 12,
                            color: UnifiedTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Play',
                            style: TextStyle(
                              fontSize: 11,
                              color: UnifiedTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    if (_filteredNotes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.note_outlined,
        title: _searchQuery.isEmpty ? 'No notes yet' : 'No notes found',
        subtitle: _searchQuery.isEmpty 
            ? 'Add notes to remember key insights'
            : 'Try a different search term',
      );
    }

    final sortedNotes = List<VideoNoteModel>.from(_filteredNotes)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedNotes.length,
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildNoteCard(VideoNoteModel note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Timestamp
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    note.formattedTimestamp,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Actions
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 16, color: Colors.grey.shade600),
                  onSelected: (value) => _handleNoteAction(value, note),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Content
            Text(
              note.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Footer
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatRelativeTime(note.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                
                if (note.updatedAt != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(edited)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Go to timestamp button
                InkWell(
                  onTap: () => widget.onBookmarkTap(note.timestamp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          size: 12,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Go to',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAddBookmarkDialog(),
              icon: const Icon(Icons.bookmark_add),
              label: const Text('Add Bookmark'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UnifiedTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAddNoteDialog(),
              icon: const Icon(Icons.note_add),
              label: const Text('Add Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _handleBookmarkAction(String action, VideoBookmarkModel bookmark) {
    switch (action) {
      case 'edit':
        _showEditBookmarkDialog(bookmark);
        break;
      case 'delete':
        _showDeleteBookmarkDialog(bookmark);
        break;
    }
  }

  void _handleNoteAction(String action, VideoNoteModel note) {
    switch (action) {
      case 'edit':
        _showEditNoteDialog(note);
        break;
      case 'delete':
        _showDeleteNoteDialog(note);
        break;
    }
  }

  void _showAddBookmarkDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddBookmarkDialog(
        currentPosition: widget.currentPosition,
        onBookmarkAdded: widget.onBookmarkAdded,
      ),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddNoteDialog(
        currentPosition: widget.currentPosition,
        onNoteAdded: widget.onNoteAdded,
      ),
    );
  }

  void _showEditBookmarkDialog(VideoBookmarkModel bookmark) {
    showDialog(
      context: context,
      builder: (context) => _EditBookmarkDialog(
        bookmark: bookmark,
        onBookmarkUpdated: (updatedBookmark) {
          // In a real implementation, this would update the bookmark
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bookmark updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showEditNoteDialog(VideoNoteModel note) {
    showDialog(
      context: context,
      builder: (context) => _EditNoteDialog(
        note: note,
        onNoteUpdated: widget.onNoteUpdated,
      ),
    );
  }

  void _showDeleteBookmarkDialog(VideoBookmarkModel bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookmark'),
        content: Text('Are you sure you want to delete "${bookmark.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onBookmarkDeleted(bookmark.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bookmark deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteNoteDialog(VideoNoteModel note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onNoteDeleted(note.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Add Bookmark Dialog
class _AddBookmarkDialog extends StatefulWidget {
  final int currentPosition;
  final Function(VideoBookmarkModel) onBookmarkAdded;

  const _AddBookmarkDialog({
    required this.currentPosition,
    required this.onBookmarkAdded,
  });

  @override
  State<_AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<_AddBookmarkDialog> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final minutes = widget.currentPosition ~/ 60;
    final seconds = widget.currentPosition % 60;
    _titleController.text = 'Bookmark at $minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Bookmark'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Bookmark Title',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
              hintText: 'Add a note about this moment...',
            ),
            maxLines: 3,
            maxLength: 500,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              final bookmark = VideoBookmarkModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                timestamp: widget.currentPosition,
                title: _titleController.text,
                note: _noteController.text,
                createdAt: DateTime.now(),
              );
              
              widget.onBookmarkAdded(bookmark);
              Navigator.pop(context);
            }
          },
          child: const Text('Add Bookmark'),
        ),
      ],
    );
  }
}

// Add Note Dialog
class _AddNoteDialog extends StatefulWidget {
  final int currentPosition;
  final Function(VideoNoteModel) onNoteAdded;

  const _AddNoteDialog({
    required this.currentPosition,
    required this.onNoteAdded,
  });

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Adding note at ${_formatTime(widget.currentPosition)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Note Content',
              border: OutlineInputBorder(),
              hintText: 'Write your note here...',
            ),
            maxLines: 4,
            maxLength: 1000,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_contentController.text.isNotEmpty) {
              final note = VideoNoteModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                timestamp: widget.currentPosition,
                content: _contentController.text,
                createdAt: DateTime.now(),
              );
              
              widget.onNoteAdded(note);
              Navigator.pop(context);
            }
          },
          child: const Text('Add Note'),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

// Edit dialogs would be similar to add dialogs but with pre-filled data
class _EditBookmarkDialog extends StatefulWidget {
  final VideoBookmarkModel bookmark;
  final Function(VideoBookmarkModel) onBookmarkUpdated;

  const _EditBookmarkDialog({
    required this.bookmark,
    required this.onBookmarkUpdated,
  });

  @override
  State<_EditBookmarkDialog> createState() => _EditBookmarkDialogState();
}

class _EditBookmarkDialogState extends State<_EditBookmarkDialog> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bookmark.title);
    _noteController = TextEditingController(text: widget.bookmark.note);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Bookmark'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Bookmark Title',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 500,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedBookmark = VideoBookmarkModel(
              id: widget.bookmark.id,
              timestamp: widget.bookmark.timestamp,
              title: _titleController.text,
              note: _noteController.text,
              createdAt: widget.bookmark.createdAt,
            );
            
            widget.onBookmarkUpdated(updatedBookmark);
            Navigator.pop(context);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _EditNoteDialog extends StatefulWidget {
  final VideoNoteModel note;
  final Function(String noteId, String content) onNoteUpdated;

  const _EditNoteDialog({
    required this.note,
    required this.onNoteUpdated,
  });

  @override
  State<_EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<_EditNoteDialog> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Note Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            maxLength: 1000,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onNoteUpdated(widget.note.id, _contentController.text);
            Navigator.pop(context);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}