import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/note_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import 'note_reader_screen.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        return Column(
          children: [
            // Breadcrumb
            _buildBreadcrumb(context, notesProvider),
            
            // Content
            Expanded(
              child: _buildContent(context, notesProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBreadcrumb(BuildContext context, NotesProvider notesProvider) {
    final selectedCategory = notesProvider.categories.firstWhere(
      (cat) => cat['id'] == notesProvider.selectedCategoryId,
      orElse: () => <String, Object>{'title': 'Category'},
    );
    final selectedSubject = notesProvider.subjects.firstWhere(
      (subj) => subj['id'] == notesProvider.selectedSubjectId,
      orElse: () => <String, Object>{'title': 'Subject'},
    );
    final selectedTopic = notesProvider.topics.firstWhere(
      (topic) => topic['id'] == notesProvider.selectedTopicId,
      orElse: () => <String, Object>{'title': 'Topic'},
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: UnifiedTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              onTap: () => notesProvider.resetToCategories(),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  selectedCategory['title'] ?? 'Categories',
                  style: TextStyle(
                    color: UnifiedTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: UnifiedTheme.tertiaryText,
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                // Go back to subjects
                notesProvider.loadSubjects(
                  notesProvider.selectedCategoryId!,
                  context.read<AuthProvider>().currentUser!.userRole,
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  selectedSubject['title'] ?? 'Subjects',
                  style: TextStyle(
                    color: UnifiedTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: UnifiedTheme.tertiaryText,
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                // Go back to topics
                notesProvider.loadTopics(
                  notesProvider.selectedSubjectId!,
                  context.read<AuthProvider>().currentUser!.userRole,
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  selectedTopic['title'] ?? 'Topics',
                  style: TextStyle(
                    color: UnifiedTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: UnifiedTheme.tertiaryText,
            ),
            const SizedBox(width: 4),
            Text(
              'Notes',
              style: TextStyle(
                color: UnifiedTheme.secondaryText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotesProvider notesProvider) {
    if (notesProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(UnifiedTheme.primaryGreen),
        ),
      );
    }

    if (notesProvider.hasError) {
      return _buildErrorState(context, notesProvider);
    }

    if (notesProvider.notes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notesProvider.notes.length,
      itemBuilder: (context, index) {
        final note = notesProvider.notes[index];
        return _buildNoteCard(context, note, notesProvider);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, NotesProvider notesProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: UnifiedTheme.tertiaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Notes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notesProvider.errorMessage ?? 'Something went wrong',
            style: TextStyle(
              color: UnifiedTheme.tertiaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.currentUser != null && notesProvider.selectedTopicId != null) {
                notesProvider.loadNotes(
                  notesProvider.selectedTopicId!,
                  authProvider.currentUser!.userRole,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 80,
            color: UnifiedTheme.tertiaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No Notes Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notes will appear here when content is added',
            style: TextStyle(
              color: UnifiedTheme.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, NoteModel note, NotesProvider notesProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _openNoteDetail(context, note),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and bookmark
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: UnifiedTheme.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.bookmark_outline,
                      size: 16,
                      color: UnifiedTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Content preview
              Text(
                note.content.length > 150 
                    ? '${note.content.substring(0, 150)}...'
                    : note.content,
                style: TextStyle(
                  fontSize: 14,
                  color: UnifiedTheme.tertiaryText,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Tags
              if (note.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: note.tags.take(3).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: UnifiedTheme.primaryGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        color: UnifiedTheme.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              
              // Stats and actions
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
                      fontSize: 12,
                      color: UnifiedTheme.tertiaryText,
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
                      fontSize: 12,
                      color: UnifiedTheme.tertiaryText,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(note.createdAt),
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
    );
  }

  void _openNoteDetail(BuildContext context, NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteReaderScreen(note: note),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}