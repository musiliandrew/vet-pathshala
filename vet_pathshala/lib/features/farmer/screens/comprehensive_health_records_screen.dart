import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'deworming_record_form.dart';
import 'active_medications_screen.dart';
import 'new_medication_form.dart';

class ComprehensiveHealthRecordsScreen extends StatefulWidget {
  const ComprehensiveHealthRecordsScreen({super.key});

  @override
  State<ComprehensiveHealthRecordsScreen> createState() => _ComprehensiveHealthRecordsScreenState();
}

class _ComprehensiveHealthRecordsScreenState extends State<ComprehensiveHealthRecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final List<String> _tabLabels = [
    'Vaccines',
    'Deworming', 
    'Medicines',
    'Diseases'
  ];

  final List<String> _tabIcons = [
    '💉',
    '🦠',
    '💊',
    '🏥'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        return Scaffold(
          backgroundColor: Colors.green.shade50,
          appBar: AppBar(
            backgroundColor: const Color(0xFF2E7D32),
            title: const Row(
              children: [
                Text('🩺', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text(
                  'HEALTH RECORDS',
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
                    Icon(Icons.search, color: Colors.white, size: 20),
                    SizedBox(width: 4),
                    Text('Search', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Navigation Tabs
              _buildNavigationTabs(),
              
              // Tab Content
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ASCII header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Text(
                '░░░░░░░░░░░░░░░ HEALTH NAVIGATION TABS ░░░░░░░░░░░░░░░',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          // Tab buttons
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: List.generate(4, (index) {
                final isSelected = _selectedTabIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? const Color(0xFF2E7D32) 
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _tabIcons[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tabLabels[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildVaccinesTab();
      case 1:
        return _buildDewormingTab();
      case 2:
        return _buildMedicinesTab();
      case 3:
        return _buildDiseasesTab();
      default:
        return _buildVaccinesTab();
    }
  }

  Widget _buildVaccinesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ VACCINATION HISTORY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          
          // Vaccination entries
          _buildVaccinationEntry(
            'FMD Vaccine',
            'Laxmi (Cow #12)',
            'Batch: VX2024-89',
            'Given: 15 Jan 2024',
            'Next Due: 15 Jul 2024',
            Colors.green,
            'COMPLETED'
          ),
          const SizedBox(height: 12),
          _buildVaccinationEntry(
            'HS Vaccine',
            'Kaali (Buffalo #5)',
            'Batch: HS2024-45',
            'Given: 20 Dec 2023',
            'Next Due: 20 Jun 2024',
            Colors.red,
            'OVERDUE'
          ),
          const SizedBox(height: 12),
          _buildVaccinationEntry(
            'Anthrax Vaccine',
            'Chhoti (Goat #8)',
            'Batch: AN2024-12',
            'Scheduled: 10 Feb 2024',
            'Status: Pending',
            Colors.orange,
            'UPCOMING'
          ),
          
          const SizedBox(height: 24),
          
          // Add new vaccination button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddVaccinationDialog(context),
              icon: const Text('➕'),
              label: const Text('Add Vaccination Record (1 Coin)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDewormingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ DEWORMING REMINDERS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          
          // Deworming alerts
          _buildDewormingAlert('🔴 OVERDUE: Laxmi (Cow #12) - Last dewormed 4 months ago', Colors.red, true),
          const SizedBox(height: 8),
          _buildDewormingAlert('🟢 COMPLETED: Kaali (Buffalo #5) - Dewormed 1 week ago', Colors.green, false),
          const SizedBox(height: 8),
          _buildDewormingAlert('🟡 UPCOMING: Chhoti (Goat #8) - Due in 2 weeks', Colors.orange, false),
          
          const SizedBox(height: 24),
          
          // Schedule section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📅 SCHEDULE DEWORMING',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDewormingForm(context),
                        icon: const Text('📅'),
                        label: const Text('Schedule'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showMarkDewormingDialog(context),
                        icon: const Text('✅'),
                        label: const Text('Mark Done (1C)'),
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
        ],
      ),
    );
  }

  Widget _buildMedicinesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ ACTIVE MEDICATIONS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          
          // Active medications
          _buildMedicationEntry(
            'Amoxicillin',
            'Laxmi (Cow #12)',
            'Dosage: 500mg 2x daily',
            'Treatment: Respiratory infection',
            'Duration: 7 days (3 remaining)',
            Colors.blue,
            'ACTIVE'
          ),
          const SizedBox(height: 12),
          _buildMedicationEntry(
            'Ivermectin',
            'Chhoti (Goat #8)',
            'Dosage: 0.2mg/kg once',
            'Treatment: External parasites',
            'Duration: Single dose (completed)',
            Colors.green,
            'COMPLETED'
          ),
          
          const SizedBox(height: 24),
          
          // Medication management
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💊 MEDICATION MANAGEMENT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showNewMedicationForm(context),
                        icon: const Text('➕'),
                        label: const Text('Add Treatment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showActiveMedicationsScreen(context),
                        icon: const Text('📋'),
                        label: const Text('View Active'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildDiseasesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ DISEASE CASES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          
          // Disease cases
          _buildDiseaseEntry(
            'Mastitis',
            'Laxmi (Cow #12)',
            'Detected: 10 Jan 2024',
            'Status: Under treatment',
            'Vet: Dr. Sharma',
            Colors.orange,
            'TREATING'
          ),
          const SizedBox(height: 12),
          _buildDiseaseEntry(
            'Foot & Mouth Disease',
            'Kaali (Buffalo #5)',
            'Detected: 5 Dec 2023',
            'Status: Recovered',
            'Vet: Dr. Patel',
            Colors.green,
            'RECOVERED'
          ),
          
          const SizedBox(height: 24),
          
          // Disease management
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🏥 DISEASE MANAGEMENT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showReportDiseaseDialog(context),
                        icon: const Text('🚨'),
                        label: const Text('Report Case'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDiseaseHistory(context),
                        icon: const Text('📊'),
                        label: const Text('Analytics'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          side: const BorderSide(color: Color(0xFF4CAF50)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildVaccinationEntry(String vaccine, String animal, String batch, String given, String nextDue, Color statusColor, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '💉 $vaccine',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(animal, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(batch, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(given, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(nextDue, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDewormingAlert(String text, Color color, bool isOverdue) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(isOverdue ? 0.5 : 0.3),
          width: isOverdue ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isOverdue) Icon(Icons.warning, color: color, size: 20),
        ],
      ),
    );
  }

  Widget _buildMedicationEntry(String medicine, String animal, String dosage, String treatment, String duration, Color statusColor, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '💊 $medicine',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(animal, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(dosage, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(treatment, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(duration, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDiseaseEntry(String disease, String animal, String detected, String status, String vet, Color statusColor, String statusLabel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '🏥 $disease',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(animal, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(detected, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(status, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(vet, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500)),
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
            Text('Search Health Records', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search vaccines, medicines, diseases...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Search across:\n'
              '• Vaccination records\n'
              '• Medication history\n'
              '• Disease cases\n'
              '• Deworming schedule',
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
                  content: Text('Health records search coming soon!'),
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

  void _showAddVaccinationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('💉', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Add Vaccination', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text('Vaccination recording feature coming soon!\n\nThis will allow you to:\n• Select animal from your list\n• Choose vaccine type\n• Record batch number\n• Set next due date\n• Upload certificate photo\n\nCost: 1 coin per record'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDewormingForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DewormingRecordForm(),
    );
  }

  void _showMarkDewormingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('✅', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Mark Deworming Complete', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text('Mark deworming complete (1 coin)\n\nThis will:\n• Update animal health status\n• Set next deworming reminder\n• Add to health history\n• Award completion points'),
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
                  content: Text('Deworming marked complete! (1 coin deducted)'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
            child: const Text('Confirm (1 Coin)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNewMedicationForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NewMedicationForm(),
    );
  }

  void _showActiveMedicationsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ActiveMedicationsScreen(),
      ),
    );
  }

  void _showReportDiseaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🚨', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Report Disease Case', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text('Disease reporting coming soon!\n\nFeatures:\n• Select affected animal\n• Describe symptoms\n• Upload photos\n• Connect with local vet\n• Get treatment recommendations\n• Track recovery progress'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDiseaseHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('📊', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Disease Analytics', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text('Health analytics coming soon!\n\n• Disease frequency patterns\n• Seasonal health trends\n• Treatment effectiveness\n• Prevention recommendations\n• Farm health score\n• Comparative analysis'),
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