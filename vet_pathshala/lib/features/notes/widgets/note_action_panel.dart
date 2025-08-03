import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/note_model.dart';
import '../providers/notes_provider.dart';

class NoteActionPanel extends StatelessWidget {
  final NoteModel note;
  final String userId;
  final VoidCallback onClose;

  const NoteActionPanel({
    super.key,
    required this.note,
    required this.userId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: UnifiedTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Note Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: UnifiedTheme.primaryText,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  color: UnifiedTheme.tertiaryText,
                ),
              ],
            ),
          ),
          
          // Actions Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  final interaction = notesProvider.currentInteraction;
                  
                  return GridView.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildActionItem(
                        icon: interaction?.isLiked == true ? Icons.favorite : Icons.favorite_outline,
                        label: 'Like',
                        color: interaction?.isLiked == true ? UnifiedTheme.redAccent : UnifiedTheme.tertiaryText,
                        onTap: () => notesProvider.toggleLike(userId, note.id),
                      ),
                      _buildActionItem(
                        icon: interaction?.isBookmarked == true ? Icons.bookmark : Icons.bookmark_outline,
                        label: 'Bookmark',
                        color: interaction?.isBookmarked == true ? UnifiedTheme.goldAccent : UnifiedTheme.tertiaryText,
                        onTap: () => notesProvider.toggleBookmark(userId, note.id),
                      ),
                      _buildActionItem(
                        icon: Icons.note_add_outlined,
                        label: 'Sticky Note',
                        color: UnifiedTheme.primaryGreen,
                        onTap: () => _showStickyNoteDialog(context, notesProvider),
                      ),
                      _buildActionItem(
                        icon: Icons.style_outlined,
                        label: 'Flashcard',
                        color: UnifiedTheme.blueAccent,
                        onTap: () => _showFlashcardInfo(context),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: UnifiedTheme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showStickyNoteDialog(BuildContext context, NotesProvider notesProvider) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UnifiedTheme.cardBackground,
        title: const Text('Add Sticky Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write your note here...',
                border: OutlineInputBorder(),
              ),
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
              if (controller.text.isNotEmpty) {
                notesProvider.addStickyNote(
                  userId,
                  note.id,
                  controller.text,
                  0, // Position at the beginning for now
                );
                Navigator.pop(context);
                onClose();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.primaryGreen,
            ),
            child: const Text('Add Note', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFlashcardInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UnifiedTheme.cardBackground,
        title: const Text('Create Flashcard'),
        content: const Text(
          'Select text from the note to automatically generate a flashcard. '
          'The AI will create a question and answer based on your selection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}