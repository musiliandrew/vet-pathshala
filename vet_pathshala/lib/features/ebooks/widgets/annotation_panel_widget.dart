import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/ebook_models.dart';
import '../../../shared/models/user_model.dart';

class AnnotationPanelWidget extends StatefulWidget {
  final EbookModel ebook;
  final UserModel user;
  final int currentPage;
  final Function(EbookAnnotationModel) onAnnotationTap;

  const AnnotationPanelWidget({
    super.key,
    required this.ebook,
    required this.user,
    required this.currentPage,
    required this.onAnnotationTap,
  });

  @override
  State<AnnotationPanelWidget> createState() => _AnnotationPanelWidgetState();
}

class _AnnotationPanelWidgetState extends State<AnnotationPanelWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<EbookAnnotationModel> _annotations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnnotations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAnnotations() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading annotations from service
    Future.delayed(const Duration(seconds: 1), () {
      // Sample annotations for demo
      final sampleAnnotations = [
        EbookAnnotationModel(
          id: '1',
          userId: widget.user.id,
          ebookId: widget.ebook.id,
          pageNumber: 15,
          type: 'highlight',
          content: 'Important concept about heart anatomy',
          selectedText: 'The cardiovascular system is responsible for circulating blood',
          color: '#FFEB3B',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        EbookAnnotationModel(
          id: '2',
          userId: widget.user.id,
          ebookId: widget.ebook.id,
          pageNumber: 32,
          type: 'note',
          content: 'Remember to study this section for the exam. The different types of heart valves and their functions are crucial.',
          color: '#2196F3',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        EbookAnnotationModel(
          id: '3',
          userId: widget.user.id,
          ebookId: widget.ebook.id,
          pageNumber: widget.currentPage,
          type: 'highlight',
          content: 'Current page highlight',
          selectedText: 'This is important information on the current page',
          color: '#4CAF50',
          createdAt: DateTime.now(),
        ),
      ];

      setState(() {
        _annotations.clear();
        _annotations.addAll(sampleAnnotations);
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          color: Colors.grey[50],
          child: TabBar(
            controller: _tabController,
            labelColor: UnifiedTheme.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: UnifiedTheme.primaryColor,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Highlights'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAnnotationsList(_annotations),
              _buildAnnotationsList(_annotations.where((a) => a.type == 'highlight').toList()),
              _buildAnnotationsList(_annotations.where((a) => a.type == 'note').toList()),
            ],
          ),
        ),
        
        // Add annotation FAB
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddAnnotationDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Annotation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UnifiedTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnotationsList(List<EbookAnnotationModel> annotations) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (annotations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No annotations yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add highlights and notes while reading',
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
      padding: const EdgeInsets.all(16),
      itemCount: annotations.length,
      itemBuilder: (context, index) {
        final annotation = annotations[index];
        return _buildAnnotationCard(annotation);
      },
    );
  }

  Widget _buildAnnotationCard(EbookAnnotationModel annotation) {
    final isCurrentPage = annotation.pageNumber == widget.currentPage;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrentPage ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isCurrentPage 
            ? BorderSide(color: UnifiedTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => widget.onAnnotationTap(annotation),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Type indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(annotation.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTypeIcon(annotation.type),
                          size: 12,
                          color: _getTypeColor(annotation.type),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          annotation.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getTypeColor(annotation.type),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Page number
                  Text(
                    'Page ${annotation.pageNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentPage ? UnifiedTheme.primaryColor : Colors.grey[600],
                      fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  
                  // More options
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 16, color: Colors.grey[600]),
                    onSelected: (value) => _handleAnnotationAction(value, annotation),
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
              
              // Selected text (for highlights)
              if (annotation.selectedText != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(int.parse(annotation.color.replaceAll('#', '0xFF'))).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Color(int.parse(annotation.color.replaceAll('#', '0xFF'))).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    annotation.selectedText!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Annotation content
              if (annotation.content.isNotEmpty)
                Text(
                  annotation.content,
                  style: const TextStyle(fontSize: 14),
                ),
              
              const SizedBox(height: 8),
              
              // Footer
              Row(
                children: [
                  Text(
                    _formatDate(annotation.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (annotation.updatedAt != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(edited)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'highlight':
        return Colors.yellow.shade700;
      case 'note':
        return Colors.blue;
      case 'bookmark':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'highlight':
        return Icons.highlight;
      case 'note':
        return Icons.note;
      case 'bookmark':
        return Icons.bookmark;
      default:
        return Icons.help;
    }
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
    } else {
      return 'Just now';
    }
  }

  void _handleAnnotationAction(String action, EbookAnnotationModel annotation) {
    switch (action) {
      case 'edit':
        _showEditAnnotationDialog(annotation);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(annotation);
        break;
    }
  }

  void _showAddAnnotationDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddAnnotationDialog(
        pageNumber: widget.currentPage,
        onAnnotationAdded: (annotation) {
          setState(() {
            _annotations.add(annotation);
          });
        },
      ),
    );
  }

  void _showEditAnnotationDialog(EbookAnnotationModel annotation) {
    showDialog(
      context: context,
      builder: (context) => _EditAnnotationDialog(
        annotation: annotation,
        onAnnotationUpdated: (updatedAnnotation) {
          setState(() {
            final index = _annotations.indexWhere((a) => a.id == annotation.id);
            if (index != -1) {
              _annotations[index] = updatedAnnotation;
            }
          });
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(EbookAnnotationModel annotation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Annotation'),
        content: const Text('Are you sure you want to delete this annotation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _annotations.removeWhere((a) => a.id == annotation.id);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddAnnotationDialog extends StatefulWidget {
  final int pageNumber;
  final Function(EbookAnnotationModel) onAnnotationAdded;

  const _AddAnnotationDialog({
    required this.pageNumber,
    required this.onAnnotationAdded,
  });

  @override
  State<_AddAnnotationDialog> createState() => _AddAnnotationDialogState();
}

class _AddAnnotationDialogState extends State<_AddAnnotationDialog> {
  final _contentController = TextEditingController();
  String _selectedType = 'note';
  String _selectedColor = '#2196F3';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Annotation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(labelText: 'Type'),
            items: const [
              DropdownMenuItem(value: 'note', child: Text('Note')),
              DropdownMenuItem(value: 'highlight', child: Text('Highlight')),
            ],
            onChanged: (value) => setState(() => _selectedType = value!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
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
              final annotation = EbookAnnotationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: 'current_user',
                ebookId: 'current_ebook',
                pageNumber: widget.pageNumber,
                type: _selectedType,
                content: _contentController.text,
                color: _selectedColor,
                createdAt: DateTime.now(),
              );
              
              widget.onAnnotationAdded(annotation);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _EditAnnotationDialog extends StatefulWidget {
  final EbookAnnotationModel annotation;
  final Function(EbookAnnotationModel) onAnnotationUpdated;

  const _EditAnnotationDialog({
    required this.annotation,
    required this.onAnnotationUpdated,
  });

  @override
  State<_EditAnnotationDialog> createState() => _EditAnnotationDialogState();
}

class _EditAnnotationDialogState extends State<_EditAnnotationDialog> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.annotation.content);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Annotation'),
      content: TextField(
        controller: _contentController,
        decoration: const InputDecoration(
          labelText: 'Content',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedAnnotation = EbookAnnotationModel(
              id: widget.annotation.id,
              userId: widget.annotation.userId,
              ebookId: widget.annotation.ebookId,
              pageNumber: widget.annotation.pageNumber,
              type: widget.annotation.type,
              content: _contentController.text,
              selectedText: widget.annotation.selectedText,
              position: widget.annotation.position,
              color: widget.annotation.color,
              createdAt: widget.annotation.createdAt,
              updatedAt: DateTime.now(),
              isPrivate: widget.annotation.isPrivate,
            );
            
            widget.onAnnotationUpdated(updatedAnnotation);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}