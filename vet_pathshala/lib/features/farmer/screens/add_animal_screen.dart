import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/unified_theme.dart';
import '../services/qr_service.dart';
import '../models/animal_model.dart';
import '../../coins/providers/coin_provider.dart';
import 'animal_profile_screen.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
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

  DateTime selectedBirthDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime? selectedPurchaseDate;

  List<String> customTags = [];
  List<Map<String, String>> vaccinationHistory = [
    {'date': '15 Jan 2024', 'vaccine': 'Foot & Mouth (Booster)'},
    {'date': '30 Dec 2023', 'vaccine': 'Black Quarter'},
  ];

  @override
  Widget build(BuildContext context) {
    print('AddAnimalScreen build called'); // Debug
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('➕ ADD NEW ANIMAL'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '🏡 Back',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
              
              // Basic Info
              _buildBasicInfoSection(),
              const SizedBox(height: 16),
              
              // Family Tree
              _buildFamilyTreeSection(),
              const SizedBox(height: 16),
              
              // Origin Details
              _buildOriginSection(),
              const SizedBox(height: 16),
              
              // Breed and Marks
              _buildBreedSection(),
              const SizedBox(height: 16),
              
              // Custom Tags
              _buildCustomTagsSection(),
              const SizedBox(height: 16),
              
              // Vaccination History
              _buildVaccinationSection(),
              const SizedBox(height: 16),
              
              // Notes
              _buildNotesSection(),
              const SizedBox(height: 24),
              
              // Save Button
              _buildSaveButton(),
            ],
          ),
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🐄', style: TextStyle(fontSize: 40)),
                SizedBox(height: 8),
                Text('(Tap to add photo)', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('📷 Camera    🖼️ Gallery'),
                  ],
                ),
              ],
            ),
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        children: [
          Text('🔲 QR Code: [Generate = 10 coins ]'),
          SizedBox(height: 8),
          Text('Download Qr Code'),
          Text('🎯 Scan to view full profile'),
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ANIMAL TYPE:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: ['🐄', '🐃', '🐐', '🐑', '🐕'].map((emoji) {
              String type = '';
              switch (emoji) {
                case '🐄': type = 'Cow'; break;
                case '🐃': type = 'Buffalo'; break;
                case '🐐': type = 'Goat'; break;
                case '🐑': type = 'Sheep'; break;
                case '🐕': type = 'Dog'; break;
              }
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedAnimalType = type),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedAnimalType == type ? Colors.green.shade100 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedAnimalType == type ? Colors.green : Colors.grey,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 24)),
                        Text(type, style: const TextStyle(fontSize: 10)),
                      ],
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

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '🔖 NAME',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagIdController,
            decoration: const InputDecoration(
              labelText: '#️⃣ TAG ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedBirthDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => selectedBirthDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('🎂 DOB: ${DateFormat('dd MMM yyyy').format(selectedBirthDate)}'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: '⚥ GENDER',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female'].map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedGender = value!),
                ),
              ),
            ],
          ),
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('FAMILY TREE:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _damController,
            decoration: const InputDecoration(
              labelText: '👩 DAM (Mother)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sireController,
            decoration: const InputDecoration(
              labelText: '👨 SIRE (Father)',
              border: OutlineInputBorder(),
            ),
          ),
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: selectedOrigin,
            decoration: const InputDecoration(
              labelText: '🏠 ORIGIN',
              border: OutlineInputBorder(),
            ),
            items: ['Home-born', 'Purchased'].map((origin) {
              return DropdownMenuItem(value: origin, child: Text(origin));
            }).toList(),
            onChanged: (value) => setState(() => selectedOrigin = value!),
          ),
          if (selectedOrigin == 'Purchased') ...[
            const SizedBox(height: 12),
            const Text('💰 PURCHASE DETAILS:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedPurchaseDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => selectedPurchaseDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        selectedPurchaseDate != null 
                          ? DateFormat('dd/MM/yyyy').format(selectedPurchaseDate!) 
                          : 'Select Date'
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _purchasePriceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedBreed,
            decoration: const InputDecoration(
              labelText: '🧬 BREED',
              border: OutlineInputBorder(),
            ),
            items: ['Gir', 'Holstein', 'Jersey', 'Sahiwal', 'Tharparkar'].map((breed) {
              return DropdownMenuItem(value: breed, child: Text(breed));
            }).toList(),
            onChanged: (value) => setState(() => selectedBreed = value!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _specialMarksController,
            decoration: const InputDecoration(
              labelText: '🏷️ SPECIAL MARKS',
              border: OutlineInputBorder(),
            ),
          ),
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏷️ CUSTOM TAGS:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ...customTags.map((tag) => Chip(
                label: Text(tag),
                onDeleted: () => setState(() => customTags.remove(tag)),
              )),
              ActionChip(
                label: const Text('+ Add Tag'),
                onPressed: () {
                  // Add tag functionality
                  setState(() => customTags.add('High Milk'));
                },
              ),
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💉 VACCINATION HISTORY', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...vaccinationHistory.map((vaccination) => Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('🗓️ ${vaccination['date']}: ${vaccination['vaccine']}'),
          )),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Add vaccination functionality
            },
            child: const Text('[+] Add New Vaccination Record'),
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          labelText: '📝 NOTES',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
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
        ),
      ),
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