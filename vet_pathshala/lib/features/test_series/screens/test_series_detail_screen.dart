import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/test_series_model.dart';
import '../providers/test_series_provider.dart';
import '../../coins/providers/coin_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../payments/services/payment_service.dart';
import '../../payments/screens/subscription_plans_screen.dart';
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
                  // Title and premium badge with schedule download
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          if (widget.testSeries.requiresSubscription)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [UnifiedTheme.goldAccent, UnifiedTheme.goldAccent.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Premium Only',
                                    style: TextStyle(
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
                      
                      // Batch year and schedule download button
                      if (widget.testSeries.batchYear.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Batch: ${widget.testSeries.batchYear}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: UnifiedTheme.secondaryText,
                                ),
                              ),
                            ),
                            if (widget.testSeries.scheduleDocumentUrl.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: _downloadSchedule,
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text('Test Schedule'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: UnifiedTheme.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
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
                  
                  // Scheduled Tests (if available)
                  if (widget.testSeries.scheduledTests.isNotEmpty)
                    _buildScheduledTestsCard(),
                  
                  if (widget.testSeries.scheduledTests.isNotEmpty)
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

  Widget _buildScheduledTestsCard() {
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
          Row(
            children: [
              const Text(
                'Scheduled Tests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UnifiedTheme.primaryText,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.testSeries.releaseSchedule.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    color: UnifiedTheme.primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Available Tests
          if (widget.testSeries.availableTests.isNotEmpty) ...[
            Text(
              'Available Now (${widget.testSeries.availableTestsCount})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.testSeries.availableTests.take(3).map((test) => 
              _buildScheduledTestItem(test, true)),
            if (widget.testSeries.availableTestsCount > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${widget.testSeries.availableTestsCount - 3} more available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
          
          // Upcoming Tests
          if (widget.testSeries.upcomingTests.isNotEmpty) ...[
            if (widget.testSeries.availableTests.isNotEmpty) const SizedBox(height: 16),
            Text(
              'Coming Soon (${widget.testSeries.upcomingTestsCount})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.testSeries.upcomingTests.take(3).map((test) => 
              _buildScheduledTestItem(test, false)),
            if (widget.testSeries.upcomingTestsCount > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${widget.testSeries.upcomingTestsCount - 3} more upcoming',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
          
          // Next Test Countdown
          if (widget.testSeries.nextTest != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [UnifiedTheme.blueAccent.withOpacity(0.1), UnifiedTheme.primaryGreen.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: UnifiedTheme.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: UnifiedTheme.blueAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next Test',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: UnifiedTheme.secondaryText,
                          ),
                        ),
                        Text(
                          widget.testSeries.nextTest!.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: UnifiedTheme.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: UnifiedTheme.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.testSeries.nextTest!.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduledTestItem(ScheduledTest test, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                test.sequenceNumber.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: UnifiedTheme.primaryText,
                  ),
                ),
                Text(
                  '${test.duration}min • ${test.maxMarks} marks',
                  style: const TextStyle(
                    fontSize: 12,
                    color: UnifiedTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              test.statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartTestFAB() {
    return Consumer3<TestSeriesProvider, PaymentService, AuthProvider>(
      builder: (context, testProvider, paymentService, authProvider, child) {
        return FutureBuilder<bool>(
          future: widget.testSeries.requiresSubscription && authProvider.currentUser != null
              ? Future.wait(
                  widget.testSeries.featureIds.map((featureId) =>
                    paymentService.hasActiveSubscription(
                      authProvider.currentUser!.id, 
                      'test_series', 
                      featureId: featureId
                    )
                  )
                ).then((results) => results.any((result) => result))
              : Future.value(!widget.testSeries.requiresSubscription),
          builder: (context, snapshot) {
            final hasActiveSubscription = snapshot.data ?? false;
            final canStartTest = !widget.testSeries.requiresSubscription || hasActiveSubscription;
        
        return FloatingActionButton.extended(
          onPressed: canStartTest ? _startTest : _showSubscriptionRequiredDialog,
          backgroundColor: canStartTest ? UnifiedTheme.primaryGreen : Colors.grey,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.play_arrow),
          label: Text(
            widget.testSeries.requiresSubscription && !canStartTest
              ? 'Subscribe to Access'
              : widget.testSeries.availableTestsCount > 0
                ? 'Start Available Test'
                : 'Start Test'
          ),
        );
          },
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

  Future<void> _downloadSchedule() async {
    try {
      if (widget.testSeries.scheduleDocumentUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule document not available')),
        );
        return;
      }

      // Show options for download or share
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Test Series Schedule'),
          content: const Text('How would you like to access the test schedule?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'download'),
              child: const Text('Download'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'share'),
              child: const Text('Share'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (result == 'download') {
        final uri = Uri.parse(widget.testSeries.scheduleDocumentUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else if (result == 'share') {
        await Share.share(
          'Test Series Schedule for ${widget.testSeries.title}\\n'
          'Batch: ${widget.testSeries.batchYear}\\n'
          'Schedule: ${widget.testSeries.scheduleDocumentUrl}',
          subject: 'Test Series Schedule - ${widget.testSeries.title}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing schedule: $e')),
      );
    }
  }

  void _showSubscriptionRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This test series requires an active subscription to access.'),
            const SizedBox(height: 16),
            const Text('Features included:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.testSeries.featureIds.map((feature) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(feature.replaceAll('_', ' ').toUpperCase()),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription plans
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPlansScreen(category: 'test_series'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPlansScreen(),
                ),
              );
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