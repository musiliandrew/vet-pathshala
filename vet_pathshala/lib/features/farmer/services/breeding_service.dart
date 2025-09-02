import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/breeding_records_model.dart';
import '../../../core/utils/firebase_availability.dart';

class BreedingService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<HeatCycleRecord>> getHeatCycles(String animalId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🔥 BreedingService: Fetching heat cycles for animal: $animalId');
      
      final snapshot = await _firestore
          .collection('heat_cycles')
          .where('animalId', isEqualTo: animalId)
          .orderBy('detectedDate', descending: true)
          .get();

      final cycles = snapshot.docs
          .map((doc) => HeatCycleRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ BreedingService: Retrieved ${cycles.length} heat cycles');
      return cycles;
    } catch (e) {
      debugPrint('❌ BreedingService: Error fetching heat cycles: $e');
      throw Exception('Failed to fetch heat cycles: $e');
    }
  }

  Future<HeatCycleRecord> recordHeatCycle(HeatCycleRecord cycle, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🔥 BreedingService: Recording heat cycle for animal: ${cycle.animalId}');

      final cycleData = cycle.toFirestore();
      cycleData['userId'] = userId;

      final docRef = await _firestore
          .collection('heat_cycles')
          .add(cycleData);

      final createdCycle = HeatCycleRecord(
        id: docRef.id,
        animalId: cycle.animalId,
        detectedDate: cycle.detectedDate,
        matingDate: cycle.matingDate,
        intensity: cycle.intensity,
        symptoms: cycle.symptoms,
        result: cycle.result,
        notes: cycle.notes,
        createdAt: cycle.createdAt,
        updatedAt: cycle.updatedAt,
      );

      // Create alert for next expected heat cycle
      await _createHeatCycleAlert(createdCycle, userId);

      debugPrint('✅ BreedingService: Heat cycle recorded with ID: ${docRef.id}');
      notifyListeners();
      return createdCycle;
    } catch (e) {
      debugPrint('❌ BreedingService: Error recording heat cycle: $e');
      throw Exception('Failed to record heat cycle: $e');
    }
  }

  Future<void> updateHeatCycleResult(String cycleId, HeatCycleResult result, {DateTime? matingDate}) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🔥 BreedingService: Updating heat cycle result: $cycleId');

      final updateData = {
        'result': result.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (matingDate != null) {
        updateData['matingDate'] = Timestamp.fromDate(matingDate);
      }

      await _firestore
          .collection('heat_cycles')
          .doc(cycleId)
          .update(updateData);

      debugPrint('✅ BreedingService: Heat cycle result updated');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ BreedingService: Error updating heat cycle: $e');
      throw Exception('Failed to update heat cycle result: $e');
    }
  }

  Future<List<AIRecord>> getAIRecords(String animalId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🎯 BreedingService: Fetching AI records for animal: $animalId');
      
      final snapshot = await _firestore
          .collection('ai_records')
          .where('animalId', isEqualTo: animalId)
          .orderBy('aiDate', descending: true)
          .get();

      final records = snapshot.docs
          .map((doc) => AIRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ BreedingService: Retrieved ${records.length} AI records');
      return records;
    } catch (e) {
      debugPrint('❌ BreedingService: Error fetching AI records: $e');
      throw Exception('Failed to fetch AI records: $e');
    }
  }

  Future<AIRecord> recordAI(AIRecord aiRecord, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🎯 BreedingService: Recording AI for animal: ${aiRecord.animalId}');

      final recordData = aiRecord.toFirestore();
      recordData['userId'] = userId;

      final docRef = await _firestore
          .collection('ai_records')
          .add(recordData);

      final createdRecord = AIRecord(
        id: docRef.id,
        animalId: aiRecord.animalId,
        aiDate: aiRecord.aiDate,
        bullId: aiRecord.bullId,
        bullBreed: aiRecord.bullBreed,
        semenBatch: aiRecord.semenBatch,
        technician: aiRecord.technician,
        method: aiRecord.method,
        cost: aiRecord.cost,
        result: aiRecord.result,
        pregnancyCheckDate: aiRecord.pregnancyCheckDate,
        notes: aiRecord.notes,
        createdAt: aiRecord.createdAt,
        updatedAt: aiRecord.updatedAt,
      );

      // Create pregnancy check alert
      await _createPregnancyCheckAlert(createdRecord, userId);

      debugPrint('✅ BreedingService: AI record created with ID: ${docRef.id}');
      notifyListeners();
      return createdRecord;
    } catch (e) {
      debugPrint('❌ BreedingService: Error recording AI: $e');
      throw Exception('Failed to record artificial insemination: $e');
    }
  }

  Future<void> updateAIResult(String aiRecordId, AIResult result, {DateTime? pregnancyCheckDate}) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🎯 BreedingService: Updating AI result: $aiRecordId');

      final updateData = {
        'result': result.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (pregnancyCheckDate != null) {
        updateData['pregnancyCheckDate'] = Timestamp.fromDate(pregnancyCheckDate);
      }

      await _firestore
          .collection('ai_records')
          .doc(aiRecordId)
          .update(updateData);

      // If conceived, create pregnancy record
      if (result == AIResult.conceived) {
        await _createPregnancyFromAI(aiRecordId);
      }

      debugPrint('✅ BreedingService: AI result updated');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ BreedingService: Error updating AI result: $e');
      throw Exception('Failed to update AI result: $e');
    }
  }

  Future<List<PregnancyRecord>> getActivePregnancies(String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🤰 BreedingService: Fetching active pregnancies for user: $userId');
      
      final snapshot = await _firestore
          .collection('pregnancy_records')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: PregnancyStatus.ongoing.name)
          .orderBy('expectedCalvingDate')
          .get();

      final pregnancies = snapshot.docs
          .map((doc) => PregnancyRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ BreedingService: Retrieved ${pregnancies.length} active pregnancies');
      return pregnancies;
    } catch (e) {
      debugPrint('❌ BreedingService: Error fetching active pregnancies: $e');
      throw Exception('Failed to fetch active pregnancies: $e');
    }
  }

  Future<List<PregnancyRecord>> getAnimalPregnancies(String animalId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🤰 BreedingService: Fetching pregnancies for animal: $animalId');
      
      final snapshot = await _firestore
          .collection('pregnancy_records')
          .where('animalId', isEqualTo: animalId)
          .orderBy('conceptionDate', descending: true)
          .get();

      final pregnancies = snapshot.docs
          .map((doc) => PregnancyRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ BreedingService: Retrieved ${pregnancies.length} pregnancies');
      return pregnancies;
    } catch (e) {
      debugPrint('❌ BreedingService: Error fetching animal pregnancies: $e');
      throw Exception('Failed to fetch animal pregnancies: $e');
    }
  }

  Future<PregnancyRecord> createPregnancy(PregnancyRecord pregnancy, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🤰 BreedingService: Creating pregnancy record for animal: ${pregnancy.animalId}');

      final pregnancyData = pregnancy.toFirestore();
      pregnancyData['userId'] = userId;

      final docRef = await _firestore
          .collection('pregnancy_records')
          .add(pregnancyData);

      final createdPregnancy = PregnancyRecord(
        id: docRef.id,
        animalId: pregnancy.animalId,
        conceptionDate: pregnancy.conceptionDate,
        expectedCalvingDate: pregnancy.expectedCalvingDate,
        actualCalvingDate: pregnancy.actualCalvingDate,
        sireId: pregnancy.sireId,
        status: pregnancy.status,
        checks: pregnancy.checks,
        veterinarian: pregnancy.veterinarian,
        notes: pregnancy.notes,
        createdAt: pregnancy.createdAt,
        updatedAt: pregnancy.updatedAt,
      );

      // Create calving alert
      await _createCalvingAlert(createdPregnancy, userId);

      debugPrint('✅ BreedingService: Pregnancy record created with ID: ${docRef.id}');
      notifyListeners();
      return createdPregnancy;
    } catch (e) {
      debugPrint('❌ BreedingService: Error creating pregnancy: $e');
      throw Exception('Failed to create pregnancy record: $e');
    }
  }

  Future<void> addPregnancyCheck(String pregnancyId, PregnancyCheck check) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🤰 BreedingService: Adding pregnancy check for: $pregnancyId');

      // Get current pregnancy record
      final doc = await _firestore
          .collection('pregnancy_records')
          .doc(pregnancyId)
          .get();

      if (!doc.exists) {
        throw Exception('Pregnancy record not found');
      }

      final pregnancy = PregnancyRecord.fromFirestore(doc);
      final updatedChecks = [...pregnancy.checks, check];

      await _firestore
          .collection('pregnancy_records')
          .doc(pregnancyId)
          .update({
            'checks': updatedChecks.map((c) => c.toMap()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      debugPrint('✅ BreedingService: Pregnancy check added');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ BreedingService: Error adding pregnancy check: $e');
      throw Exception('Failed to add pregnancy check: $e');
    }
  }

  Future<void> completePregnancy(String pregnancyId, CalvingRecord calvingRecord, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🤰 BreedingService: Completing pregnancy: $pregnancyId');

      // Update pregnancy status
      await _firestore
          .collection('pregnancy_records')
          .doc(pregnancyId)
          .update({
            'status': PregnancyStatus.completed.name,
            'actualCalvingDate': Timestamp.fromDate(calvingRecord.calvingDate),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Create calving record
      final calvingData = calvingRecord.toFirestore();
      calvingData['userId'] = userId;
      calvingData['pregnancyId'] = pregnancyId;

      await _firestore
          .collection('calving_records')
          .add(calvingData);

      debugPrint('✅ BreedingService: Pregnancy completed and calving recorded');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ BreedingService: Error completing pregnancy: $e');
      throw Exception('Failed to complete pregnancy: $e');
    }
  }

  Future<List<CalvingRecord>> getCalvingHistory(String animalId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🍼 BreedingService: Fetching calving history for animal: $animalId');
      
      final snapshot = await _firestore
          .collection('calving_records')
          .where('motherId', isEqualTo: animalId)
          .orderBy('calvingDate', descending: true)
          .get();

      final records = snapshot.docs
          .map((doc) => CalvingRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ BreedingService: Retrieved ${records.length} calving records');
      return records;
    } catch (e) {
      debugPrint('❌ BreedingService: Error fetching calving history: $e');
      throw Exception('Failed to fetch calving history: $e');
    }
  }

  Future<List<PregnancyRecord>> getUpcomingCalvings(String userId, {int? daysAhead}) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🍼 BreedingService: Fetching upcoming calvings for user: $userId');
      
      final endDate = DateTime.now().add(Duration(days: daysAhead ?? 30));
      
      final snapshot = await _firestore
          .collection('pregnancy_records')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: PregnancyStatus.ongoing.name)
          .where('expectedCalvingDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('expectedCalvingDate')
          .get();

      final pregnancies = snapshot.docs
          .map((doc) => PregnancyRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ BreedingService: Retrieved ${pregnancies.length} upcoming calvings');
      return pregnancies;
    } catch (e) {
      debugPrint('❌ BreedingService: Error fetching upcoming calvings: $e');
      throw Exception('Failed to fetch upcoming calvings: $e');
    }
  }

  Future<List<PregnancyRecord>> getOverdueCalvings(String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🍼 BreedingService: Fetching overdue calvings for user: $userId');
      
      final snapshot = await _firestore
          .collection('pregnancy_records')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: PregnancyStatus.ongoing.name)
          .where('expectedCalvingDate', isLessThan: Timestamp.now())
          .orderBy('expectedCalvingDate')
          .get();

      final pregnancies = snapshot.docs
          .map((doc) => PregnancyRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ BreedingService: Retrieved ${pregnancies.length} overdue calvings');
      return pregnancies;
    } catch (e) {
      debugPrint('❌ BreedingService: Error fetching overdue calvings: $e');
      throw Exception('Failed to fetch overdue calvings: $e');
    }
  }

  Future<Map<String, dynamic>> getBreedingStatistics(String userId, {String? animalId}) async {
    try {
      debugPrint('📊 BreedingService: Calculating breeding statistics for user: $userId');
      
      Query pregnancyQuery = _firestore
          .collection('pregnancy_records')
          .where('userId', isEqualTo: userId);

      Query aiQuery = _firestore
          .collection('ai_records')
          .where('userId', isEqualTo: userId);

      Query calvingQuery = _firestore
          .collection('calving_records')
          .where('userId', isEqualTo: userId);

      if (animalId != null) {
        pregnancyQuery = pregnancyQuery.where('animalId', isEqualTo: animalId);
        aiQuery = aiQuery.where('animalId', isEqualTo: animalId);
        calvingQuery = calvingQuery.where('motherId', isEqualTo: animalId);
      }

      final results = await Future.wait([
        pregnancyQuery.get(),
        aiQuery.get(),
        calvingQuery.get(),
      ]);

      final pregnancies = results[0].docs.map((doc) => PregnancyRecord.fromFirestore(doc)).toList();
      final aiRecords = results[1].docs.map((doc) => AIRecord.fromFirestore(doc)).toList();
      final calvings = results[2].docs.map((doc) => CalvingRecord.fromFirestore(doc)).toList();

      final activePregnancies = pregnancies.where((p) => p.status == PregnancyStatus.ongoing).length;
      final completedPregnancies = pregnancies.where((p) => p.status == PregnancyStatus.completed).length;
      final successfulAIs = aiRecords.where((ai) => ai.result == AIResult.conceived).length;
      final totalAIs = aiRecords.length;
      final conceptionRate = totalAIs > 0 ? (successfulAIs / totalAIs) * 100 : 0.0;

      final totalCalves = calvings.fold<int>(0, (sum, calving) => sum + calving.calves.length);
      final femaleCalves = calvings.fold<int>(0, (sum, calving) => 
          sum + calving.calves.where((calf) => calf.gender == CalfGender.female).length);
      final maleCalves = calvings.fold<int>(0, (sum, calving) => 
          sum + calving.calves.where((calf) => calf.gender == CalfGender.male).length);

      final statistics = {
        'activePregnancies': activePregnancies,
        'completedPregnancies': completedPregnancies,
        'totalAIAttempts': totalAIs,
        'successfulAIs': successfulAIs,
        'conceptionRate': conceptionRate,
        'totalCalvings': calvings.length,
        'totalCalves': totalCalves,
        'femaleCalves': femaleCalves,
        'maleCalves': maleCalves,
        'averageCalvingInterval': _calculateAverageCalvingInterval(calvings),
        'lastCalving': calvings.isNotEmpty ? calvings.first.calvingDate.toIso8601String() : null,
      };

      debugPrint('✅ BreedingService: Breeding statistics calculated');
      return statistics;
    } catch (e) {
      debugPrint('❌ BreedingService: Error calculating breeding statistics: $e');
      throw Exception('Failed to calculate breeding statistics: $e');
    }
  }

  Future<List<HeatCycleRecord>> getPendingHeatCycles(String userId) async {
    try {
      debugPrint('🔥 BreedingService: Fetching pending heat cycles for user: $userId');
      
      final snapshot = await _firestore
          .collection('heat_cycles')
          .where('userId', isEqualTo: userId)
          .where('result', isEqualTo: HeatCycleResult.pending.name)
          .orderBy('detectedDate', descending: true)
          .get();

      final cycles = snapshot.docs
          .map((doc) => HeatCycleRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ BreedingService: Retrieved ${cycles.length} pending heat cycles');
      return cycles;
    } catch (e) {
      debugPrint('❌ BreedingService: Error fetching pending heat cycles: $e');
      throw Exception('Failed to fetch pending heat cycles: $e');
    }
  }

  Future<List<AIRecord>> getPendingPregnancyChecks(String userId) async {
    try {
      debugPrint('🎯 BreedingService: Fetching pending pregnancy checks for user: $userId');
      
      final snapshot = await _firestore
          .collection('ai_records')
          .where('userId', isEqualTo: userId)
          .where('result', isEqualTo: AIResult.pending.name)
          .orderBy('aiDate', descending: true)
          .get();

      final aiRecords = snapshot.docs
          .map((doc) => AIRecord.fromFirestore(doc))
          .where((ai) => ai.isPregnancyCheckDue)
          .toList();

      debugPrint('✅ BreedingService: Retrieved ${aiRecords.length} pending pregnancy checks');
      return aiRecords;
    } catch (e) {
      debugPrint('❌ BreedingService: Error fetching pending pregnancy checks: $e');
      throw Exception('Failed to fetch pending pregnancy checks: $e');
    }
  }

  Stream<List<PregnancyRecord>> watchActivePregnancies(String userId) {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    debugPrint('🔄 BreedingService: Starting real-time watch for active pregnancies');
    
    return _firestore
        .collection('pregnancy_records')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: PregnancyStatus.ongoing.name)
        .orderBy('expectedCalvingDate')
        .snapshots()
        .map((snapshot) {
          final pregnancies = snapshot.docs
              .map((doc) => PregnancyRecord.fromFirestore(doc))
              .toList();
          debugPrint('🔄 BreedingService: Real-time update - ${pregnancies.length} active pregnancies');
          return pregnancies;
        });
  }

  Future<void> _createHeatCycleAlert(HeatCycleRecord cycle, String userId) async {
    try {
      // Create alert for next expected heat cycle (18-24 days, average 21)
      final nextHeatDate = cycle.detectedDate.add(const Duration(days: 21));
      final alertDate = nextHeatDate.subtract(const Duration(days: 2)); // Alert 2 days before

      if (alertDate.isAfter(DateTime.now())) {
        await _firestore.collection('farm_alerts').add({
          'animalId': cycle.animalId,
          'title': 'Expected Heat Cycle',
          'description': 'Next heat cycle expected around ${_formatDate(nextHeatDate)}',
          'type': 'breeding',
          'priority': 'medium',
          'dueDate': Timestamp.fromDate(nextHeatDate),
          'isCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': userId,
        });
      }
    } catch (e) {
      debugPrint('⚠️ BreedingService: Could not create heat cycle alert: $e');
    }
  }

  Future<void> _createPregnancyCheckAlert(AIRecord aiRecord, String userId) async {
    try {
      // Create alert for pregnancy check (typically 30-60 days after AI)
      final checkDate = aiRecord.aiDate.add(const Duration(days: 35));
      
      await _firestore.collection('farm_alerts').add({
        'animalId': aiRecord.animalId,
        'title': 'Pregnancy Check Due',
        'description': 'Check pregnancy status after AI on ${_formatDate(aiRecord.aiDate)}',
        'type': 'breeding',
        'priority': 'high',
        'dueDate': Timestamp.fromDate(checkDate),
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
      });
    } catch (e) {
      debugPrint('⚠️ BreedingService: Could not create pregnancy check alert: $e');
    }
  }

  Future<void> _createCalvingAlert(PregnancyRecord pregnancy, String userId) async {
    try {
      // Create alert 1 week before expected calving
      final alertDate = pregnancy.expectedCalvingDate.subtract(const Duration(days: 7));
      
      if (alertDate.isAfter(DateTime.now())) {
        await _firestore.collection('farm_alerts').add({
          'animalId': pregnancy.animalId,
          'title': 'Calving Expected Soon',
          'description': 'Expected calving date: ${_formatDate(pregnancy.expectedCalvingDate)}',
          'type': 'breeding',
          'priority': 'high',
          'dueDate': Timestamp.fromDate(pregnancy.expectedCalvingDate),
          'isCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': userId,
        });
      }
    } catch (e) {
      debugPrint('⚠️ BreedingService: Could not create calving alert: $e');
    }
  }

  Future<void> _createPregnancyFromAI(String aiRecordId) async {
    try {
      // Get AI record details
      final aiDoc = await _firestore.collection('ai_records').doc(aiRecordId).get();
      if (!aiDoc.exists) return;

      final aiData = aiDoc.data()!;
      final conceptionDate = (aiData['aiDate'] as Timestamp).toDate();
      
      // Calculate expected calving date (280 days for cattle)
      final expectedCalvingDate = conceptionDate.add(const Duration(days: 280));

      final pregnancy = PregnancyRecord(
        id: '',
        animalId: aiData['animalId'],
        conceptionDate: conceptionDate,
        expectedCalvingDate: expectedCalvingDate,
        sireId: aiData['bullId'],
        status: PregnancyStatus.ongoing,
        checks: [],
        veterinarian: aiData['technician'],
        notes: 'Auto-created from successful AI',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final pregnancyData = pregnancy.toFirestore();
      pregnancyData['userId'] = aiData['userId'];
      pregnancyData['aiRecordId'] = aiRecordId;

      await _firestore.collection('pregnancy_records').add(pregnancyData);
    } catch (e) {
      debugPrint('⚠️ BreedingService: Could not create pregnancy from AI: $e');
    }
  }

  double _calculateAverageCalvingInterval(List<CalvingRecord> calvings) {
    if (calvings.length < 2) return 0.0;

    double totalDays = 0;
    int intervals = 0;

    for (int i = 0; i < calvings.length - 1; i++) {
      final current = calvings[i];
      final next = calvings[i + 1];
      
      if (current.motherId == next.motherId) {
        totalDays += current.calvingDate.difference(next.calvingDate).inDays.abs();
        intervals++;
      }
    }

    return intervals > 0 ? totalDays / intervals : 0.0;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<List<String>> getBullBreeds() async {
    return [
      'Holstein Friesian',
      'Jersey',
      'Angus',
      'Brahman',
      'Charolais',
      'Hereford',
      'Limousin',
      'Simmental',
      'Gir',
      'Sahiwal',
      'Red Sindhi',
      'Tharparkar',
      'Crossbred',
      'Other',
    ];
  }

  Future<List<String>> getCommonSymptoms() async {
    return [
      'Restlessness',
      'Vocalization',
      'Mounting others',
      'Standing to be mounted',
      'Clear vaginal discharge',
      'Reduced appetite',
      'Swollen vulva',
      'Frequent urination',
      'Increased movement',
      'Nervousness',
    ];
  }

  Future<List<String>> getTechnicians() async {
    return [
      'Dr. Ram Sharma',
      'Dr. Krishna Patel',
      'Mr. Suresh Kumar',
      'Dr. Mahesh Yadav',
      'Mr. Rajesh Singh',
      'Other',
    ];
  }

  Future<void> abortPregnancy(String pregnancyId, String reason) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      await _firestore
          .collection('pregnancy_records')
          .doc(pregnancyId)
          .update({
            'status': PregnancyStatus.aborted.name,
            'notes': reason,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to abort pregnancy: $e');
    }
  }

  Future<void> reportPregnancyComplications(String pregnancyId, String complications) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      await _firestore
          .collection('pregnancy_records')
          .doc(pregnancyId)
          .update({
            'status': PregnancyStatus.complications.name,
            'notes': complications,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to report pregnancy complications: $e');
    }
  }
}