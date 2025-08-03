import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import 'notes_categories_screen.dart';
import 'note_reader_screen.dart';

class ShortNotesScreen extends StatefulWidget {
  const ShortNotesScreen({super.key});

  @override
  State<ShortNotesScreen> createState() => _ShortNotesScreenState();
}

class _ShortNotesScreenState extends State<ShortNotesScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final notesProvider = context.read<NotesProvider>();
      
      if (authProvider.currentUser != null && notesProvider.categories.isEmpty) {
        notesProvider.loadCategories(authProvider.currentUser!.userRole);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search
            _buildHeader(),
            
            // Content
            Expanded(
              child: Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  if (notesProvider.searchQuery.isNotEmpty) {
                    return _buildSearchResults(notesProvider);
                  }
                  
                  return const NotesCategoriesScreen();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title Row
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: UnifiedTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Short Notes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: UnifiedTheme.primaryText,
                ),
              ),
              const Spacer(),
              Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  return Row(
                    children: [
                      // Bookmarks button
                      IconButton(
                        icon: const Icon(Icons.bookmark_outline),
                        onPressed: () => _showBookmarkedNotes(),
                        color: UnifiedTheme.primaryGreen,
                      ),
                      // Reset/Home button
                      if (notesProvider.selectedCategoryId != null || 
                          notesProvider.searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.home_outlined),
                          onPressed: () {
                            notesProvider.resetToCategories();
                            notesProvider.clearSearch();
                          },
                          color: UnifiedTheme.primaryGreen,
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Search Bar
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: UnifiedTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: UnifiedTheme.borderColor),
          ),
          child: TextField(
            onChanged: (query) {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.currentUser != null) {
                notesProvider.searchNotes(query, authProvider.currentUser!.userRole);
              }
            },
            decoration: InputDecoration(
              hintText: 'Search notes, topics, or categories...',
              hintStyle: TextStyle(
                color: UnifiedTheme.tertiaryText,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: UnifiedTheme.primaryGreen,
                size: 20,
              ),
              suffixIcon: notesProvider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: UnifiedTheme.tertiaryText,
                        size: 20,
                      ),
                      onPressed: () => notesProvider.clearSearch(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(NotesProvider notesProvider) {
    if (notesProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(UnifiedTheme.primaryGreen),
        ),
      );
    }

    if (notesProvider.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: UnifiedTheme.tertiaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: UnifiedTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                color: UnifiedTheme.tertiaryText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notesProvider.searchResults.length,
      itemBuilder: (context, index) {
        final note = notesProvider.searchResults[index];
        return _buildNoteCard(note, context);
      },
    );
  }

  Widget _buildNoteCard(note, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: UnifiedTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.note_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          note.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              note.content.length > 100 
                  ? '${note.content.substring(0, 100)}...'
                  : note.content,
              style: TextStyle(
                color: UnifiedTheme.tertiaryText,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 14,
                  color: UnifiedTheme.tertiaryText,
                ),
                const SizedBox(width: 4),
                Text(
                  '${note.readCount}',
                  style: TextStyle(
                    color: UnifiedTheme.tertiaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.favorite_outline,
                  size: 14,
                  color: UnifiedTheme.tertiaryText,
                ),
                const SizedBox(width: 4),
                Text(
                  '${note.likeCount}',
                  style: TextStyle(
                    color: UnifiedTheme.tertiaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // Navigate to note detail screen
          _openNoteDetail(note);
        },
      ),
    );
  }

  void _showBookmarkedNotes() {
    final authProvider = context.read<AuthProvider>();
    final notesProvider = context.read<NotesProvider>();
    
    if (authProvider.currentUser != null) {
      notesProvider.loadBookmarkedNotes(
        authProvider.currentUser!.id,
        authProvider.currentUser!.userRole,
      );
      
      // Show bookmarked notes in a modal
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildBookmarkedNotesModal(),
      );
    }
  }

  Widget _buildBookmarkedNotesModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: UnifiedTheme.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: UnifiedTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.bookmark,
                  color: UnifiedTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bookmarked Notes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
          
          // Bookmarked notes list
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                if (notesProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(UnifiedTheme.primaryGreen),
                    ),
                  );
                }

                if (notesProvider.bookmarkedNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_outline,
                          size: 80,
                          color: UnifiedTheme.tertiaryText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookmarked notes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: UnifiedTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bookmark notes to access them quickly',
                          style: TextStyle(
                            color: UnifiedTheme.tertiaryText,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notesProvider.bookmarkedNotes.length,
                  itemBuilder: (context, index) {
                    final note = notesProvider.bookmarkedNotes[index];
                    return _buildNoteCard(note, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openNoteDetail(note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteReaderScreen(note: note),
      ),
    );
  }
}