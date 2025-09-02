import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'new_medication_form.dart';

class ActiveMedicationsScreen extends StatefulWidget {
  const ActiveMedicationsScreen({super.key});

  @override
  State<ActiveMedicationsScreen> createState() => _ActiveMedicationsScreenState();
}

class _ActiveMedicationsScreenState extends State<ActiveMedicationsScreen> {
  String selectedFilter = 'ALL';
  final List<String> filters = ['ALL', 'COW', 'BUFFALO', 'GOAT'];

  final List<Map<String, dynamic>> activeTreatments = [
    {
      'status': 'active',
      'statusColor': Colors.red,
      'statusEmoji': '🔴',
      'animal': '🐄 Laxmi (Cow12)',
      'condition': 'Mastitis',
      'medicine': 'Enrofloxacin (100mg/ml)',
      'dosage': '5ml IM 2x daily',
      'progress': 3,
      'totalDays': 7,
      'nextDose': 'Today 8PM',
      'endDate': '7 Aug 2024',
      'actions': ['Log Dose', 'View Details'],
    },
    {
      'status': 'monitoring',
      'statusColor': Colors.orange,
      'statusEmoji': '🟡',
      'animal': '🐃 Kaali (Buff5)',
      'condition': 'Wound Care',
      'medicine': 'Oxytetracycline Spray',
      'dosage': 'Apply 2x daily',
      'progress': 4,
      'totalDays': 10,
      'nextDose': 'Milk Withdrawal: 5 days left',
      'endDate': '15 Aug 2024',
      'actions': ['Mark Complete', 'Notify Vet'],
    },
    {
      'status': 'completing',
      'statusColor': Colors.green,
      'statusEmoji': '🟢',
      'animal': '🐐 Chhoti (Goat8)',
      'condition': 'Parasites',
      'medicine': 'Fenbendazole (Oral)',
      'dosage': '7.5ml 1x daily',
      'progress': 6,
      'totalDays': 7,
      'nextDose': 'Last Given: Today 7AM',
      'endDate': '25 Aug 2024',
      'actions': ['Add Note'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Row(
          children: [
            Text('💊', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'ACTIVE MEDICATIONS',
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
            onPressed: () => _showSearch(context),
            icon: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔍', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
                Text('Search', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          _buildFilterSection(),
          
          // Medications list
          Expanded(
            child: _buildMedicationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // ASCII filter header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Animal Species Filter │ ALL │ COW │ BUFFALO │ GOAT │',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filter chips
          Row(
            children: filters.map((filter) {
              final isSelected = selectedFilter == filter;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedFilter = filter),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ CURRENT TREATMENTS (3)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          
          // Treatment cards
          ...activeTreatments.map((treatment) => _buildTreatmentCard(treatment)),
          
          const SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _loadMore(),
                  icon: const Text('⬇️'),
                  label: const Text('Load More'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addNewMedication(context),
                  icon: const Text('➕'),
                  label: const Text('New Medication'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(Map<String, dynamic> treatment) {
    final progress = treatment['progress'] as int;
    final totalDays = treatment['totalDays'] as int;
    final progressPercentage = progress / totalDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Text(treatment['statusEmoji'], style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${treatment['animal']} - ${treatment['condition']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Medicine details
          Text('Medicine: ${treatment['medicine']}', 
               style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text('Dosage: ${treatment['dosage']}', 
               style: const TextStyle(fontSize: 14, color: Colors.grey)),
          
          const SizedBox(height: 12),
          
          // Progress bar
          Row(
            children: [
              const Text('Progress: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(List.generate(totalDays, (index) => index < progress ? '■' : '□').join(''),
                   style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
              Text(' $progress/$totalDays days', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Next dose info
          Text(treatment['nextDose'], 
               style: TextStyle(fontSize: 12, color: treatment['statusColor'], fontWeight: FontWeight.w500)),
          if (treatment['endDate'] != null)
            Text('Ends: ${treatment['endDate']}', 
                 style: const TextStyle(fontSize: 12, color: Colors.grey)),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: (treatment['actions'] as List<String>).map((action) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    onPressed: () => _handleAction(action, treatment),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(action, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🔍', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Search Medications', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by animal, medicine, condition...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Search filters:\n'
              '• Animal names\n'
              '• Medicine names\n'
              '• Conditions/diseases\n'
              '• Veterinarian names',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
                  content: Text('Medication search coming soon!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _loadMore() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loading more treatments...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _addNewMedication(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NewMedicationForm(),
    );
  }

  void _handleAction(String action, Map<String, dynamic> treatment) {
    switch (action) {
      case 'Log Dose':
        _showLogDoseDialog(treatment);
        break;
      case 'View Details':
        _showTreatmentDetails(treatment);
        break;
      case 'Mark Complete':
        _markComplete(treatment);
        break;
      case 'Notify Vet':
        _notifyVet(treatment);
        break;
      case 'Add Note':
        _addNote(treatment);
        break;
    }
  }

  void _showLogDoseDialog(Map<String, dynamic> treatment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('⏰', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('MEDICATION REMINDER', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Next Dose for ${treatment['animal']}'),
            Text('${treatment['medicine']}'),
            const Text('Due in 15 minutes (8:00PM)', 
                 style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Dose logged successfully!'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                  child: const Text('Log as Given', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Postpone 1hr'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Skipped'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTreatmentDetails(Map<String, dynamic> treatment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${treatment['animal']} - Treatment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Condition: ${treatment['condition']}'),
            Text('Medicine: ${treatment['medicine']}'),
            Text('Dosage: ${treatment['dosage']}'),
            Text('Progress: ${treatment['progress']}/${treatment['totalDays']} days'),
            Text('Next: ${treatment['nextDose']}'),
            Text('Ends: ${treatment['endDate']}'),
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

  void _markComplete(Map<String, dynamic> treatment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark Treatment Complete'),
        content: Text('Mark ${treatment['animal']} treatment as complete?\n\nThis will:\n• End the medication schedule\n• Update health records\n• Award completion points'),
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
                  content: Text('✅ Treatment marked complete! +3 coins earned'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _notifyVet(Map<String, dynamic> treatment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔔 Vet notification sent for ${treatment['animal']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _addNote(Map<String, dynamic> treatment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Note - ${treatment['animal']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add treatment notes, observations...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
                  content: Text('📝 Note added to treatment record'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Save Note', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}