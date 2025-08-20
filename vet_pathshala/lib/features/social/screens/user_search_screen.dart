import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/social_provider.dart';
import '../widgets/user_card_widget.dart';
import 'user_profile_screen.dart';

class UserSearchScreen extends StatefulWidget {
  final UserModel user;

  const UserSearchScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Find People',
          style: UnifiedTheme.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: UnifiedTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SocialProvider>().clearSearchResults();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.length >= 2) {
                      _debounceSearch(value);
                    } else {
                      context.read<SocialProvider>().clearSearchResults();
                    }
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Role filter
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedRole == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = null;
                        });
                        _performSearch();
                      },
                    ),
                    FilterChip(
                      label: const Text('Doctors'),
                      selected: _selectedRole == 'doctor',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = selected ? 'doctor' : null;
                        });
                        _performSearch();
                      },
                    ),
                    FilterChip(
                      label: const Text('Pharmacists'),
                      selected: _selectedRole == 'pharmacist',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = selected ? 'pharmacist' : null;
                        });
                        _performSearch();
                      },
                    ),
                    FilterChip(
                      label: const Text('Farmers'),
                      selected: _selectedRole == 'farmer',
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = selected ? 'farmer' : null;
                        });
                        _performSearch();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Search results
          Expanded(
            child: Consumer<SocialProvider>(
              builder: (context, provider, child) {
                if (_isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.searchUsers.isEmpty && _searchController.text.length >= 2) {
                  return _buildNoResultsState();
                }

                if (provider.searchUsers.isEmpty) {
                  return _buildInitialState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.searchUsers.length,
                  itemBuilder: (context, index) {
                    final user = provider.searchUsers[index];
                    return UserCardWidget(
                      user: user,
                      currentUser: widget.user,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            user: user,
                            currentUser: widget.user,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Find Fellow Professionals',
              style: UnifiedTheme.headingStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Search for veterinarians, pharmacists, and farmers to connect with and learn from.',
              style: UnifiedTheme.bodyStyle.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Popular searches or suggestions
            Container(
              padding: const EdgeInsets.all(16),
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
                    'Quick Search',
                    style: UnifiedTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSuggestionChip('Veterinarians near me'),
                      _buildSuggestionChip('Animal nutrition experts'),
                      _buildSuggestionChip('Surgery specialists'),
                      _buildSuggestionChip('Farm management advisors'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(suggestion),
      onPressed: () {
        _searchController.text = suggestion;
        _performSearch();
      },
      backgroundColor: UnifiedTheme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: UnifiedTheme.primaryColor),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'No Users Found',
              style: UnifiedTheme.headingStyle.copyWith(fontSize: 20),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Try adjusting your search terms or filters.',
              style: UnifiedTheme.bodyStyle.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedRole = null;
                });
                context.read<SocialProvider>().clearSearchResults();
              },
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  Timer? _debounceTimer;

  void _debounceSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.length < 2) return;

    setState(() {
      _isSearching = true;
    });

    try {
      await context.read<SocialProvider>().searchUsers(
        query,
        role: _selectedRole,
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }
}

