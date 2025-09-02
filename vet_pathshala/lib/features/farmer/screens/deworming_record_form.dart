import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class DewormingRecordForm extends StatefulWidget {
  const DewormingRecordForm({super.key});

  @override
  State<DewormingRecordForm> createState() => _DewormingRecordFormState();
}

class _DewormingRecordFormState extends State<DewormingRecordForm> {
  String selectedAnimalGroup = 'All Goats';
  String selectedIndividual = 'Chhoti (Goat8)';
  String selectedMedicine = 'Albendazole';
  String selectedFormulation = 'Oral Suspension';
  String selectedDate = '20 Aug 2024';
  String doseAmount = '5';
  String selectedDoseUnit = 'Animal';
  String batchNo = 'ALB-2024-08';
  String nextDueDate = '1 Oct 2024';
  String notes = 'Treated during morning feeding';
  bool showAdvanced = false;

  final List<String> animalGroups = ['All Goats', 'All Cows', 'All Buffalos', 'Mixed Group'];
  final List<String> individuals = ['Chhoti (Goat8)', 'Laxmi (Cow12)', 'Kaali (Buffalo5)', 'Moti (Bull3)'];
  final List<String> medicines = ['Albendazole', 'Fenbendazole', 'Ivermectin', 'Levamisole'];
  final List<String> formulations = ['Oral Suspension', 'Tablets', 'Injectable', 'Powder'];
  final List<String> doseUnits = ['Animal', 'kg body weight', 'ml per 10kg'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
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
                  const Text('🦠', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'SCHEDULE DEWORMING',
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
                    // Animal selection
                    _buildDropdownField('Animal Group:', selectedAnimalGroup, animalGroups, (value) {
                      setState(() => selectedAnimalGroup = value!);
                    }),
                    const SizedBox(height: 12),
                    _buildDropdownField('OR Select Individual:', selectedIndividual, individuals, (value) {
                      setState(() => selectedIndividual = value!);
                    }),
                    
                    const SizedBox(height: 20),
                    
                    // Medicine details
                    _buildDropdownField('Medicine:', selectedMedicine, medicines, (value) {
                      setState(() => selectedMedicine = value!);
                    }),
                    const SizedBox(height: 12),
                    _buildDropdownField('Formulation:', selectedFormulation, formulations, (value) {
                      setState(() => selectedFormulation = value!);
                    }),
                    
                    const SizedBox(height: 20),
                    
                    // Date and dose
                    _buildDropdownField('Date:', selectedDate, ['20 Aug 2024', '21 Aug 2024', '22 Aug 2024'], (value) {
                      setState(() => selectedDate = value!);
                    }),
                    const SizedBox(height: 12),
                    _buildDoseField(),
                    const SizedBox(height: 12),
                    _buildTextField('Batch No:', batchNo, (value) {
                      setState(() => batchNo = value);
                    }),
                    
                    const SizedBox(height: 20),
                    
                    // Advanced options
                    GestureDetector(
                      onTap: () => setState(() => showAdvanced = !showAdvanced),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(showAdvanced ? Icons.expand_less : Icons.expand_more),
                            const SizedBox(width: 8),
                            const Text(
                              '▼ ADVANCED OPTIONS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    if (showAdvanced) ...[
                      const SizedBox(height: 12),
                      _buildDropdownField('Next Due:', nextDueDate, ['1 Oct 2024', '15 Oct 2024', '1 Nov 2024'], (value) {
                        setState(() => nextDueDate = value!);
                      }),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Withdrawal Period: 7 days (for milk)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Notes
                    const Text(
                      'Notes:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: notes),
                      onChanged: (value) => setState(() => notes = value),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add notes about the deworming treatment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
                      onPressed: () => _addToCalendar(),
                      icon: const Text('📅'),
                      label: const Text('Calendar'),
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

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

  Widget _buildDoseField() {
    return Row(
      children: [
        const SizedBox(
          width: 120,
          child: Text(
            'Dose:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: TextEditingController(text: doseAmount),
                  onChanged: (value) => setState(() => doseAmount = value),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('ml per'),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDoseUnit,
                      onChanged: (value) => setState(() => selectedDoseUnit = value!),
                      isExpanded: true,
                      icon: const Text('▼', style: TextStyle(fontSize: 12)),
                      items: doseUnits.map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit, style: const TextStyle(fontSize: 14)),
                      )).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 120,
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

  void _saveRecord() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Deworming record saved successfully!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      selectedAnimalGroup = 'All Goats';
      selectedIndividual = 'Chhoti (Goat8)';
      selectedMedicine = 'Albendazole';
      selectedFormulation = 'Oral Suspension';
      selectedDate = '20 Aug 2024';
      doseAmount = '5';
      selectedDoseUnit = 'Animal';
      batchNo = 'ALB-2024-08';
      nextDueDate = '1 Oct 2024';
      notes = 'Treated during morning feeding';
      showAdvanced = false;
    });
  }

  void _addToCalendar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📅 Added to calendar: Deworming reminder set'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}