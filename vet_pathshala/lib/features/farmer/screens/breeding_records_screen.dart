import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/animal_model.dart';
import '../models/breeding_records_model.dart';
import '../../coins/providers/coin_provider.dart';
import 'add_breeding_record_screen.dart';

class BreedingRecordsScreen extends StatefulWidget {
  final AnimalModel animal;
  
  const BreedingRecordsScreen({super.key, required this.animal});

  @override
  State<BreedingRecordsScreen> createState() => _BreedingRecordsScreenState();
}

class _BreedingRecordsScreenState extends State<BreedingRecordsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  
  // Mock data - in real app this would come from Firebase
  final List<HeatCycleRecord> heatCycles = [
    HeatCycleRecord(
      id: '1',
      animalId: 'animal_1',
      detectedDate: DateTime.now().subtract(const Duration(days: 18)),
      matingDate: DateTime.now().subtract(const Duration(days: 18)),
      intensity: HeatCycleIntensity.strong,
      symptoms: ['Restlessness', 'Mounting behavior', 'Clear discharge'],
      result: HeatCycleResult.bred,
      notes: 'Strong heat cycle, good timing for AI',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      updatedAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
    HeatCycleRecord(
      id: '2',
      animalId: 'animal_1',
      detectedDate: DateTime.now().subtract(const Duration(days: 39)),
      intensity: HeatCycleIntensity.moderate,
      symptoms: ['Mild restlessness', 'Decreased appetite'],
      result: HeatCycleResult.missed,
      notes: 'Detected late, cycle missed',
      createdAt: DateTime.now().subtract(const Duration(days: 39)),
      updatedAt: DateTime.now().subtract(const Duration(days: 39)),
    ),
  ];

  final List<AIRecord> aiRecords = [
    AIRecord(
      id: '1',
      animalId: 'animal_1',
      aiDate: DateTime.now().subtract(const Duration(days: 18)),
      bullId: 'HF001',
      bullBreed: 'Holstein Friesian',
      semenBatch: 'HF-2024-001',
      technician: 'Dr. Patel',
      method: AIMethod.cervical,
      cost: 800.0,
      result: AIResult.conceived,
      pregnancyCheckDate: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Good quality semen, proper timing',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  final List<PregnancyRecord> pregnancyRecords = [
    PregnancyRecord(
      id: '1',
      animalId: 'animal_1',
      conceptionDate: DateTime.now().subtract(const Duration(days: 150)),
      expectedCalvingDate: DateTime.now().add(const Duration(days: 130)),
      sireId: 'HF001',
      status: PregnancyStatus.ongoing,
      checks: [
        PregnancyCheck(
          checkDate: DateTime.now().subtract(const Duration(days: 120)),
          dayOfPregnancy: 30,
          result: PregnancyCheckResult.positive,
          veterinarian: 'Dr. Sharma',
          notes: 'Confirmed pregnancy, healthy fetus',
        ),
        PregnancyCheck(
          checkDate: DateTime.now().subtract(const Duration(days: 90)),
          dayOfPregnancy: 60,
          result: PregnancyCheckResult.positive,
          veterinarian: 'Dr. Sharma',
          notes: 'Good fetal development',
        ),
      ],
      veterinarian: 'Dr. Sharma',
      notes: 'First pregnancy, monitoring closely',
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  final List<CalvingRecord> calvingHistory = [
    CalvingRecord(
      id: '1',
      motherId: 'animal_1',
      calvingDate: DateTime.now().subtract(const Duration(days: 400)),
      type: CalvingType.normal,
      difficulty: CalvingDifficulty.easy,
      calves: [
        CalfRecord(
          id: 'calf_1',
          tagId: 'CF-001',
          gender: CalfGender.female,
          birthWeight: 32.5,
          health: CalfHealth.healthy,
          notes: 'Healthy female calf, good birth weight',
        ),
      ],
      veterinarian: 'Dr. Kumar',
      notes: 'Smooth delivery, mother and calf healthy',
      createdAt: DateTime.now().subtract(const Duration(days: 400)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.pink.shade700,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.animal.typeEmoji} ${widget.animal.name}',
              style: const TextStyle(fontSize: 18),
            ),
            const Text(
              'Breeding Records',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAddRecordMenu,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: _showBreedingCalendar,
            icon: const Icon(Icons.calendar_month),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Heat Cycles'),
            Tab(icon: Icon(Icons.science), text: 'AI Records'),
            Tab(icon: Icon(Icons.pregnant_woman), text: 'Pregnancy'),
            Tab(icon: Icon(Icons.child_care), text: 'Calving'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHeatCyclesTab(),
          _buildAIRecordsTab(),
          _buildPregnancyTab(),
          _buildCalvingTab(),
        ],
      ),
    );
  }

  Widget _buildHeatCyclesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next Heat Prediction Card
          _buildNextHeatPredictionCard(),
          
          const SizedBox(height: 16),
          
          // Heat Cycle History
          _buildSectionHeader('Heat Cycle History', Icons.history),
          
          if (heatCycles.isEmpty)
            _buildEmptyState('No heat cycles recorded')
          else
            ...heatCycles.map((cycle) => _buildHeatCycleCard(cycle)),
          
          const SizedBox(height: 16),
          
          // Heat Cycle Statistics
          _buildHeatCycleStats(),
        ],
      ),
    );
  }

  Widget _buildAIRecordsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Success Rate Card
          _buildAISuccessRateCard(),
          
          const SizedBox(height: 16),
          
          // AI Records
          _buildSectionHeader('Artificial Insemination Records', Icons.science),
          
          if (aiRecords.isEmpty)
            _buildEmptyState('No AI records found')
          else
            ...aiRecords.map((record) => _buildAIRecordCard(record)),
          
          const SizedBox(height: 16),
          
          // Bulls Used
          _buildBullsUsedCard(),
        ],
      ),
    );
  }

  Widget _buildPregnancyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Pregnancy Status
          if (pregnancyRecords.any((p) => p.status == PregnancyStatus.ongoing))
            _buildCurrentPregnancyCard(),
          
          const SizedBox(height: 16),
          
          // Pregnancy History
          _buildSectionHeader('Pregnancy History', Icons.history),
          
          if (pregnancyRecords.isEmpty)
            _buildEmptyState('No pregnancy records found')
          else
            ...pregnancyRecords.map((pregnancy) => _buildPregnancyCard(pregnancy)),
        ],
      ),
    );
  }

  Widget _buildCalvingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calving Statistics
          _buildCalvingStatsCard(),
          
          const SizedBox(height: 16),
          
          // Calving History
          _buildSectionHeader('Calving History', Icons.child_care),
          
          if (calvingHistory.isEmpty)
            _buildEmptyState('No calving records found')
          else
            ...calvingHistory.map((calving) => _buildCalvingCard(calving)),
        ],
      ),
    );
  }

  Widget _buildNextHeatPredictionCard() {
    final lastCycle = heatCycles.isNotEmpty ? heatCycles.first : null;
    final nextExpectedDate = lastCycle?.nextExpectedHeat ?? DateTime.now().add(const Duration(days: 21));
    final daysUntil = nextExpectedDate.difference(DateTime.now()).inDays;
    final isOverdue = daysUntil < -3; // 3 days grace period

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOverdue 
                  ? [Colors.red.shade100, Colors.red.shade50]
                  : [Colors.pink.shade100, Colors.pink.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverdue 
                  ? Colors.red.withOpacity(0.3 + (_pulseController.value * 0.4))
                  : Colors.pink.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isOverdue ? [
              BoxShadow(
                color: Colors.red.withOpacity(0.2 * _pulseController.value),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('❤️', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next Heat Cycle Prediction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(nextExpectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isOverdue ? Colors.red : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOverdue ? 'OVERDUE' : '$daysUntil days',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (isOverdue) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Heat cycle is overdue. Check for signs or consult veterinarian.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _recordHeatCycle(),
                      icon: const Text('🔥'),
                      label: const Text('Record Heat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _setReminder(),
                      icon: const Icon(Icons.notifications),
                      label: const Text('Set Reminder'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.pink,
                        side: const BorderSide(color: Colors.pink),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentPregnancyCard() {
    final currentPregnancy = pregnancyRecords.firstWhere(
      (p) => p.status == PregnancyStatus.ongoing,
    );

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(currentPregnancy.statusIcon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Current Pregnancy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Pregnancy progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Month ${currentPregnancy.currentMonthOfPregnancy}'),
                    Text('${(currentPregnancy.pregnancyProgress * 100).toInt()}%'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: currentPregnancy.pregnancyProgress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Key information
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    'Days Pregnant',
                    '${currentPregnancy.currentDayOfPregnancy}',
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    'Days Until Calving',
                    '${currentPregnancy.daysUntilCalving}',
                    Icons.event,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    'Expected Date',
                    DateFormat('dd MMM').format(currentPregnancy.expectedCalvingDate),
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addPregnancyCheck(currentPregnancy),
                icon: const Icon(Icons.medical_services),
                label: const Text('Add Pregnancy Check'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatCycleCard(HeatCycleRecord cycle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cycle.intensityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(cycle.intensityIcon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heat Cycle - ${cycle.intensity.displayName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(cycle.detectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cycle.resultColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cycle.resultColor),
                  ),
                  child: Text(
                    '${cycle.resultIcon} ${cycle.result.displayName}',
                    style: TextStyle(
                      fontSize: 10,
                      color: cycle.resultColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (cycle.symptoms.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Symptoms:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: cycle.symptoms.map((symptom) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    symptom,
                    style: const TextStyle(fontSize: 10),
                  ),
                )).toList(),
              ),
            ],
            
            if (cycle.matingDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.favorite, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    'Mated: ${DateFormat('dd MMM yyyy').format(cycle.matingDate!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
            
            // Next expected cycle
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Next expected: ${DateFormat('dd MMM yyyy').format(cycle.nextExpectedHeat)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    cycle.isOverdue ? 'Overdue' : '${cycle.daysUntilNextCycle} days',
                    style: TextStyle(
                      fontSize: 10,
                      color: cycle.isOverdue ? Colors.red : Colors.blue,
                      fontWeight: FontWeight.bold,
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

  Widget _buildAIRecordCard(AIRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: record.resultColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(record.methodIcon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Artificial Insemination',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(record.aiDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.resultColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: record.resultColor),
                  ),
                  child: Text(
                    '${record.resultIcon} ${record.result.displayName}',
                    style: TextStyle(
                      fontSize: 10,
                      color: record.resultColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Bull and method information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pets, size: 16, color: Colors.brown),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bull: ${record.bullId} (${record.bullBreed})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.science, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Method: ${record.method.displayName}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  if (record.semenBatch != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.local_pharmacy, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Batch: ${record.semenBatch}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Technician and cost
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.person,
                    record.technician,
                  ),
                ),
                if (record.cost != null)
                  Expanded(
                    child: _buildInfoChip(
                      Icons.currency_rupee,
                      '₹${record.cost!.toStringAsFixed(0)}',
                    ),
                  ),
                if (record.pregnancyCheckDate != null)
                  Expanded(
                    child: _buildInfoChip(
                      Icons.check_circle,
                      'Checked ${DateFormat('dd MMM').format(record.pregnancyCheckDate!)}',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyCard(PregnancyRecord pregnancy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: pregnancy.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(pregnancy.statusIcon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pregnancy Record',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pregnancy.status.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: pregnancy.statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (pregnancy.status == PregnancyStatus.ongoing) ...[
              const SizedBox(height: 16),
              
              // Progress indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Day ${pregnancy.currentDayOfPregnancy} of 280'),
                      Text('${(pregnancy.pregnancyProgress * 100).toInt()}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: pregnancy.pregnancyProgress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(pregnancy.statusColor),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Key dates
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    'Conceived',
                    DateFormat('dd MMM yyyy').format(pregnancy.conceptionDate),
                    Icons.favorite,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    'Expected Calving',
                    DateFormat('dd MMM yyyy').format(pregnancy.expectedCalvingDate),
                    Icons.schedule,
                  ),
                ),
                if (pregnancy.actualCalvingDate != null)
                  Expanded(
                    child: _buildInfoColumn(
                      'Actual Calving',
                      DateFormat('dd MMM yyyy').format(pregnancy.actualCalvingDate!),
                      Icons.event,
                    ),
                  ),
              ],
            ),
            
            if (pregnancy.checks.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Pregnancy Checks:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              ...pregnancy.checks.map((check) => Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: check.resultColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(check.resultIcon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Day ${check.dayOfPregnancy}: ${check.result.displayName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM').format(check.checkDate),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalvingCard(CalvingRecord calving) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: calving.difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(calving.typeIcon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${calving.type.displayName} Calving',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(calving.calvingDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: calving.difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: calving.difficultyColor),
                  ),
                  child: Text(
                    '${calving.difficultyIcon} ${calving.difficulty.displayName}',
                    style: TextStyle(
                      fontSize: 10,
                      color: calving.difficultyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (calving.calves.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Calves Born:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...calving.calves.map((calf) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: calf.healthColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: calf.healthColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Text(calf.genderIcon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            calf.tagId ?? 'Tag not assigned',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${calf.gender.displayName} • ${calf.birthWeight != null ? '${calf.birthWeight}kg' : 'Weight not recorded'}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: calf.healthColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${calf.healthIcon} ${calf.health.displayName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            
            if (calving.veterinarian != null || calving.cost != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (calving.veterinarian != null)
                    Expanded(
                      child: _buildInfoChip(
                        Icons.person,
                        calving.veterinarian!,
                      ),
                    ),
                  if (calving.cost != null)
                    Expanded(
                      child: _buildInfoChip(
                        Icons.currency_rupee,
                        '₹${calving.cost!.toStringAsFixed(0)}',
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink.shade700),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddRecordMenu,
            icon: const Icon(Icons.add),
            label: const Text('Add Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Additional cards for statistics and insights
  Widget _buildHeatCycleStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Heat Cycle Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Average Cycle', '21 days', Colors.blue),
                _buildStatColumn('Success Rate', '85%', Colors.green),
                _buildStatColumn('Total Cycles', '${heatCycles.length}', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISuccessRateCard() {
    final successRate = aiRecords.isEmpty ? 0 : 
        (aiRecords.where((r) => r.result == AIResult.conceived).length / aiRecords.length * 100);

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Success Rate',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${successRate.toInt()}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text('Success Rate'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${aiRecords.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Total AI'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullsUsedCard() {
    final bullsUsed = aiRecords.map((r) => r.bullId).toSet().toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bulls Used',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (bullsUsed.isEmpty)
              const Text('No AI records found')
            else
              ...bullsUsed.map((bullId) {
                final record = aiRecords.firstWhere((r) => r.bullId == bullId);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.pets, color: Colors.brown),
                  title: Text(bullId),
                  subtitle: Text(record.bullBreed),
                  trailing: Text('${aiRecords.where((r) => r.bullId == bullId).length}x'),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCalvingStatsCard() {
    final totalCalves = calvingHistory.fold<int>(0, (sum, c) => sum + c.calves.length);
    final femaleCalves = calvingHistory.fold<int>(0, (sum, c) => 
        sum + c.calves.where((calf) => calf.gender == CalfGender.female).length);
    final maleCalves = totalCalves - femaleCalves;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calving Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Total Calves', '$totalCalves', Colors.blue),
                _buildStatColumn('♀️ Female', '$femaleCalves', Colors.pink),
                _buildStatColumn('♂️ Male', '$maleCalves', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // Action methods
  void _showAddRecordMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Breeding Record',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Text('❤️', style: TextStyle(fontSize: 24)),
              title: const Text('Heat Cycle'),
              subtitle: const Text('Record heat cycle detection'),
              onTap: () {
                Navigator.pop(context);
                _addBreedingRecord(BreedingRecordType.heatCycle);
              },
            ),
            ListTile(
              leading: const Text('🧬', style: TextStyle(fontSize: 24)),
              title: const Text('Artificial Insemination'),
              subtitle: const Text('Record AI procedure'),
              onTap: () {
                Navigator.pop(context);
                _addBreedingRecord(BreedingRecordType.ai);
              },
            ),
            ListTile(
              leading: const Text('🤰', style: TextStyle(fontSize: 24)),
              title: const Text('Pregnancy Check'),
              subtitle: const Text('Record pregnancy examination'),
              onTap: () {
                Navigator.pop(context);
                _addBreedingRecord(BreedingRecordType.pregnancy);
              },
            ),
            ListTile(
              leading: const Text('🍼', style: TextStyle(fontSize: 24)),
              title: const Text('Calving Record'),
              subtitle: const Text('Record calving event'),
              onTap: () {
                Navigator.pop(context);
                _addBreedingRecord(BreedingRecordType.calving);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addBreedingRecord(BreedingRecordType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBreedingRecordScreen(
          animal: widget.animal,
          recordType: type.stringValue,
        ),
      ),
    );
  }

  void _recordHeatCycle() {
    _addBreedingRecord(BreedingRecordType.heatCycle);
  }

  void _setReminder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔔 Heat Cycle Reminder'),
        content: const Text(
          'Set a reminder for the next expected heat cycle?',
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
                  content: Text('✅ Reminder set for next heat cycle'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set Reminder'),
          ),
        ],
      ),
    );
  }

  void _addPregnancyCheck(PregnancyRecord pregnancy) {
    _addBreedingRecord(BreedingRecordType.pregnancy);
  }

  void _showBreedingCalendar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📅 Breeding Calendar'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Breeding calendar feature coming soon!'),
            SizedBox(height: 16),
            Text(
              'This will show:\n• Heat cycle predictions\n• AI schedules\n• Pregnancy milestones\n• Calving reminders',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

enum BreedingRecordType {
  heatCycle,
  ai,
  pregnancy,
  calving,
}

extension BreedingRecordTypeExtension on BreedingRecordType {
  String get stringValue {
    switch (this) {
      case BreedingRecordType.heatCycle:
        return 'heat_cycle';
      case BreedingRecordType.ai:
        return 'ai_record';
      case BreedingRecordType.pregnancy:
        return 'pregnancy';
      case BreedingRecordType.calving:
        return 'calving';
    }
  }
}