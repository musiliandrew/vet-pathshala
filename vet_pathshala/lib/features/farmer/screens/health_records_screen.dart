import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/animal_model.dart';
import '../models/health_records_model.dart';
import '../../coins/providers/coin_provider.dart';
import 'add_health_record_screen.dart';

class HealthRecordsScreen extends StatefulWidget {
  final AnimalModel animal;
  
  const HealthRecordsScreen({super.key, required this.animal});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = 'All';
  
  // Mock data - in real app this would come from Firebase
  final List<HealthRecord> healthRecords = [
    HealthRecord(
      id: '1',
      animalId: 'animal_1',
      type: HealthRecordType.vaccination,
      title: 'FMD Vaccination',
      description: 'Foot and Mouth Disease vaccination booster',
      date: DateTime.now().subtract(const Duration(days: 30)),
      veterinarian: 'Dr. Sharma',
      medication: 'FMD Vaccine',
      cost: 150.0,
      status: HealthRecordStatus.completed,
      nextDueDate: DateTime.now().add(const Duration(days: 335)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    HealthRecord(
      id: '2',
      animalId: 'animal_1',
      type: HealthRecordType.deworming,
      title: 'Routine Deworming',
      description: 'Quarterly deworming treatment',
      date: DateTime.now().subtract(const Duration(days: 15)),
      veterinarian: 'Dr. Kumar',
      medication: 'Albendazole',
      cost: 80.0,
      status: HealthRecordStatus.completed,
      nextDueDate: DateTime.now().add(const Duration(days: 75)),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    HealthRecord(
      id: '3',
      animalId: 'animal_1',
      type: HealthRecordType.checkup,
      title: 'Pregnancy Check',
      description: 'Monthly pregnancy monitoring - Month 5',
      date: DateTime.now().add(const Duration(days: 2)),
      veterinarian: 'Dr. Sharma',
      status: HealthRecordStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<DewormingSchedule> dewormingSchedule = [
    DewormingSchedule(
      id: '1',
      animalId: 'animal_1',
      lastDeworming: DateTime.now().subtract(const Duration(days: 15)),
      nextDueDate: DateTime.now().add(const Duration(days: 75)),
      medicationUsed: 'Albendazole',
      weight: 450.0,
      notes: 'Normal response, no side effects',
      isCompleted: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  final List<TreatmentPlan> treatmentPlans = [
    TreatmentPlan(
      id: '1',
      animalId: 'animal_1',
      condition: 'Mild Respiratory Infection',
      treatment: 'Antibiotic course and rest',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      medications: ['Oxytetracycline', 'Vitamin B-Complex'],
      veterinarian: 'Dr. Kumar',
      instructions: [
        'Give medication twice daily with feed',
        'Ensure adequate rest and isolation',
        'Monitor temperature daily',
      ],
      status: TreatmentStatus.active,
      notes: 'Showing good improvement',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  final List<HealthIssue> healthIssues = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            Text(
              '${widget.animal.typeEmoji} ${widget.animal.name}',
              style: const TextStyle(fontSize: 18),
            ),
            const Text(
              'Health Records',
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
            onPressed: _showHealthSummary,
            icon: const Icon(Icons.summarize),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'Records'),
            Tab(icon: Icon(Icons.schedule), text: 'Schedule'),
            Tab(icon: Icon(Icons.medical_services), text: 'Treatments'),
            Tab(icon: Icon(Icons.warning), text: 'Issues'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordsTab(),
          _buildScheduleTab(),
          _buildTreatmentsTab(),
          _buildIssuesTab(),
        ],
      ),
    );
  }

  Widget _buildRecordsTab() {
    final filteredRecords = selectedFilter == 'All'
        ? healthRecords
        : healthRecords.where((r) => r.type.displayName == selectedFilter).toList();

    return Column(
      children: [
        // Filter bar
        _buildFilterBar(),
        
        // Records list
        Expanded(
          child: filteredRecords.isEmpty
              ? _buildEmptyState('No health records found')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _buildHealthRecordCard(record);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Upcoming Health Events', Icons.event),
          _buildUpcomingEventsCard(),
          
          const SizedBox(height: 20),
          
          _buildSectionHeader('Deworming Schedule', Icons.schedule),
          ...dewormingSchedule.map((schedule) => _buildDewormingCard(schedule)),
          
          const SizedBox(height: 20),
          
          _buildSectionHeader('Vaccination Reminders', Icons.notifications),
          _buildVaccinationRemindersCard(),
        ],
      ),
    );
  }

  Widget _buildTreatmentsTab() {
    return treatmentPlans.isEmpty
        ? _buildEmptyState('No active treatments')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: treatmentPlans.length,
            itemBuilder: (context, index) {
              final treatment = treatmentPlans[index];
              return _buildTreatmentCard(treatment);
            },
          );
  }

  Widget _buildIssuesTab() {
    return healthIssues.isEmpty
        ? _buildEmptyState('No current health issues\n🎉 Your animal is healthy!')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: healthIssues.length,
            itemBuilder: (context, index) {
              final issue = healthIssues[index];
              return _buildHealthIssueCard(issue);
            },
          );
  }

  Widget _buildFilterBar() {
    final filters = ['All', ...HealthRecordType.values.map((t) => t.displayName)];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = selected ? filter : 'All';
                });
              },
              selectedColor: const Color(0xFF4CAF50),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthRecordCard(HealthRecord record) {
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
                    color: record.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(record.typeIcon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        record.type.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: record.statusColor),
                  ),
                  child: Text(
                    '${record.statusIcon} ${record.status.displayName}',
                    style: TextStyle(
                      fontSize: 10,
                      color: record.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              record.description,
              style: const TextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.calendar_today,
                    DateFormat('dd MMM yyyy').format(record.date),
                  ),
                ),
                if (record.veterinarian != null)
                  Expanded(
                    child: _buildInfoChip(
                      Icons.person,
                      record.veterinarian!,
                    ),
                  ),
                if (record.cost != null)
                  Expanded(
                    child: _buildInfoChip(
                      Icons.currency_rupee,
                      '₹${record.cost!.toStringAsFixed(0)}',
                    ),
                  ),
              ],
            ),
            
            if (record.nextDueDate != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_note, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Next due: ${DateFormat('dd MMM yyyy').format(record.nextDueDate!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsCard() {
    final upcomingEvents = healthRecords
        .where((r) => r.status == HealthRecordStatus.scheduled)
        .toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (upcomingEvents.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      'No upcoming health events',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...upcomingEvents.map((event) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Text(event.typeIcon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy').format(event.date),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _markAsCompleted(event),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: const Text('Complete', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildDewormingCard(DewormingSchedule schedule) {
    final isOverdue = schedule.isOverdue;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isOverdue 
                    ? Colors.red.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('🪱', style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last: ${DateFormat('dd MMM yyyy').format(schedule.lastDeworming)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Next: ${DateFormat('dd MMM yyyy').format(schedule.nextDueDate)}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey,
                    ),
                  ),
                  Text(
                    'Medication: ${schedule.medicationUsed}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isOverdue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'OVERDUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(
                '${schedule.daysUntilDue} days',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationRemindersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReminderItem(
              '💉 FMD Booster',
              'Due in 305 days',
              DateFormat('dd MMM yyyy').format(DateTime.now().add(const Duration(days: 305))),
            ),
            const Divider(),
            _buildReminderItem(
              '💉 Black Quarter',
              'Due in 180 days',
              DateFormat('dd MMM yyyy').format(DateTime.now().add(const Duration(days: 180))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderItem(String title, String subtitle, String date) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.notifications, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }

  Widget _buildTreatmentCard(TreatmentPlan treatment) {
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
                    color: treatment.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(treatment.statusIcon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        treatment.condition,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        treatment.status.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: treatment.statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              treatment.treatment,
              style: const TextStyle(fontSize: 14),
            ),
            
            if (treatment.medications.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Medications: ${treatment.medications.join(', ')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.play_arrow,
                    'Started ${DateFormat('dd MMM').format(treatment.startDate)}',
                  ),
                ),
                if (treatment.endDate != null)
                  Expanded(
                    child: _buildInfoChip(
                      Icons.stop,
                      'Ends ${DateFormat('dd MMM').format(treatment.endDate!)}',
                    ),
                  ),
                if (treatment.veterinarian != null)
                  Expanded(
                    child: _buildInfoChip(
                      Icons.person,
                      treatment.veterinarian!,
                    ),
                  ),
              ],
            ),
            
            if (treatment.instructions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              ...treatment.instructions.map((instruction) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(
                        instruction,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
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

  Widget _buildHealthIssueCard(HealthIssue issue) {
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
                    color: issue.severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(issue.severityIcon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.issue,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${issue.severity.displayName} Severity',
                        style: TextStyle(
                          fontSize: 12,
                          color: issue.severityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: issue.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: issue.statusColor),
                  ),
                  child: Text(
                    '${issue.statusIcon} ${issue.status.displayName}',
                    style: TextStyle(
                      fontSize: 10,
                      color: issue.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              issue.description,
              style: const TextStyle(fontSize: 14),
            ),
            
            if (issue.symptoms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Symptoms: ${issue.symptoms.join(', ')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.event,
                    'Detected ${DateFormat('dd MMM').format(issue.detectedDate)}',
                  ),
                ),
                if (issue.veterinarian != null)
                  Expanded(
                    child: _buildInfoChip(
                      Icons.person,
                      issue.veterinarian!,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.health_and_safety_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddRecordMenu,
            icon: const Icon(Icons.add),
            label: const Text('Add Health Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

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
              'Add Health Record',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...HealthRecordType.values.map((type) => ListTile(
              leading: Text(type.icon, style: const TextStyle(fontSize: 24)),
              title: Text(type.displayName),
              subtitle: Text(_getTypeDescription(type)),
              onTap: () {
                Navigator.pop(context);
                _addHealthRecord(type);
              },
            )),
          ],
        ),
      ),
    );
  }

  String _getTypeDescription(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.vaccination:
        return 'Add vaccination records and schedules';
      case HealthRecordType.deworming:
        return 'Record deworming treatments';
      case HealthRecordType.treatment:
        return 'Log medical treatments';
      case HealthRecordType.checkup:
        return 'Regular health checkups';
      case HealthRecordType.surgery:
        return 'Surgical procedures';
      case HealthRecordType.illness:
        return 'Disease or illness records';
      case HealthRecordType.injury:
        return 'Injury records and treatment';
      case HealthRecordType.medication:
        return 'Medication logs';
      case HealthRecordType.general:
        return 'General health notes';
    }
  }

  void _addHealthRecord(HealthRecordType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHealthRecordScreen(
          animal: widget.animal,
          recordType: type,
        ),
      ),
    );
  }

  void _showHealthSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Health Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryItem('Total Records', '${healthRecords.length}', Colors.blue),
            _buildSummaryItem('Upcoming Events', '${healthRecords.where((r) => r.status == HealthRecordStatus.scheduled).length}', Colors.orange),
            _buildSummaryItem('Active Treatments', '${treatmentPlans.where((t) => t.status == TreatmentStatus.active).length}', Colors.green),
            _buildSummaryItem('Health Issues', '${healthIssues.where((i) => i.status == HealthIssueStatus.active).length}', Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Last Health Checkup: 2 months ago',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Text(
              'Overall Health Status: Excellent',
              style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateHealthReport();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateHealthReport() async {
    final coinProvider = context.read<CoinProvider>();
    const requiredCoins = 5;

    if (coinProvider.currentBalance < requiredCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient coins! Need $requiredCoins coins to generate health report.'),
          backgroundColor: Colors.red,
        ),
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
            Text('Generating health report...'),
          ],
        ),
      ),
    );

    // Simulate report generation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context); // Close loading
      coinProvider.deductCoins(5, 'Health Report Generation');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Health report generated successfully! Check your downloads.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _markAsCompleted(HealthRecord event) {
    setState(() {
      final index = healthRecords.indexWhere((r) => r.id == event.id);
      if (index != -1) {
        healthRecords[index] = event.copyWith(
          status: HealthRecordStatus.completed,
          updatedAt: DateTime.now(),
        );
      }
    });

    // Award coin for completing health task
    context.read<CoinProvider>().addCoins(2, 'Health Task Completion');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Health record marked as completed! +2 coins earned'),
        backgroundColor: Colors.green,
      ),
    );
  }
}