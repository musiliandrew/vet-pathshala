import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/social_provider.dart';

class UserCardWidget extends StatefulWidget {
  final UserModel user;
  final UserModel currentUser;
  final VoidCallback? onTap;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.currentUser,
    this.onTap,
  });

  @override
  State<UserCardWidget> createState() => _UserCardWidgetState();
}

class _UserCardWidgetState extends State<UserCardWidget> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  void _checkFollowingStatus() async {
    final provider = context.read<SocialProvider>();
    final isFollowing = await provider.checkIfFollowing(
      widget.currentUser.id,
      widget.user.id,
    );
    
    if (mounted) {
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelf = widget.user.id == widget.currentUser.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile avatar
              CircleAvatar(
                radius: 25,
                backgroundColor: _getRoleColor().withOpacity(0.2),
                child: Text(
                  widget.user.displayName.isNotEmpty 
                      ? widget.user.displayName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: _getRoleColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.displayName,
                      style: UnifiedTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getRoleDisplayName(),
                            style: TextStyle(
                              color: _getRoleColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        if (widget.user.specialization != null &&
                            widget.user.specialization!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.user.specialization!,
                              style: UnifiedTheme.captionStyle.copyWith(
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    if (widget.user.experienceYears != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${widget.user.experienceYears} years experience',
                        style: UnifiedTheme.captionStyle.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action button
              if (!isSelf)
                SizedBox(
                  width: 80,
                  child: _isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _isFollowing
                          ? OutlinedButton(
                              onPressed: _unfollowUser,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Following',
                                style: TextStyle(fontSize: 12),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _followUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UnifiedTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Follow',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                ),
              
              if (isSelf)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'You',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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
  
  void _followUser() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final provider = context.read<SocialProvider>();
      await provider.followUser(widget.currentUser.id, widget.user.id);
      
      if (mounted) {
        setState(() {
          _isFollowing = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are now following ${widget.user.displayName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to follow user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _unfollowUser() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final provider = context.read<SocialProvider>();
      await provider.unfollowUser(widget.currentUser.id, widget.user.id);
      
      if (mounted) {
        setState(() {
          _isFollowing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You unfollowed ${widget.user.displayName}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unfollow user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}