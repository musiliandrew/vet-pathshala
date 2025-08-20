import 'package:flutter/material.dart';
import '../../../shared/services/enhanced_admin_service.dart';
import '../../../core/theme/unified_theme.dart';

class ContentSearchScreen extends StatefulWidget {
  const ContentSearchScreen({super.key});

  @override
  State<ContentSearchScreen> createState() => _ContentSearchScreenState();
}

class _ContentSearchScreenState extends State<ContentSearchScreen> {
  final _searchController = TextEditingController();
  final EnhancedAdminService _adminService = EnhancedAdminService();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _selectedContentType;
  String? _selectedCategory;
  
  final List<String> _contentTypes = ['videos', 'questions', 'ebooks'];
  final List<String> _categories = [
    'Veterinary Medicine',
    'Animal Anatomy',
    'Pharmacology',
    'Surgery',
    'Pathology',
    'Microbiology',
    'Animal Husbandry',
    'Parasitology',
    'Clinical Medicine',
    'Public Health',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Content'),
        backgroundColor: UnifiedTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Form
          _buildSearchForm(),
          
          // Results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for content...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _performSearch,
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: UnifiedTheme.primary),
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          
          const SizedBox(height: 16),
          
          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedContentType,
                  decoration: const InputDecoration(
                    labelText: 'Content Type',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ..._contentTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedContentType = value;
                    });
                  },
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ..._categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching content...'),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Enter a search term to find content'
                  : 'No results found for "${_searchController.text}"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final type = result['type'] as String;
    final id = result['id'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showContentDetails(result),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeIcon(type),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getResultTitle(result),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleResultAction(result, value),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                _getResultSubtitle(result),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  _buildTypeChip(type),
                  const SizedBox(width: 8),
                  if (result['category'] != null)
                    _buildCategoryChip(result['category'] as String),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'video':
        icon = Icons.video_library;
        color = Colors.red;
        break;
      case 'question':
        icon = Icons.quiz;
        color = Colors.blue;
        break;
      case 'ebook':
        icon = Icons.book;
        color = Colors.green;
        break;
      default:
        icon = Icons.file_copy;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    Color color;
    String label;

    switch (type) {
      case 'video':
        color = Colors.red;
        label = 'VIDEO';
        break;
      case 'question':
        color = Colors.blue;
        label = 'QUESTION';
        break;
      case 'ebook':
        color = Colors.green;
        label = 'E-BOOK';
        break;
      default:
        color = Colors.grey;
        label = type.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: UnifiedTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: UnifiedTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getResultTitle(Map<String, dynamic> result) {
    switch (result['type'] as String) {
      case 'video':
        return result['title'] as String? ?? 'Untitled Video';
      case 'question':
        return result['question'] as String? ?? 'Untitled Question';
      case 'ebook':
        return result['title'] as String? ?? 'Untitled Book';
      default:
        return 'Unknown Content';
    }
  }

  String _getResultSubtitle(Map<String, dynamic> result) {
    switch (result['type'] as String) {
      case 'video':
        return '${result['instructor'] ?? 'Unknown'} • ${result['description'] ?? ''}';
      case 'question':
        return '${result['subject'] ?? ''} • ${result['topic'] ?? ''}';
      case 'ebook':
        return '${result['author'] ?? 'Unknown Author'} • ${result['description'] ?? ''}';
      default:
        return '';
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _adminService.searchContent(
        query: query,
        contentType: _selectedContentType,
        category: _selectedCategory,
        limit: 50,
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showContentDetails(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getResultTitle(result)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${result['type'].toString().toUpperCase()}'),
              const SizedBox(height: 8),
              Text('ID: ${result['id']}'),
              const SizedBox(height: 8),
              if (result['category'] != null)
                Text('Category: ${result['category']}'),
              const SizedBox(height: 8),
              Text('Content: ${_getResultSubtitle(result)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleResultAction(Map<String, dynamic> result, String action) async {
    switch (action) {
      case 'view':
        _showContentDetails(result);
        break;
      case 'edit':
        // TODO: Navigate to edit screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit functionality coming soon!')),
        );
        break;
      case 'delete':
        await _showDeleteConfirmation(result);
        break;
    }
  }

  Future<void> _showDeleteConfirmation(Map<String, dynamic> result) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content'),
        content: Text(
          'Are you sure you want to delete "${_getResultTitle(result)}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final type = result['type'] as String;
        final collection = type == 'question' ? 'questions' : '${type}s';
        
        await _adminService.deleteContent(collection, result['id'] as String);
        
        // Remove from search results
        setState(() {
          _searchResults.removeWhere((item) => item['id'] == result['id']);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Content deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete content: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}