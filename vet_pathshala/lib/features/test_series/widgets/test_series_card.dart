import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/widgets/enhanced_card_widget.dart';
import '../models/test_series_model.dart';

class TestSeriesCard extends StatelessWidget {
  final TestSeries testSeries;
  final VoidCallback onTap;

  const TestSeriesCard({
    super.key,
    required this.testSeries,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isActive = testSeries.isActive && 
                    now.isAfter(testSeries.startDate) && 
                    now.isBefore(testSeries.endDate);
    final isUpcoming = now.isBefore(testSeries.startDate);
    
    return EnhancedCardWidget(
      title: testSeries.title,
      subtitle: testSeries.batchYear.isNotEmpty ? 'Batch: ${testSeries.batchYear}' : null,
      description: testSeries.description,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              UnifiedTheme.primaryGreen,
              UnifiedTheme.primaryGreen.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: UnifiedTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.quiz_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
      chips: [
        EnhancedChip(
          icon: Icons.quiz,
          label: '${testSeries.availableTestsCount}/${testSeries.scheduledTests.length} Tests',
          color: UnifiedTheme.primaryGreen,
        ),
        EnhancedChip(
          icon: Icons.access_time,
          label: '${testSeries.duration}m',
          color: UnifiedTheme.goldAccent,
        ),
        if (testSeries.nextTest != null)
          EnhancedChip(
            icon: Icons.schedule,
            label: testSeries.nextTest!.statusText,
            color: UnifiedTheme.blueAccent,
          ),
        // Status indicator
        if (isActive)
          StatusIndicator(
            status: 'LIVE',
            color: Colors.green,
          )
        else if (isUpcoming)
          StatusIndicator(
            status: 'UPCOMING',
            color: Colors.orange,
          )
        else
          StatusIndicator(
            status: 'ENDED',
            color: Colors.grey,
          ),
      ],
      isPremium: testSeries.requiresSubscription,
      premiumLabel: testSeries.requiresSubscription ? 'PREMIUM' : null,
      accentColor: UnifiedTheme.primaryGreen,
      onTap: onTap,
    );
  }

}