import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/test_series_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../payments/services/payment_service.dart';
import '../../payments/screens/subscription_plans_screen.dart';

class PYPPaperDetailScreen extends StatelessWidget {
  final PYPModel paper;

  const PYPPaperDetailScreen({super.key, required this.paper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Paper Details',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: UnifiedTheme.goldAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Paper Header
            _buildPaperHeader(),
            
            const SizedBox(height: 24),
            
            // Paper Details
            _buildPaperDetails(),
            
            const SizedBox(height: 24),
            
            // Topics Section
            _buildTopicsSection(),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            UnifiedTheme.goldAccent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: UnifiedTheme.goldAccent.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      UnifiedTheme.goldAccent,
                      UnifiedTheme.goldAccent.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${paper.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paper.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: UnifiedTheme.primaryText,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      paper.category,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaperDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paper Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: UnifiedTheme.primaryText,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildDetailRow('Exam Type', paper.examType, Icons.school),
            _buildDetailRow('Total Questions', '${paper.totalQuestions}', Icons.quiz),
            _buildDetailRow('Total Marks', '${paper.totalMarks}', Icons.grade),
            _buildDetailRow('Duration', '${paper.duration} minutes', Icons.access_time),
            _buildDetailRow('Target Role', _formatTargetRole(paper.targetRole), Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: UnifiedTheme.goldAccent,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: UnifiedTheme.primaryText,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsSection() {
    final topics = paper.metadata['topics'] as List<dynamic>? ?? [];
    
    if (topics.isEmpty) return const SizedBox();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topics.map<Widget>((topic) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: UnifiedTheme.goldAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: UnifiedTheme.goldAccent.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  topic.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: UnifiedTheme.goldAccent.withOpacity(0.8),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer2<AuthProvider, PaymentService>(
      builder: (context, authProvider, paymentService, child) {
        return FutureBuilder<bool>(
          future: authProvider.currentUser != null 
              ? paymentService.hasActiveSubscription(
                  authProvider.currentUser!.id,
                  'pyp',
                  featureId: 'previous_year_papers',
                )
              : Future.value(false),
          builder: (context, snapshot) {
            final hasActiveSubscription = snapshot.data ?? false;

        return Column(
          children: [
            // Premium access notice if no subscription
            if (!hasActiveSubscription) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [UnifiedTheme.goldAccent.withOpacity(0.1), UnifiedTheme.goldAccent.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: UnifiedTheme.goldAccent.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: UnifiedTheme.goldAccent,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Premium Feature',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: UnifiedTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Subscribe to access PYP practice sessions and downloads',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasActiveSubscription ? _startPractice : () => _showSubscriptionDialog(context),
                icon: Icon(hasActiveSubscription ? Icons.play_arrow : Icons.lock),
                label: Text(hasActiveSubscription ? 'Start Practice' : 'Subscribe to Practice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasActiveSubscription ? UnifiedTheme.goldAccent : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: hasActiveSubscription ? _downloadPaper : () => _showSubscriptionDialog(context),
                icon: Icon(hasActiveSubscription ? Icons.download : Icons.lock),
                label: Text(hasActiveSubscription ? 'Download Paper' : 'Subscribe to Download'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: hasActiveSubscription ? UnifiedTheme.goldAccent : Colors.grey,
                  side: BorderSide(color: hasActiveSubscription ? UnifiedTheme.goldAccent : Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
          },
        );
      },
    );
  }

  void _startPractice() {
    // TODO: Navigate to practice session
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Starting practice session...'),
    //     backgroundColor: Colors.green,
    //   ),
    // );
  }

  void _downloadPaper() {
    // TODO: Implement paper download
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Downloading paper...'),
    //     backgroundColor: Colors.blue,
    //   ),
    // );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Access Required'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Previous Year Papers require a premium subscription.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'With subscription you get:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Unlimited PYP practice sessions'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('PDF downloads for offline study'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Detailed solutions and explanations'),
              ],
            ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPlansScreen(category: 'pyp'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UnifiedTheme.goldAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  String _formatTargetRole(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'Veterinary Doctor';
      case 'pharmacist':
        return 'Veterinary Pharmacist';
      case 'farmer':
        return 'Farmer';
      default:
        return role.toUpperCase();
    }
  }
}