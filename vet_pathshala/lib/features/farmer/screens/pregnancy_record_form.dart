import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class PregnancyRecordForm extends StatefulWidget {
  const PregnancyRecordForm({super.key});

  @override
  State<PregnancyRecordForm> createState() => _PregnancyRecordFormState();
}

class _PregnancyRecordFormState extends State<PregnancyRecordForm> {
  String selectedEntryType = 'Recheck';
  String selectedAnimal = 'Laxmi (Cow12)';
  String confirmationDate = '20 Aug 2024';
  String selectedMethod = 'PD Test';
  String selectedSire = 'HF-5678 (Holstein)';
  String gestationDays = '145 (Auto)';
  String expectedCalving = '15 Sep ±3d (Auto)';
  String notes = 'Right horn pregnancy, normal fluids';
  String selectedVet = 'Dr. Sharma';
  String findings = 'Normal';
  String nextVisit = '1 Sep 2024';
  
  bool showPregnancyDetails = true;
  bool showVetCheckup = true;
  bool showRiskFactors = true;
  
  Map<String, bool> riskFactors = {
    'History of Dystocia': true,
    'Twin Pregnancy': true,
    'Metabolic Disorders': false,
    'Age >8 years': false,
    'First Pregnancy': false,
  };

  final List<String> entryTypes = ['New Pregnancy', 'Recheck', 'Loss Record'];
  final List<String> animals = ['Laxmi (Cow12)', 'Kaali (Buffalo5)', 'Sunita (Cow15)', 'Gopi (Buffalo8)'];
  final List<String> methods = ['PD Test', 'Ultrasound', 'Blood Test', 'Rectal Palpation'];
  final List<String> sires = ['HF-5678 (Holstein)', 'JER-2341 (Jersey)', 'MUR-8890 (Murrah)', 'Local Bull'];
  final List<String> vets = ['Dr. Sharma', 'Dr. Patel', 'Dr. Kumar', 'Dr. Singh'];
  final List<String> findingsOptions = ['Normal', 'Concerns', 'High Risk', 'Monitor Closely'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('➕', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'ADD PREGNANCY RECORD',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Text('❌', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Entry type selection
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '░░░░░░░░░░░░░░░ ENTRY TYPE ░░░░░░░░░░░░░░░░░░░░░░░░',
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
                    
                    // Radio buttons for entry type
                    Row(
                      children: entryTypes.map((type) {
                        final isSelected = selectedEntryType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedEntryType = type),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey),
                                    color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                                  ),
                                  child: isSelected 
                                    ? const Icon(Icons.circle, size: 12, color: Colors.white)
                                    : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Basic information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildDropdownField('Animal:', selectedAnimal, animals, (value) {
                            setState(() => selectedAnimal = value!);
                          }),
                          const SizedBox(height: 12),
                          _buildDropdownField('Confirmation Date:', confirmationDate, ['20 Aug 2024', '21 Aug 2024', '22 Aug 2024'], (value) {
                            setState(() => confirmationDate = value!);
                          }),
                          const SizedBox(height: 12),
                          _buildDropdownField('Method:', selectedMethod, methods, (value) {
                            setState(() => selectedMethod = value!);
                          }),
                          const SizedBox(height: 12),
                          _buildDropdownField('Sire:', selectedSire, sires, (value) {
                            setState(() => selectedSire = value!);
                          }),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Pregnancy Details Section
                    _buildExpandableSection(
                      '▼ PREGNANCY DETAILS', 
                      showPregnancyDetails, 
                      () => setState(() => showPregnancyDetails = !showPregnancyDetails),
                      _buildPregnancyDetailsContent(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Veterinary Checkup Section
                    _buildExpandableSection(
                      '▼ VETERINARY CHECKUP (Optional)', 
                      showVetCheckup, 
                      () => setState(() => showVetCheckup = !showVetCheckup),
                      _buildVetCheckupContent(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Risk Factors Section
                    _buildExpandableSection(
                      '▼ RISK FACTORS', 
                      showRiskFactors, 
                      () => setState(() => showRiskFactors = !showRiskFactors),
                      _buildRiskFactorsContent(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveRecord(),
                      icon: const Text('📌'),
                      label: const Text('Save'),
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
                      onPressed: () => _resetForm(),
                      icon: const Text('🔄'),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addReminders(),
                      icon: const Text('📅'),
                      label: const Text('Reminders'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4CAF50),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  Widget _buildExpandableSection(String title, bool isExpanded, VoidCallback onTap, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
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
        ],
      ),
    );
  }

  Widget _buildPregnancyDetailsContent() {
    return Column(
      children: [
        _buildDropdownField('Gestation Days:', gestationDays, ['145 (Auto)', '120', '150', '180'], (value) {
          setState(() => gestationDays = value!);
        }),
        const SizedBox(height: 12),
        _buildReadOnlyField('Expected Calving:', expectedCalving),
        const SizedBox(height: 12),
        _buildTextField('Notes:', notes, (value) {
          setState(() => notes = value);
        }),
      ],
    );
  }

  Widget _buildVetCheckupContent() {
    return Column(
      children: [
        _buildDropdownField('Vet:', selectedVet, vets, (value) {
          setState(() => selectedVet = value!);
        }),
        const SizedBox(height: 12),
        _buildDropdownField('Findings:', findings, findingsOptions, (value) {
          setState(() => findings = value!);
        }),
        const SizedBox(height: 12),
        _buildDropdownField('Next Visit:', nextVisit, ['1 Sep 2024', '15 Sep 2024', '1 Oct 2024'], (value) {
          setState(() => nextVisit = value!);
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text('🖼️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Add Ultrasound',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => _addUltrasoundPhoto(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: const Text('Add Photo', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskFactorsContent() {
    return Column(
      children: [
        ...riskFactors.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Checkbox(
                  value: entry.value,
                  onChanged: (value) {
                    setState(() {
                      riskFactors[entry.key] = value!;
                    });
                  },
                  activeColor: Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      color: entry.value ? Colors.red : Colors.black87,
                      fontWeight: entry.value ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _addCustomRisk(),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Custom Risk'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: const BorderSide(color: Colors.orange),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                onChanged: onChanged,
                isExpanded: true,
                icon: const Text('▼', style: TextStyle(fontSize: 12)),
                items: options.map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option, style: const TextStyle(fontSize: 14)),
                )).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: TextEditingController(text: value),
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.withOpacity(0.1),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addUltrasoundPhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🖼️', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Add Ultrasound Photo', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                  Text('Tap to add ultrasound image', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Photo will be saved with pregnancy record and used for tracking fetal development.'),
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
                  content: Text('📸 Photo upload feature coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addCustomRisk() {
    String customRisk = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Custom Risk Factor'),
        content: TextField(
          onChanged: (value) => customRisk = value,
          decoration: const InputDecoration(
            hintText: 'Enter custom risk factor...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (customRisk.isNotEmpty) {
                setState(() {
                  riskFactors[customRisk] = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Added custom risk: $customRisk'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Add Risk', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveRecord() {
    // Validate form
    if (selectedAnimal.isEmpty || confirmationDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${selectedEntryType.toLowerCase()} record saved for $selectedAnimal!'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      selectedEntryType = 'New Pregnancy';
      selectedAnimal = 'Laxmi (Cow12)';
      confirmationDate = '20 Aug 2024';
      selectedMethod = 'PD Test';
      selectedSire = 'HF-5678 (Holstein)';
      gestationDays = '145 (Auto)';
      expectedCalving = '15 Sep ±3d (Auto)';
      notes = 'Right horn pregnancy, normal fluids';
      selectedVet = 'Dr. Sharma';
      findings = 'Normal';
      nextVisit = '1 Sep 2024';
      
      riskFactors = {
        'History of Dystocia': false,
        'Twin Pregnancy': false,
        'Metabolic Disorders': false,
        'Age >8 years': false,
        'First Pregnancy': false,
      };
    });
  }

  void _addReminders() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('📅', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Pregnancy Reminders', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Automatic reminders will be set for:'),
            SizedBox(height: 12),
            Text('• 1 Sep 2024 - Ultrasound checkup'),
            Text('• 10 Sep 2024 - Body condition scoring'),
            Text('• 12 Sep 2024 - Calving preparation'),
            Text('• 15 Sep 2024 - Expected calving date'),
            SizedBox(height: 16),
            Text('You will receive notifications 2 days before each event.'),
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
                  content: Text('📅 Pregnancy reminders activated!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Set Reminders', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}