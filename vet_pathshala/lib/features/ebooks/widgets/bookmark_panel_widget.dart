import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/ebook_models.dart';
import '../../../shared/models/user_model.dart';

class BookmarkPanelWidget extends StatefulWidget {
  final EbookModel ebook;
  final UserModel user;
  final Function(EbookBookmarkModel) onBookmarkTap;

  const BookmarkPanelWidget({
    super.key,
    required this.ebook,
    required this.user,
    required this.onBookmarkTap,
  });

  @override
  State<BookmarkPanelWidget> createState() => _BookmarkPanelWidgetState();
}

class _BookmarkPanelWidgetState extends State<BookmarkPanelWidget> {
  final List<EbookBookmarkModel> _bookmarks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading bookmarks from service
    Future.delayed(const Duration(seconds: 1), () {
      // Sample bookmarks for demo
      final sampleBookmarks = [
        EbookBookmarkModel(
          id: '1',
          userId: widget.user.id,
          ebookId: widget.ebook.id,
          pageNumber: 25,
          title: 'Heart Structure Overview',
          note: 'Important diagram showing the four chambers of the heart',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        EbookBookmarkModel(
          id: '2',
          userId: widget.user.id,
          ebookId: widget.ebook.id,
          pageNumber: 67,
          title: 'Clinical Assessment Guidelines',
          note: 'Key points for cardiovascular examination in small animals',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        EbookBookmarkModel(
          id: '3',
          userId: widget.user.id,
          ebookId: widget.ebook.id,
          pageNumber: 89,
          title: 'Drug Interactions Table',
          note: 'Reference table for cardiac medications - very useful',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        EbookBookmarkModel(
          id: '4',
          userId: widget.user.id,
          ebookId: widget.ebook.id,
          pageNumber: 134,
          title: 'Emergency Protocols',
          note: 'Step-by-step emergency cardiac care procedures',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ];

      setState(() {
        _bookmarks.clear();
        _bookmarks.addAll(sampleBookmarks);
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search bookmarks...',
              prefixIcon: const Icon(Icons.search),
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
            onChanged: (query) {
              // Implement search functionality
            },
          ),
        ),

        // Sort options
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Sort by:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: 'recent',
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(
                      value: 'recent',
                      child: Text('Most Recent'),
                    ),
                    DropdownMenuItem(
                      value: 'page',
                      child: Text('Page Number'),
                    ),
                    DropdownMenuItem(
                      value: 'title',
                      child: Text('Title'),
                    ),
                  ],
                  onChanged: (value) {
                    // Implement sorting
                  },
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 32),

        // Bookmarks list
        Expanded(
          child: _buildBookmarksList(),
        ),

        // Add bookmark button
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddBookmarkDialog,
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
        ),
      ],
    );
  }

  Widget _buildBookmarksList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarks yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add bookmarks to save important pages',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = _bookmarks[index];
        return _buildBookmarkCard(bookmark);
      },
    );
  }

  Widget _buildBookmarkCard(EbookBookmarkModel bookmark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => widget.onBookmarkTap(bookmark),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Page indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: UnifiedTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Page ${bookmark.pageNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: UnifiedTheme.primaryColor,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // More options
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 16, color: Colors.grey[600]),
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
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 16),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
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
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Footer
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(bookmark.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Quick action buttons
                  InkWell(
                    onTap: () => widget.onBookmarkTap(bookmark),
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
                            Icons.visibility,
                            size: 12,
                            color: UnifiedTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'View',
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
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

  void _handleBookmarkAction(String action, EbookBookmarkModel bookmark) {
    switch (action) {
      case 'edit':
        _showEditBookmarkDialog(bookmark);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(bookmark);
        break;
      case 'share':
        _shareBookmark(bookmark);
        break;
    }
  }

  void _showAddBookmarkDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddBookmarkDialog(
        onBookmarkAdded: (bookmark) {
          setState(() {
            _bookmarks.insert(0, bookmark);
          });
        },
      ),
    );
  }

  void _showEditBookmarkDialog(EbookBookmarkModel bookmark) {
    showDialog(
      context: context,
      builder: (context) => _EditBookmarkDialog(
        bookmark: bookmark,
        onBookmarkUpdated: (updatedBookmark) {
          setState(() {
            final index = _bookmarks.indexWhere((b) => b.id == bookmark.id);
            if (index != -1) {
              _bookmarks[index] = updatedBookmark;
            }
          });
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(EbookBookmarkModel bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookmark'),
        content: Text('Are you sure you want to delete the bookmark "${bookmark.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _bookmarks.removeWhere((b) => b.id == bookmark.id);
              });
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

  void _shareBookmark(EbookBookmarkModel bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Bookmark'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share bookmark: "${bookmark.title}"'),
            const SizedBox(height: 8),
            Text('Page ${bookmark.pageNumber} of ${widget.ebook.title}'),
            if (bookmark.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Note: ${bookmark.note}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bookmark shared to study group'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}

class _AddBookmarkDialog extends StatefulWidget {
  final Function(EbookBookmarkModel) onBookmarkAdded;

  const _AddBookmarkDialog({
    required this.onBookmarkAdded,
  });

  @override
  State<_AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<_AddBookmarkDialog> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _pageController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Bookmark'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pageController,
            decoration: const InputDecoration(
              labelText: 'Page Number',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
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
              hintText: 'Add a note about this bookmark...',
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
            if (_titleController.text.isNotEmpty && _pageController.text.isNotEmpty) {
              final bookmark = EbookBookmarkModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: 'current_user',
                ebookId: 'current_ebook',
                pageNumber: int.tryParse(_pageController.text) ?? 1,
                title: _titleController.text,
                note: _noteController.text,
                createdAt: DateTime.now(),
              );
              
              widget.onBookmarkAdded(bookmark);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _EditBookmarkDialog extends StatefulWidget {
  final EbookBookmarkModel bookmark;
  final Function(EbookBookmarkModel) onBookmarkUpdated;

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
              labelText: 'Title',
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
            final updatedBookmark = EbookBookmarkModel(
              id: widget.bookmark.id,
              userId: widget.bookmark.userId,
              ebookId: widget.bookmark.ebookId,
              pageNumber: widget.bookmark.pageNumber,
              title: _titleController.text,
              note: _noteController.text,
              createdAt: widget.bookmark.createdAt,
            );
            
            widget.onBookmarkUpdated(updatedBookmark);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}