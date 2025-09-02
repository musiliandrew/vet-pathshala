import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../providers/pyp_provider.dart';
import '../../../shared/models/test_series_models.dart';
import 'pyp_paper_detail_screen.dart';

class PYPMainScreen extends StatefulWidget {
  const PYPMainScreen({super.key});

  @override
  State<PYPMainScreen> createState() => _PYPMainScreenState();
}

class _PYPMainScreenState extends State<PYPMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize PYP provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PYPProvider>().initialize();
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
        title: const Text('Previous Year Papers'),
        backgroundColor: UnifiedTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.calendar_today), text: 'By Year'),
            Tab(icon: Icon(Icons.star), text: 'Popular'),
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
                _buildCategoriesTab(),
                _buildYearTab(),
                _buildPopularTab(),
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
          hintText: 'Search papers by title, subject, or topic...',
          prefixIcon: const Icon(Icons.search, color: UnifiedTheme.secondaryText),
          suffixIcon: Consumer<PYPProvider>(
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
          context.read<PYPProvider>().setSearchQuery(query);
        },
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<PYPProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.categories.length,
          itemBuilder: (context, index) {
            final category = provider.categories[index];
            return _buildCategoryCard(category);
          },
        );
      },
    );
  }

  Widget _buildCategoryCard(dynamic category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [UnifiedTheme.primaryGreen, UnifiedTheme.primaryGreen.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              category.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text('${category.totalPapers} papers available'),
        children: category.subjects.map((subject) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: const Icon(Icons.book, color: UnifiedTheme.primaryGreen),
            title: Text(subject.name),
            subtitle: Text('${subject.totalPapers} papers • ${subject.topics.length} topics'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.read<PYPProvider>().setSubject(subject.name);
              _showPapersList(subject.name);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildYearTab() {
    return Consumer<PYPProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final years = provider.availableYears;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: years.length,
          itemBuilder: (context, index) {
            final year = years[index];
            final yearPapers = provider.getPapersByYear(year);
            
            return _buildYearCard(year, yearPapers);
          },
        );
      },
    );
  }

  Widget _buildYearCard(int year, List<PYPModel> papers) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [UnifiedTheme.blueAccent, UnifiedTheme.blueAccent.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              year.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          'Year $year',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text('${papers.length} papers available'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.read<PYPProvider>().setYear(year);
          _showPapersList('$year Papers');
        },
      ),
    );
  }

  Widget _buildPopularTab() {
    return Consumer<PYPProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Sort papers by downloads and rating
        final popularPapers = [...provider.papers];
        popularPapers.sort((a, b) {
          // Sort by year (newer first) and total marks (higher first)
          final aScore = a.year * 100 + a.totalMarks;
          final bScore = b.year * 100 + b.totalMarks;
          return bScore.compareTo(aScore);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: popularPapers.take(20).length, // Show top 20
          itemBuilder: (context, index) {
            final paper = popularPapers[index];
            return _buildPaperCard(paper, showRank: index + 1);
          },
        );
      },
    );
  }

  Widget _buildPaperCard(PYPModel paper, {int? showRank}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: showRank != null
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: showRank <= 3 ? UnifiedTheme.goldAccent : UnifiedTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  showRank.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description,
                color: UnifiedTheme.primaryGreen,
              ),
            ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                paper.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: UnifiedTheme.goldAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                paper.examType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${paper.category} • ${paper.year}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber[600]),
                const SizedBox(width: 4),
                Text('4.5'), // Mock rating
                const SizedBox(width: 12),
                const Icon(Icons.download, size: 16, color: UnifiedTheme.secondaryText),
                const SizedBox(width: 4),
                Text('${paper.totalQuestions * 10}'), // Mock downloads
                const SizedBox(width: 12),
                Text('${paper.totalQuestions} Q • ${paper.duration}min'),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PYPPaperDetailScreen(paper: paper),
            ),
          );
        },
      ),
    );
  }

  void _showPapersList(String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<PYPProvider>(
        builder: (context, provider, child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                // Papers list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.filteredPapers.length,
                    itemBuilder: (context, index) {
                      final paper = provider.filteredPapers[index];
                      return _buildPaperCard(paper);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<PYPProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: const Text('Filter Papers'),
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
                    children: ['year', 'rating', 'downloads', 'title'].map((option) {
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
                  
                  // Year filter
                  const Text('Year:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [0, ...provider.availableYears.take(5)].map((year) {
                      final isSelected = provider.selectedYear == year;
                      return FilterChip(
                        label: Text(year == 0 ? 'All Years' : year.toString()),
                        selected: isSelected,
                        onSelected: (selected) {
                          provider.setYear(selected ? year : 0);
                        },
                        selectedColor: UnifiedTheme.blueAccent.withOpacity(0.2),
                        checkmarkColor: UnifiedTheme.blueAccent,
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
}