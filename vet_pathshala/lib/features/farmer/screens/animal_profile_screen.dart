import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/animal_model.dart';
import '../services/qr_service.dart';
import '../../coins/providers/coin_provider.dart';
import 'health_records_screen.dart';
import 'breeding_records_screen.dart';
import 'financial_records_screen.dart';
import 'package:intl/intl.dart';

class AnimalProfileScreen extends StatefulWidget {
  final AnimalModel animal;
  
  const AnimalProfileScreen({super.key, required this.animal});

  @override
  State<AnimalProfileScreen> createState() => _AnimalProfileScreenState();
}

class _AnimalProfileScreenState extends State<AnimalProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool showQRCode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animal = widget.animal;
    
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Text(animal.typeEmoji),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${animal.name} Profile',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _shareProfile,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () => setState(() => showQRCode = !showQRCode),
            icon: const Icon(Icons.qr_code),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Info'),
            Tab(icon: Icon(Icons.health_and_safety), text: 'Health'),
            Tab(icon: Icon(Icons.favorite), text: 'Breeding'),
            Tab(icon: Icon(Icons.local_drink), text: 'Milk'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Finance'),
          ],
        ),
      ),
      body: Column(
        children: [
          // QR Code section (collapsible)
          if (showQRCode) _buildQRSection(),
          
          // Animal header
          _buildAnimalHeader(),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildHealthTab(),
                _buildBreedingTab(),
                _buildMilkTab(),
                _buildFinanceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🔲 Animal QR Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => showQRCode = false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              QRService.buildQRWidget(
                QRService.generateAnimalQRData(widget.animal),
                size: 200,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _shareQRCode,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveQRCode,
                    icon: const Icon(Icons.download),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalHeader() {
    final animal = widget.animal;
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Animal photo or emoji
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    child: animal.photoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              animal.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(child: Text(animal.typeEmoji, style: const TextStyle(fontSize: 40))),
                            ),
                          )
                        : Center(
                            child: Text(
                              animal.typeEmoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Animal details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${animal.type} • ${animal.breed}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Age: ${animal.ageString}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: animal.status.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: animal.status.color),
                          ),
                          child: Text(
                            '${animal.status.emoji} ${animal.status.displayName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: animal.status.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Quick stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Tag ID', animal.tagId),
                  _buildStatCard('Gender', animal.gender),
                  _buildStatCard('Origin', animal.origin),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab() {
    final animal = widget.animal;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Basic Information', [
            _buildInfoRow('Name', animal.name),
            _buildInfoRow('Type', animal.type),
            _buildInfoRow('Breed', animal.breed),
            _buildInfoRow('Gender', animal.gender),
            _buildInfoRow('Date of Birth', DateFormat('dd MMM yyyy').format(animal.dateOfBirth)),
            _buildInfoRow('Age', animal.ageString),
            _buildInfoRow('Tag ID', animal.tagId),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Family Tree', [
            _buildInfoRow('Dam (Mother)', animal.dam ?? 'Not recorded'),
            _buildInfoRow('Sire (Father)', animal.sire ?? 'Not recorded'),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Origin & Purchase', [
            _buildInfoRow('Origin', animal.origin),
            if (animal.origin == 'Purchased') ...[
              _buildInfoRow('Purchase Date', 
                animal.purchaseDate != null 
                    ? DateFormat('dd MMM yyyy').format(animal.purchaseDate!)
                    : 'Not recorded'),
              _buildInfoRow('Purchase Price', 
                animal.purchasePrice != null 
                    ? '₹${animal.purchasePrice!.toStringAsFixed(0)}'
                    : 'Not recorded'),
            ],
          ]),
          
          const SizedBox(height: 16),
          
          if (animal.specialMarks != null && animal.specialMarks!.isNotEmpty)
            _buildInfoSection('Special Marks', [
              Text(animal.specialMarks!),
            ]),
          
          const SizedBox(height: 16),
          
          if (animal.customTags.isNotEmpty)
            _buildInfoSection('Tags', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: animal.customTags.map((tag) => Chip(
                  label: Text(tag),
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                )).toList(),
              ),
            ]),
          
          const SizedBox(height: 16),
          
          if (animal.notes != null && animal.notes!.isNotEmpty)
            _buildInfoSection('Notes', [
              Text(animal.notes!),
            ]),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    final animal = widget.animal;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Vaccination History', [
            if (animal.vaccinations.isEmpty)
              const Text('No vaccination records found')
            else
              ...animal.vaccinations.map((vaccination) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.vaccines, color: Colors.green),
                  title: Text(vaccination.vaccineName),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(vaccination.date)),
                  trailing: vaccination.veterinarian != null
                      ? Text('By: ${vaccination.veterinarian}')
                      : null,
                ),
              )),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Health Records', [
            _buildHealthRecordCard(
              'Deworming Schedule',
              'Last: 15 Jan 2024\nNext: 15 Apr 2024',
              Icons.medication,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildHealthRecordCard(
              'Current Treatments',
              'No ongoing treatments',
              Icons.healing,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildHealthRecordCard(
              'Health Issues',
              'No current health issues',
              Icons.health_and_safety,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            
            // Quick action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HealthRecordsScreen(animal: widget.animal),
                    ),
                  );
                },
                icon: const Icon(Icons.health_and_safety),
                label: const Text('View All Health Records'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ]),
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
          _buildInfoSection('Heat Cycle / AI Records', [
            _buildBreedingCard(
              'Last Heat Cycle',
              '28 Jul 2024',
              'Next expected: 18 Aug 2024',
              Icons.favorite,
              Colors.pink,
            ),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Pregnancy Tracking', [
            _buildBreedingCard(
              'Current Status',
              'Pregnant - Month 5',
              'Expected calving: 15 Dec 2024',
              Icons.pregnant_woman,
              Colors.purple,
            ),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Calving History', [
            _buildBreedingCard(
              'Last Calving',
              '20 Jan 2023',
              'Healthy calf born',
              Icons.child_care,
              Colors.green,
            ),
          ]),
          
          const SizedBox(height: 16),
          
          // Quick action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToBreedingRecords(),
              icon: const Icon(Icons.favorite),
              label: const Text('View All Breeding Records'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Daily Milk Production', [
            _buildMilkCard('Today (3 Aug 2024)', '22.5L', '20.0L', '42.5L'),
            _buildMilkCard('Yesterday', '21.0L', '19.5L', '40.5L'),
            _buildMilkCard('2 Aug 2024', '23.0L', '20.5L', '43.5L'),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Production Summary', [
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Weekly Avg', '41.2L', Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Monthly Avg', '39.8L', Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Peak Day', '45.2L', Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Low Day', '35.0L', Colors.red)),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildFinanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Income Records', [
            _buildFinanceCard('Milk Sales (Aug)', '₹12,450', Colors.green),
            _buildFinanceCard('Offspring Sales', '₹0', Colors.grey),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Expense Records', [
            _buildFinanceCard('Feed Costs (Aug)', '₹3,200', Colors.red),
            _buildFinanceCard('Medical Expenses', '₹450', Colors.orange),
            _buildFinanceCard('Other Costs', '₹200', Colors.blue),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoSection('Profitability Analysis', [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.green.shade50],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly Profit:', style: TextStyle(fontSize: 16)),
                      Text('₹8,600', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Profit Margin:', style: TextStyle(fontSize: 14)),
                      Text('69.2%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ]),
          
          const SizedBox(height: 16),
          
          // Quick action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToFinancialRecords(),
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('View All Financial Records'),
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

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ':',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecordCard(String title, String content, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(content),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthRecordsScreen(animal: widget.animal),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreedingCard(String title, String date, String note, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(note, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMilkCard(String date, String morning, String evening, String total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Morning: $morning'),
                Text('Evening: $evening'),
                Text('Total: $total', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String title, String amount, Color color) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  void _shareProfile() async {
    try {
      await QRService.shareAnimalQR(widget.animal);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareQRCode() async {
    try {
      await QRService.shareAnimalQR(widget.animal);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share QR code. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveQRCode() async {
    try {
      final qrData = QRService.generateAnimalQRData(widget.animal);
      final imagePath = await QRService.saveQRCodeImage(qrData, widget.animal.name);
      
      if (mounted) {
        if (imagePath != null) {
          context.read<CoinProvider>().addCoins(1, 'QR Code Save');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR code saved successfully! +1 coin earned'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save QR code. Please check permissions.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save QR code. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToBreedingRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BreedingRecordsScreen(animal: widget.animal),
      ),
    );
  }

  void _navigateToFinancialRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinancialRecordsScreen(animal: widget.animal),
      ),
    );
  }
}