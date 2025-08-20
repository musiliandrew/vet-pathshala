import 'package:flutter/material.dart';
import '../../../shared/services/firebase_data_seeder.dart';
import '../../../core/theme/unified_theme.dart';

class FirebaseSeederScreen extends StatefulWidget {
  const FirebaseSeederScreen({super.key});

  @override
  State<FirebaseSeederScreen> createState() => _FirebaseSeederScreenState();
}

class _FirebaseSeederScreenState extends State<FirebaseSeederScreen> {
  final FirebaseDataSeeder _seeder = FirebaseDataSeeder();
  bool _isSeeding = false;
  String _seedingStatus = '';
  List<String> _seedingLogs = [];

  void _addLog(String message) {
    setState(() {
      _seedingLogs.add('${DateTime.now().toIso8601String()}: $message');
      _seedingStatus = message;
    });
  }

  Future<void> _seedAllData() async {
    setState(() {
      _isSeeding = true;
      _seedingLogs.clear();
      _seedingStatus = 'Starting data seeding...';
    });

    try {
      _addLog('🌱 Starting Firebase data seeding...');
      
      _addLog('👥 Seeding users...');
      await _seedUsers();
      
      _addLog('🎥 Seeding video lectures...');
      await _seedVideoLectures();
      
      _addLog('📚 Seeding ebooks...');
      await _seedEbooks();
      
      _addLog('❓ Creating quiz collections...');
      await _createQuizCollections();
      
      _addLog('✅ All data seeded successfully!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data seeding completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  Future<void> _seedUsers() async {
    // Add sample user data to match your existing structure
    await _seeder.seedUsers();
  }

  Future<void> _seedVideoLectures() async {
    // Add sample videos to match your video service expectations
    await _seeder.seedVideos();
  }

  Future<void> _seedEbooks() async {
    // Add sample ebooks to match your ebook service expectations
    await _seeder.seedEbooks();
  }

  Future<void> _createQuizCollections() async {
    // Create quiz collections that work with your existing questions
    await _seeder.seedQuestions();
  }

  Future<void> _clearAllData() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Clear All Data'),
        content: const Text(
          'This will delete ALL data from Firebase collections. This action cannot be undone.\n\nAre you sure you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      setState(() {
        _isSeeding = true;
        _seedingLogs.clear();
        _seedingStatus = 'Clearing all data...';
      });

      try {
        _addLog('🗑️ Clearing all Firebase data...');
        await _seeder.clearAllData();
        _addLog('✅ All data cleared successfully!');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ All data cleared successfully!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        _addLog('❌ Error clearing data: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Data Seeder'),
        backgroundColor: UnifiedTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🌱 Firebase Data Seeder',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This tool will create the missing Firebase collections and seed them with sample data to fix the loading issues in your app.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSeeding ? null : _seedAllData,
                            icon: _isSeeding 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.cloud_upload),
                            label: Text(_isSeeding ? 'Seeding...' : 'Seed All Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UnifiedTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSeeding ? null : _clearAllData,
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Clear All Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status
            if (_seedingStatus.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_isSeeding)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          _seedingStatus.contains('❌') 
                              ? Icons.error 
                              : Icons.check_circle,
                          color: _seedingStatus.contains('❌') 
                              ? Colors.red 
                              : Colors.green,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _seedingStatus,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Logs
            const Text(
              'Seeding Logs:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: _seedingLogs.isEmpty
                      ? const Center(
                          child: Text(
                            'No logs yet. Click "Seed All Data" to start.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _seedingLogs.length,
                          itemBuilder: (context, index) {
                            final log = _seedingLogs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                log,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: log.contains('❌') 
                                      ? Colors.red 
                                      : log.contains('✅')
                                          ? Colors.green
                                          : Colors.black87,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            
            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Click "Seed All Data" to create the missing collections\n'
                      '2. This will create: video_lectures, ebooks, quizzes, and user_progress\n'
                      '3. Your app should then load content properly\n'
                      '4. Use "Clear All Data" only if you want to start fresh',
                      style: TextStyle(fontSize: 12),
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
}