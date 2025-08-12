import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionItem(
              icon: Icons.add_circle,
              title: 'Add Question',
              subtitle: 'Create new practice question',
              color: Colors.blue,
              onTap: () {},
            ),
            
            _buildActionItem(
              icon: Icons.note_add,
              title: 'Add Note',
              subtitle: 'Upload study material',
              color: Colors.green,
              onTap: () {},
            ),
            
            _buildActionItem(
              icon: Icons.video_call,
              title: 'Add Lecture',
              subtitle: 'Upload video content',
              color: Colors.orange,
              onTap: () {},
            ),
            
            _buildActionItem(
              icon: Icons.people_alt,
              title: 'Manage Users',
              subtitle: 'User administration',
              color: Colors.purple,
              onTap: () {},
            ),
            
            _buildActionItem(
              icon: Icons.flag,
              title: 'Review Reports',
              subtitle: 'Moderate flagged content',
              color: Colors.red,
              onTap: () {},
            ),
            
            _buildActionItem(
              icon: Icons.analytics,
              title: 'View Analytics',
              subtitle: 'Platform statistics',
              color: Colors.teal,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}