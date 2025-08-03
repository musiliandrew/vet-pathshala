import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notes_provider.dart';
import 'notes_subjects_screen.dart';

class NotesCategoriesScreen extends StatefulWidget {
  const NotesCategoriesScreen({super.key});

  @override
  State<NotesCategoriesScreen> createState() => _NotesCategoriesScreenState();
}

class _NotesCategoriesScreenState extends State<NotesCategoriesScreen> {
  @override
  void initState() {
    super.initState();
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
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.selectedCategoryId != null) {
          return const NotesSubjectsScreen();
        }

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

        if (notesProvider.categories.isEmpty) {
          return _buildEmptyState();
        }

        return _buildCategoriesList(context, notesProvider);
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
            'Error Loading Categories',
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
              if (authProvider.currentUser != null) {
                notesProvider.loadCategories(authProvider.currentUser!.userRole);
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
            Icons.folder_outlined,
            size: 80,
            color: UnifiedTheme.tertiaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No Categories Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Categories will appear here when content is added',
            style: TextStyle(
              color: UnifiedTheme.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, NotesProvider notesProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notesProvider.categories.length,
      itemBuilder: (context, index) {
        final category = notesProvider.categories[index];
        return _buildCategoryCard(context, category, notesProvider);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category, NotesProvider notesProvider) {
    final String title = category['title'] ?? 'Unknown Category';
    final String description = category['description'] ?? '';
    final String iconName = category['icon'] ?? 'category';
    final int notesCount = category['notesCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
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
            notesProvider.loadSubjects(
              category['id'],
              authProvider.currentUser!.userRole,
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: UnifiedTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getIconData(iconName),
                  color: Colors.white,
                  size: 28,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: UnifiedTheme.primaryText,
                      ),
                    ),
                    
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
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
                          size: 16,
                          color: UnifiedTheme.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$notesCount notes',
                          style: TextStyle(
                            fontSize: 13,
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

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'anatomy':
        return Icons.psychology_outlined;
      case 'physiology':
        return Icons.favorite_outline;
      case 'pathology':
        return Icons.biotech_outlined;
      case 'pharmacology':
        return Icons.medication_outlined;
      case 'surgery':
        return Icons.medical_services_outlined;
      case 'medicine':
        return Icons.local_hospital_outlined;
      case 'radiology':
        return Icons.camera_outlined;
      case 'laboratory':
        return Icons.science_outlined;
      case 'nutrition':
        return Icons.restaurant_outlined;
      case 'reproduction':
        return Icons.pets_outlined;
      case 'parasitology':
        return Icons.bug_report_outlined;
      case 'microbiology':
        return Icons.coronavirus_outlined;
      case 'epidemiology':
        return Icons.trending_up_outlined;
      case 'ethics':
        return Icons.gavel_outlined;
      case 'business':
        return Icons.business_outlined;
      default:
        return Icons.folder_outlined;
    }
  }
}