import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/gamification_models.dart';

class LeaderboardEntryWidget extends StatelessWidget {
  final LeaderboardEntryModel entry;
  final int position;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const LeaderboardEntryWidget({
    super.key,
    required this.entry,
    required this.position,
    this.isCurrentUser = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCurrentUser ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser 
            ? BorderSide(color: UnifiedTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isCurrentUser 
                ? LinearGradient(
                    colors: [
                      UnifiedTheme.primaryColor.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Position indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPositionColor(),
                  shape: BoxShape.circle,
                  boxShadow: position <= 3 ? [
                    BoxShadow(
                      color: _getPositionColor().withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: position <= 3 
                      ? Icon(
                          _getPositionIcon(),
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          '$position',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // User avatar
              CircleAvatar(
                radius: 25,
                backgroundColor: _getRoleColor().withOpacity(0.2),
                child: Text(
                  entry.displayName.isNotEmpty 
                      ? entry.displayName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: _getRoleColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.displayName,
                            style: UnifiedTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isCurrentUser ? UnifiedTheme.primaryColor : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: UnifiedTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'YOU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getRoleDisplayName(),
                            style: TextStyle(
                              color: _getRoleColor(),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Featured badges
                        if (entry.featuredBadges.isNotEmpty)
                          Row(
                            children: entry.featuredBadges.take(2).map((badgeId) {
                              return Container(
                                margin: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.military_tech,
                                  size: 12,
                                  color: Colors.amber,
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Points
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.totalPoints}',
                    style: UnifiedTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _getPositionColor(),
                    ),
                  ),
                  Text(
                    'points',
                    style: UnifiedTheme.captionStyle.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              
              // Trending indicator (optional)
              if (position <= 10)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.trending_up,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPositionColor() {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return UnifiedTheme.primaryColor;
    }
  }

  IconData _getPositionIcon() {
    switch (position) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.star;
    }
  }

  Color _getRoleColor() {
    switch (entry.userRole.toLowerCase()) {
      case 'doctor':
        return Colors.blue;
      case 'pharmacist':
        return Colors.green;
      case 'farmer':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName() {
    switch (entry.userRole.toLowerCase()) {
      case 'doctor':
        return 'VET';
      case 'pharmacist':
        return 'PHARM';
      case 'farmer':
        return 'FARM';
      default:
        return entry.userRole.toUpperCase();
    }
  }
}