import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class ReadingControlsWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double progress;
  final Function(int) onPageJump;
  final VoidCallback onAnnotationTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onContentsTap;
  final VoidCallback onSettingsTap;

  const ReadingControlsWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.progress,
    required this.onPageJump,
    required this.onAnnotationTap,
    required this.onBookmarkTap,
    required this.onContentsTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page $currentPage',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'of $totalPages',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTapDown: (details) => _handleProgressTap(details, context),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * progress,
                        height: 4,
                        decoration: BoxDecoration(
                          color: UnifiedTheme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: Icons.menu_book,
              label: 'Contents',
              onTap: onContentsTap,
            ),
            _buildControlButton(
              icon: Icons.bookmark,
              label: 'Bookmarks',
              onTap: onBookmarkTap,
            ),
            _buildControlButton(
              icon: Icons.edit_note,
              label: 'Notes',
              onTap: onAnnotationTap,
            ),
            _buildControlButton(
              icon: Icons.settings,
              label: 'Settings',
              onTap: onSettingsTap,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Navigation controls
        Row(
          children: [
            // Previous page
            Expanded(
              child: ElevatedButton.icon(
                onPressed: currentPage > 1 
                    ? () => onPageJump(currentPage - 1)
                    : null,
                icon: const Icon(Icons.navigate_before),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Jump to page
            ElevatedButton(
              onPressed: () => _showPageJumpDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: UnifiedTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('$currentPage'),
            ),
            
            const SizedBox(width: 16),
            
            // Next page
            Expanded(
              child: ElevatedButton.icon(
                onPressed: currentPage < totalPages 
                    ? () => onPageJump(currentPage + 1)
                    : null,
                icon: const Icon(Icons.navigate_next),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleProgressTap(TapDownDetails details, BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final width = renderBox.size.width - 32; // Account for horizontal margin
    final tappedProgress = (localPosition.dx - 16) / width; // Account for margin
    
    if (tappedProgress >= 0 && tappedProgress <= 1) {
      final targetPage = (tappedProgress * totalPages).round().clamp(1, totalPages);
      onPageJump(targetPage);
    }
  }

  void _showPageJumpDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jump to Page'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Page number (1-$totalPages)',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Current page: $currentPage',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
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
              final pageNumber = int.tryParse(controller.text);
              if (pageNumber != null && pageNumber >= 1 && pageNumber <= totalPages) {
                Navigator.pop(context);
                onPageJump(pageNumber);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid page number (1-$totalPages)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }
}