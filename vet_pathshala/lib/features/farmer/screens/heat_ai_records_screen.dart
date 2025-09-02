import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class HeatAIRecordsScreen extends StatefulWidget {
  const HeatAIRecordsScreen({super.key});

  @override
  State<HeatAIRecordsScreen> createState() => _HeatAIRecordsScreenState();
}

class _HeatAIRecordsScreenState extends State<HeatAIRecordsScreen> {
  String selectedRecordType = 'AI Service';
  String selectedAnimal = 'Laxmi (Cow12)';
  String selectedDate = '21 Jul 2024';
  String selectedTime = '10:30 AM';
  String selectedTechnician = 'Dr. Roy';
  String semenId = 'HF-5678 (Holstein)';
  String strawNo = '3';
  String batchNo = 'XF-2024-07';
  String method = 'Recto-Vaginal';
  String aiNotes = 'Easy insertion, good CL';
  
  // Heat details
  List<String> selectedSigns = ['Mounting', 'Discharge'];
  String duration = '14 hours';
  String intensity = 'Strong';

  final List<String> recordTypes = ['Heat Observation', 'AI Service'];
  final List<String> animals = ['Laxmi (Cow12)', 'Kaali (Buffalo5)', 'Sunita (Cow15)'];
  final List<String> technicians = ['Dr. Roy', 'Dr. Sharma', 'Dr. Patel', 'Self'];
  final List<String> semenOptions = ['HF-5678 (Holstein)', 'JER-2341 (Jersey)', 'MUR-8890 (Murrah)'];
  final List<String> methods = ['Recto-Vaginal', 'Cervical', 'Intrauterine'];
  final List<String> heatSigns = ['Mounting', 'Discharge', 'Restlessness', 'Vocalization', 'Reduced Appetite'];
  final List<String> durations = ['8 hours', '12 hours', '14 hours', '16 hours', '20 hours'];
  final List<String> intensities = ['Weak', 'Moderate', 'Strong', 'Very Strong'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Row(
          children: [
            Text('🔄', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'HEAT & AI RECORDS',
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
            onPressed: () => _showAddRecordDialog(),
            icon: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('➕', style: TextStyle(fontSize: 18)),
                SizedBox(width: 4),
                Text('New', style: TextStyle(color: Colors.white, fontSize: 12)),
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
            // Heat Cycle Chart
            _buildExpandableSection(
              '▼ HEAT CYCLE CHART',
              _buildHeatCycleChart(),
            ),
            
            const SizedBox(height: 16),
            
            // Last AI Record
            _buildExpandableSection(
              '▼ LAST AI RECORD',
              _buildLastAIRecord(),
            ),
            
            const SizedBox(height: 16),
            
            // Heat Detection Logs
            _buildExpandableSection(
              '▼ HEAT DETECTION LOGS',
              _buildHeatDetectionLogs(),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _syncToCalendar(),
                    icon: const Text('📅'),
                    label: const Text('Sync to Calendar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _setReminders(),
                    icon: const Text('🔔'),
                    label: const Text('Set Reminders'),
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
    );
  }

  Widget _buildExpandableSection(String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('[ SEE ALL ]', style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
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
      ),
    );
  }

  Widget _buildHeatCycleChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🐄 Laxmi (Cow12)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        // Heat intensity chart
        const Text('▁▁▁▃▃▃▅▅▅▇▇▇ Heat Intensity', 
             style: TextStyle(fontSize: 14, fontFamily: 'monospace')),
        const SizedBox(height: 8),
        
        // Timeline
        const Text('○───○───○───○───○───○───○───○───○───○───○───○', 
             style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
        const Text('15  18  21  24  27  30  2   5   8   11  14', 
             style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
        const Text('Jul              Aug', 
             style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Last: 20 Jul | Next: 10 Aug (±2d)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastAIRecord() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🗓️ 21 Jul 2024 10:30 AM',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        const Text('Semen: HF-5678 (Holstein) | Straw: 5', 
             style: TextStyle(fontSize: 14, color: Colors.grey)),
        const Text('Technician: Dr. Roy | Method: Recto-Vaginal', 
             style: TextStyle(fontSize: 14, color: Colors.grey)),
        const Text('Pregnancy Test Due: 20 Aug', 
             style: TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.w500)),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _editAIRecord(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  side: const BorderSide(color: Colors.purple),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Edit', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _viewSemenDetails(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF50),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('View Semen Details', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeatDetectionLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.pink.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.pink.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🗓️ 20 Jul 2024',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Signs: Mounting, Clear Discharge', 
                   style: TextStyle(fontSize: 14, color: Colors.grey)),
              const Text('Duration: 14 hours | Intensity: Strong', 
                   style: TextStyle(fontSize: 14, color: Colors.grey)),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _addPhoto(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.pink,
                        side: const BorderSide(color: Colors.pink),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Add Photo', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _comparePrevious(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4CAF50),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Compare Previous', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                    const Text('➕', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'ADD HEAT/AI RECORD',
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
              
              // Record type selection
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '░░░░░░░░░░░░░░░ RECORD TYPE ░░░░░░░░░░░░░░░░░░░░░░░░',
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
              
              // Radio buttons
              Row(
                children: recordTypes.map((type) {
                  final isSelected = selectedRecordType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedRecordType = type),
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
                                fontSize: 14,
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
                            _buildFormRow('Date:', _buildDropdown(selectedDate, ['21 Jul 2024', '22 Jul 2024', '23 Jul 2024'], (value) => setState(() => selectedDate = value!))),
                            _buildFormRow('Technician:', _buildDropdown(selectedTechnician, technicians, (value) => setState(() => selectedTechnician = value!))),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Conditional content based on record type
                      if (selectedRecordType == 'AI Service') _buildAIDetails(),
                      if (selectedRecordType == 'Heat Observation') _buildHeatDetails(),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveHeatAIRecord(),
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
                      onPressed: () => _resetHeatAIForm(),
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
      ),
    );
  }

  Widget _buildAIDetails() {
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
          const Text(
            '▼ AI DETAILS (only if AI selected)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          _buildFormRow('Semen ID:', _buildDropdown(semenId, semenOptions, (value) => setState(() => semenId = value!))),
          _buildFormRow('Straw No:', _buildTextField(strawNo, (value) => setState(() => strawNo = value))),
          _buildFormRow('Batch:', _buildTextField(batchNo, (value) => setState(() => batchNo = value))),
          _buildFormRow('Method:', _buildDropdown(method, methods, (value) => setState(() => method = value!))),
          _buildFormRow('Notes:', _buildTextField(aiNotes, (value) => setState(() => aiNotes = value))),
        ],
      ),
    );
  }

  Widget _buildHeatDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.pink.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '▼ HEAT DETAILS (only if Heat selected)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 16),
          _buildSignsSelection(),
          const SizedBox(height: 12),
          _buildFormRow('Duration:', _buildDropdown(duration, durations, (value) => setState(() => duration = value!))),
          _buildFormRow('Intensity:', _buildDropdown(intensity, intensities, (value) => setState(() => intensity = value!))),
          const SizedBox(height: 12),
          _buildPhotoSection(),
        ],
      ),
    );
  }

  Widget _buildSignsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Signs:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: heatSigns.map((sign) {
            final isSelected = selectedSigns.contains(sign);
            return FilterChip(
              label: Text(sign, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedSigns.add(sign);
                  } else {
                    selectedSigns.remove(sign);
                  }
                });
              },
              selectedColor: Colors.pink,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('🖼️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Add up to 3', style: TextStyle(fontSize: 14)),
          ),
          OutlinedButton(
            onPressed: () => _addPhoto(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.pink,
              side: const BorderSide(color: Colors.pink),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: const Text('Add', style: TextStyle(fontSize: 12)),
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

  void _syncToCalendar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📅 Heat cycle synced to calendar!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _setReminders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔔 Heat detection reminders activated!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _editAIRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✏️ AI record editing coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _viewSemenDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🧬 Semen Details - HF-5678'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bull Information:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Name: Holstein Friesian 5678'),
            Text('• Age: 5 years'),
            Text('• Genetic Merit: A+'),
            SizedBox(height: 12),
            Text('Production Records:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Daughter avg: 8500L/lactation'),
            Text('• Fat %: 4.2% | Protein %: 3.4%'),
            Text('• Conception rate: 65%'),
            SizedBox(height: 12),
            Text('Health Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Disease tested: Clear'),
            Text('• Last collection: 15 Jul 2024'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Photo capture coming soon!'),
        backgroundColor: Colors.pink,
      ),
    );
  }

  void _comparePrevious() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📊 Heat comparison analysis coming soon!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _saveHeatAIRecord() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${selectedRecordType.toLowerCase()} record saved!'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _resetHeatAIForm() {
    setState(() {
      selectedRecordType = 'Heat Observation';
      selectedAnimal = 'Laxmi (Cow12)';
      selectedDate = '21 Jul 2024';
      selectedTime = '10:30 AM';
      selectedTechnician = 'Dr. Roy';
      semenId = 'HF-5678 (Holstein)';
      strawNo = '3';
      batchNo = 'XF-2024-07';
      method = 'Recto-Vaginal';
      aiNotes = 'Easy insertion, good CL';
      selectedSigns = ['Mounting', 'Discharge'];
      duration = '14 hours';
      intensity = 'Strong';
    });
  }
}