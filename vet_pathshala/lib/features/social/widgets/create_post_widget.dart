import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/social_provider.dart';

class CreatePostWidget extends StatefulWidget {
  final UserModel user;
  final VoidCallback onPostCreated;
  final String? groupId;

  const CreatePostWidget({
    super.key,
    required this.user,
    required this.onPostCreated,
    this.groupId,
  });

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.groupId;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Create Post',
                  style: UnifiedTheme.headingStyle.copyWith(fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: UnifiedTheme.primaryColor,
                  child: Text(
                    widget.user.displayName.isNotEmpty 
                        ? widget.user.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.displayName,
                      style: UnifiedTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.user.userRole.toUpperCase(),
                      style: UnifiedTheme.captionStyle.copyWith(
                        color: UnifiedTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Group selection (if not posting to specific group)
            if (widget.groupId == null)
              Consumer<SocialProvider>(
                builder: (context, provider, child) {
                  final userGroups = provider.userStudyGroups;
                  
                  if (userGroups.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Join a study group to share posts with the community',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedGroupId,
                    decoration: const InputDecoration(
                      labelText: 'Post to Group',
                      border: OutlineInputBorder(),
                    ),
                    items: userGroups.map((group) => DropdownMenuItem(
                      value: group.id,
                      child: Text(group.name),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGroupId = value;
                      });
                    },
                  );
                },
              ),
            
            if (widget.groupId == null) const SizedBox(height: 16),
            
            // Content input
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts, ask questions, or start a discussion...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                // Future: Add image/file attachment buttons
                IconButton(
                  onPressed: () {
                    // TODO: Implement image picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image attachments coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.image),
                  tooltip: 'Add Image',
                ),
                
                IconButton(
                  onPressed: () {
                    // TODO: Implement file picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File attachments coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.attach_file),
                  tooltip: 'Attach File',
                ),
                
                const Spacer(),
                
                // Post button
                ElevatedButton(
                  onPressed: _canPost() ? _createPost : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UnifiedTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Post',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  bool _canPost() {
    return !_isLoading && 
           _contentController.text.trim().isNotEmpty && 
           (_selectedGroupId != null || widget.groupId != null);
  }
  
  void _createPost() async {
    if (!_canPost()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final provider = context.read<SocialProvider>();
      
      await provider.createGroupPost(
        groupId: widget.groupId ?? _selectedGroupId!,
        authorId: widget.user.id,
        content: _contentController.text.trim(),
      );
      
      if (context.mounted) {
        Navigator.pop(context);
        widget.onPostCreated();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
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