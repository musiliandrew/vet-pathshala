import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/social_models.dart';
import '../../../shared/models/user_model.dart';

class ActivityCardWidget extends StatelessWidget {
  final SocialActivityModel activity;
  final UserModel currentUser;

  const ActivityCardWidget({
    super.key,
    required this.activity,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and activity type
            Row(
              children: [
                // Activity type icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getActivityColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getActivityIcon(),
                    color: _getActivityColor(),
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // User name and activity title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUserDisplayName(),
                        style: UnifiedTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        activity.title,
                        style: UnifiedTheme.captionStyle.copyWith(
                          color: _getActivityColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Timestamp
                Text(
                  timeago.format(activity.createdAt),
                  style: UnifiedTheme.captionStyle.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Activity description
            Text(
              activity.description,
              style: UnifiedTheme.bodyStyle,
            ),
            
            // Activity-specific content
            if (activity.data.isNotEmpty)
              _buildActivityContent(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityContent() {
    switch (activity.type) {
      case ActivityType.quiz_completed:
        return _buildQuizContent();
      case ActivityType.achievement_unlocked:
        return _buildAchievementContent();
      case ActivityType.study_streak:
        return _buildStreakContent();
      case ActivityType.group_joined:
        return _buildGroupContent();
      case ActivityType.challenge_won:
        return _buildChallengeContent();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildQuizContent() {
    final score = activity.data['score'] as int? ?? 0;
    final category = activity.data['category'] as String? ?? '';
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.quiz, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiz Score: $score%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (category.isNotEmpty)
                  Text(
                    'Category: $category',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          _buildScoreBadge(score),
        ],
      ),
    );
  }
  
  Widget _buildAchievementContent() {
    final achievementTitle = activity.data['achievementTitle'] as String? ?? '';
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              achievementTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          const Icon(Icons.stars, color: Colors.amber, size: 16),
        ],
      ),
    );
  }
  
  Widget _buildStreakContent() {
    final streakDays = activity.data['streakDays'] as int? ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$streakDays Day Streak!',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          ...List.generate(
            (streakDays / 7).floor().clamp(0, 5),
            (index) => const Icon(Icons.whatshot, color: Colors.orange, size: 16),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGroupContent() {
    final groupName = activity.data['groupName'] as String? ?? '';
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.group, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              groupName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChallengeContent() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.purple, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Challenge Victory!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          Icon(Icons.military_tech, color: Colors.purple, size: 16),
        ],
      ),
    );
  }
  
  Widget _buildScoreBadge(int score) {
    Color badgeColor;
    String badgeText;
    
    if (score >= 90) {
      badgeColor = Colors.green;
      badgeText = 'Excellent';
    } else if (score >= 80) {
      badgeColor = Colors.blue;
      badgeText = 'Great';
    } else if (score >= 70) {
      badgeColor = Colors.orange;
      badgeText = 'Good';
    } else {
      badgeColor = Colors.grey;
      badgeText = 'Practice';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Color _getActivityColor() {
    switch (activity.type) {
      case ActivityType.quiz_completed:
        return Colors.blue;
      case ActivityType.note_shared:
        return Colors.indigo;
      case ActivityType.achievement_unlocked:
        return Colors.amber;
      case ActivityType.study_streak:
        return Colors.orange;
      case ActivityType.group_joined:
        return Colors.green;
      case ActivityType.challenge_won:
        return Colors.purple;
      case ActivityType.milestone_reached:
        return Colors.red;
    }
  }
  
  IconData _getActivityIcon() {
    switch (activity.type) {
      case ActivityType.quiz_completed:
        return Icons.quiz;
      case ActivityType.note_shared:
        return Icons.note_alt;
      case ActivityType.achievement_unlocked:
        return Icons.emoji_events;
      case ActivityType.study_streak:
        return Icons.local_fire_department;
      case ActivityType.group_joined:
        return Icons.group_add;
      case ActivityType.challenge_won:
        return Icons.military_tech;
      case ActivityType.milestone_reached:
        return Icons.flag;
    }
  }
  
  String _getUserDisplayName() {
    // In a real app, you would fetch user details from the userId
    // For now, we'll use the current user's name or show "A user"
    if (activity.userId == currentUser.id) {
      return 'You';
    } else {
      return 'A colleague'; // In production, fetch from user service
    }
  }
}