import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'heat_ai_records_screen.dart';
import 'pregnancy_tracker_screen.dart';
import 'pregnancy_record_form.dart';
import 'calving_management_screen.dart';

class BreedingDashboardScreen extends StatefulWidget {
  const BreedingDashboardScreen({super.key});

  @override
  State<BreedingDashboardScreen> createState() => _BreedingDashboardScreenState();
}

class _BreedingDashboardScreenState extends State<BreedingDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Row(
          children: [
            Text('🐄', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'BREEDING DASHBOARD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showSettings(context),
            icon: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('⚙️', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heat & AI Records Section
            _buildExpandableSection(
              '▼ HEAT & AI RECORDS (Tap to expand)',
              _buildHeatAIContent(),
            ),
            
            const SizedBox(height: 16),
            
            // Pregnancy Tracker Section
            _buildExpandableSection(
              '▼ PREGNANCY TRACKER (3 active)',
              _buildPregnancyContent(),
            ),
            
            const SizedBox(height: 16),
            
            // Calving Management Section
            _buildExpandableSection(
              '▼ CALVING MANAGEMENT',
              _buildCalvingContent(),
            ),
            
            const SizedBox(height: 16),
            
            // Alerts Section
            _buildExpandableSection(
              '▼ ALERTS (3)',
              _buildAlertsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const Icon(Icons.expand_more, color: Color(0xFF2E7D32)),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildHeatAIContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🐄 Laxmi (Cow12)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Last Heat: 20 Jul | Next Due: 10 Aug (±2d)', 
               style: TextStyle(fontSize: 14, color: Colors.grey)),
          const Text('Last AI: 21 Jul (HF-5678) | PD Due: 20 Aug', 
               style: TextStyle(fontSize: 14, color: Colors.grey)),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _logHeat(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Log Heat', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _recordAI(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Record AI', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🤰 Laxmi (Day 145/283)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Due: 15 Sep | Sire: HF-5678', 
               style: TextStyle(fontSize: 14, color: Colors.grey)),
          const Text('Next Check: 20 Aug (PD Test)', 
               style: TextStyle(fontSize: 14, color: Colors.grey)),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewAllPregnancies(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.pink,
                    side: const BorderSide(color: Colors.pink),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('View All', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _addCheckup(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Add Checkup', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalvingContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🐣 Last: 15 Apr (Laxmi) - 28kg ♀',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Next Due: 15 Sep (High Risk)', 
               style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w500)),
          const Text('Calving Int.: 405d | Dystocia: 15%', 
               style: TextStyle(fontSize: 14, color: Colors.grey)),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _prepareCalvingKit(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Prepare Kit', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewCalvingHistory(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('View History', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsContent() {
    return Column(
      children: [
        _buildAlertItem('🔴', '10 Aug - Laxmi Heat Expected', Colors.red),
        const SizedBox(height: 8),
        _buildAlertItem('🟠', '20 Aug - Pregnancy Test Due', Colors.orange),
        const SizedBox(height: 8),
        _buildAlertItem('🟡', '15 Sep - High Risk Calving', Colors.amber),
      ],
    );
  }

  Widget _buildAlertItem(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 12, color: color),
        ],
      ),
    );
  }

  void _logHeat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HeatAIRecordsScreen(),
      ),
    );
  }

  void _recordAI() {
    showDialog(
      context: context,
      builder: (context) => const PregnancyRecordForm(),
    );
  }

  void _viewAllPregnancies() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PregnancyTrackerScreen(),
      ),
    );
  }

  void _addCheckup() {
    showDialog(
      context: context,
      builder: (context) => const PregnancyRecordForm(),
    );
  }

  void _prepareCalvingKit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🧰', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Calving Kit Preparation', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Essential items for Laxmi\'s calving:'),
            SizedBox(height: 12),
            Text('• Clean towels and ropes'),
            Text('• Obstetric lubricant'),
            Text('• Iodine solution'),
            Text('• Emergency vet contact'),
            Text('• Colostrum supplements'),
            SizedBox(height: 16),
            Text('⚠️ High risk calving - vet standby recommended', 
                 style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Calving kit checklist saved!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Mark Prepared', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewCalvingHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalvingManagementScreen(),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('⚙️', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Breeding Settings', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configure breeding parameters:'),
            SizedBox(height: 12),
            Text('• Heat cycle length: 21 days'),
            Text('• Gestation period: 283 days'),
            Text('• AI window: 12-18 hours'),
            Text('• PD test timing: 30-45 days'),
            SizedBox(height: 16),
            Text('Notification preferences:'),
            Text('• Heat detection alerts'),
            Text('• Pregnancy check reminders'),
            Text('• Calving preparation notices'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚙️ Settings configuration coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Configure', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}