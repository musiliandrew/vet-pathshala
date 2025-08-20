import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/test_series_model.dart';
import '../providers/test_series_provider.dart';
import '../../coins/providers/coin_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'test_taking_screen.dart';

class TestSeriesDetailScreen extends StatefulWidget {
  final TestSeries testSeries;

  const TestSeriesDetailScreen({super.key, required this.testSeries});

  @override
  State<TestSeriesDetailScreen> createState() => _TestSeriesDetailScreenState();
}

class _TestSeriesDetailScreenState extends State<TestSeriesDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<TestSeriesProvider>().loadUserAttempts(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _getCategoryColor(widget.testSeries.category),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.testSeries.category.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(widget.testSeries.category),
                      _getCategoryColor(widget.testSeries.category).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    
                    // Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCategoryIcon(widget.testSeries.category),
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.testSeries.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and premium badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.testSeries.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: UnifiedTheme.primaryText,
                          ),
                        ),
                      ),
                      if (widget.testSeries.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [UnifiedTheme.goldAccent, UnifiedTheme.goldAccent.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.diamond, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.testSeries.coinCost} Coins',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats cards
                  _buildStatsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  _buildDescriptionCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Test details
                  _buildDetailsCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Topics covered
                  _buildTopicsCard(),
                  
                  const SizedBox(height: 16),
                  
                  // User progress
                  _buildProgressCard(),
                  
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildStartTestFAB(),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        _buildStatCard(
          Icons.quiz,
          '${widget.testSeries.totalQuestions}',
          'Questions',
          UnifiedTheme.blueAccent,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          Icons.timer,
          '${widget.testSeries.duration}',
          'Minutes',
          UnifiedTheme.goldAccent,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          Icons.grade,
          '${widget.testSeries.maxMarks}',
          'Marks',
          UnifiedTheme.primaryGreen,
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: UnifiedTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UnifiedTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.testSeries.description,
            style: const TextStyle(
              color: UnifiedTheme.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Test Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UnifiedTheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Subject', widget.testSeries.subject, Icons.book),
          _buildDetailRow('Difficulty', _formatDifficulty(widget.testSeries.difficulty), Icons.trending_up),
          _buildDetailRow('Category', _formatCategory(widget.testSeries.category), Icons.category),
          _buildDetailRow('Average Score', '${widget.testSeries.averageScore.toStringAsFixed(1)}%', Icons.bar_chart),
          _buildDetailRow('Total Attempts', widget.testSeries.attempts.toString(), Icons.people),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: UnifiedTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: UnifiedTheme.secondaryText,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: UnifiedTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Topics Covered',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UnifiedTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.testSeries.topics.map((topic) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    color: UnifiedTheme.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Consumer<TestSeriesProvider>(
      builder: (context, provider, child) {
        final userAttempts = provider.getUserAttemptCount(widget.testSeries.id);
        final bestScore = provider.getUserBestScore(widget.testSeries.id);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UnifiedTheme.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              
              if (userAttempts == 0)
                const Text(
                  'You haven\'t taken this test yet. Start now to track your progress!',
                  style: TextStyle(
                    color: UnifiedTheme.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attempts',
                            style: TextStyle(
                              color: UnifiedTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            userAttempts.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: UnifiedTheme.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Best Score',
                            style: TextStyle(
                              color: UnifiedTheme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${bestScore.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: bestScore >= 70 ? Colors.green : bestScore >= 50 ? Colors.orange : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: bestScore / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    bestScore >= 70 ? Colors.green : bestScore >= 50 ? Colors.orange : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStartTestFAB() {
    return Consumer3<TestSeriesProvider, CoinProvider, AuthProvider>(
      builder: (context, testProvider, coinProvider, authProvider, child) {
        final canStartTest = !widget.testSeries.isPremium || 
            coinProvider.currentBalance >= widget.testSeries.coinCost;
        
        return FloatingActionButton.extended(
          onPressed: canStartTest ? _startTest : _showInsufficientCoinsDialog,
          backgroundColor: canStartTest ? UnifiedTheme.primaryGreen : Colors.grey,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.play_arrow),
          label: Text(
            widget.testSeries.isPremium && widget.testSeries.coinCost > 0
              ? 'Start Test (${widget.testSeries.coinCost} 🪙)'
              : 'Start Test'
          ),
        );
      },
    );
  }

  Future<void> _startTest() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start the test')),
      );
      return;
    }

    // Show test instructions dialog
    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Instructions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: ${widget.testSeries.duration} minutes'),
            Text('Questions: ${widget.testSeries.totalQuestions}'),
            Text('Total Marks: ${widget.testSeries.maxMarks}'),
            const SizedBox(height: 16),
            const Text(
              'Instructions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('• Answer all questions within the time limit'),
            const Text('• You can navigate between questions'),
            const Text('• Submit the test before time runs out'),
            const Text('• Once submitted, you cannot change answers'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Test'),
          ),
        ],
      ),
    );

    if (shouldStart == true) {
      final success = await context.read<TestSeriesProvider>().startTest(
        widget.testSeries.id,
        user.id,
      );

      if (success && mounted) {
        // Deduct coins if premium
        if (widget.testSeries.isPremium) {
          context.read<CoinProvider>().deductCoins(
            widget.testSeries.coinCost,
            'Test Series: ${widget.testSeries.title}',
          );
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestTakingScreen(testSeries: widget.testSeries),
          ),
        );
      }
    }
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Coins'),
        content: Text(
          'You need ${widget.testSeries.coinCost} coins to start this test. '
          'You currently have ${context.read<CoinProvider>().currentBalance} coins.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to coin store
              // TODO: Implement navigation to coin store
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.goldAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buy Coins'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'practice':
        return UnifiedTheme.blueAccent;
      case 'mock':
        return UnifiedTheme.primaryGreen;
      case 'competitive':
        return UnifiedTheme.goldAccent;
      default:
        return UnifiedTheme.primaryGreen;
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

  String _formatDifficulty(String difficulty) {
    return '${difficulty[0].toUpperCase()}${difficulty.substring(1)}';
  }

  String _formatCategory(String category) {
    return '${category[0].toUpperCase()}${category.substring(1)}';
  }
}