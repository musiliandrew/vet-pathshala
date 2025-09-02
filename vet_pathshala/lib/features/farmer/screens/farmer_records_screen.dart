import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'add_animal_screen.dart';
import 'view_all_animals_screen.dart';
import 'daily_milk_log_screen.dart';
import 'comprehensive_health_records_screen.dart';
import 'breeding_dashboard_screen.dart';
import 'milk_production_dashboard_screen.dart';
import 'financial_management_screen.dart';

class FarmerRecordsScreen extends StatefulWidget {
  const FarmerRecordsScreen({super.key});

  @override
  State<FarmerRecordsScreen> createState() => _FarmerRecordsScreenState();
}

class _FarmerRecordsScreenState extends State<FarmerRecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final List<String> _tabLabels = [
    'Animals',
    'Health', 
    'Breeding',
    'Milk',
    'Finance'
  ];

  final List<String> _tabIcons = [
    '🐄',
    '💉',
    '🔄',
    '🥛',
    '💰'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
                Text('📁', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text(
                  'RECORDS DASHBOARD',
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
                '░░░░░░░░░░░░░░░ NAVIGATION TABS ░░░░░░░░░░░░░░░░░░░',
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
              children: List.generate(5, (index) {
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
        return _buildAnimalProfilesTab();
      case 1:
        return _buildHealthRecordsTab();
      case 2:
        return _buildBreedingTab();
      case 3:
        return _buildMilkProductionTab();
      case 4:
        return _buildFinancialTab();
      default:
        return _buildAnimalProfilesTab();
    }
  }

  Widget _buildAnimalProfilesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ ANIMAL PROFILES (50)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddAnimalScreen(),
                            ),
                          );
                        },
                        icon: const Text('➕'),
                        label: const Text('Add New Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showExportDialog(context),
                        icon: const Text('📤'),
                        label: const Text('Export All (5 Coins)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Recent animals list
                _buildAnimalListItem('🐄 Laxmi (Cow #12)', 'Healthy • Last check: 2 days ago'),
                _buildAnimalListItem('🐃 Kaali (Buffalo #5)', 'Pregnant • Due: 15 days'),
                _buildAnimalListItem('🐐 Chhoti (Goat #8)', 'Monitoring • Vaccination due'),
                
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewAllAnimalsScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('View All'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecordsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ HEALTH RECORDS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildHealthRecordCard('💉 Vaccination Log', 'Track all vaccinations', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ComprehensiveHealthRecordsScreen(),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildHealthRecordCard('🦠 Deworming History', 'Monitor deworming schedule', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ComprehensiveHealthRecordsScreen(),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildHealthRecordCard('💊 Medication Tracker', 'Log treatments & medicines', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ComprehensiveHealthRecordsScreen(),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildHealthRecordCard('🏥 Disease Cases', 'Record illness & recovery', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ComprehensiveHealthRecordsScreen(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBreedingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ BREEDING MANAGEMENT',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildBreedingCard('🔄 Heat/AI Records', 'Track breeding cycles', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BreedingDashboardScreen(),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildBreedingCard('🍼 Pregnancy Tracker', 'Monitor pregnancies', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BreedingDashboardScreen(),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildBreedingCard('🐣 Calving History', 'Birth records & outcomes', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BreedingDashboardScreen(),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildBreedingCard('🧬 Semen/Sire Database', 'Genetics management', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BreedingDashboardScreen(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMilkProductionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '▼ MILK PRODUCTION ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '100L [30 cows] auto write from all cows',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Milk production widget (same as home screen)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMilkCard('🌅 Morning', '22.5L'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMilkCard('🌇 Evening', '20.0L'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.85,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '██████████▊ 85% Daily',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DailyMilkLogScreen(),
                              ),
                            );
                          },
                          icon: const Text('➕'),
                          label: const Text('Log Entry (1C)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MilkProductionDashboardScreen(),
                              ),
                            );
                          },
                          icon: const Text('📊'),
                          label: const Text('Dashboard'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
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

  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ FINANCIAL TRACKING',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFinancialCard('💵 Income/Expense (2 Coins/month)', 'Track farm revenue & costs', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FinancialManagementScreen(),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildFinancialCard('🏷️ Animal Transactions', 'Buy/sell records', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FinancialManagementScreen(),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildFinancialCard('🌾 Feed & Supply Costs', 'Monitor feed expenses', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FinancialManagementScreen(),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildFinancialCard('📈 Profit Analysis', 'Calculate farm profitability', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FinancialManagementScreen(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnimalListItem(String name, String status) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildHealthRecordCard(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedingCard(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildMilkCard(String time, String amount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
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
            Text('Search Records', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search animals, records...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Search across:\n'
              '• Animal names & tags\n'
              '• Health records\n'
              '• Breeding history\n'
              '• Financial records',
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
                  content: Text('Search feature coming soon!'),
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

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('📤', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Export Records', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export all farm records (5 coins)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Includes:\n'
              '• All animal profiles\n'
              '• Health records\n'
              '• Breeding history\n'
              '• Milk production data\n'
              '• Financial records',
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
                  content: Text('Export feature coming soon! (5 coins will be deducted)'),
                  backgroundColor: Colors.amber,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Export (5 Coins)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}