import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../providers/test_series_provider.dart';
import '../../../features/pyp/providers/pyp_provider.dart';
import '../../../shared/models/test_series_models.dart';
import '../../../features/pyp/models/pyp_model.dart';
import '../widgets/test_series_card.dart';
import '../widgets/pyp_card.dart';
import 'test_series_detail_screen.dart';
import 'pyp_year_selection_screen.dart';

class TestSeriesPYPMainScreen extends StatefulWidget {
  const TestSeriesPYPMainScreen({super.key});

  @override
  State<TestSeriesPYPMainScreen> createState() => _TestSeriesPYPMainScreenState();
}

class _TestSeriesPYPMainScreenState extends State<TestSeriesPYPMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Get user role from auth provider
      final userRole = 'doctor'; // This should come from AuthProvider
      
      await Future.wait([
        context.read<TestSeriesProvider>().loadTestSeries(userRole),
        context.read<PYPProvider>().loadPYPs(userRole),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Test Series & PYP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: UnifiedTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.quiz_outlined),
              text: 'Test Series',
            ),
            Tab(
              icon: Icon(Icons.history_edu),
              text: 'Previous Year Papers',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTestSeriesTab(),
                _buildPYPTab(),
              ],
            ),
    );
  }

  Widget _buildTestSeriesTab() {
    return Consumer<TestSeriesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.testSeries.isEmpty) {
          return _buildEmptyState(
            icon: Icons.quiz,
            title: 'No Test Series Available',
            subtitle: 'Check back later for new test series',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadTestSeries('doctor'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildSectionHeader(
                  'Running Test Series',
                  'Choose from available test series below',
                ),
                
                const SizedBox(height: 16),
                
                // Test Series Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 3.5,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: provider.testSeries.length,
                    itemBuilder: (context, index) {
                      final series = provider.testSeries[index];
                      return TestSeriesCard(
                        testSeries: series,
                        onTap: () => _navigateToTestSeriesDetail(series),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPYPTab() {
    return Consumer<PYPProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.availableYears.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history_edu,
            title: 'No Previous Year Papers',
            subtitle: 'PYP will be available soon',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadPYPs('doctor'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildSectionHeader(
                  'Previous Year Papers',
                  'Select year to view question papers',
                ),
                
                const SizedBox(height: 16),
                
                // Years Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: provider.availableYears.length,
                    itemBuilder: (context, index) {
                      final year = provider.availableYears[index];
                      final pypCount = provider.getPYPCountForYear(year);
                      
                      return PYPCard(
                        year: year,
                        pypCount: pypCount,
                        onTap: () => _navigateToPYPYear(year),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: UnifiedTheme.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: UnifiedTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 50,
              color: UnifiedTheme.primary.withOpacity(0.5),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: UnifiedTheme.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTestSeriesDetail(TestSeries testSeries) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestSeriesDetailScreen(
          testSeries: testSeries,
        ),
      ),
    );
  }

  void _navigateToPYPYear(int year) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PYPYearSelectionScreen(
          year: year,
        ),
      ),
    );
  }
}