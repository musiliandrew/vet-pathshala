import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/admin_stats_card.dart';
import '../widgets/recent_activity_widget.dart';
import '../widgets/quick_actions_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  
  final List<Map<String, dynamic>> _navigationItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/admin'},
    {'icon': Icons.people, 'label': 'Users', 'route': '/admin/users'},
    {'icon': Icons.quiz, 'label': 'Questions', 'route': '/admin/questions'},
    {'icon': Icons.note, 'label': 'Notes', 'route': '/admin/notes'},
    {'icon': Icons.video_library, 'label': 'Lectures', 'route': '/admin/lectures'},
    {'icon': Icons.flag, 'label': 'Reports', 'route': '/admin/reports'},
    {'icon': Icons.analytics, 'label': 'Analytics', 'route': '/admin/analytics'},
    {'icon': Icons.settings, 'label': 'Settings', 'route': '/admin/settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Logo/Title
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = _selectedIndex == index;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: ListTile(
                    leading: Icon(
                      item['icon'],
                      color: isSelected 
                          ? UnifiedTheme.primaryGreen 
                          : Colors.grey.shade600,
                    ),
                    title: Text(
                      item['label'],
                      style: TextStyle(
                        color: isSelected 
                            ? UnifiedTheme.primaryGreen 
                            : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: UnifiedTheme.primaryGreen.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // User Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.currentUser;
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: UnifiedTheme.primaryGreen.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: UnifiedTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user?.displayName ?? 'Admin User',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Administrator',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Logout functionality
                        authProvider.signOut();
                      },
                      icon: Icon(
                        Icons.logout,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            _navigationItems[_selectedIndex]['label'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          
          // Search Bar
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Notifications
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey.shade700,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildDashboardContent();
      case 1: // Users
        return _buildPlaceholderContent('Users Management', Icons.people);
      case 2: // Questions
        return _buildPlaceholderContent('Questions Management', Icons.quiz);
      case 3: // Notes
        return _buildPlaceholderContent('Notes Management', Icons.note);
      case 4: // Lectures
        return _buildPlaceholderContent('Lectures Management', Icons.video_library);
      case 5: // Reports
        return _buildPlaceholderContent('Reports & Moderation', Icons.flag);
      case 6: // Analytics
        return _buildPlaceholderContent('Analytics & Insights', Icons.analytics);
      case 7: // Settings
        return _buildPlaceholderContent('System Settings', Icons.settings);
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: AdminStatsCard(
                  title: 'Total Users',
                  value: '1,234',
                  subtitle: '+12% this month',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AdminStatsCard(
                  title: 'Questions',
                  value: '15,678',
                  subtitle: '+5 added today',
                  icon: Icons.quiz,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AdminStatsCard(
                  title: 'Notes',
                  value: '890',
                  subtitle: '+2 pending review',
                  icon: Icons.note,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AdminStatsCard(
                  title: 'Reports',
                  value: '23',
                  subtitle: '5 unresolved',
                  icon: Icons.flag,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions
              Expanded(
                flex: 1,
                child: QuickActionsWidget(),
              ),
              
              const SizedBox(width: 16),
              
              // Recent Activity
              Expanded(
                flex: 2,
                child: RecentActivityWidget(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderContent(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This section is under development',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title coming soon!'),
                  backgroundColor: UnifiedTheme.primaryGreen,
                ),
              );
            },
            icon: const Icon(Icons.construction),
            label: const Text('Coming Soon'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}