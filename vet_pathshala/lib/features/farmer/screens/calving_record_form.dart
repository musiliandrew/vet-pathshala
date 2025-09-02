import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class CalvingRecordForm extends StatefulWidget {
  const CalvingRecordForm({super.key});

  @override
  State<CalvingRecordForm> createState() => _CalvingRecordFormState();
}

class _CalvingRecordFormState extends State<CalvingRecordForm> {
  String selectedEntryType = 'Normal Calving';
  String selectedAnimal = 'Laxmi (Cow12)';
  String selectedDate = '15 Sep 2024';
  String selectedTime = '03:45 AM';
  String selectedSex = 'Female';
  String calfId = 'RF-2024-065';
  String birthWeight = '28';
  String calvingDuration = '45';
  String dystociaScore = '0';
  String selectedAssistance = 'None';
  String complications = 'None';
  String colostrumAmount = '4';
  String colostrumTime = '2';
  String colostrumQuality = 'Excellent';
  String colostrumBrix = '24';
  String notes = '';

  final List<String> entryTypes = ['Normal Calving', 'Assisted', 'Loss Record'];
  final List<String> animals = ['Laxmi (Cow12)', 'Kaali (Buffalo5)', 'Sunita (Cow15)'];
  final List<String> sexOptions = ['Male', 'Female'];
  final List<String> assistanceTypes = ['None', 'Manual', 'Instrumental', 'Surgical'];
  final List<String> qualityOptions = ['Poor', 'Fair', 'Good', 'Excellent'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
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
                      'ADD CALVING RECORD',
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
            
            // Entry Type Selection
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
            
            const SizedBox(height: 20),
            
            // Form content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Basic details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildFormRow('Animal:', _buildDropdown(selectedAnimal, animals, (value) => setState(() => selectedAnimal = value!))),
                          _buildFormRow('Date:', _buildTextField(selectedDate, (value) => setState(() => selectedDate = value))),
                          _buildFormRow('Time:', _buildTextField(selectedTime, (value) => setState(() => selectedTime = value))),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Calf Details Section
                    if (selectedEntryType != 'Loss Record') _buildCalfDetailsSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Calving Process Section
                    _buildCalvingProcessSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Colostrum Management Section
                    if (selectedEntryType != 'Loss Record') _buildColostrumSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Notes
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Notes:', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: TextEditingController(text: notes),
                            onChanged: (value) => setState(() => notes = value),
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Additional observations...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveCalvingRecord(),
                    icon: const Text('📌'),
                    label: const Text('Save Record'),
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
                    label: const Text('Reset Form'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalfDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '░░░░░░░░░░░░░░░ CALF DETAILS ░░░░░░░░░░░░░░░░░░░░░░░░',
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
          
          // Sex selection
          Row(
            children: [
              const SizedBox(width: 100, child: Text('Sex:', style: TextStyle(fontWeight: FontWeight.w500))),
              Expanded(
                child: Row(
                  children: sexOptions.map((sex) {
                    final isSelected = selectedSex == sex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedSex = sex),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                                color: isSelected ? Colors.blue : Colors.white,
                              ),
                              child: isSelected 
                                ? const Icon(Icons.circle, size: 12, color: Colors.white)
                                : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                sex,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.blue : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          _buildFormRow('Calf ID:', _buildTextField(calfId, (value) => setState(() => calfId = value))),
          _buildFormRow('Birth Weight:', Row(
            children: [
              Expanded(
                child: _buildTextField(birthWeight, (value) => setState(() => birthWeight = value)),
              ),
              const SizedBox(width: 8),
              const Text('kg', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildCalvingProcessSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '░░░░░░░░░░░░░░░ CALVING PROCESS ░░░░░░░░░░░░░░░░░░░░░░░░',
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
          
          _buildFormRow('Duration:', Row(
            children: [
              Expanded(
                child: _buildTextField(calvingDuration, (value) => setState(() => calvingDuration = value)),
              ),
              const SizedBox(width: 8),
              const Text('minutes', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          )),
          _buildFormRow('Dystocia Score:', Row(
            children: [
              Expanded(
                child: _buildTextField(dystociaScore, (value) => setState(() => dystociaScore = value)),
              ),
              const SizedBox(width: 8),
              const Text('(0-5)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )),
          _buildFormRow('Assistance:', _buildDropdown(selectedAssistance, assistanceTypes, (value) => setState(() => selectedAssistance = value!))),
          _buildFormRow('Complications:', _buildTextField(complications, (value) => setState(() => complications = value))),
        ],
      ),
    );
  }

  Widget _buildColostrumSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '░░░░░░░░░░░░░░░ COLOSTRUM MANAGEMENT ░░░░░░░░░░░░░░░░░░░░░░░░',
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
          
          _buildFormRow('Amount:', Row(
            children: [
              Expanded(
                child: _buildTextField(colostrumAmount, (value) => setState(() => colostrumAmount = value)),
              ),
              const SizedBox(width: 8),
              const Text('liters', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          )),
          _buildFormRow('Time taken:', Row(
            children: [
              Expanded(
                child: _buildTextField(colostrumTime, (value) => setState(() => colostrumTime = value)),
              ),
              const SizedBox(width: 8),
              const Text('hours', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          )),
          _buildFormRow('Quality:', _buildDropdown(colostrumQuality, qualityOptions, (value) => setState(() => colostrumQuality = value!))),
          _buildFormRow('Brix %:', Row(
            children: [
              Expanded(
                child: _buildTextField(colostrumBrix, (value) => setState(() => colostrumBrix = value)),
              ),
              const SizedBox(width: 8),
              const Text('%', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          )),
          
          const SizedBox(height: 12),
          
          // Quality indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getQualityColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getQualityColor().withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(_getQualityEmoji(), style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Quality: ${colostrumQuality} (${_getQualityDescription()})',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getQualityColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormRow(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: field),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> options, Function(String?) onChanged) {
    return Container(
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
    );
  }

  Widget _buildTextField(String value, Function(String) onChanged) {
    return Container(
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
    );
  }

  Color _getQualityColor() {
    switch (colostrumQuality) {
      case 'Poor': return Colors.red;
      case 'Fair': return Colors.orange;
      case 'Good': return Colors.blue;
      case 'Excellent': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getQualityEmoji() {
    switch (colostrumQuality) {
      case 'Poor': return '🔴';
      case 'Fair': return '🟠';
      case 'Good': return '🔵';
      case 'Excellent': return '🟢';
      default: return '⚪';
    }
  }

  String _getQualityDescription() {
    switch (colostrumQuality) {
      case 'Poor': return 'Supplement required';
      case 'Fair': return 'Monitor closely';
      case 'Good': return 'Adequate protection';
      case 'Excellent': return 'Optimal immunity';
      default: return '';
    }
  }

  void _saveCalvingRecord() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${selectedEntryType.toLowerCase()} record saved!'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      selectedEntryType = 'Normal Calving';
      selectedAnimal = 'Laxmi (Cow12)';
      selectedDate = '15 Sep 2024';
      selectedTime = '03:45 AM';
      selectedSex = 'Female';
      calfId = 'RF-2024-065';
      birthWeight = '28';
      calvingDuration = '45';
      dystociaScore = '0';
      selectedAssistance = 'None';
      complications = 'None';
      colostrumAmount = '4';
      colostrumTime = '2';
      colostrumQuality = 'Excellent';
      colostrumBrix = '24';
      notes = '';
    });
  }
}