import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;
  final UserModel? currentUser;

  const UserProfileScreen({
    super.key,
    required this.user,
    this.currentUser,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final isSelf = widget.currentUser?.id == widget.user.id;
    
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          isSelf ? 'Your Profile' : widget.user.displayName,
          style: UnifiedTheme.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: UnifiedTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (isSelf)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to edit profile screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile editing coming soon!'),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _getRoleColor().withOpacity(0.2),
                    child: Text(
                      widget.user.displayName.isNotEmpty 
                          ? widget.user.displayName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: _getRoleColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    widget.user.displayName,
                    style: UnifiedTheme.headingStyle.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Role
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getRoleColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleDisplayName(),
                      style: TextStyle(
                        color: _getRoleColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  if (widget.user.specialization != null &&
                      widget.user.specialization!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.user.specialization!,
                      style: UnifiedTheme.bodyStyle.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  if (widget.user.experienceYears != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${widget.user.experienceYears} years of experience',
                      style: UnifiedTheme.bodyStyle.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Stats section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Stats',
                    style: UnifiedTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Coins',
                          '${widget.user.coins}',
                          Icons.monetization_on,
                          Colors.amber,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Followers',
                          '0', // TODO: Get from social profile
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Following',
                          '0', // TODO: Get from social profile
                          Icons.person_add,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recent activity section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: UnifiedTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Placeholder for recent activities
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.timeline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No recent activity',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: UnifiedTheme.headingStyle.copyWith(
            fontSize: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: UnifiedTheme.captionStyle,
        ),
      ],
    );
  }
  
  Color _getRoleColor() {
    switch (widget.user.userRole.toLowerCase()) {
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
    switch (widget.user.userRole.toLowerCase()) {
      case 'doctor':
        return 'Veterinarian';
      case 'pharmacist':
        return 'Pharmacist';
      case 'farmer':
        return 'Farmer';
      default:
        return widget.user.userRole.toUpperCase();
    }
  }
}