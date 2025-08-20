import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/social_models.dart';
import '../../../shared/providers/social_provider.dart';

class StudyGroupsScreen extends StatefulWidget {
  final UserModel user;

  const StudyGroupsScreen({
    super.key,
    required this.user,
  });

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final provider = context.read<SocialProvider>();
    provider.loadStudyGroups(targetRole: widget.user.userRole);
    provider.loadUserStudyGroups(widget.user.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Study Groups',
          style: UnifiedTheme.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: UnifiedTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'My Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildMyGroupsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGroupDialog,
        backgroundColor: UnifiedTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Group', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return Consumer<SocialProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.studyGroups.isEmpty) {
          return _buildEmptyDiscoverState();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.studyGroups.length,
            itemBuilder: (context, index) {
              final group = provider.studyGroups[index];
              return _buildGroupCard(group, false);
            },
          ),
        );
      },
    );
  }

  Widget _buildMyGroupsTab() {
    return Consumer<SocialProvider>(
      builder: (context, provider, child) {
        if (provider.userStudyGroups.isEmpty) {
          return _buildEmptyMyGroupsState();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.userStudyGroups.length,
            itemBuilder: (context, index) {
              final group = provider.userStudyGroups[index];
              return _buildGroupCard(group, true);
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupCard(StudyGroupModel group, bool isMember) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: _getGroupTypeColor(group.type).withOpacity(0.2),
                  child: Icon(
                    _getGroupTypeIcon(group.type),
                    color: _getGroupTypeColor(group.type),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: UnifiedTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        group.category,
                        style: UnifiedTheme.captionStyle.copyWith(
                          color: UnifiedTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGroupTypeColor(group.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.type.name.toUpperCase(),
                    style: TextStyle(
                      color: _getGroupTypeColor(group.type),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              group.description,
              style: UnifiedTheme.bodyStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${group.memberCount}/${group.maxMembers} members',
                  style: UnifiedTheme.captionStyle,
                ),
                
                const Spacer(),
                
                if (isMember)
                  TextButton(
                    onPressed: () => _leaveGroup(group),
                    child: const Text('Leave'),
                  )
                else if (!group.isFull)
                  ElevatedButton(
                    onPressed: () => _joinGroup(group),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UnifiedTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Join'),
                  )
                else
                  const Chip(
                    label: Text('Full'),
                    backgroundColor: Colors.grey,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDiscoverState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Discover Study Groups',
              style: UnifiedTheme.headingStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Join study groups to collaborate with fellow professionals and enhance your learning.',
              style: UnifiedTheme.bodyStyle.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMyGroupsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Groups Yet',
              style: UnifiedTheme.headingStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Join or create your first study group to start collaborating with others.',
              style: UnifiedTheme.bodyStyle.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('Discover Groups'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGroupTypeColor(StudyGroupType type) {
    switch (type) {
      case StudyGroupType.public:
        return Colors.green;
      case StudyGroupType.private:
        return Colors.orange;
      case StudyGroupType.premium:
        return Colors.purple;
    }
  }

  IconData _getGroupTypeIcon(StudyGroupType type) {
    switch (type) {
      case StudyGroupType.public:
        return Icons.public;
      case StudyGroupType.private:
        return Icons.lock;
      case StudyGroupType.premium:
        return Icons.star;
    }
  }

  void _joinGroup(StudyGroupModel group) async {
    try {
      final provider = context.read<SocialProvider>();
      await provider.joinStudyGroup(group.id, widget.user.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined "${group.name}" successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join group: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _leaveGroup(StudyGroupModel group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = context.read<SocialProvider>();
        await provider.leaveStudyGroup(group.id, widget.user.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Left "${group.name}"'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to leave group: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateGroupDialog(user: widget.user),
    );
  }
}

class _CreateGroupDialog extends StatefulWidget {
  final UserModel user;

  const _CreateGroupDialog({required this.user});

  @override
  State<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Anatomy';
  StudyGroupType _selectedType = StudyGroupType.public;
  int _maxMembers = 50;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Study Group'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Anatomy', 'Physiology', 'Pathology', 'Pharmacology', 'Surgery']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StudyGroupType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Group Type'),
              items: StudyGroupType.values
                  .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createGroup,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  void _createGroup() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<SocialProvider>();
      await provider.createStudyGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        targetRole: widget.user.userRole,
        createdBy: widget.user.id,
        type: _selectedType,
        maxMembers: _maxMembers,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Study group created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create group: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}