import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import 'notes_topics_screen.dart';

class NotesSubjectsScreen extends StatelessWidget {
  const NotesSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.selectedSubjectId != null) {
          return const NotesTopicsScreen();
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: UnifiedTheme.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    selectedCategory['title'] ?? 'Categories',
                    style: TextStyle(
                      color: UnifiedTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: UnifiedTheme.tertiaryText,
          ),
          const SizedBox(width: 8),
          Text(
            'Subjects',
            style: TextStyle(
              color: UnifiedTheme.secondaryText,
              fontWeight: FontWeight.w600,
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

    if (notesProvider.subjects.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notesProvider.subjects.length,
      itemBuilder: (context, index) {
        final subject = notesProvider.subjects[index];
        return _buildSubjectCard(context, subject, notesProvider);
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
            'Error Loading Subjects',
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
              if (authProvider.currentUser != null && notesProvider.selectedCategoryId != null) {
                notesProvider.loadSubjects(
                  notesProvider.selectedCategoryId!,
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
            Icons.book_outlined,
            size: 80,
            color: UnifiedTheme.tertiaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No Subjects Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subjects will appear here when content is added',
            style: TextStyle(
              color: UnifiedTheme.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> subject, NotesProvider notesProvider) {
    final String title = subject['title'] ?? 'Unknown Subject';
    final String description = subject['description'] ?? '';
    final int topicsCount = subject['topicsCount'] ?? 0;
    final int notesCount = subject['notesCount'] ?? 0;

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
            notesProvider.loadTopics(
              subject['id'],
              authProvider.currentUser!.userRole,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: UnifiedTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.book_outlined,
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: UnifiedTheme.primaryText,
                      ),
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
                          Icons.topic_outlined,
                          size: 14,
                          color: UnifiedTheme.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$topicsCount topics',
                          style: TextStyle(
                            fontSize: 12,
                            color: UnifiedTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.note_outlined,
                          size: 14,
                          color: UnifiedTheme.tertiaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$notesCount notes',
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
}