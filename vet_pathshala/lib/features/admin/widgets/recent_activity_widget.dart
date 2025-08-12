import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: UnifiedTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildActivityItem(
              icon: Icons.person_add,
              title: 'New user registration',
              subtitle: 'Dr. Sarah Johnson joined as Veterinarian',
              time: '2 minutes ago',
              color: Colors.green,
            ),
            
            _buildActivityItem(
              icon: Icons.quiz,
              title: 'Question added',
              subtitle: 'Pathology question submitted for review',
              time: '15 minutes ago',
              color: Colors.blue,
            ),
            
            _buildActivityItem(
              icon: Icons.flag,
              title: 'Content reported',
              subtitle: 'Question #1234 reported as inappropriate',
              time: '1 hour ago',
              color: Colors.red,
            ),
            
            _buildActivityItem(
              icon: Icons.note,
              title: 'Note updated',
              subtitle: 'Anatomy notes revised and republished',
              time: '2 hours ago',
              color: Colors.orange,
            ),
            
            _buildActivityItem(
              icon: Icons.video_library,
              title: 'Lecture uploaded',
              subtitle: 'New surgical procedure video added',
              time: '3 hours ago',
              color: Colors.purple,
            ),
            
            _buildActivityItem(
              icon: Icons.thumb_up,
              title: 'Popular content',
              subtitle: 'Question #5678 reached 100 likes',
              time: '4 hours ago',
              color: Colors.teal,
            ),
            
            _buildActivityItem(
              icon: Icons.analytics,
              title: 'Daily report',
              subtitle: '45 new users, 234 questions answered',
              time: '1 day ago',
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
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
              size: 16,
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}