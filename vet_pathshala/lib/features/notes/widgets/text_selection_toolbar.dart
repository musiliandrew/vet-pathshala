import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class CustomTextSelectionToolbar extends StatelessWidget {
  final String selectedText;
  final Function(Color) onHighlight;
  final VoidCallback onCreateFlashcard;
  final VoidCallback onAddStickyNote;
  final VoidCallback onCopy;

  const CustomTextSelectionToolbar({
    super.key,
    required this.selectedText,
    required this.onHighlight,
    required this.onCreateFlashcard,
    required this.onAddStickyNote,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          
          // Selected text preview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.format_quote,
                  color: UnifiedTheme.primaryGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedText.length > 100 
                        ? '${selectedText.substring(0, 100)}...'
                        : selectedText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: UnifiedTheme.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Highlight Colors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Highlight',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: UnifiedTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildHighlightOption(Colors.yellow, 'Yellow'),
                    _buildHighlightOption(Colors.green, 'Green'),
                    _buildHighlightOption(Colors.blue, 'Blue'),
                    _buildHighlightOption(Colors.pink, 'Pink'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.style_outlined,
                        label: 'Flashcard',
                        color: UnifiedTheme.blueAccent,
                        onTap: onCreateFlashcard,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.note_add_outlined,
                        label: 'Sticky Note',
                        color: UnifiedTheme.goldAccent,
                        onTap: onAddStickyNote,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildActionButton(
                    icon: Icons.copy_outlined,
                    label: 'Copy Text',
                    color: UnifiedTheme.tertiaryText,
                    onTap: onCopy,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHighlightOption(Color color, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onHighlight(color),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color),
              ),
              child: Icon(
                Icons.brush,
                color: color.withOpacity(0.8),
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: UnifiedTheme.tertiaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: color.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}