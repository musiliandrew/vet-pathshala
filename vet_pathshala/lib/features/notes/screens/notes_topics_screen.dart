import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import 'notes_list_screen.dart';

class NotesTopicsScreen extends StatelessWidget {
  const NotesTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.selectedTopicId != null) {
          return const NotesListScreen();
        }

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
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
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
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: UnifiedTheme.tertiaryText,
          ),
          const SizedBox(width: 4),
          Text(
            'Topics',
            style: TextStyle(
              color: UnifiedTheme.secondaryText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
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

    if (notesProvider.topics.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notesProvider.topics.length,
      itemBuilder: (context, index) {
        final topic = notesProvider.topics[index];
        return _buildTopicCard(context, topic, notesProvider);
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
            'Error Loading Topics',
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
              if (authProvider.currentUser != null && notesProvider.selectedSubjectId != null) {
                notesProvider.loadTopics(
                  notesProvider.selectedSubjectId!,
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
            Icons.topic_outlined,
            size: 80,
            color: UnifiedTheme.tertiaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No Topics Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Topics will appear here when content is added',
            style: TextStyle(
              color: UnifiedTheme.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, Map<String, dynamic> topic, NotesProvider notesProvider) {
    final String title = topic['title'] ?? 'Unknown Topic';
    final String description = topic['description'] ?? '';
    final int notesCount = topic['notesCount'] ?? 0;
    final String difficulty = topic['difficulty'] ?? 'Medium';

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
      child: InkWell(
        onTap: () {
          final authProvider = context.read<AuthProvider>();
          if (authProvider.currentUser != null) {
            notesProvider.loadNotes(
              topic['id'],
              authProvider.currentUser!.userRole,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with difficulty indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _getDifficultyGradient(difficulty),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.topic_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: UnifiedTheme.primaryText,
                            ),
                          ),
                        ),
                        _buildDifficultyChip(difficulty),
                      ],
                    ),
                    
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: UnifiedTheme.tertiaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Stats row
                    Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 14,
                          color: UnifiedTheme.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$notesCount notes',
                          style: TextStyle(
                            fontSize: 12,
                            color: UnifiedTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: UnifiedTheme.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  LinearGradient _getDifficultyGradient(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        );
      case 'hard':
        return const LinearGradient(
          colors: [Color(0xFFF44336), Color(0xFFC62828)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFEF6C00)],
        );
    }
  }
}