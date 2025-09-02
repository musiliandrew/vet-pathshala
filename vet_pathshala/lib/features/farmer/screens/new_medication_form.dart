import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class NewMedicationForm extends StatefulWidget {
  const NewMedicationForm({super.key});

  @override
  State<NewMedicationForm> createState() => _NewMedicationFormState();
}

class _NewMedicationFormState extends State<NewMedicationForm> {
  String selectedAnimal = 'Laxmi (Cow12)';
  String condition = '';
  String medicine = '';
  String dosage = '';
  String duration = '7';
  String startDate = '1 Aug 2024';
  String administeredBy = 'Dr_____';
  String notes = '';
  bool reminderEnabled = false;

  final List<String> animals = ['Laxmi (Cow12)', 'Kaali (Buffalo5)', 'Chhoti (Goat8)', 'Moti (Bull3)'];
  final List<String> durations = ['3', '5', '7', '10', '14', '21'];
  final List<String> dates = ['1 Aug 2024', '2 Aug 2024', '3 Aug 2024'];
  final List<String> doctors = ['Dr_____', 'Dr. Sharma', 'Dr. Patel', 'Dr. Kumar', 'Self'];

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
                  const Text('💊', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'NEW MEDICATION RECORD',
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
                    // Basic information
                    _buildDropdownField('Animal:', selectedAnimal, animals, (value) {
                      setState(() => selectedAnimal = value!);
                    }),
                    const SizedBox(height: 16),
                    _buildTextField('Condition:', condition, (value) {
                      setState(() => condition = value);
                    }),
                    
                    const SizedBox(height: 20),
                    
                    // Medicine details
                    _buildTextField('Medicine:', medicine, (value) {
                      setState(() => medicine = value);
                    }),
                    const SizedBox(height: 16),
                    _buildTextField('Dosage:', dosage, (value) {
                      setState(() => dosage = value);
                    }),
                    const SizedBox(height: 16),
                    _buildDurationField(),
                    const SizedBox(height: 16),
                    _buildDropdownField('Start:', startDate, dates, (value) {
                      setState(() => startDate = value!);
                    }),
                    
                    const SizedBox(height: 20),
                    
                    // Administered by
                    _buildDropdownField('Administered By:', administeredBy, doctors, (value) {
                      setState(() => administeredBy = value!);
                    }),
                    
                    const SizedBox(height: 20),
                    
                    // Notes
                    const Text(
                      'Notes:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: TextEditingController(text: notes),
                        onChanged: (value) => setState(() => notes = value),
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: 'Add treatment notes, observations...',
                          border: InputBorder.none,
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
                      onPressed: () => _setReminders(),
                      icon: const Text('⏰'),
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

  Widget _buildDurationField() {
    return Row(
      children: [
        const SizedBox(
          width: 120,
          child: Text(
            'Duration:',
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
                  controller: TextEditingController(text: duration),
                  onChanged: (value) => setState(() => duration = value),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('days'),
            ],
          ),
        ),
      ],
    );
  }

  void _saveRecord() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Medication record saved successfully!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      selectedAnimal = 'Laxmi (Cow12)';
      condition = '';
      medicine = '';
      dosage = '';
      duration = '7';
      startDate = '1 Aug 2024';
      administeredBy = 'Dr_____';
      notes = '';
      reminderEnabled = false;
    });
  }

  void _setReminders() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('⏰', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Set Medication Reminders', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: const Text('Daily dose reminders'),
              value: reminderEnabled,
              onChanged: (value) => setState(() => reminderEnabled = value!),
            ),
            const Text('Reminder times:'),
            const Text('• Morning: 8:00 AM'),
            const Text('• Evening: 8:00 PM'),
            const SizedBox(height: 16),
            const Text('Notification will include:\n• Animal name\n• Medicine details\n• Dosage instructions'),
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
                  content: Text('⏰ Medication reminders activated!'),
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