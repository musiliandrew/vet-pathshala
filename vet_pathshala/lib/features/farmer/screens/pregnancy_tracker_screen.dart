import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'pregnancy_record_form.dart';

class PregnancyTrackerScreen extends StatefulWidget {
  const PregnancyTrackerScreen({super.key});

  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Row(
          children: [
            Text('🤰', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'PREGNANCY TRACKER',
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
            onPressed: () => _addNewPregnancy(),
            icon: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('➕', style: TextStyle(fontSize: 18)),
                SizedBox(width: 4),
                Text('New', style: TextStyle(color: Colors.white, fontSize: 12)),
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
            // Current Status
            _buildExpandableSection(
              '▼ CURRENT STATUS',
              _buildCurrentStatusContent(),
            ),
            
            const SizedBox(height: 16),
            
            // Milk Production Forecast
            _buildExpandableSection(
              '▼ MILK PRODUCTION FORECAST',
              _buildMilkForecastContent(),
            ),
            
            const SizedBox(height: 16),
            
            // Veterinary Checkups
            _buildExpandableSection(
              '▼ VETERINARY CHECKUPS',
              _buildVetCheckupsContent(),
            ),
            
            const SizedBox(height: 20),
            
            // Historical conception rates button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _viewConceptionRates(),
                icon: const Text('📈'),
                label: const Text('View Historical Conception Rates'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
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

  Widget _buildCurrentStatusContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🐄 Laxmi (Cow12) - Day 145 (51%)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        // Progress bar
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.51,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pink, Colors.pinkAccent],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('■■■■■■■■■■■□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□□', 
             style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
        
        const SizedBox(height: 16),
        
        const Text('Due: 15 Sep ±3d | Sire: HF-5678', 
             style: TextStyle(fontSize: 14, color: Colors.grey)),
        const Text('Last Check: 1 Aug - Normal', 
             style: TextStyle(fontSize: 14, color: Colors.grey)),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _addCheckup(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Add Checkup'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _viewTimeline(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.pink,
                  side: const BorderSide(color: Colors.pink),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('View Timeline'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilkForecastContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expected Lactation: 28L/day (±3L)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 12),
          Text('Based on:', style: TextStyle(fontWeight: FontWeight.w500)),
          Text('• Dam\'s 1st Lactation: 25L', style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text('• Sire\'s Progeny Avg: 30L', style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text('• Body condition score: 3.5/5', style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text('• Nutrition quality: Good', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildVetCheckupsContent() {
    return Column(
      children: [
        _buildCheckupItem('🗓️ 20 Aug - PD Test', 'Pregnancy confirmation', Colors.orange),
        const SizedBox(height: 8),
        _buildCheckupItem('🗓️ 1 Sep - Ultrasound', 'Fetal development check', Colors.blue),
        const SizedBox(height: 8),
        _buildCheckupItem('🗓️ 10 Sep - Body Condition Score', 'Nutrition assessment', Colors.green),
        
        const SizedBox(height: 16),
        
        OutlinedButton.icon(
          onPressed: () => _addCustomCheckup(),
          icon: const Icon(Icons.add),
          label: const Text('Add Custom Checkup'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4CAF50),
            side: const BorderSide(color: Color(0xFF4CAF50)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckupItem(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 12, color: color),
        ],
      ),
    );
  }

  void _addNewPregnancy() {
    showDialog(
      context: context,
      builder: (context) => const PregnancyRecordForm(),
    );
  }

  void _addCheckup() {
    showDialog(
      context: context,
      builder: (context) => const PregnancyRecordForm(),
    );
  }

  void _viewTimeline() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('📅 Pregnancy Timeline'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laxmi (Cow12) - Day 145/283'),
            SizedBox(height: 12),
            Text('Timeline:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('✅ 21 Jul - AI Service (HF-5678)'),
            Text('✅ 20 Aug - PD Test (Positive)'),
            Text('⏳ 1 Sep - Ultrasound (Scheduled)'),
            Text('⏳ 10 Sep - Body Condition (Scheduled)'),
            Text('⏳ 15 Sep - Calving (Expected)'),
            SizedBox(height: 12),
            Text('Risk Factors:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            Text('• History of dystocia'),
            Text('• Large sire genetics'),
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

  void _addCustomCheckup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Custom Checkup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Checkup name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Custom checkup added!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewConceptionRates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('📈', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Historical Conception Rates', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farm Conception Statistics:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Overall Rate: 68% (Last 2 years)'),
            Text('First Service: 72%'),
            Text('Second Service: 65%'),
            Text('Third+ Service: 45%'),
            SizedBox(height: 16),
            Text('By Animal:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('🐄 Laxmi: 85% (6/7 attempts)'),
            Text('🐃 Kaali: 60% (3/5 attempts)'),
            Text('🐄 Sunita: 75% (3/4 attempts)'),
            SizedBox(height: 16),
            Text('Best performing sires:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• HF-5678: 78% conception'),
            Text('• JER-2341: 65% conception'),
            Text('• MUR-8890: 70% conception'),
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
                  content: Text('📊 Detailed analytics coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Detailed Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}