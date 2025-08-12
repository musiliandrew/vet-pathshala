import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/animal_model.dart';
import '../models/health_records_model.dart';
import '../../coins/providers/coin_provider.dart';

class AddHealthRecordScreen extends StatefulWidget {
  final AnimalModel animal;
  final HealthRecordType recordType;
  
  const AddHealthRecordScreen({
    super.key,
    required this.animal,
    required this.recordType,
  });

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _medicationController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextDueDate;
  HealthRecordStatus _selectedStatus = HealthRecordStatus.completed;
  
  // Quick templates based on record type
  List<String> _getQuickTemplates() {
    switch (widget.recordType) {
      case HealthRecordType.vaccination:
        return [
          'FMD Vaccination',
          'Black Quarter',
          'Anthrax',
          'Brucellosis',
          'Rabies',
          'Tetanus',
        ];
      case HealthRecordType.deworming:
        return [
          'Routine Deworming',
          'Heavy Worm Load Treatment',
          'Preventive Deworming',
        ];
      case HealthRecordType.treatment:
        return [
          'Antibiotic Treatment',
          'Anti-inflammatory',
          'Pain Management',
          'Wound Treatment',
        ];
      case HealthRecordType.checkup:
        return [
          'Routine Health Checkup',
          'Pregnancy Check',
          'Post-Treatment Follow-up',
          'Pre-breeding Examination',
        ];
      default:
        return [];
    }
  }

  List<String> _getCommonMedications() {
    switch (widget.recordType) {
      case HealthRecordType.vaccination:
        return [
          'FMD Vaccine',
          'Black Quarter Vaccine',
          'Anthrax Vaccine',
          'Brucella Vaccine',
        ];
      case HealthRecordType.deworming:
        return [
          'Albendazole',
          'Fenbendazole',
          'Ivermectin',
          'Levamisole',
        ];
      case HealthRecordType.treatment:
        return [
          'Oxytetracycline',
          'Penicillin',
          'Meloxicam',
          'Dexamethasone',
        ];
      default:
        return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _setDefaultValues();
  }

  void _setDefaultValues() {
    // Set default title based on record type
    _titleController.text = widget.recordType.displayName;
    
    // Set default status based on record type
    if (widget.recordType == HealthRecordType.checkup) {
      _selectedStatus = HealthRecordStatus.scheduled;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _veterinarianController.dispose();
    _medicationController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.recordType.icon} Add ${widget.recordType.displayName}'),
            Text(
              '${widget.animal.typeEmoji} ${widget.animal.name}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showQuickTemplates,
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Quick Templates',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              _buildBasicInfoCard(),
              const SizedBox(height: 16),
              
              // Date and Status Card
              _buildDateStatusCard(),
              const SizedBox(height: 16),
              
              // Medical Details Card
              _buildMedicalDetailsCard(),
              const SizedBox(height: 16),
              
              // Next Due Date Card (for recurring treatments)
              if (_shouldShowNextDueDate())
                _buildNextDueDateCard(),
              
              const SizedBox(height: 16),
              
              // Additional Notes Card
              _buildNotesCard(),
              
              const SizedBox(height: 24),
              
              // Save Button
              _buildSaveButton(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.recordType.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter record title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter detailed description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date & Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            
            // Date picker
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Date: '),
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status dropdown
            DropdownButtonFormField<HealthRecordStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: HealthRecordStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Text(status.icon),
                      const SizedBox(width: 8),
                      Text(status.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            
            // Veterinarian field
            TextFormField(
              controller: _veterinarianController,
              decoration: InputDecoration(
                labelText: 'Veterinarian',
                hintText: 'Enter veterinarian name',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _showVeterinarianList,
                  icon: const Icon(Icons.list),
                  tooltip: 'Select from list',
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Medication field
            TextFormField(
              controller: _medicationController,
              decoration: InputDecoration(
                labelText: 'Medication/Vaccine',
                hintText: 'Enter medication or vaccine name',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _showMedicationList,
                  icon: const Icon(Icons.medication),
                  tooltip: 'Common medications',
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cost field
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost (₹)',
                hintText: 'Enter cost amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final cost = double.tryParse(value);
                  if (cost == null || cost < 0) {
                    return 'Please enter a valid cost';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextDueDateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Follow-up Schedule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Checkbox(
                  value: _nextDueDate != null,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _nextDueDate = DateTime.now().add(_getDefaultInterval());
                      } else {
                        _nextDueDate = null;
                      }
                    });
                  },
                ),
                const Text('Schedule next appointment'),
              ],
            ),
            
            if (_nextDueDate != null) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectNextDueDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Next due: '),
                      Text(
                        DateFormat('dd MMM yyyy').format(_nextDueDate!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Quick interval buttons
              Wrap(
                spacing: 8,
                children: _getIntervalButtons(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any additional notes, observations, or instructions',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveRecord,
        icon: const Icon(Icons.save),
        label: const Text('Save Health Record'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  List<Widget> _getIntervalButtons() {
    final intervals = <String, Duration>{
      '1 Month': const Duration(days: 30),
      '3 Months': const Duration(days: 90),
      '6 Months': const Duration(days: 180),
      '1 Year': const Duration(days: 365),
    };

    return intervals.entries.map((entry) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _nextDueDate = _selectedDate.add(entry.value);
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.withOpacity(0.1),
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          entry.key,
          style: const TextStyle(fontSize: 12),
        ),
      );
    }).toList();
  }

  Duration _getDefaultInterval() {
    switch (widget.recordType) {
      case HealthRecordType.vaccination:
        return const Duration(days: 365); // 1 year
      case HealthRecordType.deworming:
        return const Duration(days: 90); // 3 months
      case HealthRecordType.checkup:
        return const Duration(days: 30); // 1 month
      default:
        return const Duration(days: 90); // 3 months default
    }
  }

  bool _shouldShowNextDueDate() {
    return [
      HealthRecordType.vaccination,
      HealthRecordType.deworming,
      HealthRecordType.checkup,
    ].contains(widget.recordType);
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectNextDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (date != null) {
      setState(() {
        _nextDueDate = date;
      });
    }
  }

  void _showQuickTemplates() {
    final templates = _getQuickTemplates();
    if (templates.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Templates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...templates.map((template) => ListTile(
              leading: Text(widget.recordType.icon, style: const TextStyle(fontSize: 20)),
              title: Text(template),
              onTap: () {
                _titleController.text = template;
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showMedicationList() {
    final medications = _getCommonMedications();
    if (medications.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Common Medications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...medications.map((medication) => ListTile(
              leading: const Icon(Icons.medication, color: Colors.blue),
              title: Text(medication),
              onTap: () {
                _medicationController.text = medication;
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showVeterinarianList() {
    final vets = [
      'Dr. Sharma',
      'Dr. Kumar',
      'Dr. Patel',
      'Dr. Singh',
      'Dr. Reddy',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Veterinarian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...vets.map((vet) => ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: Text(vet),
              onTap: () {
                _veterinarianController.text = vet;
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
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
            Text('Saving health record...'),
          ],
        ),
      ),
    );

    try {
      // Create health record
      final record = HealthRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        animalId: widget.animal.id,
        type: widget.recordType,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        veterinarian: _veterinarianController.text.isNotEmpty ? _veterinarianController.text : null,
        medication: _medicationController.text.isNotEmpty ? _medicationController.text : null,
        cost: _costController.text.isNotEmpty ? double.parse(_costController.text) : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        status: _selectedStatus,
        nextDueDate: _nextDueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simulate saving to database
      await Future.delayed(const Duration(seconds: 1));

      // In real app, save to Firebase here
      // await FirebaseFirestore.instance.collection('health_records').add(record.toFirestore());

      // Award coins
      context.read<CoinProvider>().addCoins(3, 'Health Record Added');

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context, record); // Return to previous screen with record
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Health record saved successfully! +3 coins earned'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save record: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}