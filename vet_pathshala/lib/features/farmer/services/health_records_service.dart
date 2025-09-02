import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/health_records_model.dart';
import '../../../core/utils/firebase_availability.dart';

class HealthRecordsService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<HealthRecord>> getAnimalHealthHistory(String animalId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🩺 HealthRecordsService: Fetching health history for animal: $animalId');
      
      final snapshot = await _firestore
          .collection('health_records')
          .where('animalId', isEqualTo: animalId)
          .orderBy('date', descending: true)
          .get();

      final records = snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ HealthRecordsService: Retrieved ${records.length} health records');
      return records;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error fetching health history: $e');
      throw Exception('Failed to fetch health history: $e');
    }
  }

  Future<List<HealthRecord>> getUserHealthRecords(String userId, {HealthRecordType? type}) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🩺 HealthRecordsService: Fetching health records for user: $userId');
      
      Query query = _firestore
          .collection('health_records')
          .where('userId', isEqualTo: userId);

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final snapshot = await query
          .orderBy('date', descending: true)
          .get();

      final records = snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ HealthRecordsService: Retrieved ${records.length} health records');
      return records;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error fetching user health records: $e');
      throw Exception('Failed to fetch health records: $e');
    }
  }

  Future<HealthRecord> addHealthRecord(HealthRecord record, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🩺 HealthRecordsService: Adding health record: ${record.title}');

      // Add userId to the record data
      final recordData = record.toFirestore();
      recordData['userId'] = userId;

      final docRef = await _firestore
          .collection('health_records')
          .add(recordData);

      final createdRecord = HealthRecord(
        id: docRef.id,
        animalId: record.animalId,
        type: record.type,
        title: record.title,
        description: record.description,
        date: record.date,
        veterinarian: record.veterinarian,
        medication: record.medication,
        cost: record.cost,
        notes: record.notes,
        attachments: record.attachments,
        status: record.status,
        nextDueDate: record.nextDueDate,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
      );

      // Create alert if there's a next due date
      if (record.nextDueDate != null) {
        await _createFollowUpAlert(record, userId);
      }

      debugPrint('✅ HealthRecordsService: Health record created with ID: ${docRef.id}');
      notifyListeners();
      return createdRecord;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error adding health record: $e');
      throw Exception('Failed to add health record: $e');
    }
  }

  Future<HealthRecord> updateHealthRecord(HealthRecord record, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🩺 HealthRecordsService: Updating health record: ${record.id}');

      final updatedRecord = record.copyWith(updatedAt: DateTime.now());
      final recordData = updatedRecord.toFirestore();
      recordData['userId'] = userId;

      await _firestore
          .collection('health_records')
          .doc(record.id)
          .update(recordData);

      debugPrint('✅ HealthRecordsService: Health record updated successfully');
      notifyListeners();
      return updatedRecord;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error updating health record: $e');
      throw Exception('Failed to update health record: $e');
    }
  }

  Future<void> deleteHealthRecord(String recordId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🩺 HealthRecordsService: Deleting health record: $recordId');

      await _firestore
          .collection('health_records')
          .doc(recordId)
          .delete();

      debugPrint('✅ HealthRecordsService: Health record deleted successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error deleting health record: $e');
      throw Exception('Failed to delete health record: $e');
    }
  }

  Future<List<HealthRecord>> getUpcomingVaccinations(String userId, {int? daysAhead}) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💉 HealthRecordsService: Fetching upcoming vaccinations for user: $userId');
      
      final endDate = DateTime.now().add(Duration(days: daysAhead ?? 30));
      
      final snapshot = await _firestore
          .collection('health_records')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: HealthRecordType.vaccination.name)
          .where('nextDueDate', isGreaterThan: Timestamp.now())
          .where('nextDueDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('nextDueDate')
          .get();

      final vaccinations = snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ HealthRecordsService: Retrieved ${vaccinations.length} upcoming vaccinations');
      return vaccinations;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error fetching upcoming vaccinations: $e');
      throw Exception('Failed to fetch upcoming vaccinations: $e');
    }
  }

  Future<List<HealthRecord>> getOverdueVaccinations(String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💉 HealthRecordsService: Fetching overdue vaccinations for user: $userId');
      
      final snapshot = await _firestore
          .collection('health_records')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: HealthRecordType.vaccination.name)
          .where('nextDueDate', isLessThan: Timestamp.now())
          .where('status', isNotEqualTo: HealthRecordStatus.completed.name)
          .orderBy('nextDueDate')
          .get();

      final overdueVaccinations = snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ HealthRecordsService: Retrieved ${overdueVaccinations.length} overdue vaccinations');
      return overdueVaccinations;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error fetching overdue vaccinations: $e');
      throw Exception('Failed to fetch overdue vaccinations: $e');
    }
  }

  Future<void> scheduleVaccination({
    required String animalId,
    required String vaccineName,
    required DateTime dueDate,
    required String userId,
    String? notes,
    String? veterinarian,
  }) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💉 HealthRecordsService: Scheduling vaccination: $vaccineName');

      final vaccinationRecord = HealthRecord(
        id: '',
        animalId: animalId,
        type: HealthRecordType.vaccination,
        title: vaccineName,
        description: 'Scheduled vaccination for $vaccineName',
        date: dueDate,
        veterinarian: veterinarian,
        medication: vaccineName,
        cost: null,
        notes: notes,
        attachments: [],
        status: HealthRecordStatus.scheduled,
        nextDueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await addHealthRecord(vaccinationRecord, userId);
      debugPrint('✅ HealthRecordsService: Vaccination scheduled successfully');
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error scheduling vaccination: $e');
      throw Exception('Failed to schedule vaccination: $e');
    }
  }

  Future<List<DewormingSchedule>> getDewormingSchedule(String animalId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🪱 HealthRecordsService: Fetching deworming schedule for animal: $animalId');
      
      final snapshot = await _firestore
          .collection('deworming_schedules')
          .where('animalId', isEqualTo: animalId)
          .orderBy('nextDueDate')
          .get();

      final schedules = snapshot.docs
          .map((doc) => DewormingSchedule.fromFirestore(doc))
          .toList();

      debugPrint('✅ HealthRecordsService: Retrieved ${schedules.length} deworming schedules');
      return schedules;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error fetching deworming schedule: $e');
      throw Exception('Failed to fetch deworming schedule: $e');
    }
  }

  Future<DewormingSchedule> addDewormingRecord({
    required String animalId,
    required DateTime dewormingDate,
    required String medication,
    required String userId,
    double? animalWeight,
    String? notes,
  }) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🪱 HealthRecordsService: Adding deworming record for animal: $animalId');

      // Calculate next due date (typically 3-6 months)
      final nextDueDate = dewormingDate.add(const Duration(days: 120)); // 4 months

      final dewormingSchedule = DewormingSchedule(
        id: '',
        animalId: animalId,
        lastDeworming: dewormingDate,
        nextDueDate: nextDueDate,
        medicationUsed: medication,
        weight: animalWeight,
        notes: notes,
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('deworming_schedules')
          .add(dewormingSchedule.toFirestore());

      // Also add to health records
      final healthRecord = HealthRecord(
        id: '',
        animalId: animalId,
        type: HealthRecordType.deworming,
        title: 'Deworming - $medication',
        description: 'Deworming treatment with $medication',
        date: dewormingDate,
        medication: medication,
        notes: notes,
        attachments: [],
        status: HealthRecordStatus.completed,
        nextDueDate: nextDueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await addHealthRecord(healthRecord, userId);

      final createdSchedule = DewormingSchedule(
        id: docRef.id,
        animalId: animalId,
        lastDeworming: dewormingDate,
        nextDueDate: nextDueDate,
        medicationUsed: medication,
        weight: animalWeight,
        notes: notes,
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      debugPrint('✅ HealthRecordsService: Deworming record created with ID: ${docRef.id}');
      notifyListeners();
      return createdSchedule;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error adding deworming record: $e');
      throw Exception('Failed to add deworming record: $e');
    }
  }

  Future<List<TreatmentPlan>> getActiveTreatmentPlans(String animalId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💊 HealthRecordsService: Fetching treatment plans for animal: $animalId');
      
      final snapshot = await _firestore
          .collection('treatment_plans')
          .where('animalId', isEqualTo: animalId)
          .where('status', whereIn: [TreatmentStatus.active.name, TreatmentStatus.scheduled.name])
          .orderBy('startDate', descending: true)
          .get();

      final plans = snapshot.docs
          .map((doc) => TreatmentPlan.fromFirestore(doc))
          .toList();

      debugPrint('✅ HealthRecordsService: Retrieved ${plans.length} treatment plans');
      return plans;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error fetching treatment plans: $e');
      throw Exception('Failed to fetch treatment plans: $e');
    }
  }

  Future<TreatmentPlan> createTreatmentPlan(TreatmentPlan plan, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💊 HealthRecordsService: Creating treatment plan: ${plan.condition}');

      final planData = plan.toFirestore();
      planData['userId'] = userId;

      final docRef = await _firestore
          .collection('treatment_plans')
          .add(planData);

      final createdPlan = TreatmentPlan(
        id: docRef.id,
        animalId: plan.animalId,
        condition: plan.condition,
        treatment: plan.treatment,
        startDate: plan.startDate,
        endDate: plan.endDate,
        medications: plan.medications,
        veterinarian: plan.veterinarian,
        instructions: plan.instructions,
        status: plan.status,
        notes: plan.notes,
        createdAt: plan.createdAt,
      );

      debugPrint('✅ HealthRecordsService: Treatment plan created with ID: ${docRef.id}');
      notifyListeners();
      return createdPlan;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error creating treatment plan: $e');
      throw Exception('Failed to create treatment plan: $e');
    }
  }

  Future<void> updateTreatmentPlanStatus(String planId, TreatmentStatus status) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💊 HealthRecordsService: Updating treatment plan status: $planId');

      final updateData = {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == TreatmentStatus.completed) {
        updateData['endDate'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('treatment_plans')
          .doc(planId)
          .update(updateData);

      debugPrint('✅ HealthRecordsService: Treatment plan status updated');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error updating treatment plan: $e');
      throw Exception('Failed to update treatment plan status: $e');
    }
  }

  Future<List<HealthIssue>> getActiveHealthIssues(String animalId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🤒 HealthRecordsService: Fetching active health issues for animal: $animalId');
      
      final snapshot = await _firestore
          .collection('health_issues')
          .where('animalId', isEqualTo: animalId)
          .where('status', whereIn: [
            HealthIssueStatus.active.name,
            HealthIssueStatus.monitoring.name,
            HealthIssueStatus.chronic.name,
          ])
          .orderBy('severity', descending: true)
          .orderBy('detectedDate', descending: true)
          .get();

      final issues = snapshot.docs
          .map((doc) => HealthIssue.fromFirestore(doc))
          .toList();

      debugPrint('✅ HealthRecordsService: Retrieved ${issues.length} active health issues');
      return issues;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error fetching health issues: $e');
      throw Exception('Failed to fetch health issues: $e');
    }
  }

  Future<HealthIssue> reportHealthIssue(HealthIssue issue, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🤒 HealthRecordsService: Reporting health issue: ${issue.issue}');

      final issueData = issue.toFirestore();
      issueData['userId'] = userId;

      final docRef = await _firestore
          .collection('health_issues')
          .add(issueData);

      final createdIssue = HealthIssue(
        id: docRef.id,
        animalId: issue.animalId,
        issue: issue.issue,
        description: issue.description,
        severity: issue.severity,
        detectedDate: issue.detectedDate,
        resolvedDate: issue.resolvedDate,
        symptoms: issue.symptoms,
        diagnosis: issue.diagnosis,
        treatment: issue.treatment,
        veterinarian: issue.veterinarian,
        medications: issue.medications,
        status: issue.status,
        notes: issue.notes,
        createdAt: issue.createdAt,
      );

      // Create health record for this issue
      final healthRecord = HealthRecord(
        id: '',
        animalId: issue.animalId,
        type: HealthRecordType.illness,
        title: issue.issue,
        description: issue.description,
        date: issue.detectedDate,
        veterinarian: issue.veterinarian,
        medication: issue.medications.isNotEmpty ? issue.medications.join(', ') : null,
        notes: issue.notes,
        attachments: [],
        status: HealthRecordStatus.inProgress,
        nextDueDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await addHealthRecord(healthRecord, userId);

      debugPrint('✅ HealthRecordsService: Health issue reported with ID: ${docRef.id}');
      notifyListeners();
      return createdIssue;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error reporting health issue: $e');
      throw Exception('Failed to report health issue: $e');
    }
  }

  Future<void> resolveHealthIssue(String issueId, String treatment, {String? notes}) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🤒 HealthRecordsService: Resolving health issue: $issueId');

      await _firestore
          .collection('health_issues')
          .doc(issueId)
          .update({
            'status': HealthIssueStatus.resolved.name,
            'resolvedDate': FieldValue.serverTimestamp(),
            'treatment': treatment,
            'notes': notes,
          });

      debugPrint('✅ HealthRecordsService: Health issue resolved successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error resolving health issue: $e');
      throw Exception('Failed to resolve health issue: $e');
    }
  }

  Future<Map<String, dynamic>> getHealthSummary(String animalId) async {
    try {
      debugPrint('📊 HealthRecordsService: Generating health summary for animal: $animalId');
      
      final healthRecords = await getAnimalHealthHistory(animalId);
      final activeIssues = await getActiveHealthIssues(animalId);
      final treatmentPlans = await getActiveTreatmentPlans(animalId);

      final lastVaccination = healthRecords
          .where((r) => r.type == HealthRecordType.vaccination)
          .isNotEmpty
          ? healthRecords
              .where((r) => r.type == HealthRecordType.vaccination)
              .reduce((a, b) => a.date.isAfter(b.date) ? a : b)
          : null;

      final lastCheckup = healthRecords
          .where((r) => r.type == HealthRecordType.checkup)
          .isNotEmpty
          ? healthRecords
              .where((r) => r.type == HealthRecordType.checkup)
              .reduce((a, b) => a.date.isAfter(b.date) ? a : b)
          : null;

      final summary = {
        'totalHealthRecords': healthRecords.length,
        'activeIssues': activeIssues.length,
        'activeTreatments': treatmentPlans.length,
        'lastVaccination': lastVaccination?.date,
        'lastCheckup': lastCheckup?.date,
        'criticalIssues': activeIssues.where((i) => i.severity == HealthIssueSeverity.critical).length,
        'highPriorityIssues': activeIssues.where((i) => i.severity == HealthIssueSeverity.high).length,
        'vaccinationCount': healthRecords.where((r) => r.type == HealthRecordType.vaccination).length,
        'treatmentCount': healthRecords.where((r) => r.type == HealthRecordType.treatment).length,
        'checkupCount': healthRecords.where((r) => r.type == HealthRecordType.checkup).length,
      };

      debugPrint('✅ HealthRecordsService: Health summary generated');
      return summary;
    } catch (e) {
      debugPrint('❌ HealthRecordsService: Error generating health summary: $e');
      throw Exception('Failed to generate health summary: $e');
    }
  }

  Stream<List<HealthRecord>> watchAnimalHealthRecords(String animalId) {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    debugPrint('🔄 HealthRecordsService: Starting real-time watch for health records: $animalId');
    
    return _firestore
        .collection('health_records')
        .where('animalId', isEqualTo: animalId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs
              .map((doc) => HealthRecord.fromFirestore(doc))
              .toList();
          debugPrint('🔄 HealthRecordsService: Real-time update - ${records.length} health records');
          return records;
        });
  }

  Future<void> _createFollowUpAlert(HealthRecord record, String userId) async {
    if (record.nextDueDate == null) return;

    try {
      // Create alert 7 days before due date
      final alertDate = record.nextDueDate!.subtract(const Duration(days: 7));
      
      if (alertDate.isAfter(DateTime.now())) {
        await _firestore.collection('farm_alerts').add({
          'animalId': record.animalId,
          'title': 'Upcoming ${record.type.displayName}',
          'description': 'Follow-up ${record.type.displayName.toLowerCase()} due for ${record.title}',
          'type': 'health',
          'priority': 'medium',
          'dueDate': Timestamp.fromDate(record.nextDueDate!),
          'isCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': userId,
        });
      }
    } catch (e) {
      debugPrint('⚠️ HealthRecordsService: Could not create follow-up alert: $e');
    }
  }

  Future<List<String>> getCommonMedications() async {
    return [
      'Albendazole',
      'Ivermectin',
      'Fenbendazole',
      'Levamisole',
      'Piperazine',
      'Closantel',
      'Doramectin',
      'Eprinomectin',
      'Moxidectin',
      'Pyrantel',
      'Thiabendazole',
      'Nitroxynil',
      'Rafoxanide',
      'Triclabendazole',
      'Oxyclozanide',
    ];
  }

  Future<List<String>> getCommonVaccines() async {
    return [
      'Foot and Mouth Disease (FMD)',
      'Haemorrhagic Septicaemia (HS)',
      'Black Quarter (BQ)',
      'Bovine Viral Diarrhea (BVD)',
      'Infectious Bovine Rhinotracheitis (IBR)',
      'Parainfluenza-3 (PI3)',
      'Bovine Respiratory Syncytial Virus (BRSV)',
      'Brucellosis',
      'Leptospirosis',
      'Anthrax',
      'Rabies',
      'Clostridial infections',
      'Mastitis vaccine',
      'Rotavirus',
      'Coronavirus',
    ];
  }

  Future<List<HealthRecord>> getHealthRecordsByType(String animalId, HealthRecordType type) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      final snapshot = await _firestore
          .collection('health_records')
          .where('animalId', isEqualTo: animalId)
          .where('type', isEqualTo: type.name)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch health records by type: $e');
    }
  }

  Future<void> completeHealthRecord(String recordId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      await _firestore
          .collection('health_records')
          .doc(recordId)
          .update({
            'status': HealthRecordStatus.completed.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to complete health record: $e');
    }
  }
}