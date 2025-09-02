import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class MilkProductionDashboardScreen extends StatefulWidget {
  const MilkProductionDashboardScreen({super.key});

  @override
  State<MilkProductionDashboardScreen> createState() => _MilkProductionDashboardScreenState();
}

class _MilkProductionDashboardScreenState extends State<MilkProductionDashboardScreen> {
  String selectedMonth = 'Aug';
  final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Row(
          children: [
            const Text('🥛', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'MILK PRODUCTION DASHBOARD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedMonth,
                  onChanged: (value) => setState(() => selectedMonth = value!),
                  icon: const Text('▼', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  dropdownColor: const Color(0xFF2E7D32),
                  items: months.map((month) => DropdownMenuItem(
                    value: month,
                    child: Text('📅 $month', style: const TextStyle(color: Colors.white)),
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Summary
            _buildTodaysSummarySection(),
            
            const SizedBox(height: 16),
            
            // Weekly Trends
            _buildWeeklyTrendsSection(),
            
            const SizedBox(height: 16),
            
            // Top/Bottom Performers
            _buildPerformersSection(),
            
            const SizedBox(height: 16),
            
            // Individual Milk Logs
            _buildIndividualLogsSection(),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportReport(),
                    icon: const Text('📤'),
                    label: const Text('Export Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysSummarySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Text(
                '░░░░░░░░░░░░░░░ TODAY\'S SUMMARY ░░░░░░░░░░░░░░░░░░░',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Morning and Evening totals
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text('🌅', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 8),
                            Text(
                              'Morning: 65.2L',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text('🌇', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 8),
                            Text(
                              'Evening: 59.8L',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Summary stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Total: 125L (▲3% from yesterday)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Avg/Cow: 4.16L | Target: 135L (93% achieved)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendsSection() {
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
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    '▼ WEEKLY TRENDS (Last 7 Days)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                Icon(Icons.expand_more, color: Color(0xFF2E7D32)),
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
            child: Column(
              children: [
                // ASCII Chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('140┬', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      Text('   │        ▄▄▄▄', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      Text('120┤     ▄▄▄   ██▄', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      Text('   │   ▄▄█    █  ██', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      Text('100┤ ▄▄▀     █    █▄▄', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      Text('   │▀▀       ▀▀▀▀▀▀▀▀', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      Text(' 80└───────────────────────────────', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      Text('    Sun Mon Tue Wed Thu Fri Sat', style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Trend summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('📈', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'Weekly Avg: 118L | Peak: Thu (135L) | Low: Sun (95L)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformersSection() {
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
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    '▼ TOP/BOTTOM PERFORMERS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                Icon(Icons.expand_more, color: Color(0xFF2E7D32)),
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
            child: Column(
              children: [
                // Top performers
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text('🥇', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 8),
                            Text(
                              'Laxmi (Cow12)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '28.5L/day (+15%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text('🥈', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 8),
                            Text(
                              'Gauri (Cow3)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              '25.2L/day (+8%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Bottom performers
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text('⚠️', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 8),
                            Text(
                              'Kaali (Buff5)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              '18.1L/day (-12%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text('⚠️', style: TextStyle(fontSize: 20)),
                            SizedBox(height: 8),
                            Text(
                              'Chhoti (Goat8)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              '2.5L/day (-22%)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualLogsSection() {
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
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    '▼ INDIVIDUAL MILK LOGS (Last 3 Entries)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                Icon(Icons.expand_more, color: Color(0xFF2E7D32)),
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
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🐄 Laxmi (Cow12)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      const Text('Aug 3: 🌅12.5L 🌇16.0L (Total: 28.5L)', 
                           style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const Text('Aug 2: 🌅11.8L 🌇15.4L (Total: 27.2L)', 
                           style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const Text('Aug 1: 🌅13.2L 🌇16.8L (Total: 30.0L)', 
                           style: TextStyle(fontSize: 14, color: Colors.grey)),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _viewAllLogs(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4CAF50),
                                side: const BorderSide(color: Color(0xFF4CAF50)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('View All', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _compareAnimals(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Compare', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('📤', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Export Milk Report', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export Options:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('• Daily production logs'),
            Text('• Weekly trend analysis'),
            Text('• Individual animal performance'),
            Text('• Comparative reports'),
            SizedBox(height: 16),
            Text('Format: PDF | CSV | Excel'),
            SizedBox(height: 8),
            Text('Cost: 3 Coins per report', 
                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
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
                  content: Text('📤 Milk production report exported! (3 coins deducted)'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Export (3 Coins)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewAllLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🐄 Laxmi - Complete Milk Logs'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 30 Days:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Aug 3: 🌅12.5L 🌇16.0L = 28.5L'),
            Text('Aug 2: 🌅11.8L 🌇15.4L = 27.2L'),
            Text('Aug 1: 🌅13.2L 🌇16.8L = 30.0L'),
            Text('Jul 31: 🌅12.0L 🌇15.5L = 27.5L'),
            Text('Jul 30: 🌅11.5L 🌇14.8L = 26.3L'),
            SizedBox(height: 16),
            Text('Monthly Average: 27.9L/day'),
            Text('Best Day: Jul 25 (32.4L)'),
            Text('Trend: +2.3% this month'),
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

  void _compareAnimals() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('📊 Animal Comparison'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Production Comparison (7-day avg):', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('🐄 Laxmi (Cow12): 28.5L (+15%)'),
            Text('🐄 Gauri (Cow3): 25.2L (+8%)'),
            Text('🐄 Sunita (Cow15): 22.8L (+3%)'),
            Text('🐃 Kaali (Buff5): 18.1L (-12%)'),
            Text('🐐 Chhoti (Goat8): 2.5L (-22%)'),
            SizedBox(height: 16),
            Text('Best Performers:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            Text('• Holstein cows leading production'),
            Text('• Consistent morning milking advantage'),
            SizedBox(height: 12),
            Text('Areas for Improvement:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            Text('• Buffalo nutrition needs attention'),
            Text('• Goat health check recommended'),
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
}