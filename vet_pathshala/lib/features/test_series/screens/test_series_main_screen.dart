import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../providers/test_series_provider.dart';
import '../models/test_series_model.dart';
import 'test_series_detail_screen.dart';

class TestSeriesMainScreen extends StatefulWidget {
  const TestSeriesMainScreen({super.key});

  @override
  State<TestSeriesMainScreen> createState() => _TestSeriesMainScreenState();
}

class _TestSeriesMainScreenState extends State<TestSeriesMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestSeriesProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Test Series'),
        backgroundColor: UnifiedTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.quiz), text: 'All Tests'),
            Tab(icon: Icon(Icons.psychology), text: 'Practice'),
            Tab(icon: Icon(Icons.assignment), text: 'Mock Tests'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Competitive'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTestsTab(),
                _buildCategoryTab('practice'),
                _buildCategoryTab('mock'),
                _buildCategoryTab('competitive'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search test series...',
          prefixIcon: const Icon(Icons.search, color: UnifiedTheme.secondaryText),
          suffixIcon: Consumer<TestSeriesProvider>(
            builder: (context, provider, child) {
              return provider.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      provider.setSearchQuery('');
                    },
                  )
                : const SizedBox.shrink();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: UnifiedTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: UnifiedTheme.primaryGreen, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (query) {
          context.read<TestSeriesProvider>().setSearchQuery(query);
        },
      ),
    );
  }

  Widget _buildAllTestsTab() {
    return Consumer<TestSeriesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _buildErrorWidget(provider);
        }

        return _buildTestGrid(provider.filteredTestSeries);
      },
    );
  }

  Widget _buildCategoryTab(String category) {
    return Consumer<TestSeriesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _buildErrorWidget(provider);
        }

        final categoryTests = provider.getTestSeriesByCategory(category);
        
        if (categoryTests.isEmpty) {
          return _buildEmptyState(category);
        }

        return _buildTestGrid(categoryTests);
      },
    );
  }

  Widget _buildTestGrid(List<TestSeries> tests) {
    if (tests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tests found',
              style: TextStyle(
                fontSize: 18,
                color: UnifiedTheme.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return _buildTestCard(test);
      },
    );
  }

  Widget _buildTestCard(TestSeries test) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestSeriesDetailScreen(testSeries: test),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: test.isPremium 
            ? Border.all(color: UnifiedTheme.goldAccent, width: 2)
            : Border.all(color: UnifiedTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getCategoryColors(test.category),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          test.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (test.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: UnifiedTheme.goldAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${test.coinCost} 🪙',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    test.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.subject,
                      style: TextStyle(
                        color: UnifiedTheme.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      test.description,
                      style: const TextStyle(
                        color: UnifiedTheme.secondaryText,
                        fontSize: 11,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    
                    // Stats
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.quiz,
                          '${test.totalQuestions}Q',
                          UnifiedTheme.blueAccent,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          Icons.timer,
                          '${test.duration}m',
                          UnifiedTheme.goldAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          test.averageScore.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.people,
                          size: 14,
                          color: UnifiedTheme.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${test.attempts}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(TestSeriesProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(provider.error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.initialize(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${category} tests available',
            style: const TextStyle(
              fontSize: 18,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new tests',
            style: TextStyle(
              color: UnifiedTheme.secondaryText.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<TestSeriesProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: const Text('Filter Tests'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort by
                  const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['created', 'popularity', 'difficulty', 'score'].map((option) {
                      final isSelected = provider.sortBy == option;
                      return FilterChip(
                        label: Text(option.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) provider.setSortBy(option);
                        },
                        selectedColor: UnifiedTheme.primaryGreen.withOpacity(0.2),
                        checkmarkColor: UnifiedTheme.primaryGreen,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Difficulty filter
                  const Text('Difficulty:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['', 'easy', 'medium', 'hard'].map((difficulty) {
                      final isSelected = provider.selectedDifficulty == difficulty;
                      return FilterChip(
                        label: Text(difficulty.isEmpty ? 'All' : difficulty.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          provider.setDifficulty(selected ? difficulty : '');
                        },
                        selectedColor: UnifiedTheme.goldAccent.withOpacity(0.2),
                        checkmarkColor: UnifiedTheme.goldAccent,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  provider.clearFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UnifiedTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Color> _getCategoryColors(String category) {
    switch (category) {
      case 'practice':
        return [UnifiedTheme.blueAccent, UnifiedTheme.blueAccent.withOpacity(0.8)];
      case 'mock':
        return [UnifiedTheme.primaryGreen, UnifiedTheme.primaryGreen.withOpacity(0.8)];
      case 'competitive':
        return [UnifiedTheme.goldAccent, UnifiedTheme.goldAccent.withOpacity(0.8)];
      default:
        return [UnifiedTheme.primaryGreen, UnifiedTheme.primaryGreen.withOpacity(0.8)];
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'practice':
        return Icons.psychology;
      case 'mock':
        return Icons.assignment;
      case 'competitive':
        return Icons.emoji_events;
      default:
        return Icons.quiz;
    }
  }
}