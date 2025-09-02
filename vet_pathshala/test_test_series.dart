import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/core/theme/unified_theme.dart';
import 'lib/features/test_series/providers/test_series_provider.dart';
import 'lib/features/pyp/providers/pyp_provider.dart';
import 'lib/shared/models/test_series_models.dart';
import 'lib/features/test_series/widgets/victory_modal.dart';

void main() {
  runApp(const TestSeriesTestApp());
}

class TestSeriesTestApp extends StatelessWidget {
  const TestSeriesTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TestSeriesProvider()),
        ChangeNotifierProvider(create: (_) => PYPProvider()),
      ],
      child: MaterialApp(
        title: 'Test Series & PYP Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const TestSeriesTestHome(),
      ),
    );
  }
}

class TestSeriesTestHome extends StatelessWidget {
  const TestSeriesTestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Test Series & PYP System Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: UnifiedTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Test Series Demo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UnifiedTheme.primaryGreen,
                    UnifiedTheme.primaryGreen.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: UnifiedTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.quiz_outlined,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Test Series System',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Live, Upcoming & Scheduled Tests',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showTestSeriesDemo(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: UnifiedTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Demo Test Series',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // PYP Demo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UnifiedTheme.goldAccent,
                    UnifiedTheme.goldAccent.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: UnifiedTheme.goldAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.history_edu,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Previous Year Papers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Year-wise Question Papers',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showPYPDemo(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: UnifiedTheme.goldAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Demo PYP System',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Victory Modal Demo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple,
                    Colors.purple.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Victory Modal System',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Test Completion with Rewards',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showVictoryDemo(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Demo Victory Modal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTestSeriesDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎯 Test Series System'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Test Series Cards with Status'),
            Text('✅ Live/Upcoming/Ended Indicators'),
            Text('✅ Scheduling Logic (3 months ahead)'),
            Text('✅ Role-based Content Filtering'),
            Text('✅ Test Taking Screen with Timer'),
            Text('✅ Question Navigation & Progress'),
            Text('✅ Victory Modal Integration'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPYPDemo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📚 PYP System'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Year-based Paper Selection'),
            Text('✅ Category & Subject Organization'),
            Text('✅ Paper Details with Metadata'),
            Text('✅ Topics, Marks, Duration Display'),
            Text('✅ Professional Card Designs'),
            Text('✅ Filter & Search Functionality'),
            Text('✅ Download & Practice Options'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVictoryDemo(BuildContext context) {
    // Create mock result data
    final mockResult = TestResultModel(
      attemptId: 'demo_attempt_001',
      finalScore: 85,
      totalMarks: 100,
      percentage: 85.0,
      rank: 2,
      totalParticipants: 50,
      timeSpent: 1800, // 30 minutes
      categoryWiseScores: {
        'Easy': 25,
        'Medium': 15,
        'Hard': 5,
      },
      xpEarned: 80,
      coinsEarned: 8,
      isPassed: true,
      topRankers: [],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryModal(
        result: mockResult,
        onContinue: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Victory Modal Demo Complete!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}