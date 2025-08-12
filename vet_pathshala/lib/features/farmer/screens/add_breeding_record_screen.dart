import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/animal_model.dart';
import '../models/breeding_records_model.dart';
import '../../coins/providers/coin_provider.dart';

class AddBreedingRecordScreen extends StatefulWidget {
  final AnimalModel animal;
  final String recordType; // 'heat_cycle', 'ai_record', 'pregnancy', 'calving'
  
  const AddBreedingRecordScreen({
    super.key,
    required this.animal,
    required this.recordType,
  });

  @override
  State<AddBreedingRecordScreen> createState() => _AddBreedingRecordScreenState();
}

class _AddBreedingRecordScreenState extends State<AddBreedingRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Common controllers
  final _notesController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _costController = TextEditingController();
  
  // Heat Cycle controllers
  final _symptomsController = TextEditingController();
  DateTime _detectedDate = DateTime.now();
  DateTime? _matingDate;
  HeatCycleIntensity _intensity = HeatCycleIntensity.moderate;
  HeatCycleResult _heatResult = HeatCycleResult.pending;
  
  // AI Record controllers
  final _bullIdController = TextEditingController();
  final _bullBreedController = TextEditingController();
  final _semenBatchController = TextEditingController();
  final _technicianController = TextEditingController();
  DateTime _aiDate = DateTime.now();
  AIMethod _aiMethod = AIMethod.cervical;
  AIResult _aiResult = AIResult.pending;
  DateTime? _pregnancyCheckDate;
  
  // Pregnancy controllers
  DateTime _conceptionDate = DateTime.now();
  DateTime _expectedCalvingDate = DateTime.now().add(const Duration(days: 280));
  final _sireIdController = TextEditingController();
  PregnancyStatus _pregnancyStatus = PregnancyStatus.ongoing;
  final List<PregnancyCheck> _pregnancyChecks = [];
  
  // Calving controllers
  DateTime _calvingDate = DateTime.now();
  CalvingType _calvingType = CalvingType.normal;
  CalvingDifficulty _calvingDifficulty = CalvingDifficulty.easy;
  final _complicationsController = TextEditingController();
  final List<CalfRecord> _calves = [];

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
  }

  void _initializeDefaults() {
    // Set some default values based on record type
    switch (widget.recordType) {
      case 'heat_cycle':
        _symptomsController.text = 'Restlessness, mounting behavior, clear mucus discharge';
        break;
      case 'ai_record':
        _technicianController.text = 'AI Technician';
        _bullBreedController.text = 'Holstein';
        break;
      case 'pregnancy':
        _conceptionDate = DateTime.now().subtract(const Duration(days: 30));
        _expectedCalvingDate = _conceptionDate.add(const Duration(days: 280));
        break;
      case 'calving':
        _calves.add(CalfRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          gender: CalfGender.male,
          health: CalfHealth.healthy,
          birthWeight: 35.0,
        ));
        break;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _veterinarianController.dispose();
    _costController.dispose();
    _symptomsController.dispose();
    _bullIdController.dispose();
    _bullBreedController.dispose();
    _semenBatchController.dispose();
    _technicianController.dispose();
    _sireIdController.dispose();
    _complicationsController.dispose();
    super.dispose();
  }

  String get _screenTitle {
    switch (widget.recordType) {
      case 'heat_cycle':
        return '🌸 Add Heat Cycle Record';
      case 'ai_record':
        return '🎯 Add AI Record';
      case 'pregnancy':
        return '🤰 Add Pregnancy Record';
      case 'calving':
        return '🍼 Add Calving Record';
      default:
        return 'Add Breeding Record';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_screenTitle),
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
            children: [
              _buildFormContent(),
              const SizedBox(height: 24),
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    switch (widget.recordType) {
      case 'heat_cycle':
        return _buildHeatCycleForm();
      case 'ai_record':
        return _buildAIRecordForm();
      case 'pregnancy':
        return _buildPregnancyForm();
      case 'calving':
        return _buildCalvingForm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildHeatCycleForm() {
    return Column(
      children: [
        _buildBasicInfoCard(
          'Heat Cycle Detection',
          '🌸',
          [
            _buildDatePicker(
              'Detection Date',
              _detectedDate,
              (date) => setState(() => _detectedDate = date),
            ),
            const SizedBox(height: 16),
            _buildDatePicker(
              'Mating Date (Optional)',
              _matingDate,
              (date) => setState(() => _matingDate = date),
              optional: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HeatCycleIntensity>(
              value: _intensity,
              decoration: const InputDecoration(
                labelText: 'Intensity',
                border: OutlineInputBorder(),
              ),
              items: HeatCycleIntensity.values.map((intensity) {
                return DropdownMenuItem(
                  value: intensity,
                  child: Row(
                    children: [
                      Text(intensity.icon),
                      const SizedBox(width: 8),
                      Text(intensity.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _intensity = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _symptomsController,
              decoration: const InputDecoration(
                labelText: 'Symptoms Observed',
                hintText: 'List observed symptoms',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HeatCycleResult>(
              value: _heatResult,
              decoration: const InputDecoration(
                labelText: 'Result',
                border: OutlineInputBorder(),
              ),
              items: HeatCycleResult.values.map((result) {
                return DropdownMenuItem(
                  value: result,
                  child: Row(
                    children: [
                      Text(result.icon),
                      const SizedBox(width: 8),
                      Text(result.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _heatResult = value!),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCommonFieldsCard(),
      ],
    );
  }

  Widget _buildAIRecordForm() {
    return Column(
      children: [
        _buildBasicInfoCard(
          'Artificial Insemination Details',
          '🎯',
          [
            _buildDatePicker(
              'AI Date',
              _aiDate,
              (date) => setState(() => _aiDate = date),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bullIdController,
              decoration: const InputDecoration(
                labelText: 'Bull ID *',
                hintText: 'Enter bull identification',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter bull ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bullBreedController,
              decoration: const InputDecoration(
                labelText: 'Bull Breed *',
                hintText: 'Enter bull breed',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter bull breed';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _semenBatchController,
              decoration: const InputDecoration(
                labelText: 'Semen Batch',
                hintText: 'Enter semen batch number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _technicianController,
              decoration: const InputDecoration(
                labelText: 'Technician *',
                hintText: 'Enter technician name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter technician name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AIMethod>(
              value: _aiMethod,
              decoration: const InputDecoration(
                labelText: 'AI Method',
                border: OutlineInputBorder(),
              ),
              items: AIMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Row(
                    children: [
                      Text(method.icon),
                      const SizedBox(width: 8),
                      Text(method.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _aiMethod = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AIResult>(
              value: _aiResult,
              decoration: const InputDecoration(
                labelText: 'Result',
                border: OutlineInputBorder(),
              ),
              items: AIResult.values.map((result) {
                return DropdownMenuItem(
                  value: result,
                  child: Row(
                    children: [
                      Text(result.icon),
                      const SizedBox(width: 8),
                      Text(result.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _aiResult = value!),
            ),
            const SizedBox(height: 16),
            _buildDatePicker(
              'Pregnancy Check Date (Optional)',
              _pregnancyCheckDate,
              (date) => setState(() => _pregnancyCheckDate = date),
              optional: true,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCommonFieldsCard(),
      ],
    );
  }

  Widget _buildPregnancyForm() {
    return Column(
      children: [
        _buildBasicInfoCard(
          'Pregnancy Information',
          '🤰',
          [
            _buildDatePicker(
              'Conception Date',
              _conceptionDate,
              (date) {
                setState(() {
                  _conceptionDate = date;
                  _expectedCalvingDate = date.add(const Duration(days: 280));
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDatePicker(
              'Expected Calving Date',
              _expectedCalvingDate,
              (date) => setState(() => _expectedCalvingDate = date),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sireIdController,
              decoration: const InputDecoration(
                labelText: 'Sire ID',
                hintText: 'Enter sire identification',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PregnancyStatus>(
              value: _pregnancyStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: PregnancyStatus.values.map((status) {
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
              onChanged: (value) => setState(() => _pregnancyStatus = value!),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPregnancyProgressCard(),
        const SizedBox(height: 16),
        _buildCommonFieldsCard(),
      ],
    );
  }

  Widget _buildCalvingForm() {
    return Column(
      children: [
        _buildBasicInfoCard(
          'Calving Information',
          '🍼',
          [
            _buildDatePicker(
              'Calving Date',
              _calvingDate,
              (date) => setState(() => _calvingDate = date),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CalvingType>(
              value: _calvingType,
              decoration: const InputDecoration(
                labelText: 'Calving Type',
                border: OutlineInputBorder(),
              ),
              items: CalvingType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(type.icon),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _calvingType = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CalvingDifficulty>(
              value: _calvingDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
              items: CalvingDifficulty.values.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Row(
                    children: [
                      Text(difficulty.icon),
                      const SizedBox(width: 8),
                      Text(difficulty.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _calvingDifficulty = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _complicationsController,
              decoration: const InputDecoration(
                labelText: 'Complications (if any)',
                hintText: 'Describe any complications during calving',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCalvesCard(),
        const SizedBox(height: 16),
        _buildCommonFieldsCard(),
      ],
    );
  }

  Widget _buildBasicInfoCard(String title, String icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCommonFieldsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _veterinarianController,
              decoration: const InputDecoration(
                labelText: 'Veterinarian',
                hintText: 'Enter veterinarian name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any additional notes or observations',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyProgressCard() {
    final currentDay = _conceptionDate.difference(DateTime.now()).inDays.abs();
    final progress = (currentDay / 280).clamp(0.0, 1.0);
    final monthsPregnant = (currentDay / 30).ceil();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Pregnancy Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Day $currentDay of 280'),
                Text('Month $monthsPregnant'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% Complete',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalvesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '👶 Calf Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addCalf,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Calf'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_calves.isEmpty)
              const Center(
                child: Text(
                  'No calves added yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._calves.asMap().entries.map((entry) {
                final index = entry.key;
                final calf = entry.value;
                return _buildCalfCard(calf, index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCalfCard(CalfRecord calf, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${calf.genderIcon} Calf ${index + 1}'),
                const Spacer(),
                IconButton(
                  onPressed: () => _removeCalf(index),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Gender: ${calf.gender.displayName}'),
                ),
                if (calf.birthWeight != null)
                  Expanded(
                    child: Text('Weight: ${calf.birthWeight}kg'),
                  ),
              ],
            ),
            Row(
              children: [
                Text('${calf.healthIcon} ${calf.health.displayName}'),
                const SizedBox(width: 16),
                Text(calf.isAlive ? '✅ Alive' : '❌ Deceased'),
              ],
            ),
            if (calf.tagId != null)
              Text('Tag: ${calf.tagId}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate, Function(DateTime) onDateSelected, {bool optional = false}) {
    return InkWell(
      onTap: () => _selectDate(selectedDate ?? DateTime.now(), onDateSelected),
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
            Text('$label: '),
            Text(
              selectedDate != null 
                ? DateFormat('dd MMM yyyy').format(selectedDate)
                : optional ? 'Not set' : 'Select date',
              style: TextStyle(
                fontWeight: selectedDate != null ? FontWeight.bold : FontWeight.normal,
                color: selectedDate != null ? Colors.black : Colors.grey,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
        label: Text('Save ${widget.recordType.replaceAll('_', ' ').toUpperCase()} Record'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _selectDate(DateTime initialDate, Function(DateTime) onDateSelected) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (date != null) {
      onDateSelected(date);
    }
  }

  void _addCalf() {
    showDialog(
      context: context,
      builder: (context) => _CalfDialog(
        onSave: (calf) {
          setState(() {
            _calves.add(calf);
          });
        },
      ),
    );
  }

  void _removeCalf(int index) {
    setState(() {
      _calves.removeAt(index);
    });
  }

  void _showQuickTemplates() {
    // Implementation for quick templates based on record type
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quick templates coming soon!'),
        backgroundColor: Colors.blue,
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
            Text('Saving breeding record...'),
          ],
        ),
      ),
    );

    try {
      // Create appropriate record based on type
      dynamic record;
      
      switch (widget.recordType) {
        case 'heat_cycle':
          record = HeatCycleRecord(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            animalId: widget.animal.id,
            detectedDate: _detectedDate,
            matingDate: _matingDate,
            intensity: _intensity,
            symptoms: _symptomsController.text.split(',').map((s) => s.trim()).toList(),
            result: _heatResult,
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          break;
          
        case 'ai_record':
          record = AIRecord(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            animalId: widget.animal.id,
            aiDate: _aiDate,
            bullId: _bullIdController.text,
            bullBreed: _bullBreedController.text,
            semenBatch: _semenBatchController.text.isNotEmpty ? _semenBatchController.text : null,
            technician: _technicianController.text,
            method: _aiMethod,
            cost: _costController.text.isNotEmpty ? double.parse(_costController.text) : null,
            result: _aiResult,
            pregnancyCheckDate: _pregnancyCheckDate,
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          break;
          
        case 'pregnancy':
          record = PregnancyRecord(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            animalId: widget.animal.id,
            conceptionDate: _conceptionDate,
            expectedCalvingDate: _expectedCalvingDate,
            sireId: _sireIdController.text.isNotEmpty ? _sireIdController.text : null,
            status: _pregnancyStatus,
            checks: _pregnancyChecks,
            veterinarian: _veterinarianController.text.isNotEmpty ? _veterinarianController.text : null,
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          break;
          
        case 'calving':
          record = CalvingRecord(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            motherId: widget.animal.id,
            calvingDate: _calvingDate,
            type: _calvingType,
            difficulty: _calvingDifficulty,
            calves: _calves,
            veterinarian: _veterinarianController.text.isNotEmpty ? _veterinarianController.text : null,
            complications: _complicationsController.text.isNotEmpty ? _complicationsController.text : null,
            cost: _costController.text.isNotEmpty ? double.parse(_costController.text) : null,
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            createdAt: DateTime.now(),
          );
          break;
      }

      // Simulate saving to database
      await Future.delayed(const Duration(seconds: 1));

      // Award coins
      context.read<CoinProvider>().addCoins(4, 'Breeding Record Added');

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context, record); // Return to previous screen with record
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Breeding record saved successfully! +4 coins earned'),
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

class _CalfDialog extends StatefulWidget {
  final Function(CalfRecord) onSave;
  
  const _CalfDialog({required this.onSave});

  @override
  State<_CalfDialog> createState() => _CalfDialogState();
}

class _CalfDialogState extends State<_CalfDialog> {
  final _tagController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  
  CalfGender _gender = CalfGender.male;
  CalfHealth _health = CalfHealth.healthy;
  bool _isAlive = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Calf Information'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<CalfGender>(
              value: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: CalfGender.values.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Row(
                    children: [
                      Text(gender.icon),
                      const SizedBox(width: 8),
                      Text(gender.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _gender = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Birth Weight (kg)',
                hintText: 'Enter birth weight',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CalfHealth>(
              value: _health,
              decoration: const InputDecoration(
                labelText: 'Health Status',
                border: OutlineInputBorder(),
              ),
              items: CalfHealth.values.map((health) {
                return DropdownMenuItem(
                  value: health,
                  child: Row(
                    children: [
                      Text(health.icon),
                      const SizedBox(width: 8),
                      Text(health.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _health = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagController,
              decoration: const InputDecoration(
                labelText: 'Tag ID (Optional)',
                hintText: 'Enter tag identification',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isAlive,
                  onChanged: (value) => setState(() => _isAlive = value!),
                ),
                const Text('Calf is alive'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveCalf,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveCalf() {
    final calf = CalfRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tagId: _tagController.text.isNotEmpty ? _tagController.text : null,
      gender: _gender,
      birthWeight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
      health: _health,
      isAlive: _isAlive,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    
    widget.onSave(calf);
    Navigator.pop(context);
  }
}