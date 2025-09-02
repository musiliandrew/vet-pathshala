import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'calving_record_form.dart';

class CalvingManagementScreen extends StatefulWidget {
  const CalvingManagementScreen({super.key});

  @override
  State<CalvingManagementScreen> createState() => _CalvingManagementScreenState();
}

class _CalvingManagementScreenState extends State<CalvingManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Row(
          children: [
            Text('🐣', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'CALVING MANAGEMENT',
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
            onPressed: () => _addNewCalvingRecord(),
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
            // Last Calving
            _buildExpandableSection(
              '▼ LAST CALVING',
              _buildLastCalvingContent(),
            ),
            
            const SizedBox(height: 16),
            
            // Dystocia Risk Assessment
            _buildExpandableSection(
              '▼ DYSTOCIA RISK ASSESSMENT',
              _buildRiskAssessmentContent(),
            ),
            
            const SizedBox(height: 16),
            
            // Calf Performance
            _buildExpandableSection(
              '▼ CALF PERFORMANCE',
              _buildCalfPerformanceContent(),
            ),
            
            const SizedBox(height: 20),
            
            // Calving interval info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Text('📊', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Text(
                    'Calving Interval: 405 days',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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

  Widget _buildLastCalvingContent() {
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
            '🗓️ 15 Apr 2024 03:45 AM',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Dam: Laxmi (Cow12) | Sire: HF-5678', 
               style: TextStyle(fontSize: 14, color: Colors.grey)),
          const Text('Calf: ♀ 28kg | Assisted: No', 
               style: TextStyle(fontSize: 14, color: Colors.grey)),
          const Text('Colostrum: 4L within 2 hours', 
               style: TextStyle(fontSize: 14, color: Colors.grey)),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewCalfProfile(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('View Calf Profile', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _editCalvingRecord(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    side: const BorderSide(color: Color(0xFF4CAF50)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Edit', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAssessmentContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Pregnancy:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Risk Score: ', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '15% (Moderate)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Factors:', style: TextStyle(fontWeight: FontWeight.w500)),
          const Text('• First Calving', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const Text('• Sire\'s BW: 42kg', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const Text('• Dam age: 3 years', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const Text('• Body condition: 3.2/5', style: TextStyle(fontSize: 14, color: Colors.grey)),
          
          const SizedBox(height: 16),
          
          OutlinedButton.icon(
            onPressed: () => _viewPreventionTips(),
            icon: const Icon(Icons.info_outline, size: 16),
            label: const Text('View Prevention Tips'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalfPerformanceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🐄 Previous Calves:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildCalfPerformanceItem(
          '2023: ♀ 26kg - Now 380kg (12mo)',
          'Current weight gain: 1.0kg/day',
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildCalfPerformanceItem(
          '2022: ♂ 30kg - Sold ₹18,500',
          'Sale weight: 220kg at 8 months',
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildCalfPerformanceItem(
          '2021: ♀ 24kg - Breeding stock',
          'First lactation: 22L/day',
          Colors.purple,
        ),
        
        const SizedBox(height: 16),
        
        OutlinedButton.icon(
          onPressed: () => _viewGrowthCharts(),
          icon: const Icon(Icons.show_chart, size: 16),
          label: const Text('Growth Charts'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4CAF50),
            side: const BorderSide(color: Color(0xFF4CAF50)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCalfPerformanceItem(String mainText, String subText, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mainText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subText,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _addNewCalvingRecord() {
    showDialog(
      context: context,
      builder: (context) => const CalvingRecordForm(),
    );
  }

  void _viewCalfProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🐄', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Calf Profile - RF-2024-065', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Birth Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Born: 15 Apr 2024'),
            Text('• Dam: Laxmi (Cow12)'),
            Text('• Sire: HF-5678 (Holstein)'),
            Text('• Birth weight: 28kg'),
            SizedBox(height: 12),
            Text('Current Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Age: 4 months 1 week'),
            Text('• Current weight: 125kg'),
            Text('• Daily gain: 0.8kg/day'),
            Text('• Health: Excellent'),
            SizedBox(height: 12),
            Text('Vaccinations:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('✅ Birth vaccines (complete)'),
            Text('⏳ 6-month booster (due 15 Oct)'),
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
                  content: Text('📝 Full calf management coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Manage Calf', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editCalvingRecord() {
    showDialog(
      context: context,
      builder: (context) => const CalvingRecordForm(),
    );
  }

  void _viewPreventionTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('💡', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Dystocia Prevention Tips', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For current pregnancy (15% risk):', 
                 style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            SizedBox(height: 12),
            Text('Nutrition Management:'),
            Text('• Maintain body condition 3.0-3.5'),
            Text('• Reduce energy 3 weeks before calving'),
            Text('• Ensure adequate mineral intake'),
            SizedBox(height: 12),
            Text('Monitoring:'),
            Text('• Daily observation 2 weeks before'),
            Text('• Check udder development'),
            Text('• Monitor behavioral changes'),
            SizedBox(height: 12),
            Text('Preparation:'),
            Text('• Have vet contact ready'),
            Text('• Prepare clean calving area'),
            Text('• Stock obstetric supplies'),
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
                  content: Text('📋 Prevention checklist saved!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Save Checklist', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewGrowthCharts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('📈', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Calf Growth Charts', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Growth Performance:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('RF-2024-065 (Current):'),
            Text('Birth: 28kg → 4mo: 125kg'),
            Text('Daily gain: 0.8kg (Target: 0.7kg)'),
            SizedBox(height: 12),
            Text('Comparison to Farm Average:'),
            Text('• Birth weight: +2kg above avg'),
            Text('• Growth rate: +0.1kg/day above avg'),
            Text('• Health score: 95% (Excellent)'),
            SizedBox(height: 12),
            Text('Projected Performance:'),
            Text('• 6 months: 165kg'),
            Text('• 1 year: 280kg'),
            Text('• First lactation: 25L/day'),
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
                  content: Text('📊 Detailed growth analytics coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Full Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}