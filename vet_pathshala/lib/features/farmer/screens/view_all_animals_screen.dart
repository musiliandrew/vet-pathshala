import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/unified_theme.dart';
import '../services/qr_service.dart';
import '../models/animal_model.dart';
import '../../coins/providers/coin_provider.dart';
import 'qr_scanner_screen.dart';
import 'animal_profile_screen.dart';
import 'add_animal_screen.dart';

class ViewAllAnimalsScreen extends StatefulWidget {
  const ViewAllAnimalsScreen({super.key});

  @override
  State<ViewAllAnimalsScreen> createState() => _ViewAllAnimalsScreenState();
}

class _ViewAllAnimalsScreenState extends State<ViewAllAnimalsScreen> {
  String selectedType = 'All';
  String selectedStatus = 'All';
  String selectedAge = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> animals = [
    {
      'id': '12',
      'name': 'Laxmi',
      'type': '🐄',
      'typeName': 'Cow',
      'status': 'Urgent',
      'statusColor': Colors.red,
      'age': '4 years',
      'lastMilk': '22.5L',
      'date': '3 Aug 2024',
      'notes': 'Heat due in 2 days • Pregnancy: Month 5',
      'qrCode': '■■■■',
    },
    {
      'id': '5',
      'name': 'Raja',
      'type': '🐃',
      'typeName': 'Buffalo',
      'status': 'Healthy',
      'statusColor': Colors.green,
      'age': '6 years',
      'lastMilk': '18.0L',
      'date': '3 Aug 2024',
      'notes': 'Last Vaccine: FMD (15 Jul 2024)',
      'qrCode': '■■■■',
    },
    {
      'id': '8',
      'name': 'Chhoti',
      'type': '🐐',
      'typeName': 'Goat',
      'status': 'Monitoring',
      'statusColor': Colors.orange,
      'age': '2 years',
      'lastMilk': '',
      'date': '10 Jul 2024',
      'notes': 'Weight loss detected (-5% in 2 weeks)',
      'qrCode': '■■■■',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          '🐄 ALL ANIMALS (50)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🏡', style: TextStyle(fontSize: 16)),
                Icon(Icons.arrow_back, color: Colors.white, size: 16),
                Text('Back', style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),
          
          // Action Buttons  
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _showFilters(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Filter', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showQRScanner(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('QR Scan', style: TextStyle(fontSize: 12)),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showDownloadDialog(context),
                  icon: const Text('📤', style: TextStyle(fontSize: 12)),
                  label: const Text('Download animal lists (3 Coins)', style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          
          // Animals List
          Expanded(
            child: _buildAnimalsList(),
          ),
          
          // Add New Animal Button
          _buildAddAnimalButton(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ FILTERS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '🔍 Search animals...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 12),
          
          // Type Filter
          Row(
            children: [
              const Text('Type: ', style: TextStyle(fontWeight: FontWeight.w500)),
              _buildFilterChip('All'),
              _buildAnimalTypeChip('🐄'),
              _buildAnimalTypeChip('🐃'),
              _buildAnimalTypeChip('🐐'),
              _buildAnimalTypeChip('🐑'),
              _buildAnimalTypeChip('🐕'),
            ],
          ),
          const SizedBox(height: 8),
          
          // Status Filter
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w500)),
              _buildFilterChip('All'),
              _buildStatusChip('🟢', 'Healthy'),
              _buildStatusChip('🟡', 'Monitoring'),
              _buildStatusChip('🔴', 'Urgent'),
            ],
          ),
          const SizedBox(height: 8),
          
          // Age Filter
          Row(
            children: [
              const Text('Age: ', style: TextStyle(fontWeight: FontWeight.w500)),
              _buildFilterChip('All'),
              _buildFilterChip('<1yr'),
              _buildFilterChip('1-3yrs'),
              _buildFilterChip('3+yrs'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = (label == 'All' && selectedType == 'All') ||
                      selectedType == label ||
                      selectedStatus == label ||
                      selectedAge == label;
                      
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (label.contains('yr') || label == 'All') {
              selectedAge = selected ? label : 'All';
            } else {
              selectedType = selected ? label : 'All';
            }
          });
        },
        selectedColor: const Color(0xFF2E7D32),
        backgroundColor: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  Widget _buildAnimalTypeChip(String emoji) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedType = selectedType == emoji ? 'All' : emoji;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selectedType == emoji ? const Color(0xFF2E7D32) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String emoji, String status) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatus = selectedStatus == status ? 'All' : status;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 2),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                color: selectedStatus == status ? const Color(0xFF2E7D32) : Colors.black54,
                fontWeight: selectedStatus == status ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, size: 16),
              label: const Text('QR Scan', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle download (requires 3 coins)
                _showCoinRequiredDialog();
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('📤 Download animal lists (3 Coins)', 
                               style: TextStyle(fontSize: 10)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: animals.length,
      itemBuilder: (context, index) {
        final animal = animals[index];
        return _buildAnimalCard(animal);
      },
    );
  }

  Widget _buildAnimalCard(Map<String, dynamic> animal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: animal['statusColor'].withOpacity(0.3),
          width: 1,
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                '${animal['type']} ${animal['name']} (${animal['typeName']} #${animal['id']})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: animal['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: animal['statusColor']),
                ),
                child: Text(
                  '${_getStatusEmoji(animal['status'])} ${animal['status']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: animal['statusColor'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Details Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QR: ${animal['qrCode']}', style: const TextStyle(fontSize: 12)),
                    Text('Age: ${animal['age']}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              if (animal['lastMilk'].isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last Milk: ${animal['lastMilk']}', 
                           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      Text('🗓️ ${animal['date']}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Notes
          if (animal['notes'].isNotEmpty)
            Text(
              '⚠️ ${animal['notes']}',
              style: TextStyle(
                fontSize: 12,
                color: animal['statusColor'],
                fontStyle: FontStyle.italic,
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to animal profile
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showCoinRequiredDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Log Activity (1 Coin)',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddAnimalButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAnimalScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('➕ Add New Animal'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  String _getStatusEmoji(String status) {
    switch (status) {
      case 'Healthy':
        return '🟢';
      case 'Monitoring':
        return '🟡';
      case 'Urgent':
        return '🔴';
      default:
        return '⚪';
    }
  }

  void _showCoinRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('🪙 Coins Required'),
          content: const Text(
            'This feature requires coins to unlock. Would you like to earn some coins or purchase them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to coin store
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('Get Coins'),
            ),
          ],
        );
      },
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔍 Filter Animals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Current Filters:', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('• Type: $selectedType', style: const TextStyle(fontSize: 12)),
            Text('• Status: $selectedStatus', style: const TextStyle(fontSize: 12)),
            Text('• Age: $selectedAge', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 Search Animals'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search by name, tag, breed...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📱 QR Scanner'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('QR code scanner will open camera to scan animal tags.'),
            SizedBox(height: 8),
            Text('Compatible with all Vet-Pathshala animal QR codes.', 
                 style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('QR Scanner opening...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Open Scanner', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📤 Download Animal Lists'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Download complete animal records (3 coins)'),
            SizedBox(height: 12),
            Text('Export includes:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• All animal profiles with photos'),
            Text('• Health and vaccination records'),
            Text('• Breeding and pregnancy data'),
            Text('• Milk production history'),
            Text('• Financial transaction records'),
            SizedBox(height: 8),
            Text('Format: PDF + Excel spreadsheet', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download starting... (3 coins deducted)'),
                  backgroundColor: Colors.amber,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Download (3 Coins)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Add New Animal Screen based on add_new_animal_profile.md
class AddNewAnimalScreen extends StatefulWidget {
  const AddNewAnimalScreen({super.key});

  @override
  State<AddNewAnimalScreen> createState() => _AddNewAnimalScreenState();
}

class _AddNewAnimalScreenState extends State<AddNewAnimalScreen> {
  String selectedAnimalType = 'Cow';
  String selectedGender = 'Female';
  String selectedOrigin = 'Home-born';
  String selectedBreed = 'Gir';
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagIdController = TextEditingController(text: 'RF-2024-');
  final TextEditingController _damController = TextEditingController();
  final TextEditingController _sireController = TextEditingController();
  final TextEditingController _specialMarksController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();
  
  DateTime selectedBirthDate = DateTime(2022, 8, 15);
  DateTime? selectedPurchaseDate;
  List<String> customTags = ['High Milk', 'Breeder', 'Vaccinated'];
  List<Map<String, String>> vaccinationHistory = [
    {'date': '15 Jan 2024', 'vaccine': 'Foot & Mouth (Booster)'},
    {'date': '30 Dec 2023', 'vaccine': 'Black Quarter'},
  ];

  @override
  Widget build(BuildContext context) {
    print('AddNewAnimalScreen build called'); // Debug
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('➕ ADD NEW ANIMAL'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🏡', style: TextStyle(fontSize: 16)),
                Icon(Icons.arrow_back, size: 16),
                Text(' Back', style: TextStyle(fontSize: 12)),
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
            // Photo Section
            _buildPhotoSection(),
            const SizedBox(height: 16),
            
            // QR Code Section
            _buildQRSection(),
            const SizedBox(height: 16),
            
            // Animal Type Selection
            _buildAnimalTypeSection(),
            const SizedBox(height: 16),
            
            // Basic Information
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            
            // Family Tree
            _buildFamilyTreeSection(),
            const SizedBox(height: 16),
            
            // Origin & Purchase Details
            _buildOriginSection(),
            const SizedBox(height: 16),
            
            // Breed & Special Marks
            _buildBreedSection(),
            const SizedBox(height: 16),
            
            // Custom Tags
            _buildCustomTagsSection(),
            const SizedBox(height: 16),
            
            // Records Section (placeholder)
            _buildRecordsSection(),
            const SizedBox(height: 16),
            
            // Vaccination History
            _buildVaccinationSection(),
            const SizedBox(height: 16),
            
            // Notes
            _buildNotesSection(),
            const SizedBox(height: 24),
            
            // Save Button
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🐄', style: TextStyle(fontSize: 48)),
                Text('(Tap to add photo)', 
                     style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Handle camera
                },
                icon: const Text('📷'),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Handle gallery
                },
                icon: const Text('🖼️'),
                label: const Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔲 QR Code: '),
              ElevatedButton(
                onPressed: () {
                  _showGenerateQRDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: const Text('Generate = 10 coins', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '🎯 Scan to view full profile',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalTypeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ANIMAL TYPE: ▾ $selectedAnimalType ▼',
               style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnimalTypeButton('🐄', 'Cow'),
              _buildAnimalTypeButton('🐃', 'Buffalo'),
              _buildAnimalTypeButton('🐐', 'Goat'),
              _buildAnimalTypeButton('🐑', 'Sheep'),
              _buildAnimalTypeButton('🐕', 'Dog'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalTypeButton(String emoji, String type) {
    final isSelected = selectedAnimalType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnimalType = type;
        });
      },
      child: Container(
        width: 60,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            Text(
              type,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          _buildTextField('🔖 NAME:', _nameController, 'Enter animal name'),
          const SizedBox(height: 12),
          _buildTextField('#️⃣ TAG ID:', _tagIdController, 'RF-2024-'),
          const SizedBox(height: 12),
          _buildDateField('🎂 DATE OF BIRTH:', selectedBirthDate, (date) {
            setState(() {
              selectedBirthDate = date;
            });
          }),
          const SizedBox(height: 12),
          _buildDropdownField('⚥ GENDER:', selectedGender, ['Female', 'Male'], (value) {
            setState(() {
              selectedGender = value!;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildFamilyTreeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FAMILY TREE:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTextField('👩 DAM (Mother):', _damController, 'Enter mother\'s name'),
          const SizedBox(height: 12),
          _buildTextField('👨 SIRE (Father):', _sireController, 'Enter father\'s name'),
        ],
      ),
    );
  }

  Widget _buildOriginSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField('🏠 ORIGIN:', selectedOrigin, ['Home-born', 'Purchased'], (value) {
            setState(() {
              selectedOrigin = value!;
            });
          }),
          if (selectedOrigin == 'Purchased') ...[
            const SizedBox(height: 12),
            const Text(
              '💰 PURCHASE DETAILS:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateField('Date:', selectedPurchaseDate, (date) {
                    setState(() {
                      selectedPurchaseDate = date;
                    });
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField('Price:', _purchasePriceController, '₹ Enter price'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreedSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          _buildDropdownField('🧬 BREED:', selectedBreed, ['Gir', 'Holstein', 'Jersey', 'Sahiwal'], (value) {
            setState(() {
              selectedBreed = value!;
            });
          }),
          const SizedBox(height: 12),
          _buildTextField('🏷️ SPECIAL MARKS:', _specialMarksController, 'Enter special markings'),
        ],
      ),
    );
  }

  Widget _buildCustomTagsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏷️ CUSTOM TAGS:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...customTags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    customTags.remove(tag);
                  });
                },
              )),
              ActionChip(
                label: const Text('+ Add Tag'),
                onPressed: () {
                  _showAddTagDialog();
                },
                backgroundColor: Colors.grey.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Daily Milk Record', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Production record', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Daily Feed Amount', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Last Deworming', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💉 VACCINATION HISTORY', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...vaccinationHistory.map((record) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('🗓️ ${record['date']}: ${record['vaccine']}', 
                              style: const TextStyle(fontSize: 12)),
                )),
                TextButton(
                  onPressed: () {
                    _showAddVaccinationDialog();
                  },
                  child: const Text('[+] Add New Vaccination Record'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📝 NOTES:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter additional notes about the animal...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _saveAnimalProfile();
        },
        icon: const Text('💾'),
        label: const Text('Save Animal Profile'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onChanged(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    date != null 
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  const Icon(Icons.calendar_today, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter tag name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  customTags.add(controller.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddVaccinationDialog() {
    final dateController = TextEditingController();
    final vaccineController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Vaccination Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(hintText: 'Date (e.g., 15 Jan 2024)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: vaccineController,
              decoration: const InputDecoration(hintText: 'Vaccine name'),
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
              if (dateController.text.isNotEmpty && vaccineController.text.isNotEmpty) {
                setState(() {
                  vaccinationHistory.add({
                    'date': dateController.text,
                    'vaccine': vaccineController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showGenerateQRDialog() async {
    final coinProvider = context.read<CoinProvider>();
    const requiredCoins = 10;

    if (coinProvider.currentBalance < requiredCoins) {
      _showCoinRequiredDialog('Generate QR Code', requiredCoins);
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔲 Generate QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Generate a high-quality QR code for this animal profile?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Cost: $requiredCoins coins',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Google Lens compatible\n• High-quality scanning\n• Shareable format',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _generateQRCode();
    }
  }

  void _generateQRCode() async {
    // For demo, create a sample animal - in real app this would be current animal being added
    final sampleAnimal = AnimalModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.isNotEmpty ? _nameController.text : 'Sample Animal',
      type: selectedAnimalType,
      tagId: _tagIdController.text,
      dateOfBirth: selectedBirthDate,
      gender: selectedGender,
      origin: selectedOrigin,
      breed: selectedBreed,
      customTags: customTags,
      vaccinations: vaccinationHistory.map((v) => VaccinationRecord(
        vaccineName: v['vaccine']!,
        date: DateTime.now(), // In real app, parse date
      )).toList(),
      qrCode: '',
      ownerId: 'current_user_id', // In real app, get from auth
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: AnimalStatus.healthy,
    );

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating QR code...'),
            ],
          ),
        ),
      );

      // Generate QR code data
      final qrData = QRService.generateAnimalQRData(sampleAnimal);
      
      // Save QR code image
      final imagePath = await QRService.saveQRCodeImage(qrData, sampleAnimal.name);
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (imagePath != null) {
        // Deduct coins and show success
        context.read<CoinProvider>().deductCoins(10, 'QR Code Generation');
        
        // Show QR code dialog
        _showQRCodePreview(qrData, sampleAnimal.name);
      } else {
        throw Exception('Failed to generate QR code image');
      }
      
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate QR code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQRCodePreview(String qrData, String animalName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '✅ QR Code Generated!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 20),
              
              // QR Code display
              QRService.buildQRWidget(qrData, size: 200),
              
              const SizedBox(height: 20),
              
              Text(
                'QR code for $animalName has been generated and saved to your device.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        // For demo, create animal instance for sharing
                        final animal = AnimalModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: animalName,
                          type: 'cow',
                          tagId: 'DEMO-001',
                          dateOfBirth: DateTime.now().subtract(const Duration(days: 365)),
                          gender: 'Female',
                          origin: 'Home-born',
                          breed: 'Holstein',
                          customTags: [],
                          vaccinations: [],
                          qrCode: qrData,
                          ownerId: 'demo',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          status: AnimalStatus.healthy,
                        );
                        
                        await QRService.shareAnimalQR(animal);
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to share QR code'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
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

  void _showCoinRequiredDialog(String feature, int coins) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('🪙 $feature'),
          content: Text(
            'This feature requires $coins coins to unlock. Would you like to earn some coins or purchase them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to coin store
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('Get Coins'),
            ),
          ],
        );
      },
    );
  }

  void _saveAnimalProfile() async {
    // Validate required fields
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter animal name')),
      );
      return;
    }

    if (_tagIdController.text.isEmpty || _tagIdController.text == 'RF-2024-') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the tag ID')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creating animal profile...'),
          ],
        ),
      ),
    );

    try {
      // Create AnimalModel
      final animalId = DateTime.now().millisecondsSinceEpoch.toString();
      final animal = AnimalModel(
        id: animalId,
        name: _nameController.text,
        type: selectedAnimalType,
        tagId: _tagIdController.text,
        dateOfBirth: selectedBirthDate,
        gender: selectedGender,
        breed: selectedBreed,
        ownerId: 'current_farmer', // In real app, get from auth
        status: AnimalStatus.healthy,
        dam: _damController.text.isNotEmpty ? _damController.text : null,
        sire: _sireController.text.isNotEmpty ? _sireController.text : null,
        origin: selectedOrigin,
        purchaseDate: selectedOrigin == 'Purchased' ? selectedPurchaseDate : null,
        purchasePrice: selectedOrigin == 'Purchased' && _purchasePriceController.text.isNotEmpty 
            ? double.tryParse(_purchasePriceController.text) : null,
        specialMarks: _specialMarksController.text.isNotEmpty ? _specialMarksController.text : null,
        customTags: customTags,
        vaccinations: vaccinationHistory.map((v) => VaccinationRecord(
          vaccineName: v['vaccine']!,
          date: DateFormat('dd MMM yyyy').parse(v['date']!),
          veterinarian: null,
          notes: null,
        )).toList(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        qrCode: 'https://vetpathshala.app/animal/$animalId',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simulate saving to database
      await Future.delayed(const Duration(seconds: 1));

      // Award coins for creating new animal profile
      if (mounted) {
        context.read<CoinProvider>().addCoins(10, 'New Animal Profile Created');
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show success dialog with QR code generation option
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('✅ Success!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Animal profile for ${_nameController.text} has been saved successfully!',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '+10 coins earned! 🪙',
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Would you like to:'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Return to animals list
                  },
                  child: const Text('Done'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => AnimalProfileScreen(animal: animal),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save animal profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagIdController.dispose();
    _damController.dispose();
    _sireController.dispose();
    _specialMarksController.dispose();
    _notesController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }
}