import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/animal_model.dart';
import '../../../core/utils/firebase_availability.dart';

class AnimalService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AnimalModel>> getUserAnimals(String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🐄 AnimalService: Fetching animals for user: $userId');
      
      final snapshot = await _firestore
          .collection('animals')
          .where('ownerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final animals = snapshot.docs
          .map((doc) => AnimalModel.fromFirestore(doc))
          .toList();

      debugPrint('✅ AnimalService: Retrieved ${animals.length} animals');
      return animals;
    } catch (e) {
      debugPrint('❌ AnimalService: Error fetching animals: $e');
      throw Exception('Failed to fetch animals: $e');
    }
  }

  Future<AnimalModel?> getAnimalById(String animalId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🐄 AnimalService: Fetching animal: $animalId');
      
      final doc = await _firestore
          .collection('animals')
          .doc(animalId)
          .get();

      if (doc.exists) {
        final animal = AnimalModel.fromFirestore(doc);
        debugPrint('✅ AnimalService: Animal found: ${animal.name}');
        return animal;
      }

      debugPrint('⚠️ AnimalService: Animal not found: $animalId');
      return null;
    } catch (e) {
      debugPrint('❌ AnimalService: Error fetching animal: $e');
      throw Exception('Failed to fetch animal: $e');
    }
  }

  Future<AnimalModel?> getAnimalByQR(String qrCode, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('📱 AnimalService: Searching by QR code: $qrCode');
      
      final snapshot = await _firestore
          .collection('animals')
          .where('qrCode', isEqualTo: qrCode)
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final animal = AnimalModel.fromFirestore(snapshot.docs.first);
        debugPrint('✅ AnimalService: Animal found by QR: ${animal.name}');
        return animal;
      }

      debugPrint('⚠️ AnimalService: No animal found with QR: $qrCode');
      return null;
    } catch (e) {
      debugPrint('❌ AnimalService: Error searching by QR: $e');
      throw Exception('Failed to find animal by QR code: $e');
    }
  }

  Future<AnimalModel> createAnimal(AnimalModel animal) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🐄 AnimalService: Creating animal: ${animal.name}');

      // Check if tag ID is unique for this user
      final existingWithTag = await _checkTagIdUnique(animal.tagId, animal.ownerId);
      if (existingWithTag) {
        throw Exception('Tag ID ${animal.tagId} already exists for another animal');
      }

      // Check if QR code is unique for this user
      final existingWithQR = await _checkQRCodeUnique(animal.qrCode, animal.ownerId);
      if (existingWithQR) {
        throw Exception('QR code already exists for another animal');
      }

      final docRef = await _firestore
          .collection('animals')
          .add(animal.toFirestore());

      final createdAnimal = animal.copyWith();
      
      // Update the model with the generated document ID
      final updatedAnimal = AnimalModel(
        id: docRef.id,
        name: createdAnimal.name,
        type: createdAnimal.type,
        tagId: createdAnimal.tagId,
        dateOfBirth: createdAnimal.dateOfBirth,
        gender: createdAnimal.gender,
        dam: createdAnimal.dam,
        sire: createdAnimal.sire,
        origin: createdAnimal.origin,
        purchaseDate: createdAnimal.purchaseDate,
        purchasePrice: createdAnimal.purchasePrice,
        breed: createdAnimal.breed,
        specialMarks: createdAnimal.specialMarks,
        customTags: createdAnimal.customTags,
        vaccinations: createdAnimal.vaccinations,
        notes: createdAnimal.notes,
        photoUrl: createdAnimal.photoUrl,
        qrCode: createdAnimal.qrCode,
        ownerId: createdAnimal.ownerId,
        createdAt: createdAnimal.createdAt,
        updatedAt: createdAnimal.updatedAt,
        status: createdAnimal.status,
      );

      debugPrint('✅ AnimalService: Animal created with ID: ${docRef.id}');
      notifyListeners();
      return updatedAnimal;
    } catch (e) {
      debugPrint('❌ AnimalService: Error creating animal: $e');
      throw Exception('Failed to create animal: $e');
    }
  }

  Future<AnimalModel> updateAnimal(AnimalModel animal) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🐄 AnimalService: Updating animal: ${animal.id}');

      // Update the updatedAt timestamp
      final updatedAnimal = animal.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('animals')
          .doc(animal.id)
          .update(updatedAnimal.toFirestore());

      debugPrint('✅ AnimalService: Animal updated successfully');
      notifyListeners();
      return updatedAnimal;
    } catch (e) {
      debugPrint('❌ AnimalService: Error updating animal: $e');
      throw Exception('Failed to update animal: $e');
    }
  }

  Future<void> deleteAnimal(String animalId, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🐄 AnimalService: Deleting animal: $animalId');

      // Verify ownership before deletion
      final animal = await getAnimalById(animalId);
      if (animal == null) {
        throw Exception('Animal not found');
      }

      if (animal.ownerId != userId) {
        throw Exception('Not authorized to delete this animal');
      }

      // Delete related records in batch
      final batch = _firestore.batch();

      // Delete the animal document
      batch.delete(_firestore.collection('animals').doc(animalId));

      // Delete related milk production records
      final milkRecords = await _firestore
          .collection('milk_production')
          .where('animalId', isEqualTo: animalId)
          .get();
      
      for (final doc in milkRecords.docs) {
        batch.delete(doc.reference);
      }

      // Delete related health records
      final healthRecords = await _firestore
          .collection('health_records')
          .where('animalId', isEqualTo: animalId)
          .get();
      
      for (final doc in healthRecords.docs) {
        batch.delete(doc.reference);
      }

      // Delete related breeding records
      final breedingRecords = await _firestore
          .collection('breeding_records')
          .where('animalId', isEqualTo: animalId)
          .get();
      
      for (final doc in breedingRecords.docs) {
        batch.delete(doc.reference);
      }

      // Delete related financial records
      final financialRecords = await _firestore
          .collection('financial_records')
          .where('animalId', isEqualTo: animalId)
          .get();
      
      for (final doc in financialRecords.docs) {
        batch.delete(doc.reference);
      }

      // Commit all deletions
      await batch.commit();

      debugPrint('✅ AnimalService: Animal and related records deleted successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ AnimalService: Error deleting animal: $e');
      throw Exception('Failed to delete animal: $e');
    }
  }

  Future<void> updateAnimalStatus(String animalId, AnimalStatus status, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🐄 AnimalService: Updating status for animal: $animalId to ${status.displayName}');

      // Verify ownership
      final animal = await getAnimalById(animalId);
      if (animal == null || animal.ownerId != userId) {
        throw Exception('Animal not found or not authorized');
      }

      await _firestore
          .collection('animals')
          .doc(animalId)
          .update({
            'status': status.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      debugPrint('✅ AnimalService: Animal status updated successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ AnimalService: Error updating animal status: $e');
      throw Exception('Failed to update animal status: $e');
    }
  }

  Future<List<AnimalModel>> getAnimalsByType(String userId, String type) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🐄 AnimalService: Fetching $type animals for user: $userId');
      
      final snapshot = await _firestore
          .collection('animals')
          .where('ownerId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .orderBy('name')
          .get();

      final animals = snapshot.docs
          .map((doc) => AnimalModel.fromFirestore(doc))
          .toList();

      debugPrint('✅ AnimalService: Retrieved ${animals.length} $type animals');
      return animals;
    } catch (e) {
      debugPrint('❌ AnimalService: Error fetching animals by type: $e');
      throw Exception('Failed to fetch animals by type: $e');
    }
  }

  Future<List<AnimalModel>> getAnimalsByStatus(String userId, AnimalStatus status) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🐄 AnimalService: Fetching ${status.displayName} animals for user: $userId');
      
      final snapshot = await _firestore
          .collection('animals')
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: status.name)
          .orderBy('updatedAt', descending: true)
          .get();

      final animals = snapshot.docs
          .map((doc) => AnimalModel.fromFirestore(doc))
          .toList();

      debugPrint('✅ AnimalService: Retrieved ${animals.length} ${status.displayName} animals');
      return animals;
    } catch (e) {
      debugPrint('❌ AnimalService: Error fetching animals by status: $e');
      throw Exception('Failed to fetch animals by status: $e');
    }
  }

  Stream<List<AnimalModel>> watchUserAnimals(String userId) {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    debugPrint('🔄 AnimalService: Starting real-time watch for user animals: $userId');
    
    return _firestore
        .collection('animals')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final animals = snapshot.docs
              .map((doc) => AnimalModel.fromFirestore(doc))
              .toList();
          debugPrint('🔄 AnimalService: Real-time update - ${animals.length} animals');
          return animals;
        });
  }

  Future<Map<String, int>> getAnimalStats(String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('📊 AnimalService: Calculating stats for user: $userId');
      
      final animals = await getUserAnimals(userId);
      
      final stats = <String, int>{
        'total': animals.length,
        'healthy': animals.where((a) => a.status == AnimalStatus.healthy).length,
        'sick': animals.where((a) => a.status == AnimalStatus.sick).length,
        'pregnant': animals.where((a) => a.status == AnimalStatus.pregnant).length,
        'monitoring': animals.where((a) => a.status == AnimalStatus.monitoring).length,
        'urgent': animals.where((a) => a.status == AnimalStatus.urgent).length,
      };

      // Add type-based stats
      for (final animal in animals) {
        final typeKey = animal.type.toLowerCase();
        stats[typeKey] = (stats[typeKey] ?? 0) + 1;
      }

      debugPrint('✅ AnimalService: Stats calculated: $stats');
      return stats;
    } catch (e) {
      debugPrint('❌ AnimalService: Error calculating stats: $e');
      throw Exception('Failed to calculate animal statistics: $e');
    }
  }

  Future<List<FarmAlert>> getActiveAlerts(String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🚨 AnimalService: Fetching active alerts for user: $userId');
      
      // Get user's animals first
      final animals = await getUserAnimals(userId);
      final animalIds = animals.map((a) => a.id).toList();

      if (animalIds.isEmpty) {
        return [];
      }

      final snapshot = await _firestore
          .collection('farm_alerts')
          .where('animalId', whereIn: animalIds)
          .where('isCompleted', isEqualTo: false)
          .where('dueDate', isGreaterThan: Timestamp.now())
          .orderBy('dueDate')
          .orderBy('priority', descending: true)
          .get();

      final alerts = snapshot.docs
          .map((doc) => FarmAlert.fromFirestore(doc))
          .toList();

      debugPrint('✅ AnimalService: Retrieved ${alerts.length} active alerts');
      return alerts;
    } catch (e) {
      debugPrint('❌ AnimalService: Error fetching alerts: $e');
      throw Exception('Failed to fetch farm alerts: $e');
    }
  }

  Future<FarmAlert> createAlert(FarmAlert alert) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🚨 AnimalService: Creating alert: ${alert.title}');

      final docRef = await _firestore
          .collection('farm_alerts')
          .add(alert.toFirestore());

      // Return alert with generated ID
      final createdAlert = FarmAlert(
        id: docRef.id,
        animalId: alert.animalId,
        title: alert.title,
        description: alert.description,
        type: alert.type,
        priority: alert.priority,
        dueDate: alert.dueDate,
        isCompleted: alert.isCompleted,
        createdAt: alert.createdAt,
      );

      debugPrint('✅ AnimalService: Alert created with ID: ${docRef.id}');
      notifyListeners();
      return createdAlert;
    } catch (e) {
      debugPrint('❌ AnimalService: Error creating alert: $e');
      throw Exception('Failed to create alert: $e');
    }
  }

  Future<void> completeAlert(String alertId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🚨 AnimalService: Completing alert: $alertId');

      await _firestore
          .collection('farm_alerts')
          .doc(alertId)
          .update({
            'isCompleted': true,
            'completedAt': FieldValue.serverTimestamp(),
          });

      debugPrint('✅ AnimalService: Alert completed successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ AnimalService: Error completing alert: $e');
      throw Exception('Failed to complete alert: $e');
    }
  }

  Future<List<MilkProductionRecord>> getMilkRecords(String animalId, {int? limitDays}) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🥛 AnimalService: Fetching milk records for animal: $animalId');
      
      Query query = _firestore
          .collection('milk_production')
          .where('animalId', isEqualTo: animalId)
          .orderBy('date', descending: true);

      if (limitDays != null) {
        final cutoffDate = DateTime.now().subtract(Duration(days: limitDays));
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffDate));
      }

      final snapshot = await query.limit(100).get();

      final records = snapshot.docs
          .map((doc) => MilkProductionRecord.fromFirestore(doc))
          .toList();

      debugPrint('✅ AnimalService: Retrieved ${records.length} milk records');
      return records;
    } catch (e) {
      debugPrint('❌ AnimalService: Error fetching milk records: $e');
      throw Exception('Failed to fetch milk production records: $e');
    }
  }

  Future<MilkProductionRecord> logMilkProduction(MilkProductionRecord record) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🥛 AnimalService: Logging milk production for animal: ${record.animalId}');

      // Check if record already exists for this date
      final existingSnapshot = await _firestore
          .collection('milk_production')
          .where('animalId', isEqualTo: record.animalId)
          .where('date', isEqualTo: Timestamp.fromDate(record.date))
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        // Update existing record
        final docId = existingSnapshot.docs.first.id;
        await _firestore
            .collection('milk_production')
            .doc(docId)
            .update(record.toFirestore());

        final updatedRecord = MilkProductionRecord(
          id: docId,
          animalId: record.animalId,
          date: record.date,
          morningMilk: record.morningMilk,
          eveningMilk: record.eveningMilk,
          remarks: record.remarks,
          createdAt: record.createdAt,
        );

        debugPrint('✅ AnimalService: Milk record updated');
        notifyListeners();
        return updatedRecord;
      } else {
        // Create new record
        final docRef = await _firestore
            .collection('milk_production')
            .add(record.toFirestore());

        final createdRecord = MilkProductionRecord(
          id: docRef.id,
          animalId: record.animalId,
          date: record.date,
          morningMilk: record.morningMilk,
          eveningMilk: record.eveningMilk,
          remarks: record.remarks,
          createdAt: record.createdAt,
        );

        debugPrint('✅ AnimalService: Milk record created with ID: ${docRef.id}');
        notifyListeners();
        return createdRecord;
      }
    } catch (e) {
      debugPrint('❌ AnimalService: Error logging milk production: $e');
      throw Exception('Failed to log milk production: $e');
    }
  }

  Future<Map<String, double>> getMilkProductionStats(String animalId, {int? days}) async {
    try {
      debugPrint('📊 AnimalService: Calculating milk stats for animal: $animalId');
      
      final records = await getMilkRecords(animalId, limitDays: days);
      
      if (records.isEmpty) {
        return {
          'totalMilk': 0.0,
          'averageDaily': 0.0,
          'averageMorning': 0.0,
          'averageEvening': 0.0,
          'recordCount': 0.0,
        };
      }

      final totalMilk = records.fold<double>(0.0, (sum, record) => sum + record.totalMilk);
      final totalMorning = records.fold<double>(0.0, (sum, record) => sum + record.morningMilk);
      final totalEvening = records.fold<double>(0.0, (sum, record) => sum + record.eveningMilk);
      
      final stats = {
        'totalMilk': totalMilk,
        'averageDaily': totalMilk / records.length,
        'averageMorning': totalMorning / records.length,
        'averageEvening': totalEvening / records.length,
        'recordCount': records.length.toDouble(),
      };

      debugPrint('✅ AnimalService: Milk stats calculated: $stats');
      return stats;
    } catch (e) {
      debugPrint('❌ AnimalService: Error calculating milk stats: $e');
      throw Exception('Failed to calculate milk production statistics: $e');
    }
  }

  Future<bool> _checkTagIdUnique(String tagId, String ownerId) async {
    try {
      final snapshot = await _firestore
          .collection('animals')
          .where('ownerId', isEqualTo: ownerId)
          .where('tagId', isEqualTo: tagId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ AnimalService: Error checking tag ID uniqueness: $e');
      return false;
    }
  }

  Future<bool> _checkQRCodeUnique(String qrCode, String ownerId) async {
    try {
      final snapshot = await _firestore
          .collection('animals')
          .where('ownerId', isEqualTo: ownerId)
          .where('qrCode', isEqualTo: qrCode)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ AnimalService: Error checking QR code uniqueness: $e');
      return false;
    }
  }

  Future<List<AnimalModel>> searchAnimals(String userId, String searchTerm) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🔍 AnimalService: Searching animals for: $searchTerm');
      
      final animals = await getUserAnimals(userId);
      
      final filteredAnimals = animals.where((animal) {
        final searchLower = searchTerm.toLowerCase();
        return animal.name.toLowerCase().contains(searchLower) ||
               animal.tagId.toLowerCase().contains(searchLower) ||
               animal.breed.toLowerCase().contains(searchLower) ||
               animal.type.toLowerCase().contains(searchLower);
      }).toList();

      debugPrint('✅ AnimalService: Search found ${filteredAnimals.length} animals');
      return filteredAnimals;
    } catch (e) {
      debugPrint('❌ AnimalService: Error searching animals: $e');
      throw Exception('Failed to search animals: $e');
    }
  }

  Future<void> addVaccination(String animalId, VaccinationRecord vaccination, String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('💉 AnimalService: Adding vaccination for animal: $animalId');

      // Verify ownership
      final animal = await getAnimalById(animalId);
      if (animal == null || animal.ownerId != userId) {
        throw Exception('Animal not found or not authorized');
      }

      // Add vaccination to the animal's vaccination list
      final updatedVaccinations = [...animal.vaccinations, vaccination];

      await _firestore
          .collection('animals')
          .doc(animalId)
          .update({
            'vaccinations': updatedVaccinations.map((v) => v.toMap()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      debugPrint('✅ AnimalService: Vaccination added successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ AnimalService: Error adding vaccination: $e');
      throw Exception('Failed to add vaccination: $e');
    }
  }

  String generateQRCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'VET$random';
  }

  Future<bool> isTagIdAvailable(String tagId, String ownerId) async {
    try {
      final exists = await _checkTagIdUnique(tagId, ownerId);
      return !exists;
    } catch (e) {
      debugPrint('❌ AnimalService: Error checking tag availability: $e');
      return false;
    }
  }

  Future<List<String>> getSuggestedBreeds(String animalType) async {
    final breedSuggestions = <String, List<String>>{
      'cow': [
        'Holstein Friesian',
        'Jersey',
        'Gir',
        'Sahiwal',
        'Red Sindhi',
        'Tharparkar',
        'Crossbred',
        'Indigenous',
      ],
      'buffalo': [
        'Murrah',
        'Nili-Ravi',
        'Surti',
        'Jaffarabadi',
        'Bhadawari',
        'Mehsana',
        'Nagpuri',
        'Pandharpuri',
      ],
      'goat': [
        'Jamunapari',
        'Boer',
        'Sirohi',
        'Barbari',
        'Osmanabadi',
        'Malabari',
        'Beetal',
        'Black Bengal',
      ],
      'sheep': [
        'Dorper',
        'Suffolk',
        'Merino',
        'Corriedale',
        'Deccani',
        'Madras Red',
        'Rampur Bushair',
        'Marwari',
      ],
      'dog': [
        'German Shepherd',
        'Labrador',
        'Golden Retriever',
        'Indian Pariah',
        'Rottweiler',
        'Doberman',
        'Mixed Breed',
        'Unknown',
      ],
    };

    return breedSuggestions[animalType.toLowerCase()] ?? ['Unknown'];
  }
}