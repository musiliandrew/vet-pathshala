import 'package:flutter/material.dart';
import '../../../shared/services/firebase_data_seeder.dart';
import '../../../core/theme/unified_theme.dart';

class DataSeederScreen extends StatefulWidget {
  const DataSeederScreen({super.key});

  @override
  State<DataSeederScreen> createState() => _DataSeederScreenState();
}

class _DataSeederScreenState extends State<DataSeederScreen> {
  final FirebaseDataSeeder _seeder = FirebaseDataSeeder();
  bool _isSeeding = false;
  bool _isClearing = false;
  String? _lastOperation;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Data Seeder'),
        backgroundColor: UnifiedTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Database Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: UnifiedTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Load sample data into Firebase to see the dynamic content system in action.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Sample Data Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: UnifiedTheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Sample Data Included',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _DataInfoRow(icon: Icons.people, label: 'Users', count: '4 sample users'),
                    const _DataInfoRow(icon: Icons.video_library, label: 'Videos', count: '4 educational videos'),
                    const _DataInfoRow(icon: Icons.quiz, label: 'Questions', count: '6 practice questions'),
                    const _DataInfoRow(icon: Icons.book, label: 'E-books', count: '4 reference books'),
                    const _DataInfoRow(icon: Icons.trending_up, label: 'Progress', count: '3 progress entries'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSeeding || _isClearing ? null : _seedData,
                    icon: _isSeeding 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.upload),
                    label: Text(_isSeeding ? 'Seeding...' : 'Load Sample Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UnifiedTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSeeding || _isClearing ? null : _clearData,
                    icon: _isClearing 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.clear_all),
                    label: Text(_isClearing ? 'Clearing...' : 'Clear All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Status Card
            if (_lastOperation != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Operation Successful',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            Text(
                              _lastOperation!,
                              style: TextStyle(
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const Spacer(),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Instructions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Click "Load Sample Data" to populate Firebase with mock data\n'
                    '2. Go to Admin Dashboard to see the analytics and content\n'
                    '3. Browse videos, questions, and ebooks tabs to see real data\n'
                    '4. Use the search feature to find specific content\n'
                    '5. Click "Clear All Data" to remove all sample data',
                    style: TextStyle(
                      color: Colors.blue.shade700,
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
  
  Future<void> _seedData() async {
    setState(() {
      _isSeeding = true;
      _lastOperation = null;
    });
    
    try {
      await _seeder.seedAllData();
      
      setState(() {
        _lastOperation = 'Sample data loaded successfully! Check the Admin Dashboard to see the results.';
        _isSeeding = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sample data loaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      setState(() {
        _isSeeding = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to load data: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
  
  Future<void> _clearData() async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to clear all data from Firebase? '
          'This will delete all users, videos, questions, ebooks, and progress data.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isClearing = true;
      _lastOperation = null;
    });
    
    try {
      await _seeder.clearAllData();
      
      setState(() {
        _lastOperation = 'All data cleared successfully! The database is now empty.';
        _isClearing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ All data cleared successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      setState(() {
        _isClearing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to clear data: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

class _DataInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  
  const _DataInfoRow({
    required this.icon,
    required this.label,
    required this.count,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            count,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}